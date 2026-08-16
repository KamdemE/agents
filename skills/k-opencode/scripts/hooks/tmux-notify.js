// tmux-notify.js — notify the OpenCode agent when a tmux pane returns to its
// shell prompt (a command it launched finished).
//
// Problem solved: the agent wants to fire several long commands (sudo, builds,
// tests) into persistent tmux panes WITHOUT tracking/waiting/polling, and be
// notified + brought back to work when each pane finishes and returns to the
// prompt. Panes PERSIST (nothing is killed or detached).
//
// Mechanism:
//   tmux does the tracking. `monitor-silence` (k-tmux/assets/tmux.conf) fires
//   the GLOBAL `alert-silence` hook when a window has no output for the
//   silence period — a persistent pane back at the prompt is silent. The hook
//   invokes `tmux-pane-done.sh #{session_name} #{window_index} #{window_name}
//   #{pane_id}`, which appends one JSON line per event to a log. This plugin
//   polls that log (recursive setTimeout, see startWatcher) and, on each line,
//   queues a notification and delivers it to the agent.
//
// Delivery (two complementary paths, same pattern as stop-enforcer.js + the
// non-interrupting queue from oh-my-opencode):
//   1. `event` / session.idle  -> `client.session.prompt()` relaunches the
//      agent with the pending notification(s) as a synthetic user message.
//   2. `chat.message`          -> if a notification is still pending when the
//      next user message arrives, it is prepended to that message (safe point,
//      never interrupts a running task mid-stream).
//
// The active session id is tracked from session events so `session.prompt` has
// a valid target even without an explicit `sessionID` in scope.
//
// Requires the `client` (OpenCode server client) and a tmux server.

import * as fs from "node:fs";
import { currentAgent } from "./libs/agent-scope.js";

const TARGET_AGENTS = ["Colab", "Agent"];

const NOTIFY_LOG = process.env.TMUX_NOTIFY_LOG || "/tmp/tmux-pane-done.log";
const DEBUG_LOG = "/tmp/tmux-notify-debug.log";

// ---- helpers ---------------------------------------------------------------

function debug(message) {
  if (process.env.TMUX_NOTIFY_DEBUG === "1") {
    try {
      fs.appendFileSync(DEBUG_LOG, `[${new Date().toISOString()}] ${message}\n`);
    } catch {}
  }
}

// Build the notification text injected into the agent conversation.
// ev: parsed JSON line from the log — { event:"silence", session, window, pane, ts }.
function notificationFor(ev) {
  const where =
    (ev.session && ev.session !== "unknown" ? ev.session + ":" : "") +
    (ev.window && ev.window !== "unknown" ? ev.window + "." : "") +
    (ev.pane || "");
  return (
    "<tmux-notify> tmux pane " +
    (where || ev.pane || "?") +
    " has returned to its prompt (command finished). " +
    "Read the pane output (capture-pane / list-panes) and continue the current " +
    "task with this new result. " +
    "</tmux-notify>"
  );
}

// ---- plugin ----------------------------------------------------------------

export default async function ({ client }) {
  // pending: notifications waiting for a delivery point.
  let pending = [];
  // activeSessionID: last session we saw active (from events / chat.message).
  let activeSessionID = null;

  // Deliver all queued notifications into a session via session.prompt.
  async function flushToSession(sessionId) {
    if (!sessionId || pending.length === 0) return;
    const batch = pending;
    pending = [];
    const text = batch.join("\n\n");
    debug(`flushToSession(${sessionId}) len=${batch.length}`);
    try {
      // Resolve the current agent so the injected prompt is routed to the
      // right agent (same as stop-enforcer.js: `body.agent` is required —
      // without it opencode may not know which agent should process it).
      let agent;
      try {
        const response = await client.session.messages({ path: { id: sessionId } });
        const messages = Array.isArray(response) ? response : response.data || [];
        agent = currentAgent(messages);
      } catch {}
      // Scope to TARGET_AGENTS. This hook uses `event`+`chat.message` (no
      // `messages` in input), so the `currentAgentIs` helper cannot gate at
      // the hook level — the check is done on the agent resolved from the
      // target session's messages instead (same pattern as make-check-guard.js
      // for tool-level hooks that lack messages).
      if (
        agent &&
        !TARGET_AGENTS.includes("*") &&
        !TARGET_AGENTS.some((t) => t.toLowerCase() === agent.toLowerCase())
      ) {
        return;
      }
      await client.session.prompt({
        path: { id: sessionId },
        body: {
          agent: agent || undefined,
          parts: [{ type: "text", text, synthetic: true }],
        },
      });
    } catch (error) {
      // Re-queue on failure so nothing is lost; a later idle/chat will retry.
      pending = batch.concat(pending);
      fs.appendFileSync(
        "/tmp/tmux-notify-error.log",
        `${error && error.stack ? error.stack : error}\n`,
      );
    }
  }

  // Background watcher: poll the pane-done log for new JSON lines.
  //
  // Deliberately NOT a `tail` child process (a spawned `tail -F` keeps the
  // opencode process alive — its readable stdout stream stays referenced even
  // with child.unref(), hanging `opencode run` on exit). It is also NOT a
  // plain `setInterval().unref()`: an interval re-references itself on every
  // fire, so once it starts polling it keeps the process alive forever.
  // The correct pattern is a RECURSIVE `setTimeout` that calls `.unref()`
  // again on each re-arm — the timer stays unreferenced across fires, so the
  // opencode process exits cleanly while pending lines are still delivered.
  function startWatcher() {
    // lastOffset tracks how much of the log we've already consumed so lines
    // appended before this plugin loaded are ignored (`tail -n 0` semantics).
    let lastOffset = 0;
    try {
      lastOffset = fs.statSync(NOTIFY_LOG).size;
    } catch {}
    let stopped = false;
    let timer = null;

    function poll() {
      if (stopped) return;
      debug(`poll tick`);
      let size = 0;
      try {
        size = fs.statSync(NOTIFY_LOG).size;
      } catch {
        timer = setTimeout(poll, 400);
        timer.unref();
        return;
      }
      if (size < lastOffset) {
        // Log was truncated/recreated (external `rm`); restart from 0.
        lastOffset = 0;
      }
      if (size !== lastOffset) {
        let data = "";
        try {
          const buf = Buffer.alloc(size - lastOffset);
          const fd = fs.openSync(NOTIFY_LOG, "r");
          fs.readSync(fd, buf, 0, buf.length, lastOffset);
          fs.closeSync(fd);
          data = buf.toString("utf8");
        } catch {
          data = "";
        }
        lastOffset = size;
        for (const line of data.split("\n")) {
          const trimmed = line.trim();
          if (!trimmed) continue;
          try {
            const ev = JSON.parse(trimmed);
            if (ev.event === "silence" && ev.pane) {
              const note = notificationFor(ev);
              pending.push(note);
              debug(`queued silence pane=${ev.pane} window=${ev.window} session=${ev.session}`);
              // If we already know an active session, flush immediately; the
              // session.prompt call itself is safe when the session is idle.
              if (activeSessionID) flushToSession(activeSessionID);
            }
          } catch {
            debug(`bad line: ${trimmed}`);
          }
        }
      }
      // Re-arm and stay unreferenced (does not keep the process alive).
      timer = setTimeout(poll, 400);
      timer.unref();
    }

    timer = setTimeout(poll, 400);
    timer.unref();
    return {
      stop() {
        stopped = true;
        if (timer) clearTimeout(timer);
      },
    };
  }

  // Make sure the log file exists so the watcher has something to stat/read.
  try {
    fs.closeSync(fs.openSync(NOTIFY_LOG, "a+"));
  } catch {}

  const watcher = startWatcher();

  return {
    event: async ({ event }) => {
      // Track the active session from lifecycle events so we have a target for
      // session.prompt even when no explicit sessionID is in scope.
      const sessionID = event.properties?.sessionID;
      if (event.type === "session.created" && sessionID) {
        activeSessionID = sessionID;
        debug(`activeSessionID=${sessionID} (created)`);
      }
      // On idle, flush pending notifications by relaunching the agent.
      if (event.type === "session.idle" && pending.length > 0) {
        await flushToSession(sessionID || activeSessionID);
      }
    },

    "chat.message": async (input, output) => {
      // Track the active session from the message context.
      if (input.sessionID) activeSessionID = input.sessionID;
      // Non-interrupting delivery point: prepend pending notifications to the
      // next user message instead of injecting mid-stream.
      if (pending.length > 0 && output.parts && output.parts.length > 0) {
        const batch = pending;
        pending = [];
        const note = batch.join("\n\n");
        // Prepend to the first text part (keeps the agent's own message intact).
        const firstText = output.parts.find((part) => part.type === "text");
        if (firstText) {
          firstText.text = `${note}\n\n---\n\n${firstText.text}`;
        } else {
          output.parts.unshift({
            type: "text",
            text: note,
            synthetic: true,
          });
        }
        debug(`chat.message injected ${batch.length} notification(s)`);
      }
    },

    dispose: async () => {
      // Clean up the watcher when the plugin is disabled/reloaded.
      try {
        watcher.stop();
      } catch {}
    },
  };
}

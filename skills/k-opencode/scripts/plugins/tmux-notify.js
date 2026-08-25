// tmux-notify.js — notify the OpenCode agent when a tmux pane returns to its
// shell prompt (a command it launched finished).
//
// Problem solved: the agent wants to fire several long commands (sudo, builds,
// tests) into persistent tmux panes WITHOUT tracking/waiting/polling, and be
// notified + brought back to work when each pane finishes and returns to the
// prompt. Panes PERSIST (nothing is killed or detached).
//
// Mechanism:
//   The shell (via zsh `precmd` / bash `PROMPT_COMMAND` in `.kshrc`) writes
//   a JSON line with `{"event":"prompt","pane":"$TMUX_PANE","ts":"..."}` to
//   a log. This plugin polls that log (recursive setTimeout, see startWatcher)
//   and, on each line, queues a notification and delivers it to the agent.
//
// Delivery (three complementary paths, same pattern as stop-enforcer.js + the
// non-interrupting queue from oh-my-opencode):
//   1. `event` / session.idle  -> `client.session.prompt()` relaunches the
//      agent with the pending notification(s) as a synthetic user message.
//   2. `chat.message`          -> if a notification is still pending when the
//      next user message arrives, it is prepended to that message (safe point,
//      never interrupts a running task mid-stream).
//   3. `tool.execute.after`    -> a PROACTIVE reminder is appended directly to
//      the result of the `send-keys` tool call itself (no round-trip), the
//      moment the send-keys command actually finished. Fires for EVERY
//      stateful send-keys, whether or not the agent added TMUX_TIMEOUT/
//      TMUX_LINES (defaults still arm it). This is the CURRENT anti-"manual
//      capture-pane" mechanism (KπX, 2026-08-16) — a REACTIVE `throw`-based
//      block used to exist here but was REMOVED per explicit directive: never
//      intercept `capture-pane`, the agent may legitimately need it if this
//      very plugin malfunctions (log not written, watcher stuck, etc.).
//
// Session isolation (fixed 2026-08-16, real bug found): `pending` is a
// `Map<sessionID, string[]>`, NEVER a flat/global queue. A notification armed
// by session A is delivered ONLY to session A — `chat.message`/`session.idle`
// only ever drain the bucket matching their OWN `sessionID`. The old flat
// array could leak session A's notification into session B's next message if
// the immediate flush failed/was delayed — this is now impossible.
//
// Requires the `client` (OpenCode server client) and a tmux server.

import * as fs from "node:fs";
import { execSync } from "node:child_process";
import { currentAgent } from "./libs/agent-scope.js";

const TARGET_AGENTS = ["Colab", "Agent", "Build"];

const NOTIFY_LOG = process.env.TMUX_NOTIFY_LOG || "/tmp/tmux-pane-done.log";
const DEBUG_LOG = "/tmp/tmux-notify-debug.log";

// registry: Map<paneId, { agent, sessionID, timeoutTimer, timeoutSecs, maxLines, cmd, armedAt }>
const registry = new Map();

// ---- helpers ---------------------------------------------------------------

function debug(message) {
  if (process.env.TMUX_NOTIFY_DEBUG === "1") {
    try {
      fs.appendFileSync(DEBUG_LOG, `[${new Date().toISOString()}] ${message}\n`);
    } catch {}
  }
}

// Build the notification text injected into the agent conversation.
// The line-count in the label is the ACTUAL number of lines being shown
// (never a vague "some lines" — it reflects `TMUX_LINES`/`TMUX_MAX_LINES`,
// capped by however many lines the pane actually had).
function notificationFor(paneId, lines, isTimeout, timeoutSecs) {
  const status = isTimeout
    ? `is still running after ${timeoutSecs} seconds.`
    : `has returned to its prompt.`;
  const lineCount = lines === "" ? 0 : lines.split("\n").length;
  return (
    `<tmux-notify>\n` +
    `tmux pane ${paneId} ${status}\n` +
    `Last ${lineCount} output line${lineCount === 1 ? "" : "s"}:\n` +
    `===\n` +
    `${lines}\n` +
    `===\n` +
    `Continue your task directly with this result.\n` +
    `</tmux-notify>`
  );
}

async function resolveAgent(client, sessionID) {
  try {
    const response = await client.session.messages({ path: { id: sessionID } });
    const messages = Array.isArray(response) ? response : response.data || [];
    return currentAgent(messages);
  } catch {
    return null;
  }
}

// ---- plugin ----------------------------------------------------------------

export default async function ({ client }) {
  // pending: notifications waiting for a delivery point, keyed by the OWNING
  // session id. NEVER a flat/global queue (real bug found 2026-08-16 — see
  // header comment): a notification armed by session A must never leak into
  // session B's conversation via `chat.message`/`session.idle`.
  const UNSCOPED = "__unscoped__"; // rare fallback bucket: armed without a resolvable sessionID.
  const pending = new Map(); // sessionID -> string[]

  function pushPending(sessionId, note) {
    const key = sessionId || UNSCOPED;
    const list = pending.get(key) || [];
    list.push(note);
    pending.set(key, list);
  }

  function takePending(sessionId) {
    const key = sessionId || UNSCOPED;
    const batch = pending.get(key) || [];
    pending.delete(key);
    return batch;
  }

  function hasPending(sessionId) {
    const key = sessionId || UNSCOPED;
    return (pending.get(key) || []).length > 0;
  }

  // Deliver all queued notifications OWNED BY `sessionId` into that session
  // via session.prompt. Also drains the rare `UNSCOPED` bucket as a
  // last-resort fallback — this NEVER mixes in another session's notes.
  async function flushToSession(sessionId) {
    if (!sessionId) return;
    // No-op when nothing is queued (owned or unscoped) — avoids a pointless
    // `session.messages` fetch below.
    if (
      !hasPending(sessionId) &&
      !(sessionId !== UNSCOPED && hasPending(UNSCOPED))
    ) {
      return;
    }
    // Resolve the current agent and gate BEFORE draining anything.
    // The old order (drain first, gate second) PERMANENTLY DESTROYED queued
    // notifications whenever the resolved agent was outside TARGET_AGENTS
    // (real case 2026-08-25 on blglaptop139: session running as `build`
    // while TARGET_AGENTS was ["Colab","Agent"] — every tmux notification
    // was silently eaten). A rejected gate now leaves everything queued for
    // a later delivery point (session.idle / chat.message retry naturally).
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
      debug(`flushToSession(${sessionId}) gated out agent=${agent}`);
      return;
    }
    const own = takePending(sessionId);
    const unscoped = sessionId !== UNSCOPED ? takePending(UNSCOPED) : [];
    const batch = own.concat(unscoped);
    if (batch.length === 0) return;
    const text = batch.join("\n\n");
    debug(`flushToSession(${sessionId}) len=${batch.length} agent=${agent}`);
    try {
      await client.session.prompt({
        path: { id: sessionId },
        body: {
          agent: agent || undefined,
          parts: [{ type: "text", text, synthetic: true }],
        },
      });
    } catch (error) {
      // Re-queue on failure so nothing is lost; a later idle/chat will retry.
      // Re-queued under the SAME sessionId — never merged into another
      // session's bucket.
      for (const note of batch) pushPending(sessionId, note);
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
            if (ev.event === "prompt" && ev.pane) {
              const entry = registry.get(ev.pane);
              if (entry) {
                if (entry.timeoutTimer) {
                  clearTimeout(entry.timeoutTimer);
                }
                registry.delete(ev.pane);

                let output = "";
                try {
                  output = execSync(`tmux capture-pane -p -t ${ev.pane}`, { timeout: 3000, encoding: "utf8" });
                } catch (e) {
                  output = `(failed to capture pane: ${e.message})`;
                }
                const sliced = output.split("\n").slice(-entry.maxLines).join("\n");
                const note = notificationFor(ev.pane, sliced, false);

                // Push under the OWNING session id (never a global queue —
                // see header comment on session isolation) and flush right
                // to that same session, never to "whichever is active".
                pushPending(entry.sessionID, note);
                debug(`queued prompt pane=${ev.pane} session=${entry.sessionID}`);
                flushToSession(entry.sessionID);
              }
            }
          } catch (e) {
            debug(`bad line or error: ${trimmed} - ${e.message}`);
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

  // Resolve a tmux target (`%12`, `session:win.pane`, `session:win`, ...) to a
  // stable pane id (`%N`). Shared by the send-keys armer and the
  // `tool.execute.after` reminder below — never duplicate this resolution logic.
  function resolvePaneId(target) {
    if (target.startsWith("%")) return target;
    try {
      return execSync(`tmux display-message -p -t '${target}' '#{pane_id}'`, { timeout: 2000, encoding: "utf8" }).trim();
    } catch (e) {
      debug(`failed to resolve target ${target}: ${e.message}`);
      return null;
    }
  }

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return input;
      // `output.args.command` matches the proven pattern used by
      // make-check-guard.js and the plugin API type (`tool.execute.before`
      // exposes args on `output`, not `input`); `input.input` kept as a
      // fallback in case a specific opencode build also surfaces it there.
      const cmd = output?.args?.command || input.input || "";

      // NOTE (KπX, 2026-08-16): `capture-pane` is intentionally NEVER
      // intercepted or blocked here. A REACTIVE `throw`-based guard used to
      // live in this exact spot, but was explicitly REMOVED: the agent may
      // legitimately need a manual `capture-pane` if THIS plugin itself
      // malfunctions (log not written, watcher stuck, registry desync,
      // etc.) — blocking its only diagnostic fallback in that failure mode
      // would be worse than the anti-pattern it tried to prevent. The reflex
      // is now enforced PROACTIVELY instead: a reminder is appended to the
      // `send-keys` tool call's own result (see `tool.execute.after` below),
      // not by rejecting a later `capture-pane` call.

      const sendKeysRegex = /tmux\s+send-keys\s+(?:-l\s+|-p\s+)?-t\s+([%$@\w.:-]+)/;

      const match = sendKeysRegex.exec(cmd);
      if (match) {
        const target = match[1];
        const timeoutMatch = /TMUX_TIMEOUT=(\d+)/.exec(cmd);
        const linesMatch = /TMUX_LINES=(\d+)|TMUX_MAX_LINES=(\d+)/.exec(cmd);

        // Defaults apply whether or not the agent added the env vars — EVERY
        // stateful send-keys gets armed (and reminded), not just opt-ins.
        const timeout = timeoutMatch ? parseInt(timeoutMatch[1], 10) : 300;
        const maxLines = linesMatch ? parseInt(linesMatch[1] || linesMatch[2], 10) : 20;

        const paneId = resolvePaneId(target);

        if (paneId) {
          // BLOCK a send-keys into an already-busy pane (KπX, 2026-08-16:
          // "on demande d'utiliser un autre pane vide si présent, ou en
          // créer un si tous occupés" — never send-keys into an occupied
          // pane). Before this check, a second arm() on the SAME pane
          // silently overwrote the first registry entry ("last-arm-wins") —
          // a real gap found the same day: the first session would be
          // silently dropped with zero trace, even in debug logs, because
          // the pane's `precmd` prompt event would only ever match the
          // NEWEST entry. Same `throw`-to-block pattern as
          // `make-check-guard.js` (the only other hook in this kernel that
          // blocks a tool call outright).
          const existing = registry.get(paneId);
          if (existing) {
            const elapsedSecs = Math.round((Date.now() - existing.armedAt) / 1000);
            throw new Error(
              `BLOCKED: pane ${paneId} is already busy — a command armed ` +
                `${elapsedSecs}s ago (TMUX_TIMEOUT=${existing.timeoutSecs}s) has not ` +
                `yet returned to its prompt. NEVER send-keys into an occupied pane — ` +
                `use a different EMPTY pane if one exists (check with 'tmux list-panes -a'), ` +
                `or create a new pane/window if all are occupied.`,
            );
          }

          // Layer 2 (KπX, 2026-08-16): layer 1 above only catches panes WE
          // armed. A pane busy for any OTHER reason (KπX typing directly in
          // it, an agent bypassing our interception, a leftover foreground
          // process) is invisible to the registry check alone. tmux exposes
          // the pane's foreground process natively — pure metadata, no
          // `capture-pane` / content read needed — so query it and block if
          // it's not a known idle shell.
          let currentCmd = "";
          try {
            currentCmd = execSync(`tmux display-message -p -t ${paneId} '#{pane_current_command}'`, {
              timeout: 3000,
              encoding: "utf8",
            }).trim();
          } catch {
            currentCmd = ""; // pane gone / tmux error — fail open, let arming proceed
          }
          const KNOWN_IDLE_SHELLS = ["zsh", "bash", "sh", "fish"];
          if (currentCmd && !KNOWN_IDLE_SHELLS.includes(currentCmd)) {
            throw new Error(
              `BLOCKED: pane ${paneId} is busy with an untracked process: '${currentCmd}' ` +
                `(not one of ${KNOWN_IDLE_SHELLS.join("/")}). NEVER send-keys into an occupied ` +
                `pane — use a different EMPTY pane if one exists (check with 'tmux list-panes -a'), ` +
                `or create a new pane/window if all are occupied.`,
            );
          }

          debug(`arming pane=${paneId} timeout=${timeout} maxLines=${maxLines}`);
          const agent = await resolveAgent(client, input.sessionID);

          const timeoutTimer = setTimeout(async () => {
            debug(`timeout expired for pane ${paneId}`);
            const entry = registry.get(paneId);
            if (!entry) return;
            entry.timeoutTimer = null; // clear timer ref

            let out = "";
            try {
              out = execSync(`tmux capture-pane -p -t ${paneId}`, { timeout: 3000, encoding: "utf8" });
            } catch (e) {
              out = `(failed to capture pane: ${e.message})`;
            }
            const sliced = out.split("\n").slice(-entry.maxLines).join("\n");
            const note = notificationFor(paneId, sliced, true, entry.timeoutSecs);

            // Push + flush under the OWNING session id (never a global
            // queue) — see header comment on session isolation.
            pushPending(entry.sessionID, note);
            flushToSession(entry.sessionID);
          }, timeout * 1000);
          timeoutTimer.unref();

          registry.set(paneId, {
            agent,
            sessionID: input.sessionID,
            timeoutTimer,
            timeoutSecs: timeout,
            maxLines,
            cmd,
            armedAt: Date.now(),
          });
        }
      }
      return input;
    },

    // Proactive reminder — appended DIRECTLY to the `send-keys` tool call's
    // OWN result (no round-trip through the conversation), the moment right
    // after the real command has actually run. Fires for EVERY stateful
    // send-keys, whether or not the agent added TMUX_TIMEOUT/TMUX_LINES
    // (defaults still armed it in `tool.execute.before` above). This is the
    // CURRENT anti-"manual capture-pane" mechanism (KπX, 2026-08-16),
    // replacing the earlier reactive `throw`-on-capture-pane guard (removed —
    // see the note in `tool.execute.before`).
    "tool.execute.after": async (input, output) => {
      if (input.tool !== "bash") return;
      const cmd = input.args?.command || "";
      const sendKeysRegex = /tmux\s+send-keys\s+(?:-l\s+|-p\s+)?-t\s+([%$@\w.:-]+)/;
      const match = sendKeysRegex.exec(cmd);
      if (!match) return;
      const paneId = resolvePaneId(match[1]);
      if (!paneId) return;
      const entry = registry.get(paneId);
      if (!entry) return; // arming failed (or already resolved) — nothing to remind about
      const reminder =
        `<tmux-armed>\n` +
        `Pane ${paneId} armed: TMUX_TIMEOUT=${entry.timeoutSecs}s, TMUX_LINES=${entry.maxLines}.\n` +
        `Do NOT run tmux capture-pane on this pane. Do NOT run sleep, wait, or any\n` +
        `timeout/polling to wait for this pane. Either CONTINUE other parallel work you\n` +
        `already have, OR stop your turn now — in BOTH cases you will be automatically\n` +
        `notified (<tmux-notify>) when the command finishes.\n` +
        `</tmux-armed>`;
      debug(`reminder appended pane=${paneId}`);
      if (typeof output.output === "string" && output.output.length > 0) {
        output.output = `${output.output}\n\n${reminder}`;
      } else {
        output.output = reminder;
      }
    },

    event: async ({ event }) => {
      // On idle, flush ONLY this session's own pending notifications — never
      // "whichever session was last active" (see session isolation note).
      const sessionID = event.properties?.sessionID;
      if (event.type === "session.idle" && sessionID && hasPending(sessionID)) {
        await flushToSession(sessionID);
      }
    },

    "chat.message": async (input, output) => {
      // Non-interrupting delivery point: prepend pending notifications to the
      // next user message instead of injecting mid-stream. ONLY drains the
      // bucket OWNED by `input.sessionID` (see session isolation note in the
      // header comment) — never another session's notifications.
      if (!input.sessionID) return;
      const batch = takePending(input.sessionID);
      if (batch.length > 0 && output.parts && output.parts.length > 0) {
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
        debug(`chat.message injected ${batch.length} notification(s) for session=${input.sessionID}`);
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

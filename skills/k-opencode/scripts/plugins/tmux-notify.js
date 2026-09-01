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
// Timeout self-adjustment (KπX, 2026-08-29): a watchdog used to re-fire on
// the SAME `timeoutSecs` forever with an identical, vague message ("Continue
// your task directly with this result") — no guidance, no way for the agent
// to say "this is a heavy process, check less often" without literally
// sending keystrokes INTO the pane (risky: would pollute the stdin of
// whatever is actually running there, e.g. a live `make -j8`). Fixed with a
// pure META command that NEVER touches the pane: `: TMUX_ADJUST <pane> <secs>`
// (`:` is the bash no-op builtin — always succeeds, zero side effects, never
// "command not found"). `tool.execute.before` recognizes this exact anchored
// pattern on the AGENT'S OWN bash command (not a send-keys call), updates the
// matching lease's `timeoutSecs` in-memory, clears+re-arms its watchdog timer
// (countdown restarts from the new value), and resets `watchdogCount`.
// `tool.execute.after` appends a `<tmux-timeout-adjusted>` confirmation.
// Ownership-gated like send-keys: only the lease's OWNING session may adjust
// it. Watchdog messages also now carry an explicit check counter and
// escalating, actionable guidance (continue in parallel / adjust / abort)
// instead of one static sentence repeated forever — see `notificationFor()`.
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
import { SEND_KEYS_REGEX } from "./libs/tmux-patterns.js";

// "Live" added 2026-08-27 (found live while investigating the 6th root
// cause below): the agent renamed/split from "Colab" but this gate was
// never updated — every tmux notification to a "Live" session was silently
// dropped by the flushToSession gate (agent resolved, not in the list ->
// return without delivering). Same class of gap as the 2026-08-25
// "Build" miss documented below.
const TARGET_AGENTS = ["Colab", "Agent", "Build", "Live"];

const NOTIFY_LOG = process.env.TMUX_NOTIFY_LOG || "/tmp/tmux-pane-done.log";
const DEBUG_LOG = "/tmp/tmux-notify-debug.log";

// registry: Map<paneId, { agent, sessionID, timeoutTimer, timeoutSecs, maxLines,
//                         cmd, armedAtNs }>
// A lease owns WATCHING, not the pane's input: its owning OpenCode session may
// continue an interactive program, while every other session remains blocked.
const registry = new Map();

// ---- helpers ---------------------------------------------------------------

function debug(message) {
  if (process.env.TMUX_NOTIFY_DEBUG === "1") {
    try {
      fs.appendFileSync(
        DEBUG_LOG,
        `[${new Date().toISOString()}] ${message}\n`,
      );
    } catch {}
  }
}

// Build the notification text injected into the agent conversation.
// The line-count in the label is the ACTUAL number of lines being shown
// (never a vague "some lines" — it reflects `TMUX_LINES`/`TMUX_MAX_LINES`,
// capped by however many lines the pane actually had).
//
// `watchdogCount` (KπX, 2026-08-29 — REWRITTEN same day, 2nd pass: KπX caught
// that even the escalating version above still left an agent unable to
// decide, cycling on vague "Understood, I will follow these instructions"
// acknowledgements instead of acting): every watchdog message MUST make the
// agent's exact situation and full decision tree explicit, EVERY time, never
// assuming context from an earlier `<tmux-armed>` message is still "in mind"
// (a watchdog can fire long after, in a very different part of the
// conversation). Structure enforced below: (1) an unambiguous STATUS line —
// "what you launched has NOT returned to its shell yet" — (2) an explicit
// warning that this WILL repeat forever unless the agent acts or the pane
// naturally returns, (3) a lettered A/B/C/D decision tree covering every
// real case (interactive program / normal-but-slow / just-wait / stuck or
// forgotten), each with the EXACT command to run, never a vague suggestion.
function notificationFor(paneId, lines, kind, timeoutSecs, watchdogCount) {
  const isWatchdog = kind === "watchdog";
  const tag = isWatchdog ? "tmux-watchdog" : "tmux-notify";
  const lineCount = lines === "" ? 0 : lines.split("\n").length;
  const body =
    `Last ${lineCount} output line${lineCount === 1 ? "" : "s"}:\n` +
    `===\n${lines}\n===\n`;

  if (!isWatchdog) {
    return (
      `<${tag}>\n` +
      `tmux pane ${paneId}: the command you launched has FINISHED (shell prompt returned). Lease released.\n` +
      body +
      `Use this result directly and continue your task. Nothing else to do for this pane.\n` +
      `</${tag}>`
    );
  }

  const count = watchdogCount || 1;
  const heavy = count >= 3;
  const elapsed = count * timeoutSecs;
  const adjustCmd = `: TMUX_ADJUST ${paneId} <bigger_seconds>`;  // typed in YOUR shell (not the pane), colon : is mandatory (bash no-op builtin)
  const ctrlcCmd = `tmux send-keys -t ${paneId} C-c`;

  return (
    `<${tag}>\n` +
    `STATUS: the command you launched in pane ${paneId} has NOT returned to its shell yet ` +
    `(check #${count}, ~${elapsed}s elapsed since launch).\n` +
    body +
    `This is NOT a final result. You WILL keep receiving this notification in a loop, roughly every ` +
    `${timeoutSecs}s, until EITHER the pane returns to its shell on its own (final <tmux-notify>) OR you ` +
    `force it back yourself (option D below). Decide now, based on the output above:\n` +
    `  A. INTERACTIVE program you are actively driving (a TUI/prompt waiting for your input) ` +
    `-> send it more input via \`tmux send-keys\`, or if you are done with it, send \`${ctrlcCmd}\` to return to the shell.\n` +
    `  B. Still working NORMALLY, just slow (build/install/long test) and you expect it to take MUCH longer than ${timeoutSecs}s ` +
    `-> TYPE \`${adjustCmd}\` in YOUR OWN SHELL (not in the tmux pane!) — the colon : is mandatory (bash no-op builtin). Estimate the real duration so you stop being pinged this often.\n` +
    `  C. Still working normally and the current interval is fine, you just need to wait a bit more ` +
    `-> do NOTHING: CONTINUE other work in parallel or pause here, the next check arrives automatically.\n` +
    `  D. STUCK, crashed, erroring, or you FORGOT about / no longer need this pane ` +
    `-> send \`${ctrlcCmd}\` now to force it back to the shell — otherwise you will keep being woken up forever.\n` +
    (heavy
      ? `NOTE: this is check #${count} (~${elapsed}s total, not your first check) — this reads as a genuinely ` +
        `long-running process, not a hang. Seriously consider B (adjust) or D (abort) now instead of letting ` +
        `this repeat indefinitely.\n`
      : ``) +
    `Never sleep/poll this pane manually — one of A/B/C/D above is always the right move.\n` +
    `</${tag}>`
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
  const controlCalls = new Set(); // owner input sent while its lease remains active
  const adjustResults = new Map(); // callID -> {paneId, old, newTimeout, status} for the `: TMUX_ADJUST` no-op marker (2026-08-29)

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

  function paneCurrentCommand(paneId) {
    try {
      return execSync(
        `tmux display-message -p -t ${paneId} '#{pane_current_command}'`,
        { timeout: 3000, encoding: "utf8" },
      ).trim();
    } catch {
      return ""; // pane gone / tmux error: fail open
    }
  }

  function capturePane(paneId) {
    try {
      return execSync(`tmux capture-pane -p -t ${paneId}`, {
        timeout: 3000,
        encoding: "utf8",
      });
    } catch (error) {
      return `(failed to capture pane: ${error.message})`;
    }
  }

  function eventBelongsToLease(event, entry) {
    try {
      return BigInt(event.ts) >= entry.armedAtNs;
    } catch {
      // Older/malformed shell events remain usable; only a valid older event
      // is rejected. The normal prompt protocol always provides a nanosecond ts.
      return true;
    }
  }

  async function completeLease(paneId, entry) {
    if (registry.get(paneId) !== entry) return;
    if (entry.timeoutTimer) clearTimeout(entry.timeoutTimer);
    registry.delete(paneId);
    const output = capturePane(paneId);
    const sliced = output.split("\n").slice(-entry.maxLines).join("\n");
    pushPending(entry.sessionID, notificationFor(paneId, sliced, "complete"));
    debug(`completed pane=${paneId} session=${entry.sessionID}`);
    await flushToSession(entry.sessionID);
  }

  function armWatchdog(paneId, entry) {
    entry.timeoutTimer = setTimeout(async () => {
      debug(`timeout expired for pane ${paneId}`);
      if (registry.get(paneId) !== entry) return;

      entry.watchdogCount = (entry.watchdogCount || 0) + 1;
      const out = capturePane(paneId);
      const sliced = out.split("\n").slice(-entry.maxLines).join("\n");
      const note = notificationFor(
        paneId,
        sliced,
        "watchdog",
        entry.timeoutSecs,
        entry.watchdogCount,
      );

      // Push + flush under the OWNING session id (never a global queue) — see
      // header comment on session isolation. Keep the lease alive and re-arm:
      // only return to the shell stops the cycle.
      pushPending(entry.sessionID, note);
      await flushToSession(entry.sessionID);
      if (registry.get(paneId) === entry) armWatchdog(paneId, entry);
    }, entry.timeoutSecs * 1000);
    entry.timeoutTimer.unref();
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
              if (entry && eventBelongsToLease(ev, entry)) {
                void completeLease(ev.pane, entry);
              } else if (entry) {
                debug(`ignored stale prompt pane=${ev.pane}`);
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
      return execSync(`tmux display-message -p -t '${target}' '#{pane_id}'`, {
        timeout: 2000,
        encoding: "utf8",
      }).trim();
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

      // Timeout self-adjustment (KπX, 2026-08-29): `: TMUX_ADJUST <pane> <secs>`
      // is a pure META marker — `:` is the bash no-op builtin, it NEVER touches
      // the target pane (no send-keys involved at all). Anchored on the WHOLE
      // trimmed command so it can only ever be a deliberate, standalone call,
      // never an accidental substring match inside a larger script/grep.
      const adjustRegex = /^:\s+TMUX_ADJUST\s+([%$@\w.:-]+)\s+(\d+)\s*$/;
      const adjustMatch = adjustRegex.exec(cmd.trim());
      if (adjustMatch) {
        const adjTarget = adjustMatch[1];
        const newTimeout = parseInt(adjustMatch[2], 10);
        const adjPaneId = resolvePaneId(adjTarget);
        const adjEntry = adjPaneId ? registry.get(adjPaneId) : null;

        if (adjEntry && adjEntry.sessionID === input.sessionID) {
          const old = adjEntry.timeoutSecs;
          adjEntry.timeoutSecs = newTimeout;
          adjEntry.watchdogCount = 0; // urgency escalation restarts with the new interval
          if (adjEntry.timeoutTimer) clearTimeout(adjEntry.timeoutTimer);
          armWatchdog(adjPaneId, adjEntry);
          adjustResults.set(input.callID, {
            paneId: adjPaneId,
            old,
            newTimeout,
            status: "ok",
          });
          debug(
            `adjusted pane=${adjPaneId} ${old}s->${newTimeout}s session=${input.sessionID}`,
          );
        } else if (adjEntry) {
          adjustResults.set(input.callID, { paneId: adjPaneId, status: "denied" });
          debug(`adjust denied pane=${adjPaneId} (owned by another session)`);
        } else {
          adjustResults.set(input.callID, {
            paneId: adjPaneId || adjTarget,
            status: "noop",
          });
          debug(`adjust noop, no active lease on target=${adjTarget}`);
        }
        // Let `:` execute for real — inert, always succeeds, never blocking.
        return input;
      }

      // SEND_KEYS_REGEX (imported) — single source of truth shared with
      // `raw-exec-guard.js`, see `libs/tmux-patterns.js`.

      const match = SEND_KEYS_REGEX.exec(cmd);
      if (match) {
        const target = match[1];
        const timeoutMatch = /TMUX_TIMEOUT=(\d+)/.exec(cmd);
        const linesMatch = /TMUX_LINES=(\d+)|TMUX_MAX_LINES=(\d+)/.exec(cmd);

        // Defaults apply whether or not the agent added the env vars — EVERY
        // stateful send-keys gets armed (and reminded), not just opt-ins.
        const timeout = timeoutMatch ? parseInt(timeoutMatch[1], 10) : 30;
        const maxLines = linesMatch
          ? parseInt(linesMatch[1] || linesMatch[2], 10)
          : 50;

        const paneId = resolvePaneId(target);

        if (paneId) {
          const existing = registry.get(paneId);
          const currentCmd = paneCurrentCommand(paneId);
          if (existing) {
            // The lease owner may freely continue, correct, or cancel an
            // interactive process. Crucially this is CONTROL INPUT, not a new
            // arm: the original completion watch is never overwritten. Even
            // when tmux still reports a shell, it may simply not have started
            // the prior send-keys payload yet; only the timestamped prompt
            // event is authoritative for releasing a lease.
            if (existing.sessionID === input.sessionID) {
              controlCalls.add(input.callID);
              debug(`owner control pane=${paneId} session=${input.sessionID}`);
              return input;
            } else {
              const elapsedSecs = Math.round(
                (Date.now() - Number(existing.armedAtNs / 1000000n)) / 1000,
              );
              throw new Error(
                `BLOCKED: pane ${paneId} is leased by another OpenCode session ` +
                  `(${elapsedSecs}s active). Use a different EMPTY pane, or ask its owner ` +
                  `to release it by returning to the shell.`,
              );
            }
          }

          // Layer 2 (KπX, 2026-08-16): layer 1 above only catches panes WE
          // armed. A pane busy for any OTHER reason (KπX typing directly in
          // it, an agent bypassing our interception, a leftover foreground
          // process) is invisible to the registry check alone. tmux exposes
          // the pane's foreground process natively — pure metadata, no
          // `capture-pane` / content read needed — so query it and block if
          // it's not a known idle shell.
          const KNOWN_IDLE_SHELLS = ["zsh", "bash", "sh", "fish"];
          if (currentCmd && !KNOWN_IDLE_SHELLS.includes(currentCmd)) {
            throw new Error(
              `BLOCKED: pane ${paneId} is busy with an untracked process: '${currentCmd}' ` +
                `(not one of ${KNOWN_IDLE_SHELLS.join("/")}). NEVER send-keys into an occupied ` +
                `pane — use a different EMPTY pane if one exists (check with 'tmux list-panes -a'), ` +
                `or create a new pane/window if all are occupied.`,
            );
          }

          debug(
            `arming pane=${paneId} timeout=${timeout} maxLines=${maxLines}`,
          );
          const agent = await resolveAgent(client, input.sessionID);

          const entry = {
            agent,
            sessionID: input.sessionID,
            timeoutTimer: null,
            timeoutSecs: timeout,
            maxLines,
            cmd,
            armedAtNs: BigInt(Date.now()) * 1000000n,
            watchdogCount: 0,
          };
          registry.set(paneId, entry);
          armWatchdog(paneId, entry);
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

      // Confirmation for the `: TMUX_ADJUST <pane> <secs>` meta marker (see
      // `tool.execute.before`). Never touches `output.output` from a
      // send-keys path — this command never matches `SEND_KEYS_REGEX` below,
      // it is a plain no-op bash command, so it is handled first and returns.
      if (adjustResults.has(input.callID)) {
        const r = adjustResults.get(input.callID);
        adjustResults.delete(input.callID);
        const msg =
          r.status === "ok"
            ? `<tmux-timeout-adjusted>\n` +
              `Pane ${r.paneId}: timeout ${r.old}s -> ${r.newTimeout}s. Watchdog countdown restarted from ${r.newTimeout}s.\n` +
              `No input was sent to the pane — its running command is untouched.\n` +
              `</tmux-timeout-adjusted>`
            : r.status === "denied"
            ? `<tmux-timeout-adjusted>\n` +
              `Pane ${r.paneId} is leased by another session — you cannot adjust its timeout.\n` +
              `</tmux-timeout-adjusted>`
            : `<tmux-timeout-adjusted>\n` +
              `No active watch on pane ${r.paneId} — nothing to adjust (already completed, never armed, or wrong pane id).\n` +
              `</tmux-timeout-adjusted>`;
        output.output = output.output ? `${output.output}\n\n${msg}` : msg;
        debug(`adjust confirmation appended pane=${r.paneId} status=${r.status}`);
        return;
      }

      const cmd = input.args?.command || "";
      // SEND_KEYS_REGEX (imported) — single source of truth shared with
      // `raw-exec-guard.js`, see `libs/tmux-patterns.js`.
      const match = SEND_KEYS_REGEX.exec(cmd);
      if (!match) return;
      const paneId = resolvePaneId(match[1]);
      if (!paneId) return;
      if (controlCalls.delete(input.callID)) {
        const reminder =
          `<tmux-control>\n` +
          `Pane ${paneId} remains leased to this session — your input was just sent to it, and the ORIGINAL ` +
          `completion watch is UNCHANGED (not reset, not extended). It still has NOT returned to its shell.\n` +
          `Same rules as when it was armed: if it is an interactive program, keep driving it with more input as ` +
          `needed; if you are done with it (or it needs aborting), send \`tmux send-keys -t ${paneId} C-c\` to ` +
          `return it to the shell; otherwise just wait — the next <tmux-watchdog>/<tmux-notify> arrives ` +
          `automatically, no polling needed.\n` +
          `</tmux-control>`;
        output.output = output.output ? `${output.output}\n\n${reminder}` : reminder;
        return;
      }
      const entry = registry.get(paneId);
      if (!entry) return; // arming failed (or already resolved) — nothing to remind about
      const reminder =
        `<tmux-armed>\n` +
        `Pane ${paneId} armed: TMUX_TIMEOUT=${entry.timeoutSecs}s, TMUX_LINES=${entry.maxLines}.\n` +
        `STATUS: you just sent this command to the pane. It has NOT returned to its shell yet (still running) — ` +
        `this is expected, not an error.\n` +
        `What happens next, automatically, with ZERO polling from you:\n` +
        `  - Returns to shell within ${entry.timeoutSecs}s -> you get a definitive <tmux-notify> (finished, lease released, nothing more to do).\n` +
        `  - Does not -> you get a <tmux-watchdog> every ${entry.timeoutSecs}s with fresh output and an explicit A/B/C/D decision (continue / adjust / wait / abort), repeating until it finishes.\n` +
        `What you can do right now, your choice — none of these are wrong:\n` +
        `  - CONTINUE other work in parallel, or stop this turn here -> you will be re-invoked automatically either way, nothing is lost.\n` +
        `  - This is interactive (a TUI/prompt you are driving) -> keep sending it input via send-keys as needed.\n` +
        `  - You already expect this to take much longer than ${entry.timeoutSecs}s -> TYPE \`: TMUX_ADJUST ${paneId} <seconds>\` in YOUR OWN SHELL (not in the tmux pane!) — the colon : is mandatory (bash no-op builtin).\n` +
        `  - You change your mind and want to abort -> send \`tmux send-keys -t ${paneId} C-c\` to force it back to the shell.\n` +
        `If the final <tmux-notify> capture is empty, incomplete, or does not explain the result, immediately run \`tmux capture-pane -p -t ${paneId} -S -100\` and use that larger one-shot diagnostic capture. Never turn it into a polling loop.\n` +
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
        debug(
          `chat.message injected ${batch.length} notification(s) for session=${input.sessionID}`,
        );
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

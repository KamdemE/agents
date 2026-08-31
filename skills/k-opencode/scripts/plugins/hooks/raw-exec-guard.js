// raw-exec-guard.js — technically enforces two long-standing PROSE-ONLY rules
// (KπX, 2026-08-29, following the tmux-notify TMUX_ADJUST work in this same
// session): `rules/tool-discipline.md` → `## tmux sudo Gate` ("never run raw
// sudo in agent tool shells") and the 5th tmux-notify root cause fix
// ("self-backgrounding" — never manually `sleep`/`wait`/`timeout`-poll a
// command instead of routing it through tmux). Both were documented, NEVER
// technically blocked — an agent could always just run them directly.
//
// Mechanism: same pattern as `make-check-guard.js` — `tool.execute.before`
// is the ONLY reliable block point (mutating `output.args` does NOT
// propagate, upstream opencode issue #31680), so the enforcement is a
// `throw new Error(...)` that aborts the tool call before it runs.
//
// Scope decision (KπX, 2026-08-29): explicitly LIMITED to these two static,
// pre-execution checks. A 3rd idea (kill any raw command once it exceeds
// 30s and relaunch the agent) was proposed and explicitly REJECTED as
// out-of-scope for this pass — it is not achievable anyway with the current
// plugin API (no PID access, no reliable command rewriting), and KπX chose
// to keep this hook simple and verifiably correct rather than add a
// reactive mechanism that could only ever be an after-the-fact reminder.
//
// Duration threshold (KπX, 2026-08-30): `sleep` and `timeout` are only
// blocked when their duration exceeds POLL_THRESHOLD_SECS (20s). Short
// sleeps/timeouts (<20s) are allowed as quick inline polls. The `wait`
// bash builtin is ALWAYS blocked — it has no duration parameter and is
// inherently an indeterminate hang.
//
// False-positive guard (KπX, 2026-08-30): the `wait` pattern uses a
// negative lookbehind `(?<![a-zA-Z-])` so that flags like `--wait-for-cdp`
// or `--wait-for-something` are NOT blocked — only the bare `wait` bash
// builtin (preceded by space, quote, or start-of-string) triggers.
//
// Compliant path (never blocked): a command that is ALREADY a
// `tmux send-keys -t <target> ...` call. The quoted payload inside it
// (which may itself contain "sudo"/"sleep"/"wait"/"timeout") is delivered
// to the target pane and executed there — never by the agent's own shell —
// so it is explicitly exempt via `SEND_KEYS_REGEX` (shared with
// `tmux-notify.js`, see `libs/tmux-patterns.js`).
//
// NOTE — `TARGET_AGENTS` is intentionally ABSENT, same reasoning as
// `make-check-guard.js`: `tool.execute.before` does not receive `messages`,
// so agent-scoping is not possible here; this is a GLOBAL kernel rule that
// must apply to every agent.

import { SEND_KEYS_REGEX } from "../libs/tmux-patterns.js";

/** Only block sleep/timeout when duration exceeds this (seconds). */
const POLL_THRESHOLD_SECS = 20;

const SUDO_PATTERN = /\bsudo\b/;
const SLEEP_PATTERN = /\bsleep\s+([\d.]+)/;
/** Matches `wait` bash builtin only — NOT flags like `--wait-for-cdp`. */
const WAIT_PATTERN = /(?<![a-zA-Z-])\bwait\b/;
const TIMEOUT_PATTERN = /\btimeout\s+([\d.]+)/;

export default async function () {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return input;
      const cmd = output?.args?.command || input.input || "";
      if (!cmd.trim()) return input;

      // Compliant path: already routed through tmux — the quoted payload is
      // executed IN THE PANE, never by the agent's own shell. Nothing to
      // block here; `tmux-notify.js` already arms/handles it.
      if (SEND_KEYS_REGEX.test(cmd)) return input;

      if (SUDO_PATTERN.test(cmd)) {
        throw new Error(
          "🛑 tmux sudo Gate (rules/tool-discipline.md → `## tmux sudo Gate`): " +
            "raw `sudo` is never allowed directly in an agent shell.\n" +
            "Route it through a tmux pane instead (see k-tmux skill):\n" +
            "  TMUX_TIMEOUT=20 TMUX_LINES=15 tmux send-keys -t <session>:agents.2 'sudo ...' Enter\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // Sleep: extract duration, only block if > threshold
      const sleepMatch = cmd.match(SLEEP_PATTERN);
      if (sleepMatch) {
        const secs = parseFloat(sleepMatch[1]);
        if (secs > POLL_THRESHOLD_SECS) {
          throw new Error(
            "🛑 Manual polling is never allowed (rules/tool-discipline.md → " +
              "`## Tmux Stateful Command Execution`): `sleep` with duration " +
              `${secs}s exceeds the ${POLL_THRESHOLD_SECS}s threshold.\n` +
              "Launch your command in a tmux pane instead (see k-tmux skill) — " +
              "tmux-notify's <tmux-armed>/<tmux-watchdog>/<tmux-notify> will handle " +
              "waiting for you automatically, no polling needed:\n" +
              "  TMUX_TIMEOUT=30 TMUX_LINES=20 tmux send-keys -t <session>:agents.2 '<your command>' Enter\n" +
              `Blocked command: ${cmd}`,
          );
        }
      }

      // Wait (bash builtin): always blocked — inherently indeterminate, no
      // duration to extract. Pattern uses negative lookbehind to avoid
      // false positives on flags like `--wait-for-cdp`.
      if (WAIT_PATTERN.test(cmd)) {
        throw new Error(
          "🛑 Manual polling is never allowed (rules/tool-discipline.md → " +
            "`## Tmux Stateful Command Execution`): `wait` (bash builtin) is " +
            "prohibited — it is an indeterminate wait with no timeout.\n" +
            "Launch your command in a tmux pane instead (see k-tmux skill) — " +
            "tmux-notify's <tmux-armed>/<tmux-watchdog>/<tmux-notify> will handle " +
            "waiting for you automatically, no polling needed:\n" +
            "  TMUX_TIMEOUT=30 TMUX_LINES=20 tmux send-keys -t <session>:agents.2 '<your command>' Enter\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // Timeout: extract duration, only block if > threshold
      const timeoutMatch = cmd.match(TIMEOUT_PATTERN);
      if (timeoutMatch) {
        const secs = parseFloat(timeoutMatch[1]);
        if (secs > POLL_THRESHOLD_SECS) {
          throw new Error(
            "🛑 Manual polling is never allowed (rules/tool-discipline.md → " +
              "`## Tmux Stateful Command Execution`): `timeout` with duration " +
              `${secs}s exceeds the ${POLL_THRESHOLD_SECS}s threshold.\n` +
              "Launch your command in a tmux pane instead (see k-tmux skill) — " +
              "tmux-notify's <tmux-armed>/<tmux-watchdog>/<tmux-notify> will handle " +
              "waiting for you automatically, no polling needed:\n" +
              "  TMUX_TIMEOUT=30 TMUX_LINES=20 tmux send-keys -t <session>:agents.2 '<your command>' Enter\n" +
              `Blocked command: ${cmd}`,
          );
        }
      }

      return input;
    },
  };
}

/**
 * Shared regex: does a bash command string already look like a compliant
 * `tmux send-keys -t <target> ...` call?
 *
 * Single source of truth (KπX, 2026-08-29) — this exact pattern used to be
 * duplicated THREE times (twice inside `tmux-notify.js`'s own `.before`/
 * `.after`, and would have been a 3rd copy in `raw-exec-guard.js`). Any drift
 * between copies (e.g. supporting a new tmux target syntax) would silently
 * desync the two files' notion of "is this already routed through tmux" —
 * the exact class of bug already documented once in this kernel (2026-08-16
 * cross-hook field-name inconsistency, see k-opencode/references/insights.md).
 *
 * Used by:
 *   - `tmux-notify.js` — arms a pane lease only when a command matches this.
 *   - `raw-exec-guard.js` — SKIPS its sudo/sleep/wait/timeout block entirely
 *     when a command matches this (the quoted payload inside `send-keys` is
 *     delivered to the pane, never executed by the agent's own shell — it is
 *     the compliant path, not a bypass).
 */
export const SEND_KEYS_REGEX =
  /tmux\s+send-keys\s+(?:-l\s+|-p\s+)?-t\s+([%$@\w.:-]+)/;

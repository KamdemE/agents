#!/usr/bin/env bash
# tmux-pane-done.sh — relay an alert-silence event to the tmux-notify plugin.
#
# Invoked by a global tmux hook: `alert-silence`, which fires when a window
# produces no output for the `monitor-silence` period — i.e. a persistent pane
# has finished its command and RETURNED TO THE SHELL PROMPT. Persistent panes
# stay alive (nothing is killed/detached, no remain-on-exit). The pane_id and
# window/session context are resolvable because the pane still exists.
# This script appends a single JSON line to the notify log that the
# `tmux-notify.js` plugin polls.
#
# Usage (from a tmux hook, see k-tmux/assets/tmux.conf):
#   set-hook -g alert-silence 'run-shell "$HOME/.agents/skills/k-opencode/scripts/plugins/tmux/tmux-pane-done.sh #{session_name} #{window_index} #{window_name} #{pane_id}"'
#
# Args:
#   $1 — session name where the pane lives (e.g. "ubuntu").
#   $2 — window index (e.g. "2").
#   $3 — window name (e.g. "main").
#   $4 — pane id (e.g. "%8").
#
# Output: one JSON line appended to $TMUX_NOTIFY_LOG (default
#   /tmp/tmux-pane-done.log), e.g.:
#   {"event":"silence","session":"ubuntu","window":"main","pane":"%8","ts":"1734567890123456789"}

# The log path stays stable regardless of how run-shell invokes this script:
# $HOME is always set in the hook environment, and ${TMUX_NOTIFY_LOG:-...}
# falls back to a fixed /tmp path.
LOG="${TMUX_NOTIFY_LOG:-/tmp/tmux-pane-done.log}"

session="${1:-unknown}"
window_index="${2:-unknown}"
window_name="${3:-unknown}"
pane="${4:-unknown}"

# Build a single JSON line atomically. `run-shell` may fire several
# alert-silence events concurrently; a per-writer lock keeps lines from
# interleaving.
(
  flock 9
  printf '{"event":"silence","session":"%s","window":"%s","pane":"%s","ts":"%s"}\n' \
    "$session" "$window_name" "$pane" "$(date +%s%N)" >>"$LOG"
) 9>"$LOG.lock"

# Debug trace (off by default; set TMUX_PANE_DONE_DEBUG=1 to inspect ordering).
if [ "${TMUX_PANE_DONE_DEBUG:-0}" = "1" ]; then
  printf '[tmux-pane-done] silence %s:%s.%s -> %s\n' "$session" "$window_index" "$pane" "$LOG" >>"$LOG.debug"
fi

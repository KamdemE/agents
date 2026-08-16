#!/usr/bin/env bash
# tmux-pane-done.sh — relay a pane-died event to the tmux-notify plugin.
#
# Invoked by a global tmux hook: `pane-died`, which fires reliably ONLY as a
# GLOBAL hook and ONLY with `remain-on-exit on` (per-pane `pane-exited`/
# `pane-died` is broken upstream — tmux issues #2882 and #3736: the pane is
# destroyed before its own hook runs, so #{pane_id}/#{pane_dead_status}
# resolve to garbage). The pane must stay visible (remain-on-exit) for its
# context to be resolvable. This script appends a single JSON line to the
# notify log that the `tmux-notify.js` plugin polls.
#
# Usage (from a tmux hook, see k-tmux/assets/tmux.conf):
#   set-hook -g pane-died 'run-shell "$HOME/.agents/skills/k-opencode/scripts/hooks/tmux-pane-done.sh #{pane_id} #{pane_dead_status}"'
#
# Args:
#   $1 — pane id that exited (e.g. "%8").
#   $2 — exit status of the pane's process (`#{pane_dead_status}`).
#
# Output: one JSON line appended to $TMUX_NOTIFY_LOG (default
#   /tmp/tmux-pane-done.log), e.g.:
#   {"pane":"%8","exit":"0","ts":"1734567890123456789"}

# The log path stays stable regardless of how run-shell invokes this script:
# $HOME is always set in the hook environment, and ${TMUX_NOTIFY_LOG:-...}
# falls back to a fixed /tmp path.
LOG="${TMUX_NOTIFY_LOG:-/tmp/tmux-pane-done.log}"

pane="${1:-unknown}"
exit_status="${2:-unknown}"

# Build a single JSON line atomically. `run-shell` may fire several pane-died
# events concurrently; a per-writer lock keeps lines from interleaving.
(
  flock 9
  printf '{"pane":"%s","exit":"%s","ts":"%s"}\n' \
    "$pane" "$exit_status" "$(date +%s%N)" >>"$LOG"
) 9>"$LOG.lock"

# Debug trace (off by default; set TMUX_PANE_DONE_DEBUG=1 to inspect ordering).
if [ "${TMUX_PANE_DONE_DEBUG:-0}" = "1" ]; then
  printf '[tmux-pane-done] %s exit=%s -> %s\n' "$pane" "$exit_status" "$LOG" >>"$LOG.debug"
fi

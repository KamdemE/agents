#!/usr/bin/env bash
# ~/.agents/scripts/session-guard.sh
# Claude Code Stop hook — enforces daily update of ~/.agents/memory/
# Exit 2 = Claude Code displays the output and agent can act on it.

TODAY=$(date +%Y-%m-%d)
DAILYLOG="$HOME/.agents/memory/dailylog.md"
CONTEXT="$HOME/.agents/memory/context.md"

# Check if dailylog was updated today
if grep -q "| $TODAY" "$DAILYLOG" 2>/dev/null; then
  exit 0  # Already updated — silent
fi

printf "\n"
printf "┌─ SESSION GUARD ─────────────────────────────────────────────┐\n"
printf "│  ~/.agents/memory/dailylog.md not updated today (%s)  │\n" "$TODAY"
printf "│                                                              │\n"
printf "│  Before closing:                                             │\n"
printf "│  1. Update ~/.agents/memory/context.md (TODOs, projects)    │\n"
printf "│  2. Append entry to ~/.agents/memory/dailylog.md            │\n"
printf "│  3. git commit + push to all remotes                         │\n"
printf "└──────────────────────────────────────────────────────────────┘\n"
printf "\n"

exit 2

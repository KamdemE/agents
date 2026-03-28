#!/usr/bin/env bash
# ~/.agents/scripts/session-guard.sh
# Claude Code Stop hook — enforces daily update of k-context skill.
# Exit 2 = Claude Code displays the output and agent can act on it.

TODAY=$(date +%Y-%m-%d)
KCONTEXT="$HOME/.agents/skills/k-context/SKILL.md"

# Check if k-context Session Log was updated today
if grep -q "| $TODAY" "$KCONTEXT" 2>/dev/null; then
  exit 0  # Already updated — silent
fi

printf "\n"
printf "┌─ SESSION GUARD ──────────────────────────────────────────────┐\n"
printf "│  k-context Session Log not updated today (%s)        │\n" "$TODAY"
printf "│                                                               │\n"
printf "│  Before closing:                                              │\n"
printf "│  1. Update k-context: TODOs, Active Projects, Session Log    │\n"
printf "│  2. git commit + make push (~/.agents/)                       │\n"
printf "└───────────────────────────────────────────────────────────────┘\n"
printf "\n"

exit 2

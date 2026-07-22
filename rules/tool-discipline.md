# Tool Discipline

> Cross-cutting operational rules for ALL tool usage.

## tmux sudo Gate (MANDATORY)
- Never run raw `sudo` in agent tool shells. Use permanent `ubuntu` tmux session.
- Fixed pane: `ubuntu:0.2` = zsh (designated sudo/ops pane)
- Execution cycle:
  1. Confirm session: `tmux ls` (ubuntu MUST exist)
  2. Confirm pane: `tmux list-panes -t ubuntu:0` (pane .2 = zsh)
  3. Send: `tmux send-keys -t ubuntu:0.2 '<cmd>' Enter`
  4. Poll every 3–5s: `tmux capture-pane -t ubuntu:0.2 -p | tail -10`
  5. Shell prompt = done. Password prompt = keep polling (≥15s before chat handoff)
  6. Wait for completion — keep polling until shell prompt
  7. Never kill pane `ubuntu:0.2` (permanent)
- **Never** create temp windows/panes for sudo
- **Never** run `sudo` in agent tool shells
- **Never** stop polling before 15s for password

## Browser (Edge Agent)
- Edge in tmux `default`, window `browser` (CDP 9222, profile `~/.config/kpihx-edge-automation`)
- Run `edge-agent-status` before CDP attach

## File Operations
- Read before Edit — never shell redirection for file edits
- No `sed`/`printf`/`echo >` for file edits
- No real IPs, tokens, full legal names; use placeholders

## Shell Security
- API keys/TOKENS: `env | grep -E "API\|TOKEN" | cut -d= -f1` — NEVER output values

## Zero-Deletion Policy (MANDATORY)
- NEVER delete logs/historical entries from `k-context/SKILL.md` or any skill
- If a section reaches its limit → rotate to dedicated archive BEFORE compaction
- Archive rows are append-only forever — never modify archive lines

## Context Save Proposal Gate
Signal when new context should be saved, then WAIT for `approve`/`reject`/`adjust`.

## Troubleshooting
- Unknown error → load `k-context` (active TODOs) or `k-ubuntu` (workstation environment)
- New tool/skill detected → propose updating the corresponding `k-*` skill

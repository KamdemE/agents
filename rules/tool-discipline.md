# Tool Discipline — Operational Rules

> Cross-cutting rules for ALL tool usage. Loaded from `AGENTS.md` kernel.

## Shared tmux Collaboration (MANDATORY)

For `sudo`, SSH passphrase, or any interactive prompt — `sui` is **deprecated**. Use shared tmux gate:
1. Load `k-tmux` skill
2. `tmux ls` → reuse or create a short-named session/window
3. `tmux send-keys -t SESSION:WIN.PANE '<cmd>' Enter`
4. Poll `tmux capture-pane` ≥30s before any chat handoff
5. After ≥30s without validation: give full `tmux attach`, command, and what KπX must do
Never run raw `sudo` in agent tool shells.

## Browser (Edge Agent)

KπX keeps `edge-agent` in tmux session `default`, window `browser` (visible Edge, CDP 9222, profile `$HOME/.config/kpihx-edge-automation`).
- Run `edge-agent-status` before `browser-mcp-stdio` / `playwright-mcp-stdio` (CDP attach)
- Prefer this stack over `cursor-ide-browser` for logged-in portals and extension debugging
- Launcher: `$HOME/.agents/skills/k-browser/scripts/edge-agent.sh`

## File Operations

- **Read before Edit** — use proper file editing flows for existing files; never rely on shell redirection or ad hoc shell mutation
- **No shell file ops** — never `sed`/`printf`/`echo >` for file edits
- **No sensitive data** — no real IPs, tokens, full legal names; use placeholders

## Shell Security

- When checking for API keys or tokens, ALWAYS use `env | grep -E "API|TOKEN" | cut -d= -f1` to list ONLY the keys. NEVER output values.

## Zero-Deletion Policy (MANDATORY)

Agents MUST NEVER delete logs or historical entries from `k-context/SKILL.md` or any other skill. If a section reaches its limit, older entries MUST be rotated to a dedicated archive (e.g., `skills/k-context/references/log.md`) BEFORE the main file is compacted. Every removal from a primary log MUST be an addition to its archive. Archive rows are **append-only forever** — never modify lines already written in `references/log.md` or `references/issues.md`.

## Context Save Proposal Gate

Agents MUST proactively signal when new context should be saved, then WAIT for explicit user decision (`approve`, `reject`, or `adjust`) before writing.

## Troubleshooting

- Unknown error → load `k-workspace` first
- New tool/skill detected → propose updating/creating the corresponding `k-*` skill

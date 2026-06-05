# Tool Discipline — Operational Rules

> Cross-cutting rules for ALL tool usage. Loaded from `AGENTS.md` kernel.

## tmux sudo Gate (MANDATORY — exact protocol)

### Core rule

Never run raw `sudo` in agent tool shells. Always use the user's current tmux session, window 0 ("default").

### Execution cycle (exact, in order)

1. **Identify current session**
   - `tmux ls` → find the session marked `(attached)`
   - That is KπX's active session. Use it.

2. **Locate window 0** (the "default" window)
   - `tmux list-windows -t <SESSION>` → confirm window 0 exists
   - If missing: `tmux new-window -t <SESSION>:0 -n default` (rare)

3. **Send command**
   - `tmux send-keys -t <SESSION>:0 '<sudo cmd>' Enter`

4. **Poll loop** (repeat every 3-5s):
   - `tmux capture-pane -t <SESSION>:0 -p | tail -10`
   - **Shell prompt** (`$` or `#`) → command finished → done
   - **Password prompt** → keep polling, do not stop

5. **Password timeout**:
   - Poll for **≥15s** before any chat handoff about the password
   - If after ≥15s KπX has NOT entered the password → one chat message asking
   - If KπX enters the password within 15s → keep polling until command finishes

6. **Wait for completion**:
   - Even if the sudo command takes >15s, keep polling until shell prompt returns
   - Do not ask for handoff while the command is still running

7. **Cleanup**:
   - Window 0 is permanent — **do not kill it**
   - No temp cleanup needed

### Hard rules
- **Never** create temp windows/panes for sudo — use window 0
- **Never** run `sudo` in agent tool shells
- **Never** stop polling before 15s for password
- **Never** kill window 0 (it's permanent)

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

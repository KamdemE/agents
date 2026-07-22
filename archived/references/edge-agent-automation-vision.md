# Edge agent automation — open thread

Status: **SETUP DONE** — sign-in once in automation profile (2026-05-25)

## Goal

Visible Microsoft Edge session for human-in-the-loop agent work: KπX and observers see the real browser; agents drive via MCP/CDP. Minimize repeated logins (Gmail, Lebara, portals).

## Constraint (Chrome/Edge 136+)

Remote debugging cannot target the **Default** profile directory. Use a dedicated `user-data-dir`, log in once, keep cookies there.

## Concrete stack

| Piece | Choice |
|-------|--------|
| Browser | Edge headed, `--remote-debugging-port=9222` |
| Profile | `$HOME/.config/kpihx-edge-automation` |
| Launcher | `$HOME/.agents/skills/k-browser/scripts/edge-agent.sh` |
| MCP | `@agent-infra/mcp-server-browser` (attach) + `@playwright/mcp` |
| Fast IDE demos | `cursor-ide-browser` (isolated, not Default Edge) |

## TickTick

- Task `6a14914b8f08f2bcaa2a0dbf` — setup pilot (🏠 Persos / Administratif)

## Setup completed

- `.kshrc` → `edge-agent`, `edge-agent-status`
- `$HOME/.cursor/mcp.json` → `browser-mcp-stdio`, `playwright-mcp-stdio` (CDP :9222)
- Docs: `k-browser/references/edge-cdp-setup.md`, `Work/techskills/edge-agent-cdp-setup.md`

## Remaining (KπX once)

- Run `edge-agent` and sign in to required sites in the automation window
- Reload Cursor MCP servers after first config read

## Not in scope

- Cookie sync from Default profile (fragile, blocked by policy)
- systemd auto-start (optional later)

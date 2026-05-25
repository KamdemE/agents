# Edge CDP setup — operational reference

## Launch

```bash
edge-agent
edge-agent-status   # → OK when CDP ready
```

Script: `scripts/edge-agent.sh` · env: `KPIHX_EDGE_DATA`, `KPIHX_EDGE_DEBUG_PORT` (default 9222).

## MCP (Cursor)

Servers in `$HOME/.cursor/mcp.json` attach to `http://127.0.0.1:9222/json/version` when Edge is already running.

**Pre-flight:** `edge-agent-status` must pass before agent calls `browser-mcp-stdio` / `playwright-mcp-stdio`.

**After any session:** `SKILL.md` → **Leave no trace** + techskills cleanup section.

## Policy note

Do not point CDP at `microsoft-edge/Default` user-data. Use `kpihx-edge-automation` only.

## User doc

`$HOME/Work/techskills/edge-agent-cdp-setup.md`

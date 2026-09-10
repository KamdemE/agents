# k-uv — Purged Tools (Archive)

> **Purpose:** Tools that were installed via `uv tool install` and later **purged**. Kept for the historical record — never deleted (GRAVÉ). Purge date: 2026-08-14, per maintainer directive to keep only `*-proxy` (real CLIs) and remove agent/MCP runtimes.

## Purged 2026-08-14

| Tool | Version | Binaries | Purpose | Reason |
|------|---------|----------|---------|--------|
| `desk-mcp` | v0.2.1 | `desk-mcp` | Desktop environment MCP server | Purged — MCP (only `*-proxy` CLIs kept) |
| `k-mail-mcp` | v0.2.4 | `mail-admin`, `mail-mcp` | Mail MCP server (Zimbra) — -owned | Purged — use `mail-proxy` (real CLI) |
| `mail-mcp` | v0.2.0 | `mail-admin`, `mail-mcp` | Mail MCP server (older) | Purged — use `mail-proxy` (real CLI) |
| `mistral-vibe` | v2.21.0 | `vibe`, `vibe-acp` | VIBE agent runtime — Mistral model | Purged — agent CLI purge |
| `tick-mcp` | v0.2.0 | `tick-admin`, `tick-mcp` | TickTick MCP server | Purged — use `tick-proxy` (real CLI) |

> Related: `k-node/references/purged.md` (npm-global purges) · `k-code` (purged Zed/AGY references).

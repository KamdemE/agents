# k-cline Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- Cline CLI MCP settings are stored in `~/.cline/data/settings/cline_mcp_settings.json` (not in `~/.cline/mcp.json`).
- For manual remote MCP entries, explicitly set `"type": "streamableHttp"` to avoid legacy SSE fallback ambiguity.
- Browser automation MCPs in Cline should be stdio entries named `browser` and `playwright` using `browser-mcp-stdio` / `playwright-mcp-stdio` to stay aligned with KπX browser runtime.

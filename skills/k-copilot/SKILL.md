---
name: k-copilot
description: >
  GitHub Copilot CLI runtime — copilot-instructions.md kernel link, mcp-config.json format
  (JSON mcpServers), config.json settings (account KpihX, trusted_folders), skills integration.
  Load when configuring Copilot, managing MCPs, or understanding its runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
  scope: agent-runtime
  target-agent: copilot
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — GitHub Copilot CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Home:** `$HOME/.copilot/`
- **Global kernel:** `$HOME/.copilot/copilot-instructions.md` → `$HOME/.agents/AGENTS.md`
- **Runtime shortcut:** `$HOME/COPILOT.md` → this file
- **Skills path:** `$HOME/.copilot/skills/` → `$HOME/.agents/skills/` (symlink)
- **Config files:** `$HOME/.copilot/mcp-config.json` (MCPs) · `$HOME/.copilot/config.json` (settings)

## Source Of Truth

| File | Role |
|------|------|
| `$HOME/.copilot/mcp-config.json` | MCP server definitions |
| `$HOME/.copilot/config.json` | local Copilot settings |

## config.json (Settings)

```json
{
  "last_logged_in_user": { "host": "https://github.com", "login": "KpihX" },
  "trusted_folders": ["$HOME"],
  "banner": "never"
}
```

GitHub account: **KpihX**. `trusted_folders` = workspace automatically trusted for file context.

## MCP Config Format (Copilot — JSON)

```json
{
  "mcpServers": {
    "<name>": {
      "type": "stdio",
      "command": "zsh",
      "args": ["-l", "-c", "<server_command>"]
    }
  }
}
```

HTTP servers: use `"type": "http"`. Restart Copilot + verify via `/mcp` after any config edit.

Do not list installed MCPs here; read `$HOME/.copilot/mcp-config.json` directly.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v1.4.0 — tightened the skill around source-of-truth paths and removed the last wording that encouraged a live MCP inventory here |
| 2026-04-03 | [CLAUDE] | v1.3.0 — all ~ → $HOME; /home/kpihx → $HOME; removed dup Project Context (→AGENTS.md) |
| [SUMMARY] | — | v1.2.1 standardized name to `k-copilot`; v1.2.0 Runtime Context+config.json; v1.1.0 MCP format; v1.0.0 extracted from agents/ |

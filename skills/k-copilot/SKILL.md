---
name: k-copilot
description: >
  GitHub Copilot CLI runtime — copilot-instructions.md kernel link, mcp-config.json format
  (JSON mcpServers), config.json settings (account KpihX, trusted_folders), skills integration.
  Load when configuring Copilot, managing MCPs, or understanding its runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.5.1"
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
- **Session state:** `$HOME/.copilot/session-state/`
- **Command history:** `$HOME/.copilot/command-history-state.json`

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

QMD policy: do not configure QMD as a Copilot MCP. Use local CLI directly:
- `qmd status`, `qmd get`, `qmd embed` for admin/read paths
- `qmdr query/search/vsearch ...` for important searches needing freshness guarantees

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v1.5.1 — documented the CLI-only QMD policy for Copilot and removed the expectation that QMD should live in `mcp-config.json` |
| 2026-04-03 | [CODEX] | v1.5.0 — added the real Copilot session-history paths and kept the skill focused on runtime sources of truth instead of expanding procedural detail |
| 2026-04-03 | [CODEX] | v1.4.1 — removed the last hardcoded home-path wording from the changelog summary of the earlier normalization pass |
| [SUMMARY] | — | v1.5.0–v1.0.0: CLI-only QMD policy, Copilot session-history pointers, source-of-truth paths, normalized home-path references, removed duplicated project context, standardized name, runtime context, MCP format, and extraction from agents/ |

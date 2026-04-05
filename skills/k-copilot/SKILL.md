---
name: k-copilot
description: >
  GitHub Copilot CLI runtime — copilot-instructions.md kernel link, mcp-config.json format
  (JSON mcpServers), config.json settings (account KpihX, trusted_folders), skills integration.
  Load when configuring Copilot, managing MCPs, or understanding its runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.6.1"
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

## Copilot VS Code Hooks Wiring (Preview)

Copilot VS Code hooks are wired through:

- Wrapper scripts: `$HOME/.agents/hooks/copilot/`
- Hook file: `$HOME/.agents/hooks/copilot/hooks.json`
- VS Code setting: `chat.hookFilesLocations` includes `$HOME/.agents/hooks/copilot/hooks.json` (expand to an absolute path in JSON if required)

Implemented hook events:

- `SessionStart` → `session_start.py`
- `UserPromptSubmit` → `user_prompt_submit.py`
- `PreToolUse` → `pre_tool_use.py`
- `PostToolUse` → `post_tool_use.py`
- `Stop` → `stop.py`

Notes:

- Wrappers are adapted to VS Code hook event names and payload shape.
- `PreToolUse` normalizes VS Code tool aliases (for example `create_file`, `replace_string_in_file`) so core guards can reuse existing logic.
- `PostToolUse` runs header/footer completeness checks as advisory for replace-style edits.

QMD policy: do not configure QMD as a Copilot MCP. Use local CLI directly:
- `qmd status`, `qmd get`, `qmd embed` for admin/read paths
- `qmdr query/search/vsearch ...` for important searches needing freshness guarantees

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-05 | [CLAUDE] | v1.6.1 — `chat.hookFilesLocations` documented with `$HOME` path form per AGENTS.md (no bare `~` in `.agents/` docs) |
| 2026-04-05 | [COPILOT] | v1.6.0 — added Copilot VS Code hooks runtime wiring (`$HOME/.agents/hooks/copilot/`) and documented settings integration via `chat.hookFilesLocations` |
| [SUMMARY] | — | v1.5.1 CLI-only QMD policy; v1.5.0–v1.0.0: session-history pointers, source-of-truth paths, runtime context/MCP format, earlier consolidation |

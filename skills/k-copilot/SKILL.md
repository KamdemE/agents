---
name: agent-runtime-copilot
description: >
  GitHub Copilot CLI runtime — copilot-instructions.md kernel link, mcp-config.json format
  (JSON mcpServers), config.json settings (account KpihX, trusted_folders), skills integration.
  Load when configuring Copilot, managing MCPs, or understanding its runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: agent-runtime
  target-agent: copilot
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — GitHub Copilot CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Home:** `~/.copilot/`
- **Global kernel:** `~/.copilot/copilot-instructions.md` → `~/.agents/KERNEL.md`
- **Runtime shortcut:** `~/COPILOT.md` → this file
- **Skills path:** `~/.copilot/skills/` → `~/.agents/skills/` (symlink)
- **Config files:** `~/.copilot/mcp-config.json` (MCPs) · `~/.copilot/config.json` (settings)

## config.json (Settings)

```json
{
  "last_logged_in_user": { "host": "https://github.com", "login": "KpihX" },
  "trusted_folders": ["/home/kpihx"],
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

**Current MCP list:** read `~/.copilot/mcp-config.json` directly — it is the source of truth.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v1.1.0 — added Runtime Context, config.json settings, GitHub account; broadened description |
| [SUMMARY] | — | v1.0.0 — extracted from agents/codex, dedicated SKILL.md created |

---
name: agent-runtime-copilot
description: >
  GitHub Copilot CLI runtime — mcp-config.json format (JSON mcpServers array),
  login shell wrapper pattern for secrets, installed MCP stack. Load when
  installing or configuring MCPs for Copilot.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: agent-runtime
  target-agent: copilot
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — GitHub Copilot CLI

## Runtime Context

- **Home:** `~/.copilot/`
- **Global kernel:** `~/.copilot/COPILOT.md` → `~/.agents/KERNEL.md`
- **Runtime shortcut:** `~/COPILOT.md` → this file
- **Skills path:** `~/.copilot/skills/` → `~/.agents/skills/` (symlink)
- **Config file:** `~/.copilot/mcp-config.json`

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

## Installed MCPs (Copilot)

Same stack as Codex (see `agents/codex` for full command details):
`bw_mcp` · `tick_mcp` (HTTP+fallback) · `whats_mcp` (HTTP+fallback) · `desk_mcp` · `rag_mcp` · `memory_mcp` · `sequential_thinking_mcp` · `exa_mcp` · `puppeteer_mcp` · `n8n_mcp`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-25 | [CLAUDE] | v1.0.0 — extracted from agents/codex, dedicated SKILL.md created |

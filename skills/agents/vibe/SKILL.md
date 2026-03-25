---
name: agent-runtime-vibe
description: >
  VIBE CLI runtime — TOML [[mcp_servers]] array format, login shell wrapper pattern
  for secrets, installed MCPs table. Load when installing or configuring MCPs for VIBE.
license: private
metadata:
  author: KpihX
  version: "2.0.0"
  scope: agent-runtime
  target-agent: vibe
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — VIBE CLI

## Runtime Context

- **Agent home:** `~/.vibe/`
- **Global kernel:** `~/.vibe/prompts/global.md` → `~/.agents/KERNEL.md`
- **Runtime shortcut:** `~/VIBE.md` → this file
- **Skills path:** `~/.vibe/skills/` → `~/.agents/skills/` (symlink)
- **Config file:** `~/.vibe/config.toml`

## MCP Config Format (VIBE — TOML array)

```toml
# stdio MCP with login shell (for bw-env secrets)
[[mcp_servers]]
name = "<name>"
transport = "stdio"
command = "zsh"
args = ["-l", "-c", "/home/kpihx/.local/bin/<binary> serve"]

# Remote HTTP MCP with API key
[[mcp_servers]]
name = "<name>"
transport = "http"
url = "<mcp_url>"
api_key_env = "<API_KEY_ENV_VAR>"
api_key_header = "<header_name>"
api_key_format = "{token}"
```

**Current MCP list:** read `~/.vibe/config.toml` directly (`[[mcp_servers]]` array) — it is the source of truth.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte: migrated to skills/agents/vibe/, symlinks created |
| [SUMMARY] | — | Prior: VIBE.md creation, MCP stack configured |

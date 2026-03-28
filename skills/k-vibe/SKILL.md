---
name: agent-runtime-vibe
description: >
  VIBE CLI runtime — TOML [[mcp_servers]] array format, login shell wrapper pattern
  for secrets, installed MCPs table. Load when installing or configuring MCPs for VIBE.
license: private
metadata:
  author: KpihX
  version: "2.1.0"
  scope: agent-runtime
  target-agent: vibe
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — VIBE CLI

## Runtime Context

- **Agent home:** `~/.vibe/`
- **Global kernel:** `~/.vibe/prompts/global.md` → `~/.agents/KERNEL.md`
- **Runtime skill:** `~/.vibe/prompts/vibe.md` → this file (`system_prompt_id = "global"` in config.toml)
- **Skills path:** `skill_paths = ["$HOME/.agents/skills"]` in `config.toml`
- **Config file:** `~/.vibe/config.toml`

## MCP Config Format (VIBE — TOML array)

```toml
# stdio MCP with login shell (for bw-env secrets)
[[mcp_servers]]
name = "<name>"
transport = "stdio"
command = "zsh"
args = ["-l", "-c", "$HOME/.local/bin/<binary> serve"]

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
| 2026-03-28 | [CLAUDE] | v2.1.0 — removed ~/VIBE.md shortcut (deleted); vibe.md → prompts/vibe.md; skills path corrected |
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte: migrated to skills/agents/vibe/, symlinks created |
| [SUMMARY] | — | Prior: VIBE.md creation, MCP stack configured |

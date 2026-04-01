---
name: k-vibe
description: >
  VIBE CLI runtime — config.toml (active_model, providers, skills, tools permissions),
  TOML [[mcp_servers]] format, session model. Load when configuring VIBE, changing model/provider,
  managing MCPs, adjusting tool permissions, or debugging VIBE behavior.
license: private
metadata:
  author: KpihX
  version: "2.2.1"
  scope: agent-runtime
  target-agent: vibe
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — VIBE CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `~/.vibe/`
- **Global kernel:** `~/.vibe/prompts/global.md` → `~/.agents/AGENTS.md`
- **Runtime skill:** `~/.vibe/prompts/vibe.md` → this file (`system_prompt_id = "global"` in config.toml)
- **Skills path:** `skill_paths = ["$HOME/.agents/skills"]` in `config.toml`
- **Config file:** `~/.vibe/config.toml`

## Key Config Files

| File | Role |
|------|------|
| `~/.vibe/config.toml` | Model (active_model/alias), providers, skill_paths, tools permissions, MCPs — **source of truth** |
| `~/.vibe/prompts/global.md` | → AGENTS (system_prompt_id = "global") |
| `~/.vibe/prompts/vibe.md` | → this skill (runtime context) |

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

**Current MCP list:** read `~/.vibe/config.toml` (`[[mcp_servers]]` array) — source of truth.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-31 | [CLAUDE] | v2.2.1 — standardized name: agent-runtime-vibe → k-vibe |
| 2026-03-28 | [CLAUDE] | v2.2.0 — added config.toml anatomy (model, providers, tools permissions); broadened description |
| [SUMMARY] | — | v2.1.0 prompts/vibe.md + skills path; v2.0.0 migrated to skills/ |

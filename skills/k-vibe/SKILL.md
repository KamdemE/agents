---
name: k-vibe
description: >
  VIBE CLI runtime — config.toml (active_model, providers, skills, tools permissions),
  TOML [[mcp_servers]] format, session model. Load when configuring VIBE, changing model/provider,
  managing MCPs, adjusting tool permissions, or debugging VIBE behavior.
license: private
metadata:
  author: KpihX
  version: "2.5.1"
  scope: agent-runtime
  target-agent: vibe
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — VIBE CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `$HOME/.vibe/`
- **Global kernel:** `$HOME/.vibe/prompts/global.md` → `$HOME/.agents/AGENTS.md`
- **Runtime skill:** `$HOME/.vibe/prompts/vibe.md` → this file (`system_prompt_id = "global"` in config.toml)
- **Skills path:** `skill_paths = ["$HOME/.agents/skills"]` in `config.toml`
- **Config file:** `$HOME/.vibe/config.toml`
- **Session logs:** `$HOME/.vibe/logs/session/`
- **History index:** `$HOME/.vibe/vibehistory`

## Source Of Truth

| File | Role |
|------|------|
| `$HOME/.vibe/config.toml` | Model (active_model/alias), providers, skill_paths, tools permissions, MCPs — **source of truth** |
| `$HOME/.vibe/prompts/global.md` | → AGENTS (system_prompt_id = "global") |
| `$HOME/.vibe/prompts/vibe.md` | → this skill (runtime context) |

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

Do not list installed MCPs here; read `$HOME/.vibe/config.toml` directly.

QMD policy: do not configure QMD as a VIBE MCP. Use local CLI directly:
- `qmd status`, `qmd get`, `qmd embed` for admin/read paths
- `qmdr query/search/vsearch ...` for important searches needing freshness guarantees

## Optimization (History & Cache)

- **Session Logs:** `$HOME/.vibe/logs/`
- **History Index:** `$HOME/.vibe/vibehistory`
- **Rules:** VIBE lacks an integrated cache-busting tool. For a full reset of all historical baggage, perform manual removal: `rm -rf ~/.vibe/logs/* ~/.vibe/vibehistory`.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-06 | [GEMINI] | v2.5.0 — Defined History Index and Session Logs absolute paths for explicit CLI cache-clearing rules |
| 2026-04-04 | [CODEX] | v2.4.1–v2.4.0 — documented the CLI-only QMD policy and the real VIBE session-history paths while keeping the skill compact |
| [SUMMARY] | — | v2.3.0–v2.0.0: source-of-truth config framing, standardized name, config anatomy, prompts/vibe.md + skills path, and migration to skills/ |

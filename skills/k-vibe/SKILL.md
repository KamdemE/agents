---
name: k-vibe
description: >
  VIBE CLI runtime — config.toml (active_model, providers, skills, tools permissions),
  TOML [[mcp_servers]] format, session model. Load when configuring VIBE, changing model/provider,
  managing MCPs, adjusting tool permissions, or debugging VIBE behavior.
license: private
metadata:
  author: KpihX
  version: "2.5.3"
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
- **Rules:** VIBE lacks an integrated cache-busting tool. For a full reset of all historical baggage, perform manual removal: `rm -rf $HOME/.vibe/logs/* $HOME/.vibe/vibehistory`.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-vibe/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-vibe/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-18 | [CODEX] | v2.5.3 — Generalized VIBE cache-reset commands from `~` to `$HOME` to match kernel path rules. |
| 2026-04-13 | [CODEX] | v2.5.2 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| [SUMMARY] | — | v2.5.0 history/index cache-clearing rules; +1 older changelog entries kept in file history |

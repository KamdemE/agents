---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: agent-runtime
  target-agent: opencode
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenCode CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Binary:** `$HOME/.opencode/bin/opencode`
- **Global config dir:** `$HOME/.config/opencode/`
- **Config file:** `$HOME/.config/opencode/opencode.jsonc`
- **Auth store:** `$HOME/.local/share/opencode/auth.json`
- **Global kernel symlinks (KπX):**
  - `$HOME/.config/opencode/AGENTS.md` → `$HOME/.agents/AGENTS.md`
  - `$HOME/.config/opencode/skills` → `$HOME/.agents/skills`
- **PATH source of truth:** `$HOME/.kshrc` (`export PATH="$HOME/.opencode/bin:$PATH"`)

## Source Of Truth

| File | Role |
|------|------|
| `$HOME/.config/opencode/opencode.jsonc` | OpenCode runtime config — model, permissions, MCPs |
| `$HOME/.config/opencode/AGENTS.md` | Global instruction kernel (symlink target: `$HOME/.agents/AGENTS.md`) |
| `$HOME/.config/opencode/skills/` | Skill discovery path (symlink target: `$HOME/.agents/skills/`) |
| `$HOME/.local/share/opencode/auth.json` | Provider login credentials |

## MCP Config Format (OpenCode — JSONC)

OpenCode MCP servers are configured under the top-level `mcp` key in `opencode.jsonc`.

Local (stdio-equivalent) server:

```json
{
  "mcp": {
    "mail_fallback": {
      "type": "local",
      "command": ["zsh", "-l", "-c", "/home/kpihx/.local/bin/mail-mcp serve"],
      "enabled": true,
      "timeout": 60000
    }
  }
}
```

Remote HTTP server:

```json
{
  "mcp": {
    "exa": {
      "type": "remote",
      "url": "https://mcp.exa.ai/mcp",
      "oauth": false,
      "enabled": true
    }
  }
}
```

Remote bearer token via env variable:

```json
{
  "mcp": {
    "n8n_homelab": {
      "type": "remote",
      "url": "https://n8n.kpihx-labs.com/mcp",
      "headers": {
        "Authorization": "Bearer {env:N8N_HOMELAB_API_KEY}"
      },
      "enabled": false
    }
  }
}
```

## Verification Commands

```bash
zsh -l -c 'which opencode && opencode --version'
opencode debug config
opencode mcp list
opencode providers list
opencode models
```

## Operational Rules (KπX)

- Keep OpenCode runtime config centralized in `$HOME/.config/opencode/opencode.jsonc`; avoid per-project overrides unless explicitly requested.
- Prefer `zsh -l -c` wrappers for local MCP servers that need secret-bearing login-shell context.
- Do not hardcode secrets in `opencode.jsonc`; use `{env:VAR_NAME}` placeholders.
- Keep AGENTS/skills linked to `$HOME/.agents/` so OpenCode shares the same sovereign kernel as Codex, Vibe, Copilot, and Zed.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-opencode/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-opencode/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-26 | [AUTO] | v1.0.0 — Initial OpenCode runtime skill for install, config, MCP wiring, and verification patterns. |
| [SUMMARY] | — | Initial release. |

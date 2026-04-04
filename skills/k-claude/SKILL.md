---
name: "k-claude"
description: >
  Claude Code runtime — MCP config ($HOME/.claude.json), hooks ($HOME/.claude/settings.json),
  skills/memory architecture, bw-mcp zenity auth, session model.
  Load when configuring Claude, managing MCPs/hooks, or for Claude-specific tasks.
license: "private"
metadata:
  author: "KpihX"
  version: "2.10.0"
  scope: "agent-runtime"
  target-agent: "claude"
allowed-tools: "Bash, Read, Write, Edit"
---

# Agent Runtime — Claude Code

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `$HOME/.claude/`
- **Global kernel:** `$HOME/.claude/CLAUDE.md` → `$HOME/.agents/AGENTS.md`
- **Runtime shortcut:** `$HOME/CLAUDE.md` → this file
- **Skills path:** `$HOME/.claude/skills/` → `$HOME/.agents/skills/` (symlink)
- **Auto-memory:** `$HOME/.claude/projects/-home-kpihx/memory/` — Read → Edit on existing files, never Write
- **Session model:** Single long session from `$HOME/` (HOME workspace)

## History & Memory

- **Session history:** `$HOME/.claude/projects/-home-kpihx/*.jsonl`
- **Subagent traces:** `$HOME/.claude/projects/-home-kpihx/<session-id>/subagents/*.jsonl`
- **Tool outputs:** `$HOME/.claude/projects/-home-kpihx/<session-id>/tool-results/*.json`
- **Workspace memory:** `$HOME/.claude/projects/-home-kpihx/memory/`

## MCP Configuration

**Config file:** `$HOME/.claude.json` (NOT `$HOME/.claude/settings.json` — wrong file)

```json
// User scope — root-level "mcpServers" key
// Local scope — projects["$HOME"]["mcpServers"]
{
  "<name>": { "command": "$HOME/.local/bin/<binary>", "args": ["serve"] },
  "<name>-http": { "type": "http", "url": "https://<name>.kpihx-labs.com/mcp" }
}
```

**Login shell wrapper** (for MCPs needing bw-env secrets):
```json
{ "command": "zsh", "args": ["-l", "-c", "$HOME/.local/bin/<binary> serve"] }
```

After editing `$HOME/.claude.json` → restart Claude Code. Verify with `/mcp`.

Do not enumerate MCPs here; read `$HOME/.claude.json` directly.

## bw-mcp Auth

- Uses `bw` CLI **directly** — independent from `bw-env`
- Launches `zenity` GUI on-demand — no login shell wrapper needed

## Hooks & Permissions (`$HOME/.claude/settings.json`)

`$HOME/.claude/settings.json` is the source of truth for Claude hook wiring and permission policy.

- live wrappers: `session_start.py`, `user_prompt_submit.py`, `pre_tool_use.py`, `stop.py`, `session_end.py`
- edit `$HOME/.claude/settings.json`, not `$HOME/.claude.json`, when changing hooks or permissions
- exact event mapping and examples live in `$HOME/.agents/hooks/README.md`

## k-context / k-* SKILL.md Edit Protocol

The `pre_tool_use` hook validates **each `Edit` call independently**. It blocks any call that doesn't include all required updates in the same replacement string.

**Required sections per file type:**

| File | Must include in ONE Edit call |
|------|-------------------------------|
| `k-context/SKILL.md` | `metadata.version` bump + `## Session Log` update + `## Changelog` update |
| Any other `k-*/SKILL.md` | `metadata.version` bump + `## Changelog` update |

**Pattern — always replace from the `version:` line through the end of `## Changelog`:**

```
# ✅ One Edit — old_string spans version → last Changelog line
Edit(old_string='  version: "2.9.0"\n...\n| [SUMMARY] | ...',
     new_string='  version: "2.10.0"\n...\n| [SUMMARY] | ...')

# ❌ Two separate Edits — each blocked independently by the hook
Edit(old_string='  version: "2.9.0"', ...)      # blocked: Changelog missing
Edit(old_string='## Changelog\n...', ...)        # blocked: version missing
```

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.10.0 — added k-context/k-* SKILL.md Edit Protocol: single-call pattern required by pre_tool_use hook |
| 2026-04-03 | [CODEX] | v2.9.0 — compacted the runtime history section to the minimum useful path map |
| [SUMMARY] | — | v2.8.0–v2.0.0: compact hook guidance, compact history path map, live hook wiring, path normalization, hooks ref cleanup, name standardization, and earlier runtime extraction/cleanup |

---
name: "k-claude"
description: >
  Claude Code runtime — MCP config ($HOME/.claude.json), hooks ($HOME/.claude/settings.json),
  skills/memory architecture, bw-mcp zenity auth, session model.
  Load when configuring Claude, managing MCPs/hooks, or for Claude-specific tasks.
license: "private"
metadata:
  author: "KpihX"
  version: "2.11.0"
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

## k-* SKILL.md Edit Protocol

For Claude, the **header/footer completeness check** (version bump, Changelog, SessionLog) is now a
**PostToolUse advisory** — the edit goes through, and a warning appears if sections are missing.
Structure and content checks remain blocking in PreToolUse.

**Required sections per file type (complete before session end):**

| File | Required updates |
|------|-----------------|
| `k-context/SKILL.md` | `metadata.version` bump + `## Session Log` update + `## Changelog` update |
| Any other `k-*/SKILL.md` | `metadata.version` bump + `## Changelog` update |

**Workflow:**
1. Do natural multi-step Edits — no longer blocked mid-sequence
2. After each Edit on a SKILL.md, PostToolUse will warn if sections are still incomplete
3. Follow up with another Edit to complete — session_guard blocks at Stop if still incomplete

> **Note:** Gemini still uses full PreToolUse blocking (unchanged). This change is Claude-only.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.11.0 — Edit Protocol updated: header/footer check moved to PostToolUse advisory; natural multi-step edits now allowed for Claude |
| 2026-04-04 | [CLAUDE] | v2.10.0 — added k-context/k-* SKILL.md Edit Protocol: single-call pattern required by pre_tool_use hook |
| [SUMMARY] | — | v2.9.0–v2.0.0: compact hook guidance, compact history path map, live hook wiring, path normalization, hooks ref cleanup, name standardization, and earlier runtime extraction/cleanup |

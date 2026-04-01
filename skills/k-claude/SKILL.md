---
name: k-claude
description: >
  Claude Code runtime — MCP config (JSON ~/.claude.json), hooks (settings.json),
  skills/memory architecture, bw-mcp zenity auth, session model.
  Load when configuring Claude, managing MCPs/hooks, or for Claude-specific tasks.
license: private
metadata:
  author: KpihX
  version: "2.3.1"
  scope: agent-runtime
  target-agent: claude
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Claude Code

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `~/.claude/`
- **Global kernel:** `~/.claude/CLAUDE.md` → `~/.agents/AGENTS.md`
- **Runtime shortcut:** `~/CLAUDE.md` → this file
- **Skills path:** `~/.claude/skills/` → `~/.agents/skills/` (symlink)
- **Auto-memory:** `~/.claude/projects/-home-kpihx/memory/` — Read → Edit on existing files, never Write
- **Session model:** Single long session from `~/` (HOME workspace)

## MCP Configuration

**Config file:** `~/.claude.json` (NOT `~/.claude/settings.json` — wrong file)

```json
// User scope — root-level "mcpServers" key
// Local scope — projects["/home/kpihx"]["mcpServers"]
{
  "<name>": { "command": "$HOME/.local/bin/<binary>", "args": ["serve"] },
  "<name>-http": { "type": "http", "url": "https://<name>.kpihx-labs.com/mcp" }
}
```

**Login shell wrapper** (for MCPs needing bw-env secrets):
```json
{ "command": "zsh", "args": ["-l", "-c", "$HOME/.local/bin/<binary> serve"] }
```

After editing `~/.claude.json` → restart Claude Code. Verify with `/mcp`.

**Current MCP list:** read `~/.claude.json` directly — it is the source of truth.

## bw-mcp Auth

- Uses `bw` CLI **directly** — independent from `bw-env`
- Launches `zenity` GUI on-demand — no login shell wrapper needed

## Hooks & Permissions (`~/.claude/settings.json`)

- `hooks` — event-driven shell commands (Stop, PreToolUse, etc.)
- `permissions.allow/deny` — per-tool auto-approvals
- Active: `Stop` hook → `~/.agents/scripts/session-guard.sh` (k-context final update)
- Edit this file (not `~/.claude.json`) for hooks/permissions.

## Project Context

When working in a project under `~/Work/`, check for `.agents/AGENTS.md` at the project root.
If found: treat it as project-specific context — architecture rules, stack, evolution rules.
Template: `~/.agents/skills/k-project/templates/AGENTS.md`.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-31 | [CLAUDE] | v2.3.1 — standardized name: agent-runtime-claude → k-claude |
| 2026-03-29 | [CLAUDE] | v2.3.0 — added Project Context section (.agents/AGENTS.md auto-load rule) |
| 2026-03-28 | [CLAUDE] | v2.2.0 — added Hooks section (Stop → session-guard.sh); updated description |
| [SUMMARY] | — | v2.1.0 removed Tool Discipline; v2.0.0 migrated to skills/k-claude/ |

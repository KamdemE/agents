---
name: agent-runtime-claude
description: >
  Claude Code runtime — MCP config format (JSON in ~/.claude.json), skills path
  ~/.agents/skills/, installed MCPs table, bw-mcp zenity auth, auto-memory.
  Load when installing or configuring MCPs for Claude, or for Claude-specific tasks.
license: private
metadata:
  author: KpihX
  version: "2.1.0"
  scope: agent-runtime
  target-agent: claude
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Claude Code

## Runtime Context

- **Agent home:** `~/.claude/`
- **Global kernel:** `~/.claude/CLAUDE.md` → `~/.agents/KERNEL.md`
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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v2.1.0 — removed Tool Discipline (duplicate of KERNEL); compacted |
| [SUMMARY] | — | v2.0.0 — migrated to skills/k-claude/; all MCPs registered |

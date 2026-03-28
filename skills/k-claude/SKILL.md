---
name: agent-runtime-claude
description: >
  Claude Code runtime — MCP config format (JSON in ~/.claude.json), skills path
  ~/.agents/skills/, installed MCPs table, bw-mcp zenity auth, tool discipline.
  Load when installing or configuring MCPs for Claude, or for Claude-specific tasks.
license: private
metadata:
  author: KpihX
  version: "2.0.0"
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
- **Auto-memory:** `~/.claude/projects/-home-kpihx/memory/` (Read → Edit on existing files, never Write)
- **Session model:** Single long session from `~/` (HOME workspace)

## MCP Configuration

**Config file:** `~/.claude.json` (NOT `~/.claude/settings.json` — wrong file)

```json
// User scope (all projects) — root-level "mcpServers" key
// Local scope (current project) — inside projects["$HOME"]["mcpServers"]  (key = actual home path)
{
  "<name>": {
    "command": "$HOME/.local/bin/<binary>",
    "args": ["serve"]
  }
}
```

**Login shell wrapper** (for MCPs needing bw-env secrets):
```json
{
  "command": "zsh",
  "args": ["-l", "-c", "$HOME/.local/bin/<binary> serve"]
}
```

After editing `~/.claude.json` → restart Claude Code for MCPs to load. Verify with `/mcp`.

**Current MCP list:** read `~/.claude.json` directly — it is the source of truth.

## bw-mcp Auth Specifics

- Uses `bw` CLI **directly** — independent from `bw-env`
- Launches `zenity` GUI for password prompt on auth — no pre-requisite needed
- No login shell wrapper required (auth is on-demand via zenity)

## Tool Discipline (Claude-specific)

- **Read before Edit:** Always read a file before editing. Write tool = new files only.
- **No shell file ops:** Never `sed`/`printf`/`echo >` for file changes — use Read+Edit
- **Parallel tool calls:** Maximize independence; never parallelize dependent calls
- **Auto-memory:** Read → Edit on `~/.claude/projects/*/memory/*.md`. Never Write on existing files.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte: migrated to skills/agents/claude/, symlinks updated |
| [SUMMARY] | — | Prior: CLAUDE.md creation, all MCPs registered (mail, linkedin, whats, tick, chrome) |

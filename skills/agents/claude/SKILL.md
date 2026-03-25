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
// Local scope (current project) — inside projects["/home/kpihx"]["mcpServers"]
{
  "<name>": {
    "command": "/home/kpihx/.local/bin/<binary>",
    "args": ["serve"]
  }
}
```

**Login shell wrapper** (for MCPs needing bw-env secrets):
```json
{
  "command": "zsh",
  "args": ["-l", "-c", "/home/kpihx/.local/bin/<binary> serve"]
}
```

After editing `~/.claude.json` → restart Claude Code for MCPs to load. Verify with `/mcp`.

## Installed MCPs

| Name | Transport | Endpoint / Command | Notes |
|------|-----------|-------------------|-------|
| `bw-mcp` | stdio | `/home/kpihx/.local/bin/bw-mcp serve` | zenity GUI unlock — no login shell needed |
| `tick-mcp` | HTTP | `https://tick.kpihx-labs.com/mcp` | Primary |
| `tick-mcp--fallback` | stdio | `zsh -l -c "tick-mcp serve"` | stdio fallback |
| `whats-mcp` | HTTP | `https://whats.kpihx-labs.com/mcp` | Primary |
| `whats-mcp--fallback` | stdio | `/home/kpihx/.npm-global/bin/whats-mcp` | stdio fallback |
| `desk-mcp` | stdio | `/home/kpihx/.local/bin/desk-mcp serve` | Needs DISPLAY env vars |
| `mail-mcp` | HTTP | `https://mail.kpihx-labs.com/mcp` | Primary |
| `mail-mcp--fallback` | stdio | `zsh -l -c "mail-mcp serve"` | stdio fallback |
| `linkedin-mcp` | HTTP | `https://linkedin.kpihx-labs.com/mcp` | Primary |
| `linkedin-mcp--fallback` | stdio | `/home/kpihx/.bun/bin/linkedin-mcp serve` | stdio fallback |
| `rag-mcp` | stdio | `npx -y @yikizi/mcp-local-rag` | Local hybrid RAG |
| `sequential-thinking` | stdio | `npx -y @modelcontextprotocol/server-sequential-thinking` | — |
| `memory` | stdio | `npx -y @modelcontextprotocol/server-memory` | Knowledge Graph |
| `exa` | HTTP | `https://mcp.exa.ai/mcp` | `EXA_API_KEY` header |
| `puppeteer` | stdio | `npx -y @modelcontextprotocol/server-puppeteer` | Browser automation |
| `claude-in-chrome` | browser ext | Chrome 146 | claude-in-chrome extension installed |

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

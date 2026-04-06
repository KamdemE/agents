---
name: "k-claude"
description: >
  Claude Code runtime — MCP config ($HOME/.claude.json), hooks ($HOME/.claude/settings.json),
  skills/memory architecture, bw-mcp zenity auth, session model.
  Load when configuring Claude, managing MCPs/hooks, or for Claude-specific tasks.
license: "private"
metadata:
  author: "KpihX"
  version: "2.14.1"
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
- **Workspace memory:** `$HOME/.claude/projects/-home-kpihx/memory/` (Long-term persistent markdown memory)
- **Caches & Global Logs:** `$HOME/.claude/history.jsonl`, `$HOME/.claude/shell-snapshots/`, `$HOME/.claude/debug/`, `$HOME/.claude/paste-cache/`

> **Optimization Rule:** When purging history, strictly target raw logs and caches. DO NOT blindly purge `projects/` as it destroys Claude's contextual logic and inter-session memory sandboxes.

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

QMD policy: do not configure QMD as a Claude MCP. Use local CLI directly:
- `qmd status`, `qmd get`, `qmd embed` for admin/read paths
- `qmdr query/search/vsearch ...` for important searches needing freshness guarantees

## Sudo Gate

When a task requires a `sudo` command: **STOP**, show the exact command to KπX, wait for confirmation ("c'est bon" / "done"), then continue.
Never attempt `sudo` autonomously — Claude runs as the user and sudo prompts fail silently in the agent flow.

## bw-mcp Auth

- Uses `bw` CLI **directly** — independent from `bw-env`
- Launches `zenity` GUI on-demand — no login shell wrapper needed

## Hooks & Permissions (`$HOME/.claude/settings.json`)

`$HOME/.claude/settings.json` is the source of truth for Claude hook wiring and permission policy.

- live wrappers: `session_start.py`, `user_prompt_submit.py`, `pre_tool_use.py`, `post_tool_use.py`, `stop.py`, `session_end.py`
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
| 2026-04-06 | [GEMINI] | v2.14.0 — Mapped exact cache locations and added strict caution against purging `projects/` sandboxes |
| 2026-04-05 | [CLAUDE] | v2.13.0–v2.12.1 — sudo gate added; CLI-only QMD policy enforced for admin/read and important searches |
| [SUMMARY] | — | v2.12.0–v2.0.0: post_tool_use.py desync fix, Edit Protocol PostToolUse advisory, CLI-only QMD policy, compact hook guidance, live hook wiring, path normalization, name standardization, and earlier runtime cleanup |

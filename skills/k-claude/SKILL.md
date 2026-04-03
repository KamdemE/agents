---
name: "k-claude"
description: >
  Claude Code runtime — MCP config ($HOME/.claude.json), hooks ($HOME/.claude/settings.json),
  skills/memory architecture, bw-mcp zenity auth, session model.
  Load when configuring Claude, managing MCPs/hooks, or for Claude-specific tasks.
license: "private"
metadata:
  author: "KpihX"
  version: "2.8.0"
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

## Session History & Logs

- **Main sessions:** `$HOME/.claude/projects/-home-kpihx/*.jsonl`
- **Per-session subagents:** `$HOME/.claude/projects/-home-kpihx/<session-id>/subagents/*.jsonl`
- **Tool outputs:** `$HOME/.claude/projects/-home-kpihx/<session-id>/tool-results/*.json`
- **Workspace memory index:** `$HOME/.claude/projects/-home-kpihx/memory/MEMORY.md`
- **Workspace memory docs:** `$HOME/.claude/projects/-home-kpihx/memory/*.md`

**Structure:**
- Each top-level `*.jsonl` file is one Claude session for the `$HOME` workspace
- Newest discussion = top-level `*.jsonl` with the latest modification time
- Records are JSON Lines with mixed entry types: `user`, `assistant`, `system`, `last-prompt`, `permission-mode`, `file-history-snapshot`
- Subagent traces live under the matching `<session-id>/subagents/`
- Session-level tool payloads live under the matching `<session-id>/tool-results/`

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.8.0 — compacted the hook section so this skill points to the real Claude runtime config and `$HOME/.agents/hooks/README.md` instead of re-describing the live wrapper behavior inline |
| 2026-04-03 | [CODEX] | v2.7.0 — updated Claude hook behavior notes for the lighter per-turn reminder, the write-time `SKILL.md` completion guard, and the delayed `.agents/` finalization reminder |
| [SUMMARY] | — | v2.7.0–v2.0.0: compact hook guidance, live hook wiring, session history paths and JSONL layout, path normalization, hooks ref cleanup, name standardization, and earlier runtime extraction/cleanup |

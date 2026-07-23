---
name: "k-claude"
description: >
  Claude Code runtime — MCP config ($HOME/.claude.json), hooks ($HOME/.claude/settings.json),
  skills/memory architecture, bw-mcp zenity auth, session model.
  Legacy reference kept under `skills/deactive/`; load only for archival Claude-specific runtime work.
license: "private"
metadata:
  author: "KpihX"
  version: "2.15.1"
  scope: "agent-runtime"
  target-agent: "claude"
allowed-tools: "Bash, Read, Write, Edit"
---

# Agent Runtime — Claude Code

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> Legacy / deactive skill: this file is intentionally kept in `skills/deactive/k-claude/` and is no longer part of the active runtime stack.

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

**Login shell wrapper** (for MCPs needing Vaultwarden secrets):
```json
{ "command": "zsh", "args": ["-l", "-c", "$HOME/.local/bin/<binary> serve"] }
```

After editing `$HOME/.claude.json` → restart Claude Code. Verify with `/mcp`.

Do not enumerate MCPs here; read `$HOME/.claude.json` directly.

QMD policy: do not configure QMD as a Claude MCP. Use local CLI directly:
- `qmd status`, `qmd get`, `qmd embed` for admin/read paths
- `qmdr query/search/vsearch ...` for important searches needing freshness guarantees

## Privilege Gate

When a task requires elevation: use **shared tmux** (`k-tmux` gate); **`sui` is deprecated** — poll pane ≥30s for KπX `sudo`/SSH approval.
Never attempt raw `sudo` autonomously — Claude runs as the user and legacy `sudo` prompts fail silently in the agent flow.

## bw-mcp Auth

- Uses `bw` CLI **directly** — independent from `Vaultwarden`
- Launches `zenity` GUI on-demand — no login shell wrapper needed

## Hooks & Permissions (`$HOME/.claude/settings.json`)

`$HOME/.claude/settings.json` is the source of truth for Claude hook wiring and permission policy.

- live wrappers: `session_start.py`, `user_prompt_submit.py`, `pre_tool_use.py`, `post_tool_use.py`, `stop.py`, `session_end.py`
- edit `$HOME/.claude/settings.json`, not `$HOME/.claude.json`, when changing hooks or permissions
- exact event mapping and examples live in `$HOME/.agents/hooks/README.md`
- **`make audit`** (`$HOME/.agents/hooks/audit.py`) does **not** validate this file anymore — decoupled from local Claude install; re-enable in `audit.py` if you want automated hook-matrix checks again.

## k-* SKILL.md Edit Protocol

For Claude, the **header/footer completeness check** (version bump, Changelog, SessionLog) is now a
**PostToolUse advisory** — the edit goes through, and a warning appears if sections are missing.
Structure and content checks remain blocking in PreToolUse.

**Required sections per file type (complete before session end):**

| File | Required updates |
|------|-----------------|
| `k-context/SKILL.md` | `metadata.version` bump + `## Session Log` update + `## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-claude/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-claude/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog` update |
| Any other `k-*/SKILL.md` | `metadata.version` bump + `## Changelog` update |

**Workflow:**
1. Do natural multi-step Edits — no longer blocked mid-sequence
2. After each Edit on a SKILL.md, PostToolUse will warn if sections are still incomplete
3. Follow up with another Edit to complete — session_guard blocks at Stop if still incomplete

> **Note:** Gemini still uses full PreToolUse blocking (unchanged). This change is Claude-only.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-18 | [CODEX] | v2.15.1 — Replaced the old `sudo` gate wording with the kernel-wide `sui -r` privilege model even in this legacy skill. |
| 2026-04-18 | [CODEX] | v2.15.0 — Marked the skill explicitly as legacy/deactive so the file state matches its new location under `skills/deactive/`. |
| [SUMMARY] | — | v2.14.2 insights discipline; v2.14.0 cache-location mapping + purge caution; older entries kept in file history and condensed for table limits |

---
name: k-copilot
description: >
  GitHub Copilot CLI (`copilot`) runtime — copilot-instructions.md kernel link,
  mcp-config.json format (JSON mcpServers), config.json settings (account KpihX,
  trusted_folders), skills integration.
  Load when configuring Copilot, managing MCPs, or understanding its runtime behavior.
  Registry in k-clis.
license: private
metadata:
  author: KpihX
  version: "1.8.0"
  scope: agent-runtime
  target-agent: copilot
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — GitHub Copilot CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Home:** `$HOME/.copilot/`
- **Global kernel:** `$HOME/.copilot/copilot-instructions.md` → `$HOME/.agents/AGENTS.md`
- **Runtime shortcut:** `$HOME/COPILOT.md` → this file
- **Skills path:** `$HOME/.copilot/skills/` → `$HOME/.agents/skills/` (symlink)
- **Config files:** `$HOME/.copilot/mcp-config.json` (MCPs) · `$HOME/.copilot/config.json` (settings)
- **Session state:** `$HOME/.copilot/session-state/`
- **Command history:** `$HOME/.copilot/command-history-state.json`

### Session Storage

Copilot stores sessions in a SQLite database:

- **`$HOME/.copilot/session-store.db`** (SQLite, ~50 KB) — Main session store.
  - `sessions` table: `id`, `cwd`, `repository`, `host_type`, `branch`, `summary`, timestamps.
  - `turns` table: `session_id`, `turn_index`, `user_message`, `assistant_response`, `timestamp`.
  - Each session has one or more turns (user message + assistant response).
- **`$HOME/.copilot/session-state/<uuid>/`** — Per-session state directories (runtime/tool state, not message transcripts).
- **`$HOME/.copilot/command-history-state.json`** — Recent command history (JSON).

Total session data (excluding logs): ~50 KB DB + per-session state dirs. Queryable directly via `sqlite3`.

## Source Of Truth

| File | Role |
|------|------|
| `$HOME/.copilot/mcp-config.json` | MCP server definitions |
| `$HOME/.copilot/config.json` | local Copilot settings |

## config.json (Settings)

```json
{
  "last_logged_in_user": { "host": "https://github.com", "login": "KpihX" },
  "trusted_folders": ["$HOME"],
  "banner": "never"
}
```

GitHub account: **KpihX**. `trusted_folders` = workspace automatically trusted for file context.

## MCP Config Format (Copilot — JSON)

```json
{
  "mcpServers": {
    "<name>": {
      "type": "stdio",
      "command": "zsh",
      "args": ["-l", "-c", "<server_command>"]
    }
  }
}
```

HTTP servers: use `"type": "http"`. Restart Copilot + verify via `/mcp` after any config edit.

Do not list installed MCPs here; read `$HOME/.copilot/mcp-config.json` directly.

## Copilot VS Code Hooks (Removed)

**Copilot VS Code Python hooks (`session_start.py`, `user_prompt_submit.py`, `pre_tool_use.py`, `post_tool_use.py`, `stop.py`) were removed 2026-08-09** when the kernel moved to an OpenCode-only hook architecture (see `k-opencode/references/hooks-standard.md`). Copilot no longer has dedicated lifecycle hooks in `.agents/` — it still reads the shared `AGENTS.md` kernel via symlink (`$HOME/.copilot/copilot-instructions.md`), but per-turn enforcement/context-injection is now OpenCode-exclusive. If Copilot-specific hooks are ever needed again, model them after the current `k-opencode/scripts/hooks/*.js` pattern rather than restoring the old Python wrappers.

QMD policy: do not configure QMD as a Copilot MCP. Use local CLI directly:
- `qmd status`, `qmd get`, `qmd embed` for admin/read paths
- `qmdr query/vsearch ...` for important searches needing freshness guarantees

## Optimization (History & Cache)

- **Execution Logs:** `$HOME/.copilot/logs/`
- **Session State:** `$HOME/.copilot/session-state/`
- **Command History:** `$HOME/.copilot/command-history-state.json`
- **Rules:** Copilot CLI stores historical context transparently. There is no internal prune command; flush cleanly via `rm -rf $HOME/.copilot/logs/* $HOME/.copilot/session-state/* $HOME/.copilot/command-history-state.json`.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-copilot/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-copilot/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-21 | [OPENCODE] | v1.8.0 — Added Session Storage section (session-store.db schema, session-state dirs). Removed from QMD indexing (QMD purged). |
| 2026-04-18 | [CODEX] | v1.7.3 — Generalized Copilot cleanup commands from `~` to `$HOME` for kernel-wide path consistency. |
| [SUMMARY] | — | v1.7.2 Standardized insights discipline; v1.7.0 manual history purge paths; +1 older changelog entries kept in file history |

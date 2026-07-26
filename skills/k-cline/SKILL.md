---
name: k-cline
description: >
  Cline CLI runtime — install/update path, global data/config layout (~/.cline),
  MCP settings file wiring, AGENTS/skills linkage, and runtime verification commands.
  Load when installing Cline CLI, configuring MCP servers, or debugging Cline runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: agent-runtime
  target-agent: cline
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Cline CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Binary:** `$HOME/.npm-global/bin/cline`
- **Global root:** `$HOME/.cline/`
- **Data dir:** `$HOME/.cline/data/`
- **Settings dir:** `$HOME/.cline/data/settings/`
- **MCP settings file:** `$HOME/.cline/data/settings/cline_mcp_settings.json`
- **Providers file:** `$HOME/.cline/data/settings/providers.json`
- **Kernel links (KπX):**
  - `$HOME/.cline/rules/AGENTS.md` → `$HOME/.agents/AGENTS.md`
  - `$HOME/.cline/skills` → `$HOME/.agents/skills`

### Session Storage

Cline stores sessions as per-session JSON files:

- **`$HOME/.cline/data/sessions/<ts>_<random>/`** (37 MB total) — One directory per session.
  - `<id>.json` — Session metadata: `{version, session_id, source, pid, started_at, ended_at, status, provider, model, cwd, workspace_root, prompt, messages_path, ...}`.
  - `<id>.messages.json` — Full conversation: JSON array of `{role, content, ...}` messages (user + assistant). Plain JSON, no SQLite or JSONL.
- **`$HOME/.cline/data/db/`** — Internal Cline storage (SQLite, runtime state).

Total session data: ~37 MB across ~7 sessions. Each session is a standalone JSON pair — trivially portable and readable.

## Source Of Truth

| File | Role |
|------|------|
| `$HOME/.cline/data/settings/providers.json` | Provider/model auth state for Cline |
| `$HOME/.cline/data/settings/cline_mcp_settings.json` | MCP server registrations |
| `$HOME/.cline/rules/AGENTS.md` | Global rule kernel symlink |
| `$HOME/.cline/skills/` | Global skills symlink |

## MCP Config Format (Cline)

Use top-level `mcpServers` with one entry per server.

Local stdio server:

```json
{
  "mcpServers": {
    "mail_fallback": {
      "type": "stdio",
      "command": "zsh",
      "args": ["-l", "-c", "/home/kpihx/.local/bin/mail-mcp serve"],
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

Remote HTTP server:

```json
{
  "mcpServers": {
    "exa": {
      "type": "streamableHttp",
      "url": "https://mcp.exa.ai/mcp",
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

## Verification Commands

```bash
cline --version
cline --help
cline doctor
```

## Operational Rules (KπX)

- Keep Cline runtime state under `~/.cline/`; avoid ad hoc alternate dirs unless explicitly requested.
- Keep MCP settings edits in `cline_mcp_settings.json` and avoid hardcoding secrets.
- Keep AGENTS/skills symlinked to `$HOME/.agents/` to preserve sovereign cross-agent behavior.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-cline/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-cline/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-21 | [OPENCODE] | v1.1.0 — Added Session Storage section (sessions/<ts>_<random>/ JSON format). |
| 2026-05-26 | [AUTO] | v1.0.0 — Initial Cline runtime skill (install, MCP wiring, kernel linkage, verification). |
| [SUMMARY] | — | Initial release. |

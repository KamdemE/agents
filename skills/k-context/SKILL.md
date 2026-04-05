---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.43.0"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> TODOs: only KπX adds; agents execute + remove.
> **Project rule:** before touching any project — if not already in context — read its folder's `.md` files in order: `AGENTS.md` → `CHANGELOG` → `README` → `TODO`. Never work on a project without knowing its current state. Project rows and session log entries include the folder path for this purpose.
> **Brainstorms & research:** `references/` — load on demand for deep context.
> **Visual reference asset:** `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.

## Active TODOs

| Task | IMPORTANT | URGENT | CONCERNED | Description |
|------|-----------|--------|-----------|-------------|
| *(none)* | | | | |

## Active Projects

> Limit: max 10 active rows.
> Only when full, condense stale/completed items into one short bounded `[ARCHIVE]` row.

| Project | Status | Next · Folder |
|---------|--------|---------------|
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs · `$HOME/.agents/assets/` |
| **Centralized Hooks** | ✅ Pre+Post hook split complete; k-hook v2.13.0, k-claude v2.12.0 | maintain via `make audit` · `$HOME/.agents/hooks/` |
| **Optimization map** | ✅ QMD lean-index cleanup applied; home media dirs policy added; Downloads/Documents/Pictures emptied | maintain hot-only indexing discipline · `$HOME/.config/qmd/` |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools · `$HOME/Work/AI/MCPs/mem_mcp/` |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test | `$HOME/.agents/references/` |
| **[ARCHIVE]** | Stable/completed items condensed | QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-05 | [CLAUDE] | v2.43.0 — backup-restore-sh: full agnostic refactor, .env externalized, install/purge/systemd templates, GitHub+GitLab repos, submodule added to sh/ · `$HOME/Work/sh/backup_restore/` |
| 2026-04-05 | [CLAUDE] | v2.42.0 — clean-sh: dynamic service (@SCRIPT_DIR@), /var/log/clean-system/, workspace_scan 3-tier git check, sudo gate in k-claude · `$HOME/Work/sh/clean/` |
| 2026-04-04 | [CLAUDE] | v2.41.0 — clean-sh extracted as submodule; HOME fix, crashes, DU_EXCLUDES, Makefile · `$HOME/Work/sh/clean/` |
| 2026-04-04 | [CLAUDE] | v2.40.0 — fix clean-system.service $HOME bug; install.sh/purge.sh/README + journald; k-project Bash case + templates · `$HOME/Work/sh/clean/` |
| 2026-04-04 | [CLAUDE] | v2.39.0 — response_validator.py `:` optional in section regexes; sh/clean/ audit · `$HOME/.agents/hooks/core/` |
| 2026-04-04 | [CLAUDE] | v2.38.0 — fix session_guard.py deleted-file crash; clean k-openclaw from claude.json · `$HOME/.agents/hooks/core/` |
| 2026-04-04 | [CLAUDE] | v2.37.0 — full OpenClaw purge + 5 YAML fixes; k-openclaw→deactive · `$HOME/.agents/skills/` |
| 2026-04-04 | [CLAUDE] | v2.34.1 — bw_env robustness; committed+pushed · `$HOME/Work/sh/bw_env/` |
| 2026-04-04 | [CODEX] | v2.36.0 — retired OpenClaw from active context map · `$HOME/.agents/skills/` |
| 2026-04-04 | [CLAUDE] | v2.33.0 — renamed `bw-env/` → `bw_env/` · `$HOME/Work/sh/bw_env/` |
| [SUMMARY] | — | v2.32.9–v2.21.0: AfterAgent fix, QMD CLI-only, qmdr entrypoint, k-codex frontmatter rule, QMD freshness gate, AGENTS routing, agent-owned k-agent, k-claude hook work, bw-env rollout |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-05 | [CLAUDE] | v2.43.0 — backup-restore-sh: full agnostic refactor, .env externalized, install/purge/systemd templates, GitHub+GitLab repos, submodule in sh/ |
| 2026-04-05 | [CLAUDE] | v2.42.0 — clean-sh finalized: dynamic service, /var/log/, git .env detection, sudo gate |
| [SUMMARY] | — | v2.41.0–v1.0.0: clean-sh submodule+DU_EXCLUDES, clean-system $HOME fix, journald, k-project Bash case, validator colon opt, session_guard fix, OpenClaw purge, bw-env, CLI-only QMD, and older |

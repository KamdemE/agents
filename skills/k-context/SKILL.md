---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.26.0"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> TODOs: only KπX adds; agents execute + remove.
> **Brainstorms & research:** `references/` — load on demand for deep context.
> **Visual reference asset:** `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.

## Active TODOs

| Task | IMPORTANT | URGENT | CONCERNED | Description |
|------|-----------|--------|-----------|-------------|
| *(none)* | | | | |

## Active Projects

> Limit: max 10 active rows.
> Only when full, condense stale/completed items into one short bounded `[ARCHIVE]` row.

| Project | Status | Next |
|---------|--------|------|
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs |
| **Centralized Hooks** | ✅ header/footer check moved to PostToolUse advisory; `post_tool_use.py` added; natural multi-step edits now allowed for Claude | maintain via `make audit` |
| **Optimization map** | ✅ `k-optim` v1.6.0 — home media dirs policy added; Downloads/Documents/Pictures emptied; wine.md migrated to tutos_live | maintain; log future cleanup actions |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools |
| **$HOME/.agents/ refonte** | ✅ normalized, committed, and pushed | maintain and avoid drift |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test | see `references/agentic-architecture-brainstorm.md` |
| **OpenClaw** | ✅ gateway restored; local Ollama unified on `127.0.0.1:11434`; default model is `phi4-mini:latest` | keep Telegram disabled until token exists; investigate `openclaw agent --json` CLI hang separately |
| **bw-env refactor** | ✅ fully closed — README improved, tutos_live qmd dup removed, bw-env.md desync eliminated | closed |
| **ollama-ipex** | ✅ remotes + push confirmed up-to-date on github/gitlab | closed |
| **[ARCHIVE]** | Stable/completed items condensed | QMD post-commit hygiene stable; DXO internship accepted |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-04 | [CLAUDE] | v2.26.0 — k-claude v2.12.0 (post_tool_use.py desync fix); OpenClaw handler.ts Python indent fixed; README Gemini no-AfterTool note; `_dg_backup_check` root-cause documented |
| 2026-04-04 | [CLAUDE] | v2.25.0 — `.agents/` committed+pushed (677bc15); tg.md desync eliminated from tutos_live; tools.md install path fixed (`~/Work/Tools/tg`) |
| 2026-04-04 | [CLAUDE] | v2.24.0 — PostToolUse advisory hook for Claude: `post_tool_use.py` created, PreToolUse no longer blocks on header/footer, k-hook v2.13.0 + k-claude v2.11.0; bw-env README improved + tutos_live qmd dup removed; ollama-ipex push confirmed |
| 2026-04-04 | [CODEX] | v2.23.1 — OpenClaw gateway restored: unresolved Telegram token removed from active channel config, port `18789` healthy again, local `phi4-mini:latest` loads and the gateway agent path reaches Ollama |
| 2026-04-04 | [CLAUDE] | v2.23.0 — bw-env fully delivered: dbus silence, auth guard, 4 hot-path bw status→RAM checks (4s→226ms), tray timeout+30s poll; install.sh+purge.sh committed+pushed; "Optimize bw-env" TODO closed |
| 2026-04-04 | [CODEX] | v2.22.1 — OpenClaw config repaired: local Ollama endpoint unified on `127.0.0.1:11434`, default model moved to `phi4-mini:latest`, invalid `tools` merge fixed |
| 2026-04-04 | [CODEX] | v2.22.0 — `ollama-ipex` now switches native/IPEX on the shared `11434` endpoint; editable CLI, verbose phase output, and plain `ollama ...` validation completed |
| 2026-04-04 | [CLAUDE] | v2.21.0 — bw-env: .agent/→.agents/ migration; install.sh + purge.sh sandbox-validated; Makefile + README + .gitignore updated |
| 2026-04-04 | [CLAUDE] | v2.20.0 — bw-env install.sh written: bw CLI auto-install, install path prompt, .env config, systemd sync daemon, GUI tray optional, -y flag |
| 2026-04-04 | [CLAUDE] | v2.19.0 — home media cleanup: Downloads/Documents/Pictures emptied; wine.md migrated to tutos_live; k-optim v1.6.0 with Home Media Directories section |
| [SUMMARY] | — | v2.18.0–v2.16.0: debris cleanup, hooks audit, AGENTS.md cleaned, k-optim v1.5.0–v1.4.0, session-log guard, lean hook rollout |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.26.0 — k-claude desync fix, OpenClaw indent bug, README Gemini note, `_dg_backup_check` documented |
| 2026-04-04 | [CLAUDE] | v2.25.0 — `.agents/` pushed (677bc15); tg.md desync eliminated; tools.md path fix |
| [SUMMARY] | — | v1.0.0–v2.24.0: prior session-log maintenance, PostToolUse hook, bw-env, OpenClaw repair, ollama-ipex, and older entries condensed. |

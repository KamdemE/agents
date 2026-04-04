---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.27.0"
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
> **Ref rule:** if the project has a repo, include a pointer to its `README` or `CHANGELOG` in the `Next` column so agents can dig without guessing paths.

| Project | Status | Next |
|---------|--------|------|
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs |
| **Centralized Hooks** | ✅ Pre+Post hook split complete; k-hook v2.13.0, k-claude v2.12.0 | maintain via `make audit` |
| **Optimization map** | ✅ `k-optim` v1.6.0 — home media dirs policy added; Downloads/Documents/Pictures emptied | maintain; log future cleanup actions |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools · `$HOME/Work/AI/MCPs/mem_mcp/README.md` |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test | see `references/agentic-architecture-brainstorm.md` |
| **OpenClaw** | ✅ gateway restored; local Ollama unified on `127.0.0.1:11434`; default model is `phi4-mini:latest` | keep Telegram disabled until token exists |
| **dot_guard** | ⏸️ DISABLED — `rm` wrapper causes subshell fn-not-found (`_dg_backup_check`); project needs redesign | redesign: drop shell-fn wrapping, replace with safer approach · `$HOME/Work/sh/dot_guard/` |
| **[ARCHIVE]** | Stable/completed items condensed | QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> **Ref rule:** cite commit hashes, file paths, or repo links when touching a project — makes entries self-contained for future agents who need to dig.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-04 | [CLAUDE] | v2.27.0 — dot_guard disabled in `.kshrc`; k-context: ref rule + dotguard project row; Active Projects consolidated |
| 2026-04-04 | [CLAUDE] | v2.26.0 — k-claude v2.12.0 (post_tool_use.py desync fix); OpenClaw handler.ts Python indent fixed; README Gemini no-AfterTool note |
| 2026-04-04 | [CLAUDE] | v2.25.0 — `.agents/` pushed (677bc15); tg.md desync eliminated from tutos_live; tools.md path fix |
| 2026-04-04 | [CLAUDE] | v2.24.0 — PostToolUse advisory hook: `post_tool_use.py` created, k-hook v2.13.0 + k-claude v2.11.0; bw-env README improved; ollama-ipex push confirmed |
| 2026-04-04 | [CODEX] | v2.23.1 — OpenClaw gateway restored: Telegram token removed, port `18789` healthy, `phi4-mini:latest` validated |
| 2026-04-04 | [CLAUDE] | v2.23.0 — bw-env fully delivered: 4 hot-path bw status→RAM (4s→226ms), tray timeout+30s poll; install.sh+purge.sh pushed |
| 2026-04-04 | [CODEX] | v2.22.1 — OpenClaw config repaired: Ollama endpoint unified on `127.0.0.1:11434`, `phi4-mini:latest` |
| 2026-04-04 | [CODEX] | v2.22.0 — `ollama-ipex` switches native/IPEX on shared `11434` endpoint; editable CLI |
| 2026-04-04 | [CLAUDE] | v2.21.0 — bw-env: .agent/→.agents/ migration; install.sh+purge.sh sandbox-validated |
| 2026-04-04 | [CLAUDE] | v2.20.0 — bw-env install.sh: bw CLI auto-install, .env config, systemd sync daemon, GUI tray |
| [SUMMARY] | — | v2.19.0–v2.16.0: media cleanup, k-optim v1.6.0–v1.4.0, hooks audit, AGENTS.md cleaned, lean hook rollout |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.27.0 — dot_guard disabled; ref rule added to Active Projects + Session Log; dotguard project row added |
| 2026-04-04 | [CLAUDE] | v2.26.0 — k-claude desync fix, OpenClaw indent bug, README Gemini note |
| [SUMMARY] | — | v1.0.0–v2.25.0: prior maintenance, PostToolUse hook, bw-env, tg.md desync, OpenClaw repair, ollama-ipex, and older entries condensed. |

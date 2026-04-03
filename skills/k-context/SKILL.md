---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.18.0"
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
| **Optimize bw-env** | YES | NO | [ALL] | Improve resource impact (RAM/CPU) and optimize bridge management. |
| *(none)* | | | | |

## Active Projects

> Limit: max 10 active rows.
> Only when full, condense stale/completed items into one short bounded `[ARCHIVE]` row.

| Project | Status | Next |
|---------|--------|------|
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs |
| **Centralized Hooks** | ✅ lean per-turn reminder, `SKILL.md` write guard, delayed finalization, hooks audit, compact runtime docs rolled out | maintain via `make audit` |
| **Optimization map** | ✅ `k-optim` v1.5.0 — home cleanup done (22 entries, ~1.3GB), Ubuntu LKS + Script Log updated | log future cleanup actions in k-optim |
| **QMD post-commit hygiene** | ✅ non-blocking hook pattern propagated | watch for future repos still using blocking embed-on-commit |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools |
| **$HOME/.agents/ refonte** | ✅ normalized, committed, and pushed | maintain and avoid drift |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test, roadmap | see `references/agentic-architecture-brainstorm.md` |
| **OpenClaw** | skills fixed (rsync copies), exec-approvals ask=always | file-edit approval gates (if OpenClaw adds support) |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-03 | [CLAUDE] | v2.18.0 — home cleanup: 22 debris entries removed (~1.3GB); hooks audit: skill_edit_guard:129 fixed, settings.json PreToolUse indentation fixed; k-optim v1.5.0 updated with Ubuntu LKS + Script Log |
| 2026-04-03 | [CLAUDE] | v2.17.0 — AGENTS.md cleaned (6 redundancies); k-optim v1.4.0 (max-7 LKS rule, Meta/Ubuntu/Homelab scope, load-before-optim standard) |
| 2026-04-03 | [CODEX] | v2.16.10 — aligned session-log guard: `[SUMMARY]` optional until 10-entry limit |
| 2026-04-03 | [CODEX] | v2.16.8 — k-optim: proactive AI history cleanup suggestion with KπX approval gate |
| 2026-04-03 | [CODEX] | v2.16.7 — explicit history/session pointers added to runtime skills; low-token doc rule added to k-optim |
| 2026-04-03 | [CODEX] | v2.16.6 — k-hook and runtime skills compacted; hook docs point to hooks/README.md |
| 2026-04-03 | [CODEX] | v2.16.5 — removed pycache artifacts; cleaned stale audit-path wording |
| 2026-04-03 | [CODEX] | v2.16.4 — fixed stale Claude/Codex write-guard inversion in k-hook |
| 2026-04-03 | [CODEX] | v2.16.3 — shared audit entrypoint moved to hooks/audit.py; hook docs resynced |
| [SUMMARY] | — | v2.16.2–v2.16.0: dead Codex PreToolUse path removed, OpenClaw path-guard synced, lean hook architecture rollout |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CLAUDE] | v2.18.0 — session log + Active Projects updated for home cleanup + hooks fixes |
| 2026-04-03 | [CLAUDE] | v2.17.0 — session log updated for AGENTS.md cleanup + k-optim v1.4.0 |
| [SUMMARY] | — | v1.0.0–v2.16.11: prior session-log maintenance and historical entries condensed. |

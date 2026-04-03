---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.16.11"
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
| **Centralized Hooks** | ✅ lean per-turn reminder, `SKILL.md` write guard, delayed finalization, top-level hooks audit, compact source-of-truth-first runtime docs, and explicit runtime-history pointers rolled out | maintain via `make audit` and runtime smoke checks after schema changes |
| **Optimization map** | ✅ `k-optim` created for `.agents/`, QMD, Ubuntu cleanup posture, and proactive AI-history cleanup suggestions gated by user approval | extend Homelab section when the server side is formalized |
| **QMD post-commit hygiene** | ✅ non-blocking hook pattern propagated to templates and active Work repos | watch for future repos still using blocking embed-on-commit |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools |
| **$HOME/.agents/ refonte** | ✅ normalized, committed, and pushed; `k-qmd` compacted, `k-openclaw` compacted, `make audit` + `make help` available | maintain and avoid drift |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test, roadmap | see `references/agentic-architecture-brainstorm.md` |
| **OpenClaw** | skills fixed (rsync copies), exec-approvals ask=always | file-edit approval gates (if OpenClaw adds support) |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-03 | [CODEX] | v2.16.10 — aligned the session-log guard with the new rule: `[SUMMARY]` is now optional until the 10-entry limit is actually reached. |
| 2026-04-03 | [CODEX] | v2.16.8 — updated `k-optim` so optimization work now explicitly includes proactively suggesting AI chat/session-history cleanup when relevant, while waiting for KπX approval before any destructive history action. |
| 2026-04-03 | [CODEX] | v2.16.7 — added explicit history/session pointers to the runtime skills (`k-claude`, `k-gemini`, `k-codex`, `k-copilot`, `k-vibe`, `k-openclaw`, `k-ai`), compacted a few remaining verbose sections, and added the same low-token documentation rule to `k-optim`. |
| 2026-04-03 | [CODEX] | v2.16.6 — compacted `k-hook` and the runtime skills so hook docs point to `hooks/README.md` and the owning runtime configs. |
| 2026-04-03 | [CODEX] | v2.16.5 — removed lingering pycache artifacts after the audit move and cleaned the stale historical audit-path wording. |
| 2026-04-03 | [CODEX] | v2.16.4 — fixed the stale Claude/Codex write-guard inversion in `k-hook`’s runtime table. |
| 2026-04-03 | [CODEX] | v2.16.3 — moved the shared audit entrypoint to `$HOME/.agents/hooks/audit.py` and resynced the hook docs. |
| 2026-04-03 | [CODEX] | v2.16.2 — removed the dead Codex `PreToolUse` path, aligned Claude `PreToolUse`, and synced the OpenClaw path-guard manifest. |
| 2026-04-03 | [CODEX] | v2.16.1 — added `hooks/README.md` and documented where each checker is really wired versus advisory or absent. |
| 2026-04-03 | [CODEX] | v2.16.0 — completed the lean hook architecture rollout with centralized feature flags, lighter reminders, and delayed `.agents/` finalization. |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.16.11 — removed duplicated global reminders from the top of `k-context` so response-structure and log-limit rules now live only in `AGENTS.md` and directly above the local sections that use them |
| 2026-04-03 | [CODEX] | v2.16.10 — expanded the oversized session-log summary into real entries up to the intended 10-entry capacity and aligned the structure guard so `[SUMMARY]` is no longer required before that limit |
| [SUMMARY] | — | v1.0.0–v2.16.9: prior session-log maintenance and historical entries condensed after structural normalization to the AGENTS-defined limits. |

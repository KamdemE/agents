---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.15.0"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> **RESPONSE FOOTER:** At the end of every message, agents MUST follow the AGENTS-defined footer order: `Commentaires/Comments`, `Remarques/Remarks`, `TODOs`, then at least 3 proactive suggestions.
> TODOs: only KπX adds; agents execute + remove.
> Projects: max 10 active — condense completed/stale into a fixed-width `[ARCHIVE]` row when full.
> Log: max 10 entries, newest-first — condense oldest into `[SUMMARY]` when full.
> **Brainstorms & research:** `references/` — load on demand for deep context.
> **Visual reference asset:** `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.

## Active TODOs

| Task | IMPORTANT | URGENT | CONCERNED | Description |
|------|-----------|--------|-----------|-------------|
| **Implement Agent Hooks** | YES | YES | [ALL] | Create agent-specific hooks in `hooks/` based on the Python models in `hooks/gemini/`. |
| **Optimize bw-env** | YES | NO | [ALL] | Improve resource impact (RAM/CPU) and optimize bridge management. |
| *(none)* | | | | |

## Active Projects

| Project | Status | Next |
|---------|--------|------|
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs |
| **Centralized Hooks** | ✅ wrappers aligned, audit target added, governance stable | maintain via `make audit` |
| **Optimization map** | ✅ `k-optim` created for `.agents/`, QMD, and Ubuntu cleanup posture | extend Homelab section when the server side is formalized |
| **QMD post-commit hygiene** | ✅ non-blocking hook pattern propagated to templates and active Work repos | watch for future repos still using blocking embed-on-commit |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools |
| **$HOME/.agents/ refonte** | ✅ normalized, committed, and pushed; `k-qmd` compacted, `k-openclaw` compacted, `make audit` + `make help` available | maintain and avoid drift |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test, roadmap | see `references/agentic-architecture-brainstorm.md` |
| **OpenClaw** | skills fixed (rsync copies), exec-approvals ask=always | file-edit approval gates (if OpenClaw adds support) |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log
| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-03 | [CODEX] | v2.15.0 — propagated the non-blocking QMD post-commit pattern to the `k-qmd` template, the active `tutos_live` and `presentation` hooks, the `k_ai` installer, extended `k-optim` with the first real Homelab section, and linked `k-optim` from the runtime and homelab skills that should defer to it. |
| 2026-04-03 | [CODEX] | v2.14.0 — created `k-optim`, linked it from `AGENTS.md` and `k-workspace`, grounded its Ubuntu section in the real cleanup scripts under `$HOME/Work/sh/clean/`, and continued the QMD/OpenClaw cleanup pass. |
| 2026-04-03 | [CODEX] | v2.13.0 — audited live QMD collections, tightened polluted patterns for Codex/Gemini/Copilot/VIBE, compacted `k-openclaw`, added `make help`, and finalized the `.agents/` repo state after the last governance pass. |
| 2026-04-03 | [CODEX] | v2.12.1 — removed the last stale `k-context` wording that skipped `Remarques/Remarks`, deleted the unused legacy hook script, and revalidated the hook/skill surface after the final cleanup pass. |
| 2026-04-03 | [CODEX] | v2.12.0 — finalized the hook rollout by wiring and documenting Claude/Codex/Gemini/OpenClaw consistently, hardening `response_validator` for Markdown-heading sections, adding wrapper smoke tests to `hooks/core/audit.py`, and refreshing the key runtime skills plus `k-hook` to the real source-of-truth state. |
| 2026-04-03 | [CODEX] | v2.11.0 — restored `k-skill-creator` as the explicit baseline fork, tightened hook/AGENTS/hook-skill documentation around generic core plus thin wrappers, and closed the remaining bundled-file coverage gaps surfaced by the shared guards. |
| 2026-04-03 | [CODEX] | v2.10.0 — added the mandatory `Remarques/Remarks` response contract to `AGENTS.md` and `response_validator`, normalized `.agents/` paths to `$HOME`, repaired remaining skill-structure drift across key skills, references, assets, and INIT, and revalidated the whole KπX skill set against the shared structure guard. |
| 2026-04-03 | [CODEX] | v2.9.0 — aligned `AGENTS.md` with hook validators, renamed `qmd` → `k-qmd` and `skill-creator` → `k-skill-creator`, added `hooks/core/skill_structure_guard.py`, and condensed `k-context` to the AGENTS-defined structural limits. |
| 2026-04-03 | [CODEX] | v2.8.12 — extended hook dynamic-context to inject a 4-line block on each turn: date, time, shell-style `user@machine`, and current working directory from the event `cwd` when available. |
| 2026-04-03 | [CODEX] | v2.8.11 — rewrote `k-vscode` into a stable source-of-truth map (paths, scripts, references, operational rules), confirmed no broken `references/` symlinks across skills, and removed the stray `%24HOME`-escaped VSCode workspace entry. |
| [SUMMARY] | — | 2026-04-03 v2.15.0–v2.8.8: non-blocking QMD post-commit propagation, `k-optim`, QMD collection hygiene, hook rollout completion, audit hardening, final legacy cleanup, dynamic-context enrichment, and VSCode/profile work. 2026-04-02 v2.8.4–v2.8.1: Codex/Ollama timeout and warmup diagnosis and fixes. 2026-04-01 v2.8.0–v2.3.0: Project Sovereignty docs, hook modularization, centralized hook manager, and cleanup. 2026-03-29 and earlier: `.agents/` refonte, k-* skill standardization, qmd integration, OpenClaw/Codex skill sync, and earlier session history condensed. |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.15.0 — session log updated for the QMD post-commit propagation pass, the new Homelab section in `k-optim`, and the runtime-skill pointers toward `k-optim` |
| 2026-04-03 | [CODEX] | v2.14.0 — session log updated for the `k-optim` creation, AGENTS/workspace propagation, and the continuing QMD/OpenClaw cleanup pass |
| [SUMMARY] | — | v1.0.0–v2.14.0: prior session-log maintenance and historical entries condensed after structural normalization to the AGENTS-defined `max 2 + [SUMMARY]` format. |

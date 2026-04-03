---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.12.1"
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
| **Centralized Hooks** | ✅ Gemini/Codex/Claude/OpenClaw wrappers aligned; core audit in place | git commit + make push |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools |
| **$HOME/.agents/ refonte** | ✅ AGENTS + hooks + skills + refs/assets normalized: `Remarques` contract added, changelog guard propagated, `$HOME` sweep completed, footer formats unified | git commit + make push |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test, roadmap | see `references/agentic-architecture-brainstorm.md` |
| **OpenClaw** | skills fixed (rsync copies), exec-approvals ask=always | file-edit approval gates (if OpenClaw adds support) |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log
| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-03 | [CODEX] | v2.12.1 — removed the last stale `k-context` wording that skipped `Remarques/Remarks`, deleted the unused legacy hook script, and revalidated the hook/skill surface after the final cleanup pass. |
| 2026-04-03 | [CODEX] | v2.12.0 — finalized the hook rollout by wiring and documenting Claude/Codex/Gemini/OpenClaw consistently, hardening `response_validator` for Markdown-heading sections, adding wrapper smoke tests to `hooks/core/audit.py`, and refreshing the key runtime skills plus `k-hook` to the real source-of-truth state. |
| 2026-04-03 | [CODEX] | v2.11.0 — restored `k-skill-creator` as the explicit baseline fork, tightened hook/AGENTS/hook-skill documentation around generic core plus thin wrappers, and closed the remaining bundled-file coverage gaps surfaced by the shared guards. |
| 2026-04-03 | [CODEX] | v2.10.0 — added the mandatory `Remarques/Remarks` response contract to `AGENTS.md` and `response_validator`, normalized `.agents/` paths to `$HOME`, repaired remaining skill-structure drift across key skills, references, assets, and INIT, and revalidated the whole KπX skill set against the shared structure guard. |
| 2026-04-03 | [CODEX] | v2.9.0 — aligned `AGENTS.md` with hook validators, renamed `qmd` → `k-qmd` and `skill-creator` → `k-skill-creator`, added `hooks/core/skill_structure_guard.py`, and condensed `k-context` to the AGENTS-defined structural limits. |
| 2026-04-03 | [CODEX] | v2.8.12 — extended hook dynamic-context to inject a 4-line block on each turn: date, time, shell-style `user@machine`, and current working directory from the event `cwd` when available. |
| 2026-04-03 | [CODEX] | v2.8.11 — rewrote `k-vscode` into a stable source-of-truth map (paths, scripts, references, operational rules), confirmed no broken `references/` symlinks across skills, and removed the stray VSCode workspace entry `file:///home/kpihx/%24HOME`. |
| 2026-04-03 | [CODEX] | v2.8.10 — finalized `k-vscode` audit: executable helper scripts validated, the last ambiguous legacy `Default` mention removed, and remaining live base settings documented explicitly. |
| 2026-04-03 | [CODEX] | v2.8.9 — created reusable `k-vscode` scripts for profile-registry updates and extensions generation, updated the skill to reflect the real inheritance state, and identified one suspicious VSCode workspace association: `file:///home/kpihx/%24HOME`. |
| 2026-04-03 | [CODEX] | v2.8.8 — fixed invalid YAML frontmatter in `k-context`/`k-vscode`, renamed the VSCode profile export to `general.code-profile`, and normalized `k-vscode` profile-registry examples. |
| [SUMMARY] | — | 2026-04-03 v2.12.1–v2.8.7: hook rollout completion, audit hardening, validator improvements, final legacy cleanup, dynamic-context enrichment, and VSCode/profile work. 2026-04-02 v2.8.4–v2.8.1: Codex/Ollama timeout and warmup diagnosis and fixes. 2026-04-01 v2.8.0–v2.3.0: Project Sovereignty docs, hook modularization, centralized hook manager, and cleanup. 2026-03-29 and earlier: `.agents/` refonte, k-* skill standardization, qmd integration, OpenClaw/Codex skill sync, and earlier session history condensed. |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.12.1 — session log updated after the final hook cleanup pass removed the unused legacy script and aligned `k-context` wording with the AGENTS-defined footer order |
| 2026-04-03 | [CODEX] | v2.12.0 — session log updated after finishing the multi-agent hook rollout, hardening the shared validator/audit path, and synchronizing the runtime skills plus `k-hook` with the real deployed wrapper/config state |
| [SUMMARY] | — | v1.0.0–v2.11.0: prior session-log maintenance and historical entries condensed after structural normalization to the AGENTS-defined `max 2 + [SUMMARY]` format. |

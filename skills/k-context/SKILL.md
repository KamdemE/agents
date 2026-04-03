---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.15.5"
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
| **Centralized Hooks** | ✅ wrappers aligned, centralized feature flags added, runtime configs normalized where safe | maintain via `make audit` and runtime smoke checks after schema changes |
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
| 2026-04-03 | [CLAUDE] | v2.15.5 — reformatted `$HOME/.agents/hooks/core/session_guard.py`: decomposed long list comprehension (L76) and aerated `subprocess.run` kwargs to one-per-line with trailing comma. |
| 2026-04-03 | [CODEX] | v2.15.4 — polished `hooks/core/settings.py` for readability by aligning the feature-flag booleans and rewriting the `path_generalization` comment to stay compliant with the `$HOME/$USER` rule without touching the guard logic itself. |
| [SUMMARY] | — | 2026-04-03 v2.15.3–v2.8.8: `settings.py` readability polish, workspace drift cleanup, safe runtime-config normalization to `$HOME`, multi-agent wrapper conformity pass, centralized hook feature flags, Codex hook wire-contract fix, non-blocking QMD post-commit propagation, `k-optim`, QMD collection hygiene, hook rollout completion, audit hardening, final legacy cleanup, dynamic-context enrichment, and VSCode/profile work. 2026-04-02 v2.8.4–v2.8.1: Codex/Ollama timeout and warmup diagnosis and fixes. 2026-04-01 v2.8.0–v2.3.0: Project Sovereignty docs, hook modularization, centralized hook manager, and cleanup. 2026-03-29 and earlier: `.agents/` refonte, k-* skill standardization, qmd integration, OpenClaw/Codex skill sync, and earlier session history condensed. |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CLAUDE] | v2.15.5 — session log updated for `hooks/core/session_guard.py` indentation reformat (list comprehension + subprocess.run kwargs) |
| 2026-04-03 | [CODEX] | v2.15.4 — session log updated for the final `hooks/core/settings.py` readability pass and the compliant wording fix around `path_generalization` |
| [SUMMARY] | — | v1.0.0–v2.15.3: prior session-log maintenance and historical entries condensed after structural normalization to the AGENTS-defined `max 2 + [SUMMARY]` format. |

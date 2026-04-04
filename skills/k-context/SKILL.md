---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.32.9"
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
| **OpenClaw** | ✅ gateway restored; local Ollama unified on `127.0.0.1:11434`; default model is `phi4-mini:latest` | keep Telegram disabled until token exists · `$HOME/.openclaw/` |
| **dot_guard** | ⏸️ DISABLED — `rm` wrapper causes subshell fn-not-found; needs redesign | redesign: drop shell-fn wrapping · `$HOME/Work/sh/dot_guard/` |
| **[ARCHIVE]** | Stable/completed items condensed | QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-04 | [CLAUDE] | v2.32.9 — hardened AfterAgent cancel-loop fix: skip validation when response has no section markers (covers partial + meta-retry) · `$HOME/.agents/hooks/gemini/after_agent.py` |
| 2026-04-04 | [CLAUDE] | v2.32.8 — initial AfterAgent cancel-loop fix: skip on empty/cancelled `prompt_response` · `$HOME/.agents/hooks/gemini/after_agent.py` |
| 2026-04-04 | [CODEX] | v2.32.7 — removed active qmd MCP entries from Claude, Copilot, Gemini, and OpenClaw configs; QMD is now CLI-only across runtimes |
| 2026-04-04 | [CODEX] | v2.32.6 — added `$HOME/.agents/skills/k-qmd/scripts/qmdr` and made `qmdr` the explicit safe entrypoint for important QMD calls |
| 2026-04-04 | [CODEX] | v2.32.5 — `k-codex` now requires a frontmatter re-read/validation after any `SKILL.md` header edit |
| 2026-04-04 | [CODEX] | v2.32.4 — `k-qmd` freshness gate explicit: check `qmd status`, run `qmd embed` if `Pending > 0` before important queries |
| 2026-04-04 | [CODEX] | v2.32.3 — AGENTS documentation reflex routes new knowledge to `tutos_live/` (Ubuntu) or `presentation/` (homelab) |
| 2026-04-04 | [CODEX] | v2.32.2 — shared QMD `post-commit` hook skips cleanly when repo has no active collection |
| 2026-04-04 | [CODEX] | v2.32.1 — QMD doc clarified: first Vulkan rebuild may print a CPU/no-GPU warning; steady-state check is `qmd status` |
| 2026-04-04 | [CODEX] | v2.32.0 — AGENTS now states each agent owns and must auto-update its own `k-<agent>` runtime skill |
| [SUMMARY] | — | v2.31.0–v2.21.0: QMD provenance hardening, QMD lean cleanup, project rule, dot_guard disable, k-claude hook work, bw-env rollout, OpenClaw repair, and older maintenance |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.32.9 — hardened AfterAgent cancel-loop fix: no-section-marker guard added |
| 2026-04-04 | [CLAUDE] | v2.32.8 — initial AfterAgent cancel-loop fix + session log/changelog condensed |
| [SUMMARY] | — | v2.32.7–v1.0.0: CLI-only QMD shift, `qmdr` wrapper, Codex frontmatter-safety, QMD freshness gate, doc routing, agent-memory rule, QMD provenance hardening, project rule, dot_guard disable, PostToolUse hook, bw-env, OpenClaw repair, and older entries condensed. |

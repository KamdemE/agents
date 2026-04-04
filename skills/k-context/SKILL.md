---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.38.0"
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
| **dot_guard** | ⏸️ DISABLED — `rm` wrapper causes subshell fn-not-found; needs redesign | redesign: drop shell-fn wrapping · `$HOME/Work/sh/dot_guard/` |
| **[ARCHIVE]** | Stable/completed items condensed | QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-04 | [CLAUDE] | v2.38.0 — fix session_guard.py deleted-file crash; clean k-openclaw from claude.json skillUsage; stop hook loop root cause identified (missing `:` in section headers) |
| 2026-04-04 | [CLAUDE] | v2.37.0 — full OpenClaw purge: 5 SKILL.md YAML fixes, clawhub/clawdhub/mcporter/nanoclaw removed, hooks purged, k-openclaw→deactive · `$HOME/.agents/skills/` |
| 2026-04-04 | [CLAUDE] | v2.34.1 — bw_env robustness: tray_app.py silent-button fix, control_center timeout=30, sync-daemon log_warn→log_sys; committed+pushed · `$HOME/Work/sh/bw_env/` |
| 2026-04-04 | [CODEX] | v2.36.0 — retired OpenClaw from active context map, moved durable notes to deactivated skill archive · `$HOME/.agents/skills/` |
| 2026-04-04 | [CLAUDE] | v2.33.0 — renamed `bw-env/` → `bw_env/`; updated all path refs · `$HOME/Work/sh/bw_env/` |
| 2026-04-04 | [CLAUDE] | v2.32.9 — hardened AfterAgent cancel-loop fix · `$HOME/.agents/hooks/gemini/after_agent.py` |
| 2026-04-04 | [CODEX] | v2.32.7 — removed active qmd MCP entries from Claude, Copilot, Gemini; QMD is CLI-only |
| 2026-04-04 | [CODEX] | v2.32.6 — added `qmdr` as explicit freshness-safe QMD entrypoint · `$HOME/.agents/skills/k-qmd/scripts/` |
| 2026-04-04 | [CODEX] | v2.32.5 — `k-codex` requires frontmatter re-read/validation after any SKILL.md header edit |
| 2026-04-04 | [CODEX] | v2.32.4 — `k-qmd` freshness gate: check `qmd status`, run `qmd embed` if `Pending > 0` |
| [SUMMARY] | — | v2.32.3–v2.21.0: AGENTS doc routing, QMD hook skip, agent-owned k-agent rule, QMD provenance hardening, QMD lean cleanup, project rule, dot_guard disable, k-claude hook work, bw-env rollout, older maintenance |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.38.0 — fix session_guard.py deleted-file crash; clean k-openclaw from claude.json; stop hook loop root cause (missing `:` in section headers) |
| 2026-04-04 | [CLAUDE] | v2.37.0 — OpenClaw purge complete + 5 SKILL.md YAML fixes (Codex over-indent bug) |
| [SUMMARY] | — | v2.35.2–v1.0.0: exa-only MCPs, bw-env robustness/rename, AfterAgent fix, Ollama benchmark, CLI-only QMD, qmdr, Codex frontmatter, QMD freshness, doc routing, agent-memory, QMD provenance, project rule, dot_guard, PostToolUse hook, and older |

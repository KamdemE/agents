---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.35.0"
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
| **OpenClaw** | ✅ lean local-only defaults applied; `phi4-mini:latest` remains default; `gemma3:4b` removed; only `exa` stays in `mcporter.json`; `session-memory` disabled | reopen the TUI on a fresh session after runtime edits and keep Telegram disabled until token exists · `$HOME/.openclaw/` |
| **dot_guard** | ⏸️ DISABLED — `rm` wrapper causes subshell fn-not-found; needs redesign | redesign: drop shell-fn wrapping · `$HOME/Work/sh/dot_guard/` |
| **[ARCHIVE]** | Stable/completed items condensed | QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full, condense older entries into one short bounded `[SUMMARY]` row.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-04 | [CODEX] | v2.35.0 — disabled OpenClaw `session-memory`, wiped the polluted active session, reduced stale model/session carry-over, and fixed the stale `qwen2.5:latest` preload doc to `qwen2.5-coder:3b` · `$HOME/.openclaw/` |
| 2026-04-04 | [CODEX] | v2.34.2 — reduced OpenClaw MCPs to `exa` only in `$HOME/.openclaw/workspace/config/mcporter.json` to keep the runtime minimal · `$HOME/.openclaw/` |
| 2026-04-04 | [CLAUDE] | v2.34.1 — bw_env robustness: tray_app.py silent-button fix, control_center timeout=30, sync-daemon log_warn→log_sys, install.sh bw-login step 1.5; committed+pushed · `$HOME/Work/sh/bw_env/` |
| 2026-04-04 | [CODEX] | v2.34.0 — k-ollama benchmark memo, lean OpenClaw defaults, removed `gemma3:4b` from active local set · `$HOME/.agents/skills/k-ollama/` |
| 2026-04-04 | [CODEX] | v2.33.1 — benchmarked `phi4-mini`, `llama3.1:8b`, `qwen2.5-coder:3b`, and `gemma3:4b` on Ollama IPEX + OpenClaw; `phi4-mini` remains best default · `$HOME/.openclaw/` |
| 2026-04-04 | [CLAUDE] | v2.33.0 — renamed `bw-env/` → `bw_env/`; updated all path refs across project and `.kshrc` · `$HOME/Work/sh/bw_env/` |
| 2026-04-04 | [CLAUDE] | v2.32.9 — hardened AfterAgent cancel-loop fix: skip validation when response has no section markers · `$HOME/.agents/hooks/gemini/after_agent.py` |
| 2026-04-04 | [CLAUDE] | v2.32.8 — initial AfterAgent cancel-loop fix: skip on empty/cancelled `prompt_response` · `$HOME/.agents/hooks/gemini/after_agent.py` |
| 2026-04-04 | [CODEX] | v2.32.7 — removed active qmd MCP entries from Claude, Copilot, Gemini, and OpenClaw configs; QMD is now CLI-only |
| 2026-04-04 | [CODEX] | v2.32.6 — added `$HOME/.agents/skills/k-qmd/scripts/qmdr` and made `qmdr` the explicit safe entrypoint |
| 2026-04-04 | [CODEX] | v2.32.5 — `k-codex` now requires a frontmatter re-read/validation after any `SKILL.md` header edit |
| 2026-04-04 | [CODEX] | v2.32.4 — `k-qmd` freshness gate explicit: check `qmd status`, run `qmd embed` if `Pending > 0` |
| [SUMMARY] | — | v2.32.3–v2.21.0: AGENTS doc routing, QMD hook skip, agent-owned k-agent rule, QMD provenance hardening, QMD lean cleanup, project rule, dot_guard disable, k-claude hook work, bw-env rollout, OpenClaw repair, and older maintenance |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v2.35.0 — logged the OpenClaw fresh-session cleanup and the stale `k-ollama` preload fix |
| 2026-04-04 | [CODEX] | v2.34.2 — logged the OpenClaw MCP reduction to `exa` only |
| [SUMMARY] | — | v2.34.1–v1.0.0: bw-env robustness, bw-env rename, AfterAgent fix, Ollama benchmark, CLI-only QMD, qmdr, Codex frontmatter, QMD freshness, doc routing, agent-memory, QMD provenance, project rule, dot_guard, PostToolUse hook, OpenClaw repair, and older. |

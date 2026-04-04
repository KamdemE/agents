---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.32.1"
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
| 2026-04-04 | [CODEX] | v2.32.1 — QMD doc clarified that the first Vulkan rebuild may print a temporary CPU/no-GPU warning; the real steady-state device check is `qmd status` |
| 2026-04-04 | [CODEX] | v2.32.0 — AGENTS now states that each agent owns and must auto-update its own `k-<agent>` runtime skill; `k-codex` learned the scoped escalation reflex for blocked commit/push operations |
| 2026-04-04 | [CODEX] | v2.31.0 — QMD provenance hardened: `references/qmd-optimization.md` expanded with Vulkan/hook checks, shared `post-commit` hook symlinked from `$HOME/Work/tutos_live/.git/hooks/` and `$HOME/Work/Homelab/presentation/.git/hooks/`, and VSCode exported profiles now point back to `$HOME/.agents/skills/k-vscode/references/` |
| 2026-04-04 | [CODEX] | v2.30.0 — QMD lean cleanup applied: raw runtime histories removed from `$HOME/.config/qmd/index.yml`; archive vectors purged; post-commit hook stays update-only by default |
| 2026-04-04 | [CLAUDE] | v2.28.0 — project rule added to preamble; folder paths on all Active Project rows; inline ref rules removed |
| 2026-04-04 | [CLAUDE] | v2.27.0 — dot_guard disabled (`$HOME/.kshrc`); dotguard project row added; Active Projects consolidated |
| 2026-04-04 | [CLAUDE] | v2.26.0 — k-claude v2.12.0; OpenClaw `$HOME/.agents/hooks/openclaw/path-guard/handler.ts` indent fixed; README Gemini note |
| 2026-04-04 | [CLAUDE] | v2.25.0 — `.agents/` pushed (677bc15); tg.md desync eliminated (`$HOME/Work/tutos_live/`); tools.md path fix |
| [SUMMARY] | — | v2.30.0–v2.21.0: QMD GPU-warning note, agent-memory rule, QMD provenance hardening, QMD redesign start, project rule, dot_guard disable, k-claude hook work, `.agents/` push, bw-env rollout, OpenClaw repair, and older maintenance |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v2.32.1 — logged the QMD runtime clarification that the first Vulkan rebuild can emit a temporary false CPU/no-GPU warning while `qmd status` remains the steady-state truth |
| 2026-04-04 | [CODEX] | v2.32.0 — logged the new agent-owned runtime-memory rule in AGENTS and the Codex-specific scoped-escalation learning for blocked commit/push work |
| [SUMMARY] | — | v2.31.0–v1.0.0: QMD provenance hardening, agent-memory rule, project rule, dot_guard disable, prior maintenance, PostToolUse hook, bw-env, tg.md desync, OpenClaw repair, k-claude fixes, and older entries condensed. |

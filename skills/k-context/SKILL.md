---
name: k-context
description: >
  KπX HOT context — load at EVERY session start.
  Active TODOs, current projects, and session log.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
allowed-tools: Bash(*), "*"
---

# KπX — Context

> HOT — load at every session start.
> TODOs: only KπX adds; agents execute + remove.
> Projects: max 10 active — condense completed/stale into a fixed-width `[ARCHIVE]` row when full.
> Log: max 10 entries, newest-first — condense oldest into `[SUMMARY]` when full.

## Active TODOs

- `git commit` + `make push` (`~/.agents/`)
- Install qmd post-commit hook in `~/Work/tutos_live/`
- `qmd context add` for `tutos_live` and `presentation` collections

## Active Projects

| Project | Status | Next |
|---------|--------|------|
| **~/.agents/ refonte** | ✅ v2.2.0 — k-* flat skills, KERNEL rules, qmd MCP, k-context | commit + push |
| **OpenClaw** | v2026.3.24 stable — Telegram, Mistral default, hooks pending | session-memory + command-logger hooks |
| **Edge Copilot sidebar** | Blank — cause unknown | MS account sign-in / flags |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log

| Date | Agent | Entry |
|------|-------|-------|
| 2026-03-28 | [CLAUDE] | ~/.agents/ v2.2.0: KERNEL rules (no-desync, concise md, .skill-lock sync, skill update mandate); qmd SKILL.md v2.3.0; session-guard → k-context; memory/ removed; k-context created |
| 2026-03-28 | [CLAUDE] | qmd MCP installed (npm-global, Node v24); post-commit template; skill-creator; k-soul+k-duties → KERNEL; skills flat k-* |
| 2026-03-28 | [CODEX] | OpenClaw: `thinkingDefault=off`, `tools.profile=full`, nomic-embed-text, Tailscale Serve, Gemini CLI OAuth, sessions cleaned |
| 2026-03-28 | [CLAUDE] | System: 38 zombie procs killed; UV 13.4GB + NPM purged; disk 87%→83% |
| 2026-03-27 | [CLAUDE] | k_ai deep-read: unified action model, tool governance, QMD semantic history, git exit hook |
| 2026-03-26 | [CLAUDE] | k_ai: LiteLLM routing fix, config sections renamed, lru_cache, ProviderTimeoutError, auth.py |
| 2026-03-25 | [CLAUDE] | ~/.agents/ v2.0→v2.1: COPILOT skill, QMD collection, Makefile, k-* flat structure |
| 2026-03-25 | [CLAUDE] | ~/.agents/ v2.0.0 refonte: KERNEL, INIT, 12 skills, symlinks, Stop hook, session-guard |
| [SUMMARY] | — | ≤2026-03-24: Chrome+OpenClaw; bw-env PID guard; Edge x11 fix; mail/whats/linkedin MCP; Zimbra; DXO accepted |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v1.1.0 — removed duplicate Arch/Patterns sections (live in KERNEL); TODOs populated; log condensed |
| [SUMMARY] | — | v1.0.0 — created from memory/ (context.md + dailylog.md + MEMORY.md) |

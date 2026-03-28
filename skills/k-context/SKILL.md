---
name: k-context
description: >
  KπX HOT context — load at EVERY session start.
  Active TODOs, current projects, and session log.
license: private
metadata:
  author: KpihX
  version: "1.2.0"
allowed-tools: Bash(*), "*"
---

# KπX — Context

> HOT — load at every session start.
> TODOs: only KπX adds; agents execute + remove.
> Projects: max 10 active — condense completed/stale into a fixed-width `[ARCHIVE]` row when full.
> Log: max 10 entries, newest-first — condense oldest into `[SUMMARY]` when full.

## Active TODOs

*(none)*

## Active Projects

| Project | Status | Next |
|---------|--------|------|
| **~/.agents/ refonte** | ✅ v3.0.0 committed — k-* flat skills, KERNEL compaction, 6 agent git+qmd repos | add remotes + push |
| **OpenClaw** | v2026.3.24 stable — Telegram, Mistral default, hooks pending | session-memory + command-logger hooks |
| **Edge Copilot sidebar** | Blank — cause unknown | MS account sign-in / flags |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log

| Date | Agent | Entry |
|------|-------|-------|
| 2026-03-28 | [CLAUDE] | INIT.md: removed Inject HOT Memory section; kernel symlinks fixed (codex/copilot/gemini were broken → ~/.agent/AGENT.md); ~/AGENTS.md + ~/VIBE.md deleted; skills audited (k-codex/vibe/gemini/homelab/git) — duplications and stale refs removed |
| 2026-03-28 | [CLAUDE] | ~/.agents/ v3.0.0: 6 agent dirs git-inited (.claude .codex .gemini .copilot .vibe .openclaw); qmd collections + context + post-commit hooks for all 6; tutos_live hook fixed (npm-global); agents post-commit hook fixed; qmd embed running |
| 2026-03-28 | [CLAUDE] | KERNEL: +6 agent qmd collections table; qmd context add for all 10 collections; tutos_live+presentation+agents+k-ai contexts added |
| 2026-03-28 | [CLAUDE] | ~/.agents/ v2.2.0: KERNEL rules (no-desync, concise md, .skill-lock sync, skill update mandate); qmd SKILL.md v2.3.0; session-guard → k-context; memory/ removed; k-context created |
| 2026-03-28 | [CLAUDE] | qmd MCP installed (npm-global, Node v24); post-commit template; skill-creator; k-soul+k-duties → KERNEL; skills flat k-* |
| 2026-03-28 | [CODEX] | OpenClaw: `thinkingDefault=off`, `tools.profile=full`, nomic-embed-text, Tailscale Serve, Gemini CLI OAuth, sessions cleaned |
| 2026-03-28 | [CLAUDE] | System: 38 zombie procs killed; UV 13.4GB + NPM purged; disk 87%→83% |
| 2026-03-27 | [CLAUDE] | k_ai deep-read: unified action model, tool governance, QMD semantic history, git exit hook |
| 2026-03-26 | [CLAUDE] | k_ai: LiteLLM routing fix, config sections renamed, lru_cache, ProviderTimeoutError, auth.py |
| 2026-03-25 | [CLAUDE] | ~/.agents/ v2.0→v2.1: COPILOT skill, QMD collection, Makefile, k-* flat structure |
| [SUMMARY] | — | ≤2026-03-25: ~/.agents/ v2.0.0 refonte; bw-env PID guard; Edge x11 fix; mail/whats/linkedin MCP; DXO accepted |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v1.2.0 — TODOs cleared (all done); log updated with 6 agent repos + qmd pipeline; projects table updated |
| [SUMMARY] | — | v1.0.0 created from memory/; v1.1.0 removed duplicate sections, populated TODOs |

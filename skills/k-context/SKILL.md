---
name: k-context
description: >
  KπX HOT context — load at EVERY session start.
  Active TODOs, current projects, and session log.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
allowed-tools: Bash(*), "*"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> TODOs: only KπX adds; agents execute + remove.
> Projects: max 10 active — condense completed/stale into a fixed-width `[ARCHIVE]` row when full.
> Log: max 10 entries, newest-first — condense oldest into `[SUMMARY]` when full.

## Active TODOs

*(none)*

## Active Projects

| Project | Status | Next |
|---------|--------|------|
| **~/.agents/ refonte** | ✅ v3.0.0 + k-project skill + agent runtime updates pushed | — |
| **OpenClaw** | skills fixed (rsync copies), exec-approvals ask=always | file-edit approval gates (if OpenClaw adds support) |
| **Edge Copilot sidebar** | Blank — cause unknown | MS account sign-in / flags |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log

| Date | Agent | Entry |
|------|-------|-------|
| 2026-03-29 | [CLAUDE] | k-project v1.0.0: naming conventions, init (uv/bun), AGENTS.md template, config.py/ts, pyproject.toml; Project Context added to k-claude/codex/gemini/copilot; KERNEL updated; committed + pushed |
| 2026-03-29 | [CLAUDE] | k-git v2.3.0: 3 Makefile templates (general/uv/npm-bun); k-homelab v1.4.0 SSH corrected; k-workspace v2.5.0 Tailscale table; all SKILL.md names uniformised k-* |
| 2026-03-29 | [GEMINI] | Fixed INIT.md paths (desync v3.0.0): `skills/agents/` → `skills/k-*/`. |
| 2026-03-29 | [CLAUDE] | OpenClaw: k-* skills symlinks→rsync copies (workspace root security fix); exec-approvals ask=always configured; INIT.md SYNC/COPY_TARGETS documented; k-openclaw SKILL.md v1.2.0 |
| 2026-03-29 | [CLAUDE] | k-duties + k-soul stale symlinks supprimés de ~/.codex/skills/ (fusionnés dans KERNEL) |
| 2026-03-28 | [CLAUDE] | INIT+hook: auto-sync skills Codex+OpenClaw via SYNC_TARGETS post-commit; KERNEL: mandate install → ~/.agents/skills/; tous KERNEL+skills symlinks vérifiés ✅ — commits 441e880→64b4bef |
| 2026-03-28 | [CLAUDE] | k-* skills full audit: desc élargies (codex/gemini/copilot/vibe/claude), duplications supprimées, ⚠️ edit reminder sur tous les SKILL.md, skill-creator +règle création, k-openclaw créé — commit cafbf9c |
| 2026-03-28 | [COPILOT] | OpenClaw workspace cleanup: `USER.md`, `IDENTITY.md`, `PLANNING.md`, `TOOLS.md` deleted; `SOUL.md` → `KERNEL.md`; `AGENTS.md` → `k-openclaw/SKILL.md`; `MEMORY.md` truncated to File Sharing Protocol |
| 2026-03-28 | [CLAUDE] | INIT.md: removed Inject HOT Memory section; kernel symlinks fixed (codex/copilot/gemini were broken → ~/.agent/AGENT.md); ~/AGENTS.md + ~/VIBE.md deleted; skills audited (k-codex/vibe/gemini/homelab/git) — duplications and stale refs removed |
| 2026-03-28 | [CLAUDE] | ~/.agents/ v3.0.0: 6 agent dirs git-inited (.claude .codex .gemini .copilot .vibe .openclaw); qmd collections + context + post-commit hooks for all 6; tutos_live hook fixed (npm-global); agents post-commit hook fixed; qmd embed running |
| 2026-03-28 | [CLAUDE] | KERNEL: +6 agent qmd collections table; qmd context add for all 10 collections; tutos_live+presentation+agents+k-ai contexts added |
| 2026-03-28 | [CLAUDE] | ~/.agents/ v2.2.0: KERNEL rules (no-desync, concise md, .skill-lock sync, skill update mandate); qmd SKILL.md v2.3.0; session-guard → k-context; memory/ removed; k-context created |
| 2026-03-28 | [CLAUDE] | qmd MCP installed (npm-global, Node v24); post-commit template; skill-creator; k-soul+k-duties → KERNEL; skills flat k-* |
| [SUMMARY] | — | ≤2026-03-28: OpenClaw thinkingDefault+profile=full config; system 38 zombie procs killed; k_ai deep-read + LiteLLM fix; ~/.agents/ v2.0→v2.1; ≤2026-03-25: refonte v2.0.0, bw-env PID guard, Edge x11 fix, mail/whats/linkedin MCP, DXO accepted |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v1.4.0 — log: k-project + agent runtime updates; projects table updated |
| 2026-03-29 | [CLAUDE] | v1.3.0 — session log updated (OpenClaw fixes); OpenClaw project status updated; log condensed to 10+SUMMARY |
| [SUMMARY] | — | v1.0.0 created from memory/; v1.1.0 removed duplicate sections, populated TODOs; v1.2.0 TODOs cleared, log updated |

---
name: k-context
description: >
  KπX HOT context — load at EVERY session start.
  Active TODOs, current projects, and session log.
license: private
metadata:
  author: KpihX
  version: "1.9.0"
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
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools |
| **~/.agents/ refonte** | ✅ committed+pushed: k-docker v1.4.0, k-project v1.9.0, k-homelab v1.6.0 | — |
| **OpenClaw** | skills fixed (rsync copies), exec-approvals ask=always | file-edit approval gates (if OpenClaw adds support) |
| **Edge Copilot sidebar** | Blank — cause unknown | MS account sign-in / flags |
| **DXO internship** | ✅ Accepted — "Stage Image Research" | Starts summer 2026 |

## Session Log

| Date | Agent | Entry |
|------|-------|-------|
| 2026-03-29 | [CLAUDE] | mem_mcp uv init+config.py+standard files+first push; 6 MCPs standardized (.agents/AGENTS.md, Makefile, LICENSE, .gitignore, pipelines green); Work/ Tools/ restructure (Others/, Tools/, ipynb-pdf+viperx moved); Gdrive kapoivha@gmail.com rclone+systemd setup; AGENTS.md +personal storage |
| 2026-03-29 | [CLAUDE] | k-docker v1.4.0 (CI uv/bun templates, shared Postgres, group vars, sync→legacy), k-project v1.9.0 (config.ts rewrite, Makefile rule, default email), k-homelab v1.6.0 (n8n-ops removal); presentation n8n-ops cleanup — all committed+pushed |
| 2026-03-29 | [GEMINI] | Finalized AGENTS.md rename: updated skills (qmd, vibe, gemini), INIT.md, and k-context log references; verified all agent symlinks point to AGENTS.md; deleted stale KERNEL references. |
| 2026-03-29 | [CLAUDE] | k-project v1.4.0: docs-site.md created (Docsify workflow, Pattern A/B, Makefile push-docs, link rules, checklist); skill descriptions audit + Docsify link rules documented in k-git-pages |
| 2026-03-29 | [CLAUDE] | k-project v1.2.0: config.py enriched (bw-env _resolve_env, SecretsUnavailableError, get_secret); pyproject.toml enriched (authors, license, [tool.uv]); k-git-pages skill created; tutos_live+presentation symlinks; AGENTS +External Template Dirs; 0-duplication achieved |
| 2026-03-29 | [CLAUDE] | k-project v1.0.0 + k-docker v1.0.0 created; agent runtime updated (k-claude/codex/gemini/copilot +Project Context); cv-atf in AGENTS; templates disclaimers |
| 2026-03-29 | [CLAUDE] | k-git v2.3.0: 3 Makefile templates (general/uv/npm-bun); k-homelab v1.4.0 SSH corrected; k-workspace v2.5.0 Tailscale table; SKILL.md names uniformised k-* |
| 2026-03-29 | [GEMINI] | Fixed INIT.md paths (desync v3.0.0): `skills/agents/` → `skills/k-*/`. |
| 2026-03-29 | [CLAUDE] | OpenClaw: k-* skills symlinks→rsync copies (workspace root security fix); exec-approvals ask=always; INIT.md SYNC/COPY_TARGETS documented; k-openclaw v1.2.0 |
| 2026-03-29 | [CLAUDE] | k-duties + k-soul stale symlinks supprimés de ~/.codex/skills/ (fusionnés dans AGENTS) |
| [SUMMARY] | — | ≤2026-03-28: ~/.agents/ v3.0.0 (6 agent git repos, qmd hooks); INIT+hook auto-sync skills (SYNC_TARGETS); k-* skills full audit (codex/gemini/copilot/vibe/claude); OpenClaw workspace cleanup; +qmd collections; v2.2.0 rules; qmd MCP; bw-env PID guard; Edge x11 fix; mail/whats/linkedin MCP; DXO accepted |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v1.9.0 — new entry: mem_mcp+6MCPs+Gdrive; projects: +mem_mcp; log condensed (12→10+SUMMARY) |
| 2026-03-29 | [CLAUDE] | v1.8.0 — session log: k-docker/project/homelab commits + presentation n8n-ops cleanup |
| 2026-03-29 | [CLAUDE] | v1.7.0 — log: docs-site.md + k-project v1.4.0; log condensed (11→10+SUMMARY); header version desync fixed |
| 2026-03-29 | [CLAUDE] | v1.6.0 — skill descriptions audit: k-homelab/qmd/k-project enriched; k-git-pages +Docsify link rules; homelab docker-compose headers restored |
| 2026-03-29 | [CLAUDE] | v1.5.0 — log: k-git-pages + symlinks + 0-duplication; log condensed to 10+SUMMARY |
| 2026-03-29 | [CLAUDE] | v1.4.0 — log: k-project + agent runtime updates; projects table updated |
| 2026-03-29 | [CLAUDE] | v1.3.0 — session log updated (OpenClaw fixes); OpenClaw project status updated; log condensed to 10+SUMMARY |
| [SUMMARY] | — | v1.0.0 created from memory/; v1.1.0 removed duplicate sections, populated TODOs; v1.2.0 TODOs cleared, log updated |

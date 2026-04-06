---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.68.0"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> TODOs: only KπX adds; agents execute + remove.
> **Project rule:** before touching any project — if not already in context — read its folder's `.md` files in order: `AGENTS.md` → `CHANGELOG` → `README` → `TODO`. Never work on a project without knowing its current state. Project rows and session log entries include the folder path for this purpose.
> **Brainstorms & research:** `references/` — load on demand. **Durable ideas and in-flight project visions** (not yet promoted to a skill or `$HOME/Work/` doc) are stored there as standalone `.md` files; see also **AGENTS.md → Brainstorm & vision archive**.
> **Visual reference asset:** `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.

## Active TODOs

| Task | IMPORTANT | URGENT | CONCERNED | Description |
|------|-----------|--------|-----------|-------------|
| *(none)* | | | | |

## Active Projects

> Limit: max 20 active rows.
> Only when full, condense stale/completed items into one short bounded `[ARCHIVE]` row.

| Project | Status | Next · Folder |
|---------|--------|---------------|
| **sh (Phoenix)** | ✅ STABLE — v2.1.2 Universal Orchestrator — root Makefile, `ksh` dispatcher, multi-remote sync | `ksh status` · `$HOME/Work/sh/` |
| **ai_voice** | 📑 UNDERSTANDING — whisper-overlay fork | research state, propose AGENTS.md · `$HOME/Work/AI/ai_voice/` |
| **AppArmor Mitigation** | ✅ DONE (Option A) — unprivileged_userns → complain mode | Option B: custom profile ready · `$HOME/.agents/skills/k-context/references/apparmor-custom-profile.md` |
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs · `$HOME/.agents/assets/` |
| **Centralized Hooks** | ✅ Copilot VS Code runtime wrappers added + audit passing · k-codex/gemini/vibe changelogs fixed | all hooks tested · `$HOME/.agents/hooks/` |
| **Optimization map** | ✅ QMD lean-index cleanup applied; home media dirs policy added; Downloads/Documents/Pictures emptied | maintain hot-only indexing discipline · `$HOME/.config/qmd/` |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools · `$HOME/Work/AI/MCPs/mem_mcp/` |
| **mail workspace** | 🧠 BRAINSTORM — cli/mcp/admin/skill split for mail | scaffold + contracts + generator · `$HOME/Work/AI/mail/` |
| **sh_mcp** | 🧠 BRAINSTORM — agent sandbox MCP (homelab); future user-side **sh-exec** separate | vision · `$HOME/.agents/skills/k-context/references/sh-mcp-agent-sandbox-vision.md` · code TBD · `$HOME/Work/AI/MCPs/` |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test | `$HOME/.agents/references/` |
| **[ARCHIVE]** | Stable/completed items condensed | QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full: **transfer older entries to `references/log.md` FIRST**, then condense into one short bounded `[SUMMARY]` row here.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.
> **For deeper history:** consult `references/log.md` (unlimited archive, newest-first).

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-06 | [CLAUDE] | v2.67.0 — created `Work/AI/mail/` scaffold (cli/mcp/admin/skill split) and added durable mail tooling brainstorm in `references/mail-tooling-rewrite-brainstorm.md` · `$HOME/Work/AI/mail/` · `$HOME/.agents/skills/k-context/references/` |
| 2026-04-06 | [CLAUDE] | v2.66.0 — Session finalize: `k-tg` skill + `k-workspace` committed; k-context reconciled (**sh** Phoenix row + **sh_mcp** brainstorm `references/` restored) · `$HOME/.agents/` |
| 2026-04-06 | [GEMINI] | v2.63.0 — Phoenix Protocol v2.1.2: `$HOME/Work/sh/` root Makefile, multi-remote sync, `ksh` dispatcher, submodule alignment |
| 2026-04-06 | [CLAUDE] | v2.65.0 — `references/sh-mcp-agent-sandbox-vision.md` + AGENTS brainstorm archive pointer; Active Projects **sh_mcp** row · `$HOME/.agents/skills/k-context/` |
| 2026-04-05 | [COPILOT] | v2.64.0 — fixed k-context guard limits and explicitly logged tg repair context (uv editable reinstall from `$HOME/Work/Tools/tg`, `tg --help` + `tg user chats` verified) · `$HOME/.agents/skills/k-context/` |
| 2026-04-05 | [GEMINI] | v2.62.0 — Finalized maintenance window: Clean (21:30), Backup (22:00) every 2 days. Synchronized READMEs, systemd/ timers, and Makefiles across `sh/clean` and `sh/backup_restore`. |
| 2026-04-05 | [CLAUDE] | v2.61.0 — k-git `Makefile.git` + k-project: standard target **`run`** (not `test-run`); kernel sync · `$HOME/.agents/skills/k-git/` · `$HOME/.agents/skills/k-project/` |
| 2026-04-05 | [CLAUDE] | v2.60.0 — kernel finalization: committed pending k-code v4.1.2–v4.1.4 + k-context/log rotation; `make push` · `$HOME/.agents/` |
| 2026-04-05 | [CLAUDE] | v2.59.0 — k-code v4.1.4: compact single-line frontmatter `description` · `$HOME/.agents/skills/k-code/` |
| 2026-04-05 | [CLAUDE] | v2.58.0 — k-code v4.1.3: expanded skill `description` from full tree; corrected `references/profiles/` paths in SKILL body · `$HOME/.agents/skills/k-code/` |
| [SUMMARY] | — | older entries moved to `references/log.md`; historical baseline remains v2.32.9–v2.21.0 and prior |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-06 | [GEMINI] | v2.68.0 — Stability Validation: Resolved ENOSPC (Inotify) edit loops via global watcher exclusions; k-workspace/k-context integrity verified. |
| 2026-04-06 | [CLAUDE] | v2.67.0 — mail workspace scaffold in `Work/AI/mail/`; durable mail tooling brainstorm archived in `references/mail-tooling-rewrite-brainstorm.md` |
| 2026-04-06 | [CLAUDE] | v2.66.0 — Session finalize: `k-tg` + `k-workspace`; reconcile **sh** Phoenix + **sh_mcp** brainstorm refs; Session Log cap (v2.56–v2.55 → `references/log.md`) |
| [SUMMARY] | — | v2.66 session finalize; v2.65 sh-mcp brainstorm; v2.64 tg recovery; v2.63 Phoenix (GEMINI); v2.62 maintenance; v2.61 k-git run; v2.60.1 archive; v2.59–v2.53 k-code, .mcps, Gdrive, AGENTS + k-hook, audit, k-mail, hooks, backup-restore, Cursor, AppArmor, QMD |

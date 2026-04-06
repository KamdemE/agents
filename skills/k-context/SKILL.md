---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.65.0"
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
| **ai_voice** | 📑 UNDERSTANDING — whisper-overlay fork | research state, propose AGENTS.md · `$HOME/Work/AI/ai_voice/` |
| **AppArmor Mitigation** | ✅ DONE (Option A) — unprivileged_userns → complain mode | Option B: custom profile ready · `$HOME/.agents/skills/k-context/references/apparmor-custom-profile.md` |
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs · `$HOME/.agents/assets/` |
| **Centralized Hooks** | ✅ Copilot VS Code runtime wrappers added + audit passing · k-codex/gemini/vibe changelogs fixed | all hooks tested · `$HOME/.agents/hooks/` |
| **Optimization map** | ✅ QMD lean-index cleanup applied; home media dirs policy added; Downloads/Documents/Pictures emptied | maintain hot-only indexing discipline · `$HOME/.config/qmd/` |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools · `$HOME/Work/AI/MCPs/mem_mcp/` |
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
| 2026-04-06 | [CLAUDE] | v2.65.0 — `references/sh-mcp-agent-sandbox-vision.md` + AGENTS brainstorm archive pointer; Active Projects **sh_mcp** row · `$HOME/.agents/skills/k-context/` |
| 2026-04-05 | [COPILOT] | v2.64.0 — fixed k-context guard limits and explicitly logged tg repair context (uv editable reinstall from `$HOME/Work/Tools/tg`, `tg --help` + `tg user chats` verified) · `$HOME/.agents/skills/k-context/` |
| 2026-04-05 | [GEMINI] | v2.62.0 — Finalized maintenance window: Clean (21:30), Backup (22:00) every 2 days. Synchronized READMEs, systemd/ timers, and Makefiles across `sh/clean` and `sh/backup_restore`. |
| 2026-04-05 | [CLAUDE] | v2.61.0 — k-git `Makefile.git` + k-project: standard target **`run`** (not `test-run`); kernel sync · `$HOME/.agents/skills/k-git/` · `$HOME/.agents/skills/k-project/` |
| 2026-04-05 | [CLAUDE] | v2.60.0 — kernel finalization: committed pending k-code v4.1.2–v4.1.4 + k-context/log rotation; `make push` · `$HOME/.agents/` |
| 2026-04-05 | [CLAUDE] | v2.59.0 — k-code v4.1.4: compact single-line frontmatter `description` · `$HOME/.agents/skills/k-code/` |
| 2026-04-05 | [CLAUDE] | v2.58.0 — k-code v4.1.3: expanded skill `description` from full tree; corrected `references/profiles/` paths in SKILL body · `$HOME/.agents/skills/k-code/` |
| 2026-04-05 | [CLAUDE] | v2.57.0 — k-code v4.1.2: VS Code GitHub Copilot Chat history paths (`workspaceStorage/.../chatSessions`, `GitHub.copilot-chat/`) · `$HOME/.agents/skills/k-code/` |
| 2026-04-05 | [GEMINI] | v2.56.0 — Mass cleanup of legacy debris (.zcompdump, .wget-hsts, .keras, .wacli) and migrated MCP metadata (.livemem, .ticktick-mcp, .n8n-mcp, .k-vpn) following .mcps/ standard transition. |
| 2026-04-05 | [GEMINI] | v2.55.0 — Uniformized Gdrive casing (capital G) across .env files; removed legacy gdrive mount/folder debris. |
| [SUMMARY] | — | older entries moved to `references/log.md`; historical baseline remains v2.32.9–v2.21.0 and prior |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-06 | [CLAUDE] | v2.65.0 — `sh-mcp-agent-sandbox-vision.md`; AGENTS + SKILL pointers for k-context `references/` as brainstorm archive; Active Projects **sh_mcp** |
| 2026-04-05 | [COPILOT] | v2.64.0 — tg recovery trace in Session Log; guard limits intact |
| [SUMMARY] | — | v2.63 guard caps; v2.62 maintenance; v2.61 k-git run; v2.60.1 archive; v2.59 k-code; v2.58 profiles; v2.57 Copilot JSONL; v2.56 .mcps; v2.55 Gdrive; v2.54 AGENTS + k-hook; v2.53–v1.0.0: audit, k-mail, hooks, backup-restore, Cursor, AppArmor, QMD |

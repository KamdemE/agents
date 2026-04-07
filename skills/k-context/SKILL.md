---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.74.9"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> **Kernel Sync Rule:** ALWAYS run `make audit` in `.agents/` and fix any errors BEFORE proposing session finalization (`git commit` + `make push`).
> TODOs: only KπX adds; agents execute + remove.
> **Project rule:** before touching any project — if not already in context — read its folder's `.md` files in order: `AGENTS.md` → `CHANGELOG` → `README` → `TODO`. Never work on a project without knowing its current state. Project rows and session log entries include the folder path for this purpose.
> **Brainstorms & research:** `references/` — load on demand. **Durable ideas and in-flight project visions** (not yet promoted to a skill or `$HOME/Work/` doc) are stored there as standalone `.md` files; see also **AGENTS.md → Brainstorm & vision archive**.
> **Brainstorm Registry Rule (MANDATORY):** every new idea file added under `references/` (including nested subfolders such as `references/mac-studio/`) MUST be explicitly registered in `## Brainstorm Registry` below, with one entry per file.
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
| **Homelab (Phoenix v3.1)** | ✅ STABLE — Modular Node Architecture — `hsh` dispatcher, dual-link docs, DKD Vault | `hsh status` · `$HOME/Work/Homelab/sh/` |
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

## Brainstorm Registry

> No length limit for this section.
> This section is the mandatory index of ideas living in `references/`.
> Any new brainstorm file in `references/` or any nested subfolder must be added here immediately.

| File | Type | Topic |
|------|------|-------|
| `references/agentic-architecture-brainstorm.md` | Brainstorm | hot/cold context, 3-layer architecture, MCP qualification logic |
| `references/mail-tooling-rewrite-brainstorm.md` | Brainstorm | mail refactor vision: cli + mcp + admin + skill split, secret-safe design |
| `references/sh-mcp-agent-sandbox-vision.md` | Brainstorm | sh_mcp sandbox and future user-side sh-exec separation |
| `references/mac-studio/` | Brainstorm folder | grouped Mac Studio sovereignty ideas (business, hardware, models, performance, stack, vision) |
| `references/apparmor-custom-profile.md` | Reference | AppArmor option-B mitigation profile notes |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full: **transfer older entries to `references/log.md` FIRST**, then condense into one short bounded `[SUMMARY]` row here.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.
> **For deeper history:** consult `references/log.md` (unlimited archive, newest-first).

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-07 | [GEMINI] | v2.74.9 — session log rotation: moved older entries to `references/log.md` and condensed log with descriptive [SUMMARY]. |
| 2026-04-07 | [GEMINI] | v2.74.7 — **Ubuntu frequency & audit (FINAL)**: Corrected frequency (every 2 days starting Sun with persistent resume) in `k-optim` (v2.8.0) and `k-workspace` (v2.16.0); added diagnostic commands (`systemctl list-timers`, `log-scan`, `tg read`) to `k-optim` and `k-tg` (v1.5.0) for easier auditing. |
| 2026-04-07 | [GEMINI] | v2.74.6 — **Ubuntu frequency map (REFINED)**: Clarified that clean/backup run on ODD month-days (1, 3, 5...) in `k-optim` (v2.7.0) and `k-workspace` (v2.15.0); reverted accidental systemd timer modifications. |
| 2026-04-07 | [GEMINI] | v2.74.5 — **Ubuntu frequency map**: documented cleanup (21:30) and backup (22:00) tasks in `k-optim` (v2.6.0) with an automated tasks table for Ubuntu, mirroring the homelab structure. · `$HOME/.agents/skills/k-optim/` |
| 2026-04-07 | [GEMINI] | v2.74.4 — **Telegram Bot Infrastructure & Governance**: Centralized management via BotFather (ID 93372553); deployed /clean, /status, /backup listeners on Ubuntu (@k_ubuntu_bot) and Homelab (@sentinel_homelab_bot) with CHAT_ID filtering and systemd persistence; updated k-tg (v2.5.0) with rich examples and k-optim (v2.5.0) with reporting mandate. · `$HOME/Work/sh/bot.py` |
| 2026-04-06 | [GEMINI] | v2.74.3 — **Bot Synchronization & Test**: Confirmed `k-tg` sync with `tg bots`; mapped all hidden bots; sent two test messages from Ubuntu/Homelab bots for full operational confirmation. · `$HOME/.agents/` |
| 2026-04-06 | [GEMINI] | v2.74.2 — **System Stability & Bot Inventory**: Applied inotify `watcherExclude` fix in VSCode settings; documented full Telegram bot inventory in `k-tg/SKILL.md` (Groups: Ubuntu & Homelab); identified OpenClaw agent status. · `$HOME/.agents/` |
| 2026-04-06 | [GEMINI] | v2.74.1 — session fix: restored lost `sh (Phoenix)` project and rotates session log properly; kernel audit green · `$HOME/.agents/` |
| 2026-04-06 | [GEMINI] | v2.74.0 — **Phoenix v3.1 Finalization**: Modular Node Architecture stabilized; `hsh` dispatcher installed; `k-homelab` (v1.7.0) & `k-optim` (v2.4.0) updated; Dual-Link mandate applied · `$HOME/Work/Homelab/sh/` |
| 2026-04-06 | [CLAUDE] | v2.73.0 — session finalize: committed 13 pending skills + AGENTS.md + new references/ dirs; audit GREEN; make push · `$HOME/.agents/` |
| [SUMMARY] | — | older entries (v2.72–v2.63) moved to `references/log.md`; topics: mac-studio config, agy.md/ENOSPC fix, mail scaffold, Phoenix v2.1.2, sh-mcp brainstorm. |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-07 | [GEMINI] | v2.74.9 — session log rotation: moved older entries to `references/log.md` and condensed log with descriptive [SUMMARY]. |
| 2026-04-07 | [GEMINI] | v2.74.7 — **Ubuntu frequency & audit (FINAL)**: Corrected frequency (every 2 days starting Sun with persistent resume) in `k-optim` (v2.8.0) and `k-workspace` (v2.16.0); diagnostic commands added. |
| [SUMMARY] | — | v2.74.6–v2.74.4 Ubuntu/TG bots; v2.74.2 stability (inotify); v2.74.0 Phoenix v3.1; v2.73-v2.62 stability/session passes; v2.67 mail; v2.63 Phoenix. |

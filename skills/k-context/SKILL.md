---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.74.66"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> - **Agent-memory update mandate:** update k-<agent> skill immediately after any agent-specific learning.
> - **Zero-Deletion Policy (Mandatory):** NEVER delete logs or historical entries. If a section (Session Log, Changelog) reaches its limit, the older entries MUST be moved to `references/log.md` BEFORE the main file is compacted. Every removal MUST be an addition to the archive. [GEMINI]
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> **Kernel Sync Rule:** ALWAYS run `make audit` in `.agents/` and fix any errors BEFORE proposing session finalization (`git commit` + `make push`).
> **KπX directive — `.agents` VCS (2026-04-09):** Do **not** run `git commit`, `git push`, or `make push` on `$HOME/.agents/` **unless KπX explicitly requests** end-of-session finalization. **No autonomous** commit/push after skill or kernel edits by default.
> **Project finalization:** When finishing work on a **project repository** (explicit "finalize" / "clean" / "close", or you judge the slice done), **load `k-final`** and execute its full checklist — not a mental shortcut. See **AGENTS.md → Session & Memory** and `k-project` / `k-git` / `k-workspace` cross-links.
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
| **sciencurious** | 🟢 ACTIVE — Docsify + KaTeX visual articles (math, physics, CS) | add Manim visuals to integration article · `$HOME/Work/sciencurious/` |
| **envision (PSC)** | 🟢 ACTIVE — main PSC project; academic docs site finalized, source PDFs added, GitHub Pages live | continue final report + soutenance prep from published docs baseline · `$HOME/Work/X/envision/envision/` |
| **flow** | ✅ RELEASED — `k-flow` v0.4.1 published with full channel-modular refactor (`channels/{stdio,ws,http}`), Pydantic model layer, class-based exceptions, dynamic MCP channel scan, and hardened API-key auth (hashed storage + TTL + audits) | run first production pilot over `kpihx-labs/flow` and capture operational feedback · `$HOME/Work/AI/flow/` |
| **Visual Content Engine** | 🧠 BRAINSTORM — LLM + Manim + FLUX.2 pipeline for educational video production | vision docs written · `$HOME/.agents/skills/k-context/references/vision/` |
| **[ARCHIVE]** | Stable/completed items condensed | QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Brainstorm Registry

> No length limit for this section.
> This section is the mandatory index of ideas living in `references/`.
> Any new brainstorm file in `references/` or any nested subfolder must be added here immediately.

| File | Type | Topic |
|------|------|-------|
| `references/google-workspace-full-mcp-vision.md` | Brainstorm | full Google Workspace management via MCP modules/skills (mail, calendar, drive, docs, admin, orchestration) |
| `references/agents-memory-curator-hybrid-vision.md` | Brainstorm | hybrid memory update model: immediate minimal logs + deferred memory-curator batch updates |
| `references/whatsapp-wa-core-central-auth-mini.md` | Brainstorm | centralized Baileys auth (`wa-core`) + HTTP/stdio strategy + Edge fallback constraints |
| `references/agentic-architecture-brainstorm.md` | Brainstorm | hot/cold context, 3-layer architecture, MCP qualification logic |
| `references/mail-tooling-rewrite-brainstorm.md` | Brainstorm | mail refactor vision: cli + mcp + admin + skill split, secret-safe design |
| `references/sh-mcp-agent-sandbox-vision.md` | Brainstorm | sh_mcp sandbox and future user-side sh-exec separation |
| `references/mac-studio/` | Brainstorm folder | grouped Mac Studio sovereignty ideas (business, hardware, models, performance, stack, vision) |
| `references/vision/` | Brainstorm folder | visual-first AI content creation: visual-ai-vision, k-visual architecture, code-as-visual paradigm, social media APIs, content engine pipeline, blender MCP/API/scripting |
| `references/apparmor-custom-profile.md` | Reference | AppArmor option-B mitigation profile notes |

## What's up (context-only slice)

When KπX asks *what's up* **context** / **projects** (or the first step of a full *what's up*), load this file and present — **exhaustively**, in prose + tables as needed:

1. **`## Active Projects`** — every row: status, next action, folder path; expand any row that needs narrative (blockers, recent commits, CI).
2. **`## Session Log`** — newest-first; include enough rows that recent kernel/work threads are visible; point to `references/log.md` for deeper history.
3. **`## Brainstorm Registry`** — each registered file/folder: one-line topic + why it matters now if inferable.
4. **`## Active TODOs`** if non-empty.

Do **not** fold mail/WhatsApp/TickTick/Telegram into this same response when the full *what's up* ladder applies — **AGENTS.md → What's up** mandates **one domain per turn**.

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full: **transfer older entries to `references/log.md` FIRST**, then condense into one short bounded `[SUMMARY]` row here.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.
> **For deeper history:** consult `references/log.md` (unlimited archive, newest-first).

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-09 | [CURSOR] | v2.74.66 — completed total `flow` rebuild A→Z per `ARCHITECTURE.md` + `CONTRACT.md`: migrated legacy code to `old/`, shipped new channel architecture + base abstractions + global auth aggregator + live CLI matrix tests, published `k-flow 0.4.1`, and pushed GitLab remote to `kpihx-labs/flow`. · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.65 — finalized `flow` k-final closure end-to-end after auth unlock: published `k-flow 0.3.4`, pushed `master` to `github` and `gitlab`, shipped top-level intuitive CLI aliases (`start-session`, `stop-session`, etc.) and hid low-level `op` from public help. · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.64 — finalized `flow` docs/installability pass: added Linux prerequisite install guidance in README, kept code install-agnostic (bootstrap checks only), pushed `0376a89`, published `k-flow 0.3.2` (index propagation check pending). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.63 — completed Flow STT runtime implementation pass: backend modules + runtime fallback orchestrator + bootstrap + 16k mono normalization + stream/file wiring + new tests (`27 passed`), pushed `fa51e18`, published `k-flow 0.3.0` (index propagation check still pending). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.62 — finalized MCP adapter split in `flow`: explicit per-tool functions + compatibility dispatcher, removed legacy `adapters_*` shim modules, tests green (`23 passed`), and pushed commit `815cefd`. · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.61 — completed full `flow` release finalization: auto-bootstrapped `github/gitlab` remotes, pushed `master`, published `k-flow==0.2.1` to PyPI, and validated installed CLIs (`flow`, `flow-stdio`, `flow-ws`). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.60 — finalized `flow` repository with `k-final`: tests/hygiene/docs/semver complete, initial commit `1f7030b`, transport subpackage + Typer CLI validated (`22 passed`), `make push` blocked because no remotes configured. · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.59 — `.agents` finalization required again: synchronized `k-workspace` hardware-first policy update, refreshed context tracking, and resumed kernel sync flow (`make audit`, commit, push). · `$HOME/.agents/skills/k-workspace/SKILL.md` |
| 2026-04-09 | [GEMINI] | v2.74.56 — **Tools tg closure**: implémentation de `download` (bot/user), `cleanup`, `send --file`, `bot-action`, `mark-read` et ajouts architecturels au TODO. · `$HOME/Work/Tools/tg/` |
| 2026-04-09 | [CURSOR] | v2.74.55 — **`.agents` session finalization** (explicit): **`k-tg` v3.1.0** bundle (autonomous read-only inspection gate, BotFather map + ops snippets, homelab MCP bridge token rows + `@username` inventory), **`k-tg/references/`** (`insights`, `log`, **`telegram-processed-state.md`** cursors for capture + Homelab/Ubuntu), **`k-ticktick/references/log.md`** LEN_43314_EP row normalized to table schema; `make audit`, `git commit`, `make push`. · `$HOME/.agents/` |
| [SUMMARY] | — | v2.74.52 Google Workspace note + WhatsApp probe; v2.74.47–v2.74.44 → `references/log.md`; v2.74.37 mail_mcp 0.2.4 closure; v2.74.36 AGENTS k-* freshness; v2.74.35 k-final + mail_mcp G/H; v2.74.34 mail_mcp v0.2.3 PyPI; v2.74.33 k-mail finalize; v2.74.32–v2.74.20 in `references/log.md` |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v2.74.66 — logged full `flow` v0.4.1 channel-modular refactor and finalization (tests + CLI smoke + publish + push to `kpihx-labs/flow`). |
| 2026-04-09 | [CURSOR] | v2.74.65 — finalized `flow` k-final closure after auth unlock: published `k-flow 0.3.4`, pushed both remotes, and shipped top-level discoverable session aliases in `flow --help`. |
| [SUMMARY] | — | v2.74.64 recorded flow docs/prereq release; v2.74.63 logged `flow` STT runtime release; v2.74.62 synced MCP split closure; v2.74.61 tracked `flow` release v0.2.1; v2.74.60 logged `flow` k-final closure v0.2.0; v2.74.59 forced `.agents` finalization follow-up; v2.74.57 **whats-mcp v0.2.0 finalization**; v2.74.56 Fin session Work/Tools/tg/; v2.74.55 `k-tg` v3.1.0; v2.74.54 k-tg v3.0.2 + ladder; v2.74.53 `k-tg` v3.0.0; v2.74.52 Google Workspace vision + WhatsApp probe; v2.74.51 hybrid curator + wa-core; v2.74.50–v2.74.20 see `references/log.md`. |

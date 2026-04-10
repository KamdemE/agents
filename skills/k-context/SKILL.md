---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.74.75"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> - **Agent-memory update mandate:** update k-<agent> skill immediately after any agent-specific learning.
> - **Zero-Deletion Policy (Mandatory):** NEVER delete logs or historical entries. If a section (Session Log, Changelog) reaches its limit, the older entries MUST be moved to `references/log.md` BEFORE the main file is compacted. Every removal MUST be an addition to the archive. [GEMINI]
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> **Kernel Sync Rule:** ALWAYS run `make audit` in `.agents/` and fix any errors BEFORE proposing session finalization (`git commit` + `make push`).
> **KπX directive — `.agents` VCS (2026-04-10):** Autonomous `git commit`, `git push`, and `make push` on `$HOME/.agents/` are allowed by default **after** `make audit` passes, unless KπX explicitly says not to finalize in the current session.
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
| **flow** | 🟢 ACTIVE — v0.7.3 transport-shape cleanup complete: channel configs now declare `internal/external.has`, remote endpoint description is centralized in `src/flow/remote.py`, and ws/http channel CLIs consume the shared external descriptor path | decide whether the remaining `bases/local.py`, `bases/remote.py`, and `bases/mcp.py` abstractions still earn their keep or should be trimmed too · `$HOME/Work/AI/flow/` |
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
| 2026-04-10 | [CODEX] | v2.74.75 — updated `k-context` VCS governance for `$HOME/.agents/`: autonomous finalization is now allowed by default after `make audit` passes, unless KπX explicitly forbids finalization in the active session. · `$HOME/.agents/skills/k-context/SKILL.md` |
| 2026-04-09 | [CODEX] | v2.74.74 — completed `flow` v0.7.3 endpoint-shape cleanup: replaced channel `local/remote` config blocks with `internal/external.has`, centralized external endpoint description in `src/flow/remote.py`, removed per-channel remote helpers, and kept verification green (`21 passed`, build/install OK). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CODEX] | v2.74.73 — completed `flow` v0.7.2 cleanup: removed `flow_` prefixes from public MCP tool ids, cleaned `flow status` to omit absent local surfaces, reduced dead helpers in `bases/channel.py`, and kept verification green (`21 passed`, build/install OK). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CODEX] | v2.74.72 — completed `flow` v0.7.1 MCP centralization: removed channel-local `mcp.py` files, moved the sole MCP registry into `src/flow/mcp.py`, updated tests/docs, and revalidated the package (`21 passed`, build/install OK). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CODEX] | v2.74.71 — completed `flow` v0.7.0 HTTP remote-only refactor: removed `channels/http/local.py`, converted the HTTP channel to remote HTTPS metadata only, fixed the shared config base so global YAML actually loads correctly, and kept verification green (`21 passed`, build/install OK). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CODEX] | v2.74.70 — simplified `flow` config architecture: added shared cached `YamlConfig` base, reduced channel YAMLs to one canonical name plus executable endpoint fields, removed dead config toggles/duplicates, updated MCP naming/tests/docs, and kept the repo green (`22 passed`, local build/install OK). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CODEX] | v2.74.69 — completed `flow` end-to-end HTTP hardening: embedded HTTP auth, scope enforcement, and in-process rate limiting now ship from channel-local config; contract/docs/TODO were synchronized, local build/install succeeded, and tests are green (`22 passed`). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CODEX] | v2.74.68 — completed `flow` transport/config refactor: channel identity now comes from typed per-channel config, `flow-http` ships a real embedded local server with REST route mapping, global/channel CLIs were de-hardcoded around config discovery, and docs/tests were realigned; tests green (`18 passed`). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CODEX] | v2.74.67 — cleaned `flow` after contract/architecture drift: removed `old/` + dead packages/artifacts, centralized shared primitives in `src/flow/bases/`, expanded the global CLI to cover contract operations, and resynced `ARCHITECTURE.md` / `CONTRACT.md` / `README.md`; tests green (`17 passed`). · `$HOME/Work/AI/flow/` |
| 2026-04-09 | [CURSOR] | v2.74.66 — completed total `flow` rebuild A→Z per `ARCHITECTURE.md` + `CONTRACT.md`: migrated legacy code to `old/`, shipped new channel architecture + base abstractions + global auth aggregator + live CLI matrix tests, published `k-flow 0.4.1`, and pushed GitLab remote to `kpihx-labs/flow`. · `$HOME/Work/AI/flow/` |
| [SUMMARY] | — | v2.74.65 moved to `references/log.md`; v2.74.64 moved to `references/log.md`; v2.74.63 moved to `references/log.md`; v2.74.62 moved to `references/log.md`; v2.74.61 moved to `references/log.md`; v2.74.60 moved to `references/log.md`; v2.74.59 moved to `references/log.md`; v2.74.56 Tools tg closure moved to `references/log.md`; v2.74.55 `k-tg` v3.1.0 finalization moved to `references/log.md`; v2.74.52 Google Workspace note + WhatsApp probe; v2.74.47–v2.74.44 → `references/log.md`; v2.74.37 mail_mcp 0.2.4 closure; v2.74.36 AGENTS k-* freshness; v2.74.35 k-final + mail_mcp G/H; v2.74.34 mail_mcp v0.2.3 PyPI; v2.74.33 k-mail finalize; v2.74.32–v2.74.20 in `references/log.md` |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-10 | [CODEX] | v2.74.75 — replaced the restrictive `.agents` VCS directive with an audit-first autonomous finalization rule for the default case. |
| 2026-04-09 | [CODEX] | v2.74.74 — tracked `flow` v0.7.3 endpoint-shape cleanup: `internal/external.has` config blocks, shared `src/flow/remote.py`, channel CLI alignment, and green verification (`21 passed`, build/install OK). |
| [SUMMARY] | — | v2.74.73 tracked `flow` v0.7.2 cleanup; v2.74.72 tracked `flow` v0.7.1 MCP centralization; v2.74.71 tracked `flow` v0.7.0 remote-only HTTP pass; v2.74.70 tracked `flow` v0.6.2 config simplification; v2.74.69 tracked `flow` v0.6.1 hardening closure; v2.74.68 tracked `flow` v0.6.0 refactor; v2.74.67 tracked `flow` cleanup/resync pass; v2.74.66 logged full `flow` v0.4.1 channel-modular refactor; v2.74.65 finalized `flow` v0.3.4 closure; v2.74.64 recorded flow docs/prereq release; v2.74.63 logged `flow` STT runtime release; v2.74.62 synced MCP split closure; v2.74.61 tracked `flow` release v0.2.1; v2.74.60 logged `flow` k-final closure v0.2.0; v2.74.59 forced `.agents` finalization follow-up; v2.74.57 **whats-mcp v0.2.0 finalization**; v2.74.56 Fin session Work/Tools/tg/; v2.74.55 `k-tg` v3.1.0; v2.74.54 k-tg v3.0.2 + ladder; v2.74.53 `k-tg` v3.0.0; v2.74.52 Google Workspace vision + WhatsApp probe; v2.74.51 hybrid curator + wa-core; v2.74.50–v2.74.20 see `references/log.md`. |

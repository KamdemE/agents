---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.74.34"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> - **Agent-memory update mandate:** update k-<agent> skill immediately after any agent-specific learning.
> - **Zero-Deletion Policy (Mandatory):** NEVER delete logs or historical entries. If a section (Session Log, Changelog) reaches its limit, the older entries MUST be moved to `references/log.md` BEFORE the main file is compacted. Every removal MUST be an addition to the archive. [GEMINI]
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> **Kernel Sync Rule:** ALWAYS run `make audit` in `.agents/` and fix any errors BEFORE proposing session finalization (`git commit` + `make push`).
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
| **Visual Content Engine** | 🧠 BRAINSTORM — LLM + Manim + FLUX.2 pipeline for educational video production | vision docs written · `$HOME/.agents/skills/k-context/references/vision/` |
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
| `references/vision/` | Brainstorm folder | visual-first AI content creation: visual-ai-vision, k-visual architecture, code-as-visual paradigm, social media APIs, content engine pipeline, blender MCP/API/scripting |
| `references/apparmor-custom-profile.md` | Reference | AppArmor option-B mitigation profile notes |

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full: **transfer older entries to `references/log.md` FIRST**, then condense into one short bounded `[SUMMARY]` row here.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.
> **For deeper history:** consult `references/log.md` (unlimited archive, newest-first).

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-09 | [CURSOR] | v2.74.34 — **mail_mcp** closure: `e7a2aac` v0.2.3 (SMTP `delivery_status` + optional bounce probe) → `make push` + **PyPI** `k-mail-mcp==0.2.3` + tag `v0.2.3` + `uv tool install --editable`; `.agents` **`210d3c9`** pushed to both remotes after SSH recovery. · `$HOME/Work/AI/MCPs/mail_mcp/` · `$HOME/.agents/` |
| 2026-04-09 | [CURSOR] | v2.74.33 — session finalization: committed pending **`k-mail`** v2.0.10 (IME contact) + v2.0.11 (sensitive-mail post-send verification); `make audit` + push `.agents`. · `$HOME/.agents/skills/k-mail/SKILL.md` |
| 2026-04-09 | [CURSOR] | v2.74.32 — `k-final` v1.0.2 **Phase K**: mandatory `$HOME/.agents/` closure — `k-context`/`k-workspace` updates, `make audit` until green, commit + push. · `$HOME/.agents/skills/k-final/SKILL.md` |
| 2026-04-09 | [CURSOR] | v2.74.31 — kernel mandate: **`k-final`** must be read and applied whenever finalizing a project (`AGENTS.md`, `k-project`, `k-git`, `k-workspace`, `k-context`); removed duplicate File Routing row. · `$HOME/.agents/` |
| 2026-04-09 | [CURSOR] | v2.74.30 — added `k-final` skill (post-work project closure: tests → hygiene → config-docs → markdown → semver → git/CI/deploy → install/publish); synced `AGENTS.md`, `.cursorrules`, `.skill-lock.json`. · `$HOME/.agents/skills/k-final/SKILL.md` |
| 2026-04-08 | [CODEX] | v2.74.29 — finalized communication-safety governance update in `.agents`: added mandatory dry-run before WhatsApp group sends in `k-whatsapp` and mirrored mail-context send-gate in `k-mail`; prepared session finalization commit/push. · `$HOME/.agents/skills/k-whatsapp/SKILL.md` · `$HOME/.agents/skills/k-mail/SKILL.md` |
| 2026-04-08 | [CURSOR] | v2.74.28 — rewrote entire `docs/` site in French (all pages + sidebar + index.html), added Mermaid plugin to Docsify (mermaid@10 + MutationObserver), replaced ASCII diagram with Mermaid flowchart, created TickTick task for Overleaf report session (Graph Tool + Heuristic Reranking, Sat 11/04 20h). Committed and pushed `envision-copilot-presentation`. · `$HOME/Work/X/envision/envision/` · TickTick `🎓 X/📅 Agenda` |
| 2026-04-08 | [CODEX] | v2.74.27 — moved `Soutenance PSC` into `🎓 X/📅 Agenda`, finalized academic `docs/` pages from main-branch Envision state + source PDFs in `source/`, created and pushed `KpihX/envision-psc`, enabled GitHub Pages (`main/docs`), and verified live site. · `$HOME/Work/X/envision/envision/` · TickTick `🎓 X` |
| 2026-04-08 | [CODEX] | v2.74.26 — synchronized PSC planning in TickTick (report final deadline + soutenance period + soutenance date reminders `-7d/-1d/-1h`) and created Docsify `docs/` scaffold in main PSC project `envision` (without `.agents`, AGENTS, CHANGELOG, TODO). · `$HOME/Work/X/envision/envision/` · TickTick `🎓 X` |
| 2026-04-08 | [CODEX] | v2.74.25 — updated `$HOME/.agents/AGENTS.md` proactive-suggestions rule (no upper limit), then applied TickTick execution updates: refreshed CSC_43042 course note, created TD5→TD10 reminders (-1d/-1h), and added X24 events for PA campaign + spring break. · `$HOME/.agents/AGENTS.md` · TickTick (`🎓 X/📒 Notes`, `🎓 X/📅 Agenda`) |
| [SUMMARY] | — | v2.74.24 mail/whatsapp/ticktick governance + changelog compaction; v2.74.23 MCP naming cleanup; v2.74.22 edge-automation; v2.74.21 QMD+edge; v2.74.20–v2.63 in `references/log.md` |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v2.74.34 — mail_mcp v0.2.3 ship + PyPI + tags; `.agents` push retry OK; session log rotation (v2.74.24 → log) |
| [SUMMARY] | — | v2.74.33 k-mail skill landed; v2.74.32 `k-final` Phase K; v2.74.31–v2.74.30 k-final kernel; v2.74.29 WhatsApp/mail; v2.74.28–v2.74.25 Envision/PSC/TickTick/AGENTS; v2.74.21–v2.62 QMD, blender, scien_curieux, PPTX, visual-ai, k-optim, Phoenix, session passes. |

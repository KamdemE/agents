---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.74.48"
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

## What's up (context-only slice)

When KπX asks *what's up* **context** / **projects** (or the first step of a full *what's up*), load this file and present — **exhaustively**, in prose + tables as needed:

1. **`## Active Projects`** — every row: status, next action, folder path; expand any row that needs narrative (blockers, recent commits, CI).
2. **`## Session Log`** — newest-first; include enough rows that recent kernel/work threads are visible; point to `references/log.md` for deeper history.
3. **`## Brainstorm Registry`** — each registered file/folder: one-line topic + why it matters now if inferable.
4. **`## Active TODOs`** if non-empty.

Do **not** fold mail/WhatsApp/TickTick into this same response when the full *what's up* ladder applies — **AGENTS.md → What's up** mandates **one domain per turn**.

## Session Log

> Limit: max 10 entries, newest-first.
> Only when full: **transfer older entries to `references/log.md` FIRST**, then condense into one short bounded `[SUMMARY]` row here.
> Do not use `[SUMMARY]` before the section actually reaches its limit.
> Include folder paths or commit hashes in entries so agents can navigate directly.
> **For deeper history:** consult `references/log.md` (unlimited archive, newest-first).

| Date | Agent | Entry |
|------|-------|-------|
| 2026-04-09 | [CURSOR] | v2.74.48 — finalized mail/tag governance pass: session-guard grace raised to 30 min, `k-mail` updated with Zimbra tag inventory + Important-priority in What's up open-thread scan, and runtime logs synced after Important cleanup + EX240207 discovery in Drive docs. · `$HOME/.agents/hooks/` · `$HOME/.agents/skills/k-mail/` |
| 2026-04-09 | [CURSOR] | v2.74.47 — Outlook cleanup pass finalized in `.agents` flow: m365 Graph bulk archive (`Inbox` → `Archive`) with `$batch` (2126 moved, Inbox=0), plus `k-mail/references` runtime updates (log + insights), and session finalization prep (`make audit`, commit, push). · `$HOME/.agents/skills/k-mail/` |
| 2026-04-09 | [CURSOR] | v2.74.46 — **`.agents` session finalization:** `git commit` + `make push` — **AGENTS** mail-mcp **stdio exception**; **`k-mail` v2.0.21** (Lokad **Clément Liu** / Kevin Ea, *What's up* Step 0, Outlook dedup, **`## Closure hygiene`**, `mcp.md`); **`k-ticktick` v2.0.8**; **`k-whatsapp` v2.1.2** + `mcp.md`; `make audit` green. · `$HOME/.agents/` |
| 2026-04-09 | [CURSOR] | v2.74.45 — **`k-mail` v2.0.18** *What's up*: stdio+**m365** preflight, Outlook **dedup** vs poly, M365 contacts + Clement row; **`## Closure hygiene`** mail + **`k-ticktick` v2.0.8** + **`k-whatsapp` v2.1.2**; **AGENTS** mail-mcp **stdio exception**. · `$HOME/.agents/` |
| 2026-04-09 | [CURSOR] | v2.74.44 — **AGENTS.md → MCP Protocol:** **HTTP preferred**, **stdio fallback** for KπX MCPs; **`k-whatsapp` v2.1.1** (`allowed-tools`, **`## Runtime Discipline`**, `references/mcp.md` HTTP-first). · `$HOME/.agents/AGENTS.md` · `$HOME/.agents/skills/k-whatsapp/` |
| 2026-04-09 | [CURSOR] | v2.74.43 — **`.agents` session finalization:** explicit KπX request — `git commit` + `make push` for **What's up** stack (`AGENTS.md`, `k-context` **v2.74.42**, `k-mail` **v2.0.17**, `k-whatsapp` **v2.1.0**, `k-ticktick` **v2.0.7`, runtime logs); `make audit` green. · `$HOME/.agents/` |
| 2026-04-09 | [CURSOR] | v2.74.42 — **What's up protocol:** `AGENTS.md` ladder + **`## What's up`** slices in `k-context`, `k-mail`, `k-whatsapp` **v2.1.0**, `k-ticktick`; **one domain per assistant turn**; context-only section in k-context. · `$HOME/.agents/AGENTS.md` · skills |
| 2026-04-09 | [CURSOR] | v2.74.41 — **`.agents` VCS:** no auto commit/push unless KπX asks; **`k-mail`** INBOX bulk archive (**56** msgs, keep **8323**+**8318**); Alessandra **`.edu` only** rule; read UIDs **8323**/**8318**. · `$HOME/.agents/skills/k-context/SKILL.md` · `$HOME/.agents/skills/k-mail/SKILL.md` |
| 2026-04-09 | [CURSOR] | v2.74.40 — **`k-mail` v2.0.15**: archived **2026-04-08** INBOX trio (`8444,8445,8449`); **Flagged/Open Threads** = **IME re-feedback** + **IPAI prize**; INBOX sweep since **2026-03-25** (48 msgs). · `$HOME/.agents/skills/k-mail/SKILL.md` |
| [SUMMARY] | — | v2.74.37 mail_mcp 0.2.4 closure (archived `references/log.md`); v2.74.36 AGENTS k-* freshness (archived `references/log.md`); v2.74.35 k-final v1.0.3 + mail_mcp G/H (archived `references/log.md`); v2.74.34 mail_mcp v0.2.3 PyPI push (archived `references/log.md`); v2.74.33 k-mail v2.0.10–v2.0.11 session finalize (archived `references/log.md`); v2.74.32 k-final Phase K closure (archived `references/log.md`); v2.74.31 k-final read mandate (archived `references/log.md`); v2.74.30 k-final skill + AGENTS sync; v2.74.29 WhatsApp/mail send-gate (archived `references/log.md`); v2.74.28 Envision docs FR + Mermaid + TickTick; v2.74.27 Envision PSC Pages + PDFs; v2.74.26 PSC TickTick + docs scaffold; v2.74.25 AGENTS + TickTick X24; v2.74.24 mail/whatsapp/ticktick; v2.74.23 MCP naming; v2.74.22 edge-automation; v2.74.21 QMD+edge; v2.74.20–v2.63 in `references/log.md` |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v2.74.48 — recorded finalization of hook grace 30 min + k-mail tag governance updates (inventory, proactive maintenance, Important-first open-thread pass) and synced runtime logs after Important cleanup/matricule lookup. |
| [SUMMARY] | — | v2.74.47 m365 bulk-archive workflow + runtime sync; v2.74.46 commit+push (k-mail 2.0.21 + stdio exception + tick/whats); v2.74.45 mail preflight + m365 dedup + closure + AGENTS stdio; v2.74.44 HTTP whatsapp + session rotate; v2.74.43 finalize push; v2.74.42 What's up slices; v2.74.41–v2.74.38 mail/whatsapp; v2.74.34 PyPI 0.2.3; v2.74.29 WhatsApp/mail; v2.74.26 Envision PSC; v2.74.25–v2.74.21 mail/MCP/edge/QMD; v2.74.20–v2.62 blender, PPTX, k-optim, Phoenix, session passes. |

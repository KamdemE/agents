---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.74.40"
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
| 2026-04-09 | [CURSOR] | v2.74.40 — **`k-mail` v2.0.15**: archived **2026-04-08** INBOX trio (`8444,8445,8449`); **Flagged/Open Threads** = **IME re-feedback** + **IPAI prize**; INBOX sweep since **2026-03-25** (48 msgs). · `$HOME/.agents/skills/k-mail/SKILL.md` |
| 2026-04-09 | [CURSOR] | v2.74.39 — **`k-mail` v2.0.14** + **`k-whatsapp` v2.0.12**: `references/mcp.md` post-send tooling (`verify_bounce_window_seconds` complement; WhatsApp **`get_messages`** vs **`read_messages`**); `.agents` commit + push; mail-mcp digest 2026-04-08 INBOX+Archive. · `$HOME/.agents/skills/k-mail/` · `$HOME/.agents/skills/k-whatsapp/` |
| 2026-04-09 | [CURSOR] | v2.74.38 — **`k-mail` v2.0.13** + **`k-whatsapp` v2.0.11**: mandatory post-send verification — mail: ≥~5s then **`Sent` + `INBOX`**; WhatsApp: ≥~5s then **re-read thread** for outbound presence. · `$HOME/.agents/skills/k-mail/SKILL.md` · `$HOME/.agents/skills/k-whatsapp/SKILL.md` |
| 2026-04-09 | [CURSOR] | v2.74.37 — **`k-final`** closure **mail_mcp 0.2.4**: `f3491d6` — fix `APP_VERSION` via **`k-mail-mcp`** dist, dynamic **`mail_guide`**, tests; pipeline **2438908338** jobs green; **`/health` → 0.2.4**; PyPI + tag **`v0.2.4`**; MCP probe sends (hotmail **`delivered_hint`**, wrong TLD **`delivered_hint`** @25s — no DSN in window); **`k-mail` v2.0.12** sync. · `$HOME/Work/AI/MCPs/mail_mcp/` |
| 2026-04-09 | [CURSOR] | v2.74.36 — **AGENTS.md**: mandatory **`k-*` proactive freshness** — after using or touching a skill’s domain, keep `$HOME/.agents/skills/k-<name>/SKILL.md` aligned; record working fixes in-skill, not only in chat. · `$HOME/.agents/AGENTS.md` |
| 2026-04-09 | [CURSOR] | v2.74.35 — **`k-final` v1.0.3** obligation pass + **mail_mcp** Phase G/H proof: `glab api …/pipelines/2438880154/jobs` → `validate_project`+`deploy_homelab` **success**; `curl` health + `ssh docker-host docker logs mail-mcp` → **running healthy** (runtime JSON still reports `version` **0.2.0** vs PyPI **0.2.3** — image/metadata drift to fix separately). · `$HOME/.agents/skills/k-final/SKILL.md` · `$HOME/Work/AI/MCPs/mail_mcp/` |
| 2026-04-09 | [CURSOR] | v2.74.34 — **mail_mcp** closure: `e7a2aac` v0.2.3 (SMTP `delivery_status` + optional bounce probe) → `make push` + **PyPI** `k-mail-mcp==0.2.3` + tag `v0.2.3` + `uv tool install --editable`; `.agents` **`210d3c9`** pushed to both remotes after SSH recovery. · `$HOME/Work/AI/MCPs/mail_mcp/` · `$HOME/.agents/` |
| 2026-04-09 | [CURSOR] | v2.74.33 — session finalization: committed pending **`k-mail`** v2.0.10 (IME contact) + v2.0.11 (sensitive-mail post-send verification); `make audit` + push `.agents`. · `$HOME/.agents/skills/k-mail/SKILL.md` |
| 2026-04-09 | [CURSOR] | v2.74.32 — `k-final` v1.0.2 **Phase K**: mandatory `$HOME/.agents/` closure — `k-context`/`k-workspace` updates, `make audit` until green, commit + push. · `$HOME/.agents/skills/k-final/SKILL.md` |
| 2026-04-09 | [CURSOR] | v2.74.31 — kernel mandate: **`k-final`** must be read and applied whenever finalizing a project (`AGENTS.md`, `k-project`, `k-git`, `k-workspace`, `k-context`); removed duplicate File Routing row. · `$HOME/.agents/` |
| [SUMMARY] | — | v2.74.30 k-final skill + AGENTS sync; v2.74.29 WhatsApp/mail send-gate (archived `references/log.md`); v2.74.28 Envision docs FR + Mermaid + TickTick; v2.74.27 Envision PSC Pages + PDFs; v2.74.26 PSC TickTick + docs scaffold; v2.74.25 AGENTS + TickTick X24; v2.74.24 mail/whatsapp/ticktick; v2.74.23 MCP naming; v2.74.22 edge-automation; v2.74.21 QMD+edge; v2.74.20–v2.63 in `references/log.md` |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v2.74.40 — k-mail v2.0.15 Apr8 INBOX archive + IME/IPAI open threads; k-context log rotate (v2.74.30 → archive). |
| 2026-04-09 | [CURSOR] | v2.74.39 — k-mail/k-whatsapp `references/mcp.md` post-send tooling notes; session log rotate (v2.74.29 → archive); `.agents` push. |
| [SUMMARY] | — | v2.74.38 k-mail/k-whatsapp post-send verification; v2.74.37 mail_mcp 0.2.4 + k-mail v2.0.12; v2.74.36 AGENTS k-* freshness; v2.74.35 k-final + mail_mcp G/H; v2.74.34 PyPI 0.2.3; v2.74.33 k-mail; v2.74.32–v2.74.31 k-final; v2.74.29 WhatsApp/mail; v2.74.26 Envision PSC scaffold; v2.74.25–v2.74.21 mail/MCP/edge/QMD; v2.74.20–v2.62 blender, PPTX, k-optim, Phoenix, session passes. |

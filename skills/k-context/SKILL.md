---
name: "k-context"
description: "KπX HOT context — load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.85.0"
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
> **Insights governance (k-context specific):** maintain `references/insights.md` as the general cross-domain operational memory for recurring mistakes, repeated dead-end actions, and validated workarounds. Update it autonomously whenever a durable pattern is learned.
> **Brainstorm Registry Rule (MANDATORY):** every new idea file added under `references/` (including nested subfolders such as `references/mac-studio/`) MUST be explicitly registered in `## Brainstorm Registry` below, with one entry per file.
> **Visual reference asset:** `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.

## Active TODOs

| Task | IMPORTANT | URGENT | CONCERNED | Description |
|------|-----------|--------|-----------|-------------|
| *(none)* | | | | |

## Active Projects

> Limit: max 20 active rows.
> Only when full, condense stale/completed items into one short bounded `[ARCHIVE]` row.

| **Phoenix V4.0 Vision** | 🔴 **ABSOLUTE PRIORITY #1** — Technical Foundation: K3s distributed cluster, Tailscale Mesh, Kasm WebTop agent visual sandbox | Test WebTop locally · `$HOME/.agents/skills/k-context/references/phoenix-v4-k3s-agent-sandbox-vision.md` |
| **Sovereign Learning Lab**| 🔴 **ABSOLUTE PRIORITY #2** — Convergent Vision: Real-time visual assistant (Manim/Napkin), Personal OS coaching | Propose first live lesson prototype · `$HOME/.agents/skills/k-context/references/k-personal-os-learning-laboratory-vision.md` |
| **MCP Visual Validation** | 🚧 PLANNING — Transform `send`/`create` across MCPs (TickTick, WhatsApp, LinkedIn, Mail) to launch a visual editor for review before execution | Propose architecture · `$HOME/.agents/skills/k-context/references/mcp-visual-validation-vision.md` |
| **kpihx** | ✅ STABLE — v2.6.0 Sovereign Hub with father split, manuscript archive layer, and explicit development/provenance anchoring | Maintain sovereign freshness and provenance discipline · `$HOME/.agents/skills/kpihx/` |
| **sh (Phoenix)** | ✅ STABLE — v2.1.2 Universal Orchestrator — root Makefile, `ksh` dispatcher, multi-remote sync | `ksh status` · `$HOME/Work/sh/` |
| **Homelab (Phoenix v3.1)** | ✅ STABLE — Modular Node Architecture — `hsh` dispatcher, dual-link docs, DKD Vault | `hsh status` · `$HOME/Work/Homelab/sh/` |
| **ai_voice** | 📑 UNDERSTANDING — whisper-overlay fork | research state, propose AGENTS.md · `$HOME/Work/AI/ai_voice/` |
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs · `$HOME/.agents/assets/` |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools · `$HOME/Work/AI/MCPs/mem_mcp/` |
| **mail workspace** | 🧠 BRAINSTORM — cli/mcp/admin/skill split for mail | scaffold + contracts + generator · `$HOME/Work/AI/mail/` |
| **sh_mcp** | 🧠 BRAINSTORM — agent sandbox MCP (homelab); future user-side **sh-exec** separate | vision · `$HOME/.agents/skills/k-context/references/sh-mcp-agent-sandbox-vision.md` · code TBD · `$HOME/Work/AI/MCPs/` |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test | `$HOME/.agents/references/` |
| **sciencurious** | 🟢 ACTIVE — Docsify + KaTeX visual articles (math, physics, CS) | add Manim visuals to integration article · `$HOME/Work/sciencurious/` |
| **envision (PSC)** | 🟢 ACTIVE — agentic pipeline stabilized and `env_graph` is now re-aligned with the repo: root config integration, `python -m env_graph.network` CLI usage, and `data/network/` rebuild validated end-to-end | continue final report + soutenance prep from the stabilized dense-RAG baseline; later clean placeholder-resolution path noise and decide whether to expand graph usage in the planner beyond the current fusion attempt · `$HOME/Work/X/envision/envision/` |
| **flow** | 🟢 ACTIVE — `k_env` extracted out of tree into its own framework repo; `flow` packaging no longer claims `k_env` CLI/tests | continue voice-kernel work as `flow`-only and add a local dependency on `$HOME/Work/Frameworks/k_env/` only if/when runtime imports are introduced · `$HOME/Work/AI/flow/` |
| **k_env** | 🟢 ACTIVE — autonomous framework repo scaffolded under `Work/Frameworks/`; migrated package + tests now live in their own git root and pass locally | refine autonomous docs/API after extraction and continue the post-SecretStrategy cleanup from the Gemini intent baseline · `$HOME/Work/Frameworks/k_env/` |
| **k-conf** | 🟢 ACTIVE — Meta-config framework renamed from `framework` to `k-conf` (package `k_conf`); global import refactor and variable replacement completed | internal dev in `$HOME/Work/AI/flow/src/k_conf/` |
| **Visual Content Engine** | 🧠 BRAINSTORM — LLM + Manim + FLUX.2 pipeline for educational video production | vision docs written · `$HOME/.agents/skills/k-context/references/vision/` |
| **Linguaskill 2026** | 🟢 ACTIVE — SSD Surgery completed (281GB free). Session confirmed for **2026-04-30 09:00**. | Prepare Secure Browser on a non-Linux machine · `/home/kpihx/Gdrive_X/X/LinguaSkill/` |
| **AGY account setup** | 🟠 ISSUE — Antigravity sign-in flow blocks with “There was an unexpected issue setting up your account” and disabled **Next** button | capture reproducible diagnostics and unblock AGY auth flow · `$HOME/.gemini/antigravity/` |
| **ai_dispatcher** | ✅ STABLE — v2.85.0 Universal X-IA Orchestrator. Dynamic host selection, SSD model caching, and forced GPU acceleration. | `git push` · `$HOME/Work/X/ai_dispatcher/` |
| **X-IA Cluster** | ✅ OPTIMIZED — Deployment of Ollama 0.21.0 across labs, CUDA v13 symlink fix, and local SSD rsync sync. | maintain runner health · `$HOME/Work/X/ai_cluster/` |

| **[ARCHIVE]** | Stable/completed items condensed | AppArmor (Option A done); Centralized Hooks; Optimization map; QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Brainstorm Registry

> No length limit for this section.
> This section is the mandatory index of ideas living in `references/`.
> Any new brainstorm file in `references/` or any nested subfolder must be added here immediately.

| File | Type | Topic |
|------|------|-------|
| `references/k-personal-os-learning-laboratory-vision.md` | Vision | Convergence of Homelab, Coach, and Learning Lab into the Sovereign Personal OS |
| `references/mcp-visual-validation-vision.md` | Brainstorm | Transform `send`/`create` MCP tools to launch a visual editor for user validation before execution |
| `references/google-workspace-full-mcp-vision.md` | Brainstorm | full Google Workspace management via MCP modules/skills (mail, calendar, drive, docs, admin, orchestration) |
| `references/agents-memory-curator-hybrid-vision.md` | Brainstorm | hybrid memory update model: immediate minimal logs + deferred memory-curator batch updates |
| `references/whatsapp-wa-core-central-auth-mini.md` | Brainstorm | centralized Baileys auth (`wa-core`) + HTTP/stdio strategy + Edge fallback constraints |
| `references/agentic-architecture-brainstorm.md` | Brainstorm | hot/cold context, 3-layer architecture, MCP qualification logic |
| `references/mail-tooling-rewrite-brainstorm.md` | Brainstorm | mail refactor vision: cli + mcp + admin + skill split, secret-safe design |
| `references/sh-mcp-agent-sandbox-vision.md` | Brainstorm | sh_mcp sandbox and future user-side sh-exec separation |
| `references/mac-studio/` | Brainstorm folder | grouped Mac Studio sovereignty ideas (business, hardware, models, performance, stack, vision) |
| `references/vision/` | Brainstorm folder | visual-first AI content creation: visual-ai-vision, k-visual architecture, code-as-visual paradigm, social media APIs, content engine pipeline, blender MCP/API/scripting |
| `references/apparmor-custom-profile.md` | Reference | AppArmor option-B mitigation profile notes |
| `references/mcp-central-sync-vision.md` | Brainstorm | Vision for a centralized MCP registry and synchronization pipeline to unified all agent provider configs |
| `references/phoenix-v4-k3s-agent-sandbox-vision.md` | Brainstorm | Phoenix V4.0 complete distributed cluster vision: K3s, Tailscale Sidecar, Kasm WebTop, and Sovereign AI Identity |

## What's up (context-only slice)

When KπX asks *what's up* **context** / **projects** (or the first step of a full *what's up*), load this file and present — **exhaustively**, in prose + tables as needed.
This slice is **not a summary**: report facts with **maximum available detail**, avoid synthesis compression, and avoid asking KπX to request extra details in a second pass.
Run this slice as a **batch deep exploration**: keep opening relevant records until the context is complete enough to avoid information loss.

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

| 2026-04-21 | [X-IA] | v2.85.0 — COMPLETED: X-IA cluster optimized. Installed Ollama 0.21.0, implemented SSD local caching (`rsync`), and fixed CUDA runners (`cuda_v13` symlink) for hardware acceleration on RTX A4000 (~50 tok/s). |
| 2026-04-21 | [AI DISPATCHER] | v2.84.5 — Finalized `run_dispatcher.sh` with background PTY handling, auto-reallocation to low-load nodes, and persistent SSH tunnels. |

| 2026-04-20 | [SSD SURGERY] | v2.83.0 — Completed partition surgery on `/dev/sda` (B SSD). Deleted `sda1,2,4` to reclaim 281.4 GiB. `KpihX-Datas` (`sda3`) preserved. |
| 2026-04-20 | [ANTIGRAVITY] | v2.83.0 — Analyzed WEFIT emails for Linguaskill, extracted Metrica credentials (UID 10110), updated TickTick event for 04-30, and archived manual/installers in `Gdrive_X/X/LinguaSkill/`. Identified critical Linux incompatibility for the Secure Browser. |
| 2026-04-19 | [ANTIGRAVITY] | v2.81.9 — Created the master "Sovereign Personal OS & Learning Laboratory" vision document as the convergence point for technical, professional, and educational workstreams. |
| [SUMMARY] | — | v2.81.8..v2.78.0 built kpihx hub; older → `references/log.md` |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- `references/insights.md` — autonomous general runtime insights (cross-domain mistakes, fixes, and anti-repeat guidance)
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-context/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-context/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-21 | [ANTIGRAVITY] | v2.85.0 — X-IA Cluster optimized with GPU acceleration and SSD caching. |
| 2026-04-21 | [ANTIGRAVITY] | v2.84.5 — Orchestrator finalized. |
| [SUMMARY] | — | v2.83.0..v2.81.0 archive/audit passes; older → `references/log.md` |

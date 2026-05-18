---
name: "k-context"
description: "KpihX HOT context - load at EVERY session start. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "2.87.6"
  sciencurious-lab-banner: "920x420"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> HOT — load at every session start.
> - **Agent-memory update mandate:** update k-<agent> skill immediately after any agent-specific learning.
> - **Zero-Deletion Policy (Mandatory):** NEVER delete logs or historical entries. If a section (Session Log, Changelog) reaches its limit, the older entries MUST be moved to `references/log.md` BEFORE the main file is compacted. Every removal MUST be an addition to the archive. [GEMINI]
> - **Issues Transparency Rule (Mandatory):** every attempt to understand/fix any issue (system, filesystem, crashes, thermal, noisy processes, services, etc.) MUST be appended to `references/issues.md` with full command history and outputs. No deletion, no compaction.
> - **Auto-Update Rule (Mandatory):** agents must update `references/issues.md` and relevant context sections automatically without asking KπX.
> - **Session Log Linking Rule:** `## Session Log` keeps short summaries only and each issue-related entry must include exact issue IDs (e.g., `ISS-YYYYMMDD-XXX`) that point to `references/issues.md`.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> **Kernel Sync Rule:** ALWAYS run `make audit` in `.agents/` and fix any errors BEFORE proposing session finalization (`git commit` + `make push`).
> **KπX directive — `.agents` VCS (2026-04-10):** Autonomous `git commit`, `git push`, and `make push` on `$HOME/.agents/` are allowed by default **after** `make audit` passes, unless KπX explicitly says not to finalize in the current session.
> **Project finalization:** When finishing work on a **project repository** (explicit "finalize" / "clean" / "close", or you judge the slice done), **load `k-final`** and execute its full checklist — not a mental shortcut. See **AGENTS.md → Session & Memory** and `k-project` / `k-git` / `k-workspace` cross-links.
> TODOs: only KπX adds; agents execute + remove.
> **Project rule:** before touching any project — if not already in context — read its folder's `.md` files in order: `AGENTS.md` → `CHANGELOG` → `README` → `TODO`. Never work on a project without knowing its current state. Project rows and session log entries include the folder path for this purpose.
> **Brainstorms & research:** `references/` — load on demand. **Durable ideas and in-flight project visions** (not yet promoted to a skill or `$HOME/Work/` doc) are stored there as standalone `.md` files; see also **AGENTS.md → Brainstorm & vision archive**.
> **Insights governance (k-context specific):** maintain `references/insights.md` as the general cross-domain operational memory for recurring mistakes, repeated dead-end actions, and validated workarounds. Update it autonomously whenever a durable pattern is learned.
> **Brainstorm Registry Rule (MANDATORY):** every new idea file added under `references/` (including nested subfolders such as `references/mac-studio/`) MUST be explicitly registered in `## Brainstorm Registry` below, with one entry per file.
> - **Visual reference assets:**
>   - `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.
>   - `assets/sciencurious_lab.png` — branding reference for ScienCurious Lab (ln → Assets Hub).

## Active TODOs

| Task | IMPORTANT | URGENT | CONCERNED | Description |
|------|-----------|--------|-----------|-------------|
| *(none)* | | | | |

## Active Projects

| **Optimisation** | 🟢 ACTIVE — `Projection_Simplex_Goldmann.ipynb` complété et exécuté à partir des PDFs du cours. Rendu TP (Notebook) fixé au 18/05 (23h59). Soutenance confirmée le 04/06 à 15h15 (PC 3). Tâches TickTick `69f8a9288f086d028b4d7b74` et `69f8a9298f0885d1c6763497` à jour. | Relecture finale du notebook + rendu. · `🎓 X/📅 Agenda` |
| **Sinner Visualizer** | ✅ STABLE — `sinner_analysis_1080p_fr.mp4` delivered. Full tactical video (1080p60) and multi-lang dashboard (v0.3.0). | Final high-res walkthrough delivered. · `$HOME/Work/X/Python_2A_P3/sinner-tactical-visualizer/` |
| **ScienCurious Lab** | 🟢 ACTIVE — Collaboration avec **Demartino KUETE** formalisée. Candidature au **Prix Gerondeau** en cours (échéance 10 mai). Tâche TickTick `69f629138f085570b2766a1f` créée. Assets Hub opérationnel (v1.1.5). | "Enseigner, ce n'est pas remplir un vase, mais allumer une flamme !" · `$HOME/Work/KpihX-Labs/Homelab/assets/` |
| **Choix de PA X24** | ✅ STABLE — Classement final des vœux P1 et P2 validé et capturé sur Gdrive_X. Attente de la validation finale sur la plateforme. | Captures dans `Gdrive_X/X/3A/Admin/Captures_Plateforme_Voeux/` · `$HOME/.agents/skills/kpihx/references/3a_course_planning.md` |
| **Sovereign Email Hub**| 🚧 PLANNING — Establishment of `@kpihx-labs.com` email universe. Analysis completed: Cloudflare Routing vs. Full Sovereign Server. | Propose implementation plan for Path A · `$HOME/.agents/skills/k-context/references/sovereign-email-universe-vision.md` |
| **KpihX-Labs Vision** | 🔴 **ABSOLUTE PRIORITY #1** — Technical Foundation: K3s distributed cluster, Tailscale Mesh, Kasm WebTop agent visual sandbox | Test WebTop locally · `$HOME/.agents/skills/k-context/references/KpihX-Labs.md` |
| **Sovereign Learning Lab**| 🔴 **ABSOLUTE PRIORITY #2** — Convergent Vision: Real-time visual assistant (Manim/Napkin), Personal OS coaching | Propose first live lesson prototype · `$HOME/.agents/skills/k-context/references/k-personal-os-learning-laboratory-vision.md` |
| **MIE Ubisoft Case** | ✅ STABLE — v1.0.0 Study case completed, PDF generated and sent. | Finalized analysis and style refinement. · `$HOME/Gdrive_X/X/2A/P3-IME/DM/` |
| **MCP Visual Validation** | 🚧 PLANNING — Transform `send`/`create` across MCPs (TickTick, WhatsApp, LinkedIn, Mail) to launch a visual editor for review before execution | Propose architecture · `$HOME/.agents/skills/k-context/references/mcp-visual-validation-vision.md` |
| **kpihx** | ✅ STABLE — v2.6.2 Sovereign Hub with father split, manuscript archive layer, and CAF identifier `8006862 C`. | Maintain sovereign freshness and provenance discipline · `$HOME/.agents/kpihx/` |
| **sh (KpihX-Labs)** | ✅ STABLE — v2.1.2 Universal Orchestrator — root Makefile, `ksh` dispatcher, multi-remote sync | `ksh status` · `$HOME/Work/sh/` |
| **Homelab (KpihX-Labs v3.1)** | ✅ STABLE — Modular Node Architecture — `hsh` dispatcher, dual-link docs, DKD Vault | `hsh status` · `$HOME/Work/Homelab/sh/` |
| **ai_voice** | 📑 UNDERSTANDING — whisper-overlay fork | research state, propose AGENTS.md · `$HOME/Work/AI/ai_voice/` |
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs · `$HOME/.agents/assets/` |
| **bw-proxy** | ✅ STABLE — v3.6.0 Meticulous Test Suite & Schema Hardening: 100% verified Scoped Union Fetch (no orphans), fixed collection creation bug, and successfully tested blind refactoring on organization items. | `push audit` finalized v3.6.0 · $HOME/Work/AI/MCPs/bw_mcp/ |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools · `$HOME/Work/AI/MCPs/mem_mcp/` |
| **mail workspace** | 🧠 BRAINSTORM — cli/mcp/admin/skill split for mail | scaffold + contracts + generator · `$HOME/Work/AI/mail/` |
| **sh_mcp** | 🧠 BRAINSTORM — agent sandbox MCP (homelab); future user-side **sh-exec** separate | vision · `$HOME/.agents/skills/k-context/references/sh-mcp-agent-sandbox-vision.md` · code TBD · `$HOME/Work/AI/MCPs/` |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test | `$HOME/.agents/references/` |
| **envision (PSC)** | ✅ STABLE — final report layout with dual logos aligned, branding complete, and project links pushed to main and presentation repo (`ee3398d`). Ready for soutenance prep from the stabilized dense-RAG baseline. | `push audit` · `$HOME/Work/X/envision/envision/` |
| **flow** | 🟢 ACTIVE — `k_env` extracted out of tree into its own framework repo; `flow` packaging no longer claims `k_env` CLI/tests | continue voice-kernel work as `flow`-only and add a local dependency on `$HOME/Work/Frameworks/k_env/` only if/when runtime imports are introduced · `$HOME/Work/AI/flow/` |
| **k_env** | 🟢 ACTIVE — autonomous framework repo scaffolded under `Work/Frameworks/`; migrated package + tests now live in their own git root and pass locally | refine autonomous docs/API after extraction and continue the post-SecretStrategy cleanup from the Gemini intent baseline · `$HOME/Work/Frameworks/k_env/` |
| **k-conf** | 🟢 ACTIVE — Meta-config framework renamed from `framework` to `k-conf` (package `k_conf`); global import refactor and variable replacement completed | internal dev in `$HOME/Work/AI/flow/src/k_conf/` |
| **Visual Content Engine** | 🧠 BRAINSTORM — LLM + Manim + FLUX.2 pipeline for educational video production | vision docs written · `$HOME/.agents/skills/k-context/references/vision/` |
| **linux-file-masterclass** | 🟢 ACTIVE — code-first visual Linux masterclass scaffolded in `KpihX-Labs`: Remotion + React + D3 scenes, French narration generation, synchronized subtitles, and master render pipeline now exist under one repo-local workflow. | finish the first full master render, inspect the visual storytelling scene by scene, then push the grammar from “good animated explainer” toward “self-explanatory visual cinema” · `$HOME/KpihX-Labs/linux-file-masterclass/` |
| **Linguaskill 2026** | ✅ STABLE — Results received (Score 187, C1). Certificate renamed and archived in Gdrive_X. Official submission sent to DLC. | Validation successful. · `$HOME/Gdrive_X/KpihX/Academic/LinguaSkill/` |
| **AGY account setup** | ✅ STABLE — v1.23.2 UI changes identified: Planning Mode activation via unified selector or `Ctrl + .` documented in `k-code`. | confirm unblocking of auth flow if still pending · `$HOME/.gemini/antigravity/` |
| **ai_dispatcher** | 🟢 ACTIVE — dispatcher now binds the default local Ollama endpoint (`127.0.0.1:11434`), selects X hosts by free GPU VRAM, self-cleans stale SSH tunnels, enforces a single local instance with `flock`, and exposes `SYNCING`/`READY` health states. | validate next relaunch reaches `READY` without timeout drift and keep bootstrap aligned to native tags only · `$HOME/Work/X/ai_dispatcher/` |
| **X-IA Cluster** | 🟢 ACTIVE — shared launcher now treats `$HOME/.ollama/models` as canonical and syncs `/tmp/$USER/ollama_models` back to NFS periodically and on exit; the persistent store now carries native `qwen3.5:latest` + `mistral-small:latest`. | confirm NFS stays minimal after another host switch/restart · `$HOME/Work/X/ai_cluster/` |
| **Sovereign Bookmarks** | ✅ STABLE — v1.1.0 Sovereign hierarchy: consolidated legacy bookmarks, shortened titles, categorized into labs/academic/tools/etc.
- **Current Baseline:** `assets/bookmark.html` (Sovereign hierarchy).
- **Legacy Reference:** `assets/bookmark.old.html` (Original dump).
- **Recent Export:** `assets/favorites_5_2_26.html` (Dump from 2026-05-02).
- **Source of Truth:** `assets/bookmark.md` (Markdown hierarchy).
 | Integrated as assets in `k-browser` skill. · `$HOME/.agents/skills/k-browser/assets/` |
| **k-classification** | ✅ STABLE — v1.0.0 Sovereign Framework for general data organization (Drive, files, images, bookmarks). | Formalized Semantic/Structural/Integrity pillars. · `$HOME/.agents/skills/k-classification/` |
| **ts-proxy** | 🟢 ACTIVE — v1.5.1 Sovereign HITL Hardening: Centralized async HITL engine (Web + TUI Fallback), @require_approval decorator integration, and automated mock testing. | `make uv-check` passed v1.5.1 · `$HOME/Work/KpihX-Labs/Docker-Host/ts_proxy/` |
| **PVE / vm_debian** | 🟢 ACTIVE — live CT-vs-VM DNS audit completed on `kpihx-pve`: CT `100` (`homelab`) resolves through Proxmox-managed static resolvers, while VM `101` (`pve-debian`) still ends up with `systemd-resolved` reporting `No DNS servers known` (`ISS-20260508-001`). | Patch `install.sh` DNS/resolved handling, then redeploy VM 101 and revalidate `curl raw.githubusercontent.com`. · `$HOME/KpihX-Labs/PVE/vm_debian/` |
| **Fluid** | 🟢 ACTIVE — Deep lifecycle transparency pass completed in `AA.md`: reconstructed the real Ubuntu → PVE → service lifecycle from scripts, exposed the current root-owned `state/fluid-state.json` permission break, the `fluid-node-pve` profile mismatch (`ubuntu` instead of `pve`), and the missing `fluid.yml` blocker for the local `ts_proxy` example. | Review `AA.md`, fix state ownership + host profile semantics, then add a first real `fluid.yml` service example (starting with `ts_proxy`). · `$HOME/KpihX-Labs/Fluid/fluid/` |
| **whats_proxy** | 🟢 ACTIVE — v1.0.0 Infrastructure Contract defined: 100% transparent API, port 1140 unified bridge, and robust discovery/filtering registry. | Hardened CONTRACT.md · `$HOME/Work/KpihX-Labs/Fluid/whats_proxy/` |
| **Gdrive_X Reorganization** | ✅ STABLE — Full controlled migration executed on 2026-05-03. Final roots: `.Trash-1000`, `Google AI Studio`, `KpihX`, `X`, `ENSPY`, `Pro`, `KpihX-Labs`, `Photos`, `ToPrint`, plus review roots. API validation passed with zero forbidden names, zero non-ASCII paths, zero duplicate Drive paths, zero singleton dirs outside exceptions/review, zero `_DUP*` residues in main roots, and zero dirty `..`/`.pdf.pdf`/browser suffix residues. | Review `_Purge_Review_2026-05-03/` and `_Review_Duplicates_2026-05-03/` deliberately before any real deletion. · `$HOME/Gdrive_X/` |
| **Julius Caesar Exam Prep** | ✅ STABLE — Completed the comprehensive revision guide `revision_anglais.md` and `cheat_sheet.md`, generated PDF using `k-latex`, created ultra-compact `Revision` template with automated `Makefile`. | Ready for print and review. · `$HOME/Gdrive_X/ToPrint/` |

| **[ARCHIVE]** | Stable/completed items condensed | AppArmor (Option A done); Centralized Hooks; Optimization map; QMD stable; DXO accepted; bw-env+ollama-ipex closed; `.agents/` refonte done |

## Brainstorm Registry

| File | Type | Topic |
|------|------|-------|
| `references/k-personal-os-learning-laboratory-vision.md` | Vision | Convergence of Homelab, Coach, and Learning Lab into the Sovereign Personal OS |
| `references/mcp-visual-validation-vision.md` | Brainstorm | Transform `send`/`create` MCP tools to launch a visual editor for user validation before execution |
| `references/sovereign-email-universe-vision.md` | Vision | Establishment of `@kpihx-labs.com` email universe for KpihX-Labs (Routing vs. Hosting) |
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
| `references/KpihX-Labs.md` | Vision | KpihX-Labs complete distributed cloud vision: Physical, Virtual, and Supreme Abstraction Layer (`docker-host`), Serverless MCPs, and ESO |

## What's up (context-only slice)

When KπX asks *what's up* **context** / **projects** (or the first step of a full *what's up*), load this file and present — **exhaustively**, in prose + tables as needed.
This slice is **not a summary**: report facts with **maximum available detail**, avoid synthesis compression, and avoid asking KπX to request extra details in a second pass.
Run this slice as a **batch deep exploration**: keep opening relevant records until the context is complete enough to avoid information loss.

1. **`## Active Projects`** — every row: status, next action, folder path; expand any row that needs narrative (blockers, recent commits, CI).
2. **`## Session Log`** — newest-first; include enough rows that recent kernel/work threads are visible; point to `references/log.md` for deeper history.
   - For issue work: keep the line concise and include explicit issue ID references to `references/issues.md`.
3. **`## Brainstorm Registry`** — each registered file/folder: one-line topic + why it matters now if inferable.
4. **`## Active TODOs`** if non-empty.

Do **not** fold mail/WhatsApp/TickTick/Telegram into this same response when the full *what's up* ladder applies — **AGENTS.md → What's up** mandates **one domain per turn**.

## Session Log

| 2026-05-18 | [ANTIGRAVITY] | v2.87.6 — GNOME 50 compatibility: patched KeepAwake@jepfa.de metadata to support shell version "50", disabled global GNOME extension version validation via GSettings, and logged as ISS-20260518-001. |
| 2026-05-16 | [CURSOR] | v2.87.5 — Antigravity “Open Cloud”: `k-code` bootstrap for Continue (`~/.continue/config.yaml` Mistral + `${{ secrets.MISTRAL_API_KEY }}`), global rules symlink `00-kpihx-AGENTS.md`, skills stub, `~/.continue/.env` template, optional desktop `kpihx-antigravity-open-cloud.desktop`. |
| 2026-05-16 | [CURSOR] | v2.87.4 — Transit purge + Gdrive_X filing: `Attestation_Honneur_Non_Revenu_KAMDEM.pdf` → `Gdrive_X/KpihX/Scholarships/Bourse_Eiffel/`; Data Analysis Python TD8 handin bundle → `Gdrive_X/X/2A/P3/Data_Analysis_Python/PC1_CSC43042EP_td8_1_handin/` (DM7 PDFs, semaine 07, zip); removed `cursor_3.4.20_amd64.deb`; moved `m365_inbox.json` → `Gdrive_X/KpihX/Others/m365_cli_exports/`; emptied `Documents/`, `Downloads/`, `Pictures/Screenshots`, `Videos/Screencasts`. External HDD: `Backups_Ubuntu_Workstation` confirmed directory when disk online. |
| 2026-05-16 | [CURSOR] | v2.87.3 — k-optim applied: `ksh status` shows `clean-system` OK (2026-05-15) but `backup-restore.service` FAILED on `Backups_Ubuntu_Workstation` mkdir path; logged as `ISS-20260516-001`. Meta: `make -C $HOME/.agents audit` ALL_OK. Homelab: `"$HOME/Work/KpihX-Labs/Homelab/sh/hsh" status` => PVE+LXC offline. |
| 2026-05-15 | [CURSOR] | v2.87.2 — `AGENTS.md` chat-visuals NO EXCEPTIONS block + mandatory-structure cross-link; `KpihX-Labs/AGENTS.md` hard link → symlink `.agents/AGENTS.md` + File Routing kernel layout. |
| 2026-05-14 | [CODEX] | v2.87.1 — `linux-file-masterclass`: scaffolded a new code-first Linux visual masterclass under `KpihX-Labs` with Remotion/React/D3 scenes, French `edge-tts` narration, synchronized SRT generation, still rendering, and a full `render:master` pipeline; hardened TTS resolution against pyenv drift and pinned Remotion-compatible versions. |
| 2026-05-12 | [ANTIGRAVITY] | v2.87.0 — `Sinner Tactical Visualizer`: Finalized project with High-Res (1080p60) multi-language support (EN/FR). Updated web visualizer with language toggle and high-fidelity narration (v0.3.0). |
| 2026-05-12 | [ANTIGRAVITY] | v2.86.9 — `Sinner Tactical Visualizer`: Finalized high-fidelity video `sinner_final_analysis.mp4`. Integrated Manim animations with `edge-tts` narration. Updated web visualizer with narration sync (v0.2.0). |
| 2026-05-12 | [ANTIGRAVITY] | v2.86.8 — `Sinner Tactical Visualizer`: Developed a high-end interactive visualizer for Rome Masters 2026 tactical analysis. Implemented GSAP-driven web dashboard, SVG court geometry, and Manim mathematical animation. Finalized with `k-final` pass (v0.1.0). |
| [SUMMARY] | — | v2.86.7..v2.86.4 Rome Masters web, PVE/vm_debian cloud-init/resolved DNS fixes (ISS-20260508-001); v2.86.3..v2.86.0 Fluid AA.md, hypridle/greeter fixes (ISS-20260507-003); older -> references/log.md |

## References

- `references/agentic-architecture-brainstorm.md` — hot/cold context and architecture notes
- `references/mail-tooling-rewrite-brainstorm.md` — mail cli/mcp/admin/skill split vision and secret handling
- `references/sh-mcp-agent-sandbox-vision.md` — sh-mcp agent sandbox MCP + future sh-exec (brainstorm)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY])
- `references/sciencurious_lab.md` — ScienCurious Lab vision and collaborative structure (Education/AI)
- `references/insights.md` — autonomous general runtime insights (cross-domain mistakes, fixes, and anti-repeat guidance)
- `references/issues.md` — append-only full issue ledger (diagnosis/fix attempts with full commands and outputs; newest-first)
- **Other `references/*.md`** — durable brainstorms and WIP project visions until promoted to a skill or `$HOME/Work/`

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-context/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-context/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-18 | [ANTIGRAVITY] | v2.87.6 — Session Log & Changelog: GNOME 50 compatibility fixes for KeepAwake (ISS-20260518-001). |
| 2026-05-16 | [CURSOR] | v2.87.5 — Session Log: Antigravity + Continue Open Cloud bootstrap (`bootstrap_open_cloud.sh`, Mistral secrets via `~/.continue/.env`). |
| [SUMMARY] | — | v2.87.4 Gdrive_X filing + home purge; v2.87.3 k-optim + ISS-20260516-001; v2.87.2 AGENTS symlink; v2.87.1 linux-file-masterclass; v2.86.8.. → `references/log.md` |

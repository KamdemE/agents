---
name: "k-context"
description: "KpihX HOT context - auto-injected by hooks for Colab/Build. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: "KpihX"
  version: "3.7.0"
  sciencurious-lab-banner: "920x420"
allowed-tools: "Bash(*), *"
---

# KπX — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Loading:** Auto-injected by OpenCode hooks for Colab/Build (`<startup-context>` block). If you don't see it in context AND you are not Explore/Lite, load manually.
> - **Agent-memory update mandate:** update k-<agent> skill immediately after any agent-specific learning.
> - **🔴 ENGLISH ONLY (Mandatory — ABSOLUTE):** ALL files, code, comments, docs, skills, scripts, configs, commits, AND chat responses MUST be in English. No other language unless KπX explicitly asks. Enforced in `AGENTS.md`, `rules/file-governance.md`, `rules/response-format.md`.
> - **🔴 Permanent Directive Capture (Mandatory):** When KπX says "from now on", "always", "never" — agent MUST immediately write it to the correct `rules/`, `AGENTS.md`, or skill file. Never just acknowledge. See `rules/tool-discipline.md` → Permanent Directive Capture.
> - **🔴 Proactive Skill Update (Mandatory):** After learning a new pattern, fixing an issue, or discovering a configuration quirk — immediately update the relevant `k-*` skill. Never keep knowledge only in conversation context. See `rules/tool-discipline.md` → Proactive Skill Update.
> - **🔴 `.bak` Rule (Mandatory):** Backups go to `/tmp/` with `.bak` extension. Never next to original. Never delete. See `rules/file-governance.md` → Pre-edit `.bak` Backup Rule.
> - **🔴 💡 SUGGESTIONS (≥3) IS THE ONLY MANDATORY FOOTER SECTION (Mandatory):** Every turn MUST end with a 💡 Suggestions section containing ≥3 proactive suggestions. Other sections (Commentaires, Remarques, TODOs) are pertinence-based — show them when relevant. See `rules/response-format.md` → Footer Sections.
> - **Zero-Deletion Policy (Mandatory):** NEVER delete logs or historical entries. If a section (Session Log, Changelog) reaches its limit, the older entries MUST be copied to `references/log.md` BEFORE the main file is compacted. Every reduction MUST be a copy-then-summarize, never a cut. [GEMINI]
> - **Frozen log append-only (Mandatory):** Once written, lines in **`references/log.md`**, **`references/issues.md`**, and any rotated archive are **immutable** — no in-place edits or deletions. Corrections = **new append-only lines** in live sections; rotation = **new** archive lines only, then bounded **`[SUMMARY]`** on the live section. Same rule for skill **`references/log.md`** files elsewhere.
> - **Shared tmux collaboration (Mandatory):** Privileged/interactive shell (`sudo`, SSH passphrase, prompts) → **`k-tmux`**: reuse or create a short tmux session, `send-keys`, poll pane **≥30s** (no chat handoff before); never **`sui`**. Full: **`k-tmux/SKILL.md` → Shared interactive gate** · short: **AGENTS.md → Tool Discipline**.
> - **Issues Transparency Rule (Mandatory):** every attempt to understand/fix any issue (system, filesystem, crashes, thermal, noisy processes, services, etc.) MUST be appended to `references/issues.md` with full command history and outputs. No deletion, no compaction.
> - **Issues Pre-check Rule (Mandatory):** BEFORE creating a new issue, agent MUST `grep`/`rg` `references/issues.md` for existing or related issues. If a matching issue exists, do NOT duplicate — update the existing row (Status, Updated, new Evidence/Commands/Results) instead. If no match found, create new row at the top.
> - **Issues Proactive Update Rule (Mandatory):** whenever a problem is solved, deferred, or its status changes — agent MUST proactively update the corresponding `issues.md` row with the new Status, Updated timestamp, and relevant Actions/Results. Follow the exact table structure without breaking columns.
> - **Auto-Update Rule (Mandatory):** agents must update `references/issues.md` and relevant context sections automatically without asking KπX.
> - **Session Log Linking Rule:** `## Session Log` keeps short summaries only and each issue-related entry must include exact issue IDs (e.g., `ISS-YYYYMMDD-XXX`) that point to `references/issues.md`.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify KπX of any URGENT tasks found in `k-context` upon loading.
> **Kernel Sync Rule:** ALWAYS run `make check` in `.agents/` and fix any errors BEFORE proposing session finalization (`git commit` + `make push`).
> **KπX directive — `.agents` VCS (2026-04-10):** Autonomous `git commit`, `git push`, and `make push` on `$HOME/.agents/` are allowed by default **after** `make check` passes, unless KπX explicitly says not to finalize in the current session.
> **Project finalization:** When finishing work on a **project repository** (explicit "finalize" / "clean" / "close", or you judge the slice done), **load `k-final`** and execute its full checklist — not a mental shortcut. See **AGENTS.md → Session & Memory** and `k-project` / `k-git` / `k-context` cross-links.
> **Skills & kernel homogeneity (GRAVÉ):** Before creating or editing any skill, `AGENTS.md`, or hub `references/` file — inspect first (`tree $HOME/.agents/skills/`, `rg`), find the owning `k-*` skill, extend it; never duplicate identity paths or domain tables; create new files only when nothing covers the topic. Full rule: **AGENTS.md → Skills & kernel homogeneity — GRAVÉ**.
> TODOs: only KπX adds; agents execute + remove.
> **Project rule:** before touching any project — if not already in context — read its folder's `.md` files in order: `AGENTS.md` → `CHANGELOG` → `README` → `TODO`. Never work on a project without knowing its current state. Project rows and session log entries include the folder path for this purpose.
> **Brainstorms & research:** `references/` — load on demand. **Durable ideas and in-flight project visions** (not yet promoted to a skill or `$HOME/Work/` doc) are stored there as standalone `.md` files; see also **AGENTS.md → Brainstorm & vision archive**.
> **Insights governance (k-context specific):** maintain `references/insights.md` as the general cross-domain operational memory for recurring mistakes, repeated dead-end actions, and validated workarounds. Update it autonomously whenever a durable pattern is learned.
> **Brainstorm Registry Rule (MANDATORY):** every new idea file added under `references/` (including nested subfolders such as `references/mac-studio/`) MUST be explicitly registered in `## Brainstorm Registry` below, with one entry per file.
> - **Archive standard:** superseded references and merged-away originals move to `tmp/references/` (temporary — may be cleaned by k-optim). Skills that have been deactivated remain in `skills/deactive/`. Update `## Brainstorm Registry` entries to `[ARCHIVED]` when originals are archived.
> - **Visual reference assets:**
>   - `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.
>   - `assets/sciencurious_lab.png` — branding reference for ScienCurious Lab (ln → Assets Hub).

## Active TODOs

| Task | IMPORTANT | URGENT | CONCERNED | Date | Description |
|------|-----------|--------|-----------|------|-------------|
| **GNOME extensions audit** | NO | NO | K-UBUNTU | — | Analyser les extensions GNOME installées et les référencer dans `k-ubuntu/SKILL.md` avec les automatismes d'installation (Extension Manager CLI). |
| **ISS-20260722-001** opencode-web upstream | NO | NO | OPENCODE | **2026-08-12** | Vérifier si le fix upstream **PR #28434** (MCP disabled state persistence) a été mergé dans opencode. Les settings web sont perdus au restart car stockés en `localStorage` browser uniquement (pas de persistance serveur). Si fix upstream dispo → tester et refermer l'issue. Sinon repousser le check de 3 semaines. Liens: [#23934](https://github.com/anomalyco/opencode/issues/23934), [#28428](https://github.com/anomalyco/opencode/issues/28428), PR [#28434](https://github.com/anomalyco/opencode/pull/28434). |
| **tg-homelab (k-pve)** | NO | NO | PVE | — | Old `tg-homelab.service` purged. Rebuild as k-pve arch: Telegram bot for PVE monitoring, server logs, backup notifications. Define scope vs `tg-bot` (workstation) before implementation. |
| **rclone client_id** | YES | NO | GDRIVE | 2026 | Rclone's shared Google Drive client_id is being retired in 2026. Must create own OAuth client_id in Google Cloud Console + `rclone config reconnect` for both gdrive: and gdrive-x: before it stops working. See k-rclone/SKILL.md for procedure. |
| **ts-proxy refactor** | NO | NO | TS-PROXY | — | Folder moved to `$HOME/KpihX-Labs/ts_proxy/` and reinstalled via `uv`. Remaining: Migrate secrets from `~/.ts_proxy/secrets.json` to `~/.config/ts-proxy/.env`. |

## Active Projects

| **colab** | 🟢 ACTIVE — P1 ACP core + P4 Mistral router mocked tests done. 69 tests green (`make check`). `IndexError` hardened in router. Next: P2 tmux polish, P6–P8 voice E2E. | `$HOME/KpihX-Labs/colab/` |
| **KπX Fit (fun rhythm)** | 🟢 ACTIVE — **Mois 1** depuis 2026-05-24: SU–FR `2×100` corde + **pair=20 pompes / impair=gainage 1 min** + `2×100`; **sam vélo seul**; semaine CROUS midi/soir; TickTick = 3 habits + sam task (see `fit.md`). | Créer habits TickTick ou `go` tick-mcp · `$HOME/.agents/skills/kpihx/references/fit.md` |
| **Optimisation** | 🟢 ACTIVE — `Projection_Simplex_Goldmann.ipynb` complété et exécuté à partir des PDFs du cours. Rendu TP (Notebook) fixé au 18/05 (23h59). Soutenance confirmée le 04/06 à 15h15 (PC 3). Tâches TickTick `69f8a9288f086d028b4d7b74` et `69f8a9298f0885d1c6763497` à jour. | Relecture finale du notebook + rendu. · `🎓 X/📅 Agenda` |
| **Sinner Visualizer** | ✅ STABLE — `sinner_analysis_1080p_fr.mp4` delivered. Full tactical video (1080p60) and multi-lang dashboard (v0.3.0). | Final high-res walkthrough delivered. · `$HOME/Work/X/Python_2A_P3/sinner-tactical-visualizer/` |
| **ScienCurious Lab** | 🟢 ACTIVE — Collaboration avec **Demartino KUETE** formalisée. Candidature au **Prix Gerondeau** en cours (échéance 10 mai). Tâche TickTick `69f629138f085570b2766a1f` créée. Assets Hub opérationnel (v1.1.5). | "Enseigner, ce n'est pas remplir un vase, mais allumer une flamme !" · `$HOME/Work/KpihX-Labs/Homelab/assets/` |
| **Choix de PA X24** | ✅ STABLE — Classement final des vœux P1 et P2 validé et capturé sur Gdrive_X. Attente de la validation finale sur la plateforme. | Captures dans `Gdrive_X/X/3A/Admin/Captures_Plateforme_Voeux/` · `$HOME/.agents/skills/kpihx/references/3a_course_planning.md` |
| **Sovereign Email Hub**| ✅ **INBOUND + OUTBOUND + DMARC** — 3 send-as; `_dmarc` `p=none` + `rua→kapoivha`. | Aggregate reports in kapoivha inbox · `outbound-setup-status.md` |
| **Social APIs (media)** | ✅ STABLE — hub **`k-media`**; **`k-x`** + **`k-meta`** JSON LIVE (outside git); no **`k-publish`** skill. | X credits · Meta System User · `social-dev-platforms.md` |
| **KpihX-Labs Vision** | 🔴 **ABSOLUTE PRIORITY #1** — Technical Foundation: K3s distributed cluster, Tailscale Mesh, Kasm WebTop agent visual sandbox | Test WebTop locally · `$HOME/.agents/skills/k-context/references/KpihX-Labs.md` |
| **Sovereign Learning Lab**| 🔴 **ABSOLUTE PRIORITY #2** — Convergent Vision: Real-time visual assistant (Manim/Napkin), Personal OS coaching | Propose first live lesson prototype · `$HOME/.agents/skills/k-context/references/k-personal-os-learning-laboratory-vision.md` |
| **MIE Ubisoft Case** | ✅ STABLE — v1.0.0 Study case completed, PDF generated and sent. | Finalized analysis and style refinement. · `$HOME/Gdrive_X/X/2A/P3-IME/DM/` |
| **MCP Visual Validation** | 🚧 PLANNING — Transform `send`/`create` across MCPs (TickTick, WhatsApp, LinkedIn, Mail) to launch a visual editor for review before execution | Propose architecture · `$HOME/.agents/skills/k-context/references/mcp-visual-validation-vision.md` |
| **kpihx** | 🟢 ACTIVE — v2.7.4 Sovereign Hub + transport IDF (`Navigo` `37096403`, AST `5920537`, chemins `Gdrive_X/KpihX/Fr/`). | Forms/docs → `identity.md` + `legal.md` · `$HOME/.agents/skills/kpihx/` |
| **sh (KpihX-Labs)** | ✅ STABLE — v2.1.2 Universal Orchestrator — root Makefile, `ksh` dispatcher, multi-remote sync | `ksh status` · `$HOME/Work/sh/` |
| **Homelab (KpihX-Labs v3.1)** | ✅ STABLE — Modular Node Architecture — `hsh` dispatcher, dual-link docs, DKD Vault | `hsh status` · `$HOME/Work/Homelab/sh/` |
| **ai_voice** | 📑 UNDERSTANDING — whisper-overlay fork | research state, propose AGENTS.md · `$HOME/Work/AI/ai_voice/` |
| **Voice Kernel (Ollama)** | 🧠 BRAINSTORM — Centralize STT/TTS as a sovereign cross-agent module using Ollama as the LLM backbone. Distributable to any agent runtime (OpenCode, Codex, Cline, Copilot, Gemini, Vibe) without vendor lock. Models local (whisper.cpp GPU + Piper ONNX + Ollama). | Design module interface · `$HOME/.agents/skills/k-context/references/voice-kernel-ollama-vision.md` |
| **Project Sovereignty** | 🚧 PROPOSED — 128GB Mac Studio | Draft reference docs · `$HOME/.agents/assets/` |
| **bw-proxy** | ✅ STABLE — v3.6.0 Meticulous Test Suite & Schema Hardening: 100% verified Scoped Union Fetch (no orphans), fixed collection creation bug, and successfully tested blind refactoring on organization items. | `push audit` finalized v3.6.0 · $HOME/Work/AI/MCPs/bw_mcp/ |
| **mem_mcp** | 🚧 scaffold only — uv init, config.py, standard files, first push done | implement server.py + MCP tools · `$HOME/Work/AI/MCPs/mem_mcp/` |
| **mail workspace** | 🧠 BRAINSTORM — cli/mcp/admin/skill split for mail | scaffold + contracts + generator · `$HOME/Work/AI/mail/` |
| **sh_mcp** | 🧠 BRAINSTORM — agent sandbox MCP (homelab); future user-side **sh-exec** separate | vision · `$HOME/.agents/skills/k-context/references/sh-mcp-agent-sandbox-vision.md` · code TBD · `$HOME/Work/AI/MCPs/` |
| **Agentic architecture** | 🧠 Brainstorm done — hot/cold framework, 3-layer model, MCP qualification test | `$HOME/.agents/references/` |
| 2026-05-27 | [CLINE] | **Mail recap kapoivha → Telegram** — `gws` CLI fetched 16 inbox messages (14 unread, 2 IMPORTANT). MarkdownV2 formatted recap sent to KπX via bot `KpihX` (msg_id=176). Key items: Lebara eSIM support reply (IMPORTANT), IDF Mobilites code, 4 security alerts (Google×2, Microsoft×2, Venice.ai), DMARC report, 8 other notifications. |

| **envision (PSC)** | ✅ STABLE — final report layout with dual logos aligned, branding complete, and project links pushed to main and presentation repo (`ee3398d`). Ready for soutenance prep from the stabilized dense-RAG baseline. | `push audit` · `$HOME/Work/X/envision/envision/` |
| **Terminal Editing Stack** | 🟢 ACTIVE — Vim 9.1 + Neovim 0.11; 31 nvim plugins (Lazy.nvim); LSP 8 servers; opencode.nvim; tmux plugins étendus; k-nvim skill. | Premier lancement nvim interactif à faire · `$HOME/.agents/skills/k-nvim/` |
| **flow** | 🟢 ACTIVE — `k_env` extracted out of tree into its own framework repo; `flow` packaging no longer claims `k_env` CLI/tests | continue voice-kernel work as `flow`-only and add a local dependency on `$HOME/Work/Frameworks/k_env/` only if/when runtime imports are introduced · `$HOME/Work/AI/flow/` |
| **k_env** | 🟢 ACTIVE — autonomous framework repo scaffolded under `Work/Frameworks/`; migrated package + tests now live in their own git root and pass locally | refine autonomous docs/API after extraction and continue the post-SecretStrategy cleanup from the Gemini intent baseline · `$HOME/Work/Frameworks/k_env/` |
| **k-conf** | 🟢 ACTIVE — Meta-config framework renamed from `framework` to `k-conf` (package `k_conf`); global import refactor and variable replacement completed | internal dev in `$HOME/Work/AI/flow/src/k_conf/` |
| **Visual Content Engine** | 🧠 BRAINSTORM — LLM + Manim + FLUX.2 pipeline for educational video production | vision docs written · `$HOME/.agents/skills/k-context/references/vision/` |
| **linux-file-masterclass** | 🟢 ACTIVE — code-first visual Linux masterclass scaffolded in `KpihX-Labs`: Remotion + React + D3 scenes, French narration generation, synchronized subtitles, and master render pipeline now exist under one repo-local workflow. | finish the first full master render, inspect the visual storytelling scene by scene, then push the grammar from “good animated explainer” toward “self-explanatory visual cinema” · `$HOME/KpihX-Labs/linux-file-masterclass/` |
| **Project 𝛱** | 🟢 ACTIVE — Strategy (`IDEAS`, `STATE_OF_THE_ART`, `MANIFEST`). **Product → `𝛱/live/`** v0.2.1: light agentic chain (one LLM call hot path), `VisualPlan` → Scene IR → Canvas2D motion loop; real-time/latency rules in `TODO.md` + `docs/AGENTIC_ARCHITECTURE.md`. | Sprint 3: first proof concept (gradient descent live path) · `$HOME/KpihX-Labs/𝛱/live/` |
| **Linguaskill 2026** | ✅ STABLE — Results received (Score 187, C1). Certificate renamed and archived in Gdrive_X. Official submission sent to DLC. | Validation successful. · `$HOME/Gdrive_X/KpihX/Academic/LinguaSkill/` |
| **AGY ecosystem** | 🟢 ACTIVE — Hub launch fix: `agy-hub.sh` (`--no-sandbox` + X11 on Wayland); `k-code` v4.3.7. Sandbox 4755 OK. Optional: `apt remove antigravity`, refresh GNOME dash tiles. | `$HOME/.agents/skills/k-code/references/agy.md` |
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
| **KpihX-Ubuntu (Dell 7640)** | 🟡 **MONITORING** — Display/projector **`ISS-20260515-001`** (runbook in issues Next checkpoint). Battery wear **~67%** **`ISS-20260526-001`**. Terminal D-Bus activation **`ISS-20260706-001`** (FTD). Charge stop **80%** sysfs OK (75% start). | `powerprofilesctl` after reboot · `references/issues.md` |
| **Edge agent (CDP)** | ✅ **STABLE** — Live test + manual cleanup done; favorites test folders removed by KπX; **`k-browser` v1.3.0** Leave no trace; runbook in techskills + insights. | `edge-agent-cdp-setup.md` · `k-browser/SKILL.md` |
| **whats_proxy** | 🟢 ACTIVE — v1.0.0 Infrastructure Contract defined: 100% transparent API, port 1140 unified bridge, and robust discovery/filtering registry. | Hardened CONTRACT.md · `$HOME/Work/KpihX-Labs/Fluid/whats_proxy/` |
| **whats-proxy (CLI)** | ✅ STABLE — v0.2.0 non-MCP WhatsApp CLI proxy: full whats-mcp catalog (65 actions) as JSON-RPC over Bun+Baileys daemon, tg-proxy-style (do/admin, meta+data, autosave). O_EXCL daemon lock (race-proven), 31 tests, 50-check smoke, stress harness, completions, pre-commit hook. Pushed `4e31abd` github+gitlab. | Next: real pairing via `admin setup` on a live account · `$HOME/KpihX-Labs/whats_proxy/` |
| **Gdrive_X Reorganization** | ✅ STABLE — Full controlled migration executed on 2026-05-03. Final roots: `.Trash-1000`, `Google AI Studio`, `KpihX`, `X`, `ENSPY`, `Pro`, `KpihX-Labs`, `Photos`, `ToPrint`, plus review roots. API validation passed with zero forbidden names, zero non-ASCII paths, zero duplicate Drive paths, zero singleton dirs outside exceptions/review, zero `_DUP*` residues in main roots, and zero dirty `..`/`.pdf.pdf`/browser suffix residues. | Review `_Purge_Review_2026-05-03/` and `_Review_Duplicates_2026-05-03/` deliberately before any real deletion. · `$HOME/Gdrive_X/` |
| **Julius Caesar Exam Prep** | ✅ STABLE — Completed the comprehensive revision guide `revision_anglais.md` and `cheat_sheet.md`, generated PDF using `k-latex`, created ultra-compact `Revision` template with automated `Makefile`. | Ready for print and review. · `$HOME/Gdrive_X/ToPrint/` |
| **LiveMem** | 🧠 **BRAINSTORMING** — Brain-inspired living field paradigm (BRAINSTORMING.2): Hebbian learning, multi-modal cortices, continuous flux, internal thought loop. Code reset — architecture docs intact. Next: formal math framework + first prototype "Papa" scenario. | `$HOME/Work/AI/livemem/` |

| **[ARCHIVE]** | Stable/completed items condensed | AppArmor (Option A done); Centralized Hooks; Optimization map; QMD stable; DXO accepted; ollama-ipex closed; `.agents/` refonte done; **Lebara eSIM (S25) résolu** (post-30j wait, QR rescanné avec succès) |

## Brainstorm Registry

| File | Type | Topic |
|------|------|-------|
| **LIVE** | | |
| `references/architecture-vision.md` | Vision | KpihX-Labs cloud + Personal OS + Agentic Architecture + Sovereign Email — merged unified view |
| `references/agent-mcp-architecture.md` | Vision | Memory-curator + MCP sync + visual validation + sh-mcp + voice kernel + Google Workspace — merged unified view |
| `references/communication-automation.md` | Vision | Mail rewrite + WA core + Edge agent + Tutorial automation — merged unified view |
| `references/visual-content-pipeline.md` | Vision | Visual-first AI content: code-as-visual, k-visual orchestrator, Manim/Blender/FLUX.2, content engine, social APIs |
| `references/sciencurious_lab.md` | Vision | ScienCurious Lab — Visual Learning Engine (Manim + FLUX.2 + Wan 2.6 + TTS) |
| `references/apparmor-custom-profile.md` | Reference | AppArmor option-B mitigation profile notes |
| `$HOME/Work/AI/livemem/BRAINSTORMING.2.md` | Brainstorm | Brain-inspired living field: Hebbian learning, multi-modal cortices, continuous flux, internal thought loop, paradigm shift from models to stable kernels |
| **ARCHIVED** (in `tmp/references/` — GRAVÉ-preserved) | | |
| `tmp/references/KpihX-Labs.md` | Vision | KpihX-Labs complete distributed cloud vision — merged into `architecture-vision.md` |
| `tmp/references/k-personal-os-learning-laboratory-vision.md` | Vision | Personal OS convergence — merged into `architecture-vision.md` |
| `tmp/references/agentic-architecture-brainstorm.md` | Brainstorm | hot/cold context, 3-layer architecture — merged into `architecture-vision.md` |
| `tmp/references/sovereign-email-universe-vision.md` | Vision | @kpihx-labs.com email universe — merged into `architecture-vision.md` |
| `tmp/references/agents-memory-curator-hybrid-vision.md` | Brainstorm | hybrid memory update model — merged into `agent-mcp-architecture.md` |
| `tmp/references/mcp-central-sync-vision.md` | Brainstorm | centralized MCP registry vision — merged into `agent-mcp-architecture.md` |
| `tmp/references/mcp-visual-validation-vision.md` | Brainstorm | visual MCP editor — merged into `agent-mcp-architecture.md` |
| `tmp/references/sh-mcp-agent-sandbox-vision.md` | Brainstorm | sh_mcp sandbox — merged into `agent-mcp-architecture.md` |
| `tmp/references/voice-kernel-ollama-vision.md` | Vision | STT/TTS cross-agent module — merged into `agent-mcp-architecture.md` |
| `tmp/references/google-workspace-full-mcp-vision.md` | Brainstorm | Google Workspace MCP vision — merged into `agent-mcp-architecture.md` |
| `tmp/references/mail-tooling-rewrite-brainstorm.md` | Brainstorm | mail refactor vision — merged into `communication-automation.md` |
| `tmp/references/whatsapp-wa-core-central-auth-mini.md` | Brainstorm | WA Baileys auth strategy — merged into `communication-automation.md` |
| `tmp/references/edge-agent-automation-vision.md` | Brainstorm | Edge CDP agent — merged into `communication-automation.md` |
| `tmp/references/sovereign-tutorial-automation-vision.md` | Vision | Agent-driven tutorials — merged into `communication-automation.md` |
| `tmp/references/vision/` | Brainstorm folder | Visual-first AI content creation — merged into `visual-content-pipeline.md` |
| `tmp/references/refactor.md` | Brainstorm | Skills refactoring architecture vision — superseded by done work |

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
| 2026-07-31 | [OPENCODE] | **whats-proxy v0.2.0 — daemon race ROOT-CAUSED (empirical)**: Unix sockets cannot arbitrate ownership (a 2nd `listen()` on the same path silently binds an orphaned inode — proven with a live 2-process experiment). Replaced socket-probe guard with `O_CREAT|O_EXCL` lockfile (`whats-proxy.lock`, kernel-atomic, exactly one winner), socket bound BEFORE WhatsApp connect, dispatch waits for Baileys init. Stress harness `scripts/stress.ts` + `make stress`: 48 simultaneous spawns → exactly 1 survivor, 0 orphans (10/10 runs). Also: strict `-o`/`-f` value parsing (exit 2), zsh+bash completions (65 actions), pre-commit hook (auto `make check`), hermetic smoke (50 checks). Pushed `4e31abd` github+gitlab. · `~/KpihX-Labs/whats_proxy/` |
| 2026-07-31 | [OPENCODE] | **whats-proxy v0.2.0 — non-MCP WhatsApp CLI proxy shipped**: Full `whats-mcp` catalog (65 actions) as flat JSON-RPC CLI over a Bun + Baileys daemon, mirroring tg-proxy structure (do/admin namespaces, meta+data envelope, autosave, table/json output). Daemon: Unix-socket JSON-RPC (ping/connection-info/dispatch/shutdown), auto-spawn on first `do`, exponential-backoff reconnect, store snapshot persistence, `admin setup|status|stop`. Fixes during hardening: guide category bug (registry category vs whats-mcp snake_case guesser), daemon init race (serveSocket after createSocket), smoke daemon leak (detached spawn never shut down), operator-precedence bug in smoke check, version single-sourced via version.ts ← package.json. Verified: tsc clean, 28 unit tests, 30-check smoke ×5 stable zero-leak, full lifecycle via global binary, pushed to github+gitlab (`316cda3`). · `~/KpihX-Labs/whats_proxy/` |
| 2026-07-27 | [OPENCODE] | **ASUS VE228 Display Stretch Resolution (`ISS-20260727-001`)**: Full engineering journey documented in techskills. Explored Paths A-G (DDC/CI, DRM margins, modelines, EDID injection, xrandr transform, OBS Projector, CEA-861 Overscan). Gamescope tested (worked but centered). **Final resolution: Tiling Shell** GNOME extension + `xwayland-native-scaling` + solid black wallpaper. Cleaned all intermediate packages (obs-studio, gamescope). Pushed tutorial to techskills. |
| 2026-07-27 | [OPENCODE] | **Shell startup files refactor (majeur)** : Nouvelle architecture. `.kshrc` redesigned avec 2 sections (universelle + interactive) à guards indépendants, plus de fuite d'env (`__KSHRC_LOADED` plus exporté). Les 5 fichiers partagés (zshrc/zshenv/zprofile/bashrc/profile) sont ds `k-zsh/assets/` et symlinkés depuis ~/. Chaque infra skill n'a que son `kshrc` dans assets/ (k-ubuntu, k-25). `kshrc.base` mis à jour avec le nouveau pattern. Backups des anciens dans `.agents/tmp/`. Voir session pour détails. |
| 2026-07-27 | [OPENCODE] | **Architecture corrigée** : Les 5 fichiers partagés sont dans `k-zsh/assets/` (et non k-ubuntu), les infra skills n'ont QUE leur kshrc. Symlinks fixes. k-25/assets/ nettoyé. Skills mis à jour. |
| 2026-07-27 | [OPENCODE] | **Prompt enforcer modifié** — Question part updated in all 3 files (`prompt-enforcer.js`, `prompt-enforcer-strict.js`, `core/prompt_enforcer.py`): added `IF YOU DID NOT ALREADY ANSWER IT PREVIOUSLY` condition to the question rule to prevent redundant answers. |
| 2026-07-26 | [OPENCODE] | **Commit 08c9fbf — QMD fix**: Removed fnm exec from post-commit hook. QMD index now updates successfully. Pushed to github + gitlab. |
| 2026-07-26 | [OPENCODE] | **make check refactor**: Added `check-python` (ruff+pyright) and `check-sh` (shellcheck) targets to `.agents/Makefile`. Replaced all references to `make audit` with `make check` in active skills (k-optim v3.1.0, k-context v3.6.0, k-final v1.6.0, k-uv v1.2.0, k-agents v1.3.0, k-codex, k-optim) and agents (Colab prompt, curator, pragmatic-checker). Updated pre-commit hook to `make check`. Installed `ruff` and `pyright` via `uv tool install`. |
| 2026-07-26 | [OPENCODE] | **ts-proxy path migration**: Moved ts-proxy directory from `Fluid/ts_proxy` to `~/KpihX-Labs/ts_proxy/`, adjusted its `uv` editable installation link, and verified CLI execution. |
| 2026-07-26 | [OPENCODE] | **ts-proxy warning resolution**: Resolved a hidden `pytest` `RuntimeWarning` in `test_admin_login_error` and `test_admin_login` where coroutine mocks were left unawaited. Rewrote the mocks to cleanly close and drive the coroutines using `.close()` and `.send(None)`. Bumped version to `v1.1.1` in `pyproject.toml`, successfully ran `make check` (182 passed, 0 warnings), committed, published to PyPI, and pushed to github + gitlab. |
| 2026-07-26 | [OPENCODE] | **tg-proxy & ts-proxy release**: Fixed a Telethon exception handling lint error in `tg-proxy`'s `client.py` and ran `make check` (25 passed). Fixed git permissions (root ownership of `packed-refs` and `.git/logs/HEAD` via tmux `sudo chown`) and added `push` target in `ts-proxy`'s `Makefile`, then ran `make check` (182 passed). Staged changes, committed, built, published both packages to PyPI using `with-env`, and pushed branches and tags to github + gitlab. |
| [SUMMARY] | — | *(Full entries → `references/log.md`)* |

## References

- `references/architecture-vision.md` — KpihX-Labs cloud + Personal OS + Agentic Architecture + Sovereign Email (merged)
- `references/agent-mcp-architecture.md` — Memory-curator + MCP sync + validation + sh-mcp + voice + GWS (merged)
- `references/communication-automation.md` — Mail + WA + Edge + Tutorial automation (merged)
- `references/visual-content-pipeline.md` — Visual-first AI content: code-as-visual, Manim, FLUX.2, Blender, social APIs
- `references/sciencurious_lab.md` — ScienCurious Lab vision (Visual Learning Engine — Education/AI)
- `references/log.md` — unlimited session log archive (transfer overflow here before [SUMMARY]). ⚠️ Rolling rule: use EDIT tool only — never sed, cat, echo >>, or shell redirection. Append-only via native Edit tool. Copy full entry content to log.md BEFORE any removal from SKILL.md.
- `references/insights.md` — autonomous general runtime insights (cross-domain mistakes, fixes, and anti-repeat guidance)
- `references/issues.md` — append-only full issue ledger (diagnosis/fix attempts with full commands and outputs; newest-first)
- `references/apparmor-custom-profile.md` — AppArmor option-B mitigation profile notes
- Superseded originals → `tmp/references/` (GRAVÉ-preserved, listed in Brainstorm Registry)

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-context/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-context/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-31 | [OPENCODE] | v3.7.0 — **whats-proxy CLI shipped**: Session log entry + Active Projects row for the new non-MCP WhatsApp CLI proxy (`~/KpihX-Labs/whats_proxy/`, 65 actions, Bun+Baileys daemon, github+gitlab). |
| 2026-07-26 | [OPENCODE] | v3.6.0 — **make check target**: Updated references from make audit to make check, in line with the new unified validation process. |
| [SUMMARY] | — | v3.2.0–v3.4.0 Lebara eSIM archive + Post-commit hook extended + k-workspace deactivated + k-agents from STARTUP_SKILLS + Curator GRAVÉ. Issues governance rules, Full kernel refactor. Earlier → references/log.md |

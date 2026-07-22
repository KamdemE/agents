---
name: kpihx-agents
description: KpihX global cross-agent kernel. Loaded by all agents at session start via agent-home symlink.
metadata:
  author: KpihX
  version: "3.3.0"
  scope: agent-kernel
---

# KπX — Sovereign Agent Kernel
---
## Identity

**KAMDEM Ivann** · alias `KpihX` / `KπX` · System & Ideas Architect · École Polytechnique X24 (EX240207, 2028)
→ Full identity, ancestry, academic path: `skills/kpihx/SKILL.md`

## Mantras

**Exploration:** Problem First → Why before How → Visualization
**Architecture:** 0 Trust · 100% Control | 0 Magic · 100% Transparency | 0 Hardcoding · 100% Flexibility
**Infrastructure:** 0 Loose Files · 100% `.agents/` | 0 Aliases · 100% Binaries

## Agent Modes

| Agent | Purpose | Sub-agents | Behavior |
|-------|---------|-----------|----------|
| **Colab** | Exploitation — build, deploy, refactor, execute | executor · pragmatic-checker · intent-guardian · curator | **Web Research First** — if unsure or hesitating, ALWAYS search the web before acting. Full workspace access. |
| **Explore** | Exploration — teach, research, verify | main-teacher · style-guardian · fact-verifier · scout | **Workspace-Quiet** — stay laser-focused on what KπX asks. Never explore the workspace without explicit request. Web search OK if you don't know the subject. |

## Mandatory Rules (load on first encounter, enforce every turn)

| Rule | What it says |
|------|-------------|
| `rules/web-research-first.md` | **WEB RESEARCH FIRST** — If you don't know something, are unsure, or hesitate about any fact/technology/concept: **STOP and search the web**. Do NOT guess, do NOT assume, do NOT fabricate. Use `websearch` or `google_search` before any workspace exploration. |
| `rules/file-governance.md` | **English ONLY** in files, code, comments. `$HOME`/`$USER` not hardcoded. Single source of truth. **Binaries over aliases** (bin catches all contexts). **`.agents/` centralization** (configs, services, wrappers, assets belong in the relevant skill). **`.bak` in `/tmp/` only** — backups go to `/tmp/` with `.bak` extension, never next to original, never deleted. |
| `rules/response-format.md` | **Response format** — 💬 Comments if you have an opinion, ⚠️ Remarks if issues encountered, 📋 TODOs if a plan is active (from k-context, max 3). **🚨 💡 SUGGESTIONS (≥3) = MANDATORY EVERY TURN — NEVER OMIT THIS SECTION. 🚨** Emojis mandatory everywhere. **ENGLISH ONLY — no other language in files or chat unless explicitly requested.** |
| `rules/tool-discipline.md` | **tmux sudo gate**: never raw sudo in agent shells. Identify pane before send-keys. Poll ≥30s on auth. Read before edit. No shell file ops. **Permanent Directive Capture**: persist operator's "always/never" instructions immediately to correct file — never just acknowledge. **Proactive Skill Update**: after learning a new pattern or fixing an issue, immediately update the relevant `k-*` skill — never keep knowledge only in conversation context. |
| `rules/audit-commands.md` | `uv` not `pip`. `make audit` after any `.agents/` change. `make push` not raw git push. `make check` for Python tests. Post-work checklist: audit, docs, version, sync, finalize. |
| `rules/skill-governance.md` | Before edit: inspect tree, find owning k-* skill, extend it. Version + changelog on every edit. No duplication. Insights governance. Agent ownership. |
| `rules/k-context-hygiene.md` | Session log + active projects updated proactively. Zero-deletion (append-only). Overflow → `references/log.md`. Issues → `references/issues.md`. |
| `rules/agent-registry.md` | Symlink map: how each runtime (OpenCode, Hermes, Cursor, Codex, Cline, Copilot, Gemini, Vibe, Zed, Claude) connects to `.agents/`. |
| `rules/whats-up.md` | Status digest protocol: one domain per turn. Sequence: context/mail/whatsapp/tick/tg. Full exploration mandate. |
| `rules/hermes-governance.md` | Hermes = memory/daemon only, not primary executor. Cron profile disables bash. External memory isolation. |
| `hooks/README.md` + `skills/k-hook/SKILL.md` | Lifecycle hooks: core policy at hooks/README.md, per-agent wrappers at hooks/<agent>/. Events: start, stop, tool.execute.after, messages.transform, session.compacting. |
| `rules/search-governance.md` | **Agents MUST prefer `plocate`/`locate` over `find`/`grep`/Glob for file search.** Drastic performance difference (~100×). See `skills/k-clis/references/plocate.md` for setup. Fall back to `find` only for real-time searches (files created since last `updatedb`). |

### ⚠️ Explore & sub-agents exception

The **Web Research First** rule and workspace auto-exploration do **NOT** apply to **Explore** mode and its sub-agents (`main-teacher`, `style-guardian`, `fact-verifier`, `scout`). They:
- Stay strictly focused on what KπX explicitly asks
- May do web research if the topic is unfamiliar
- **Must NOT** explore the workspace (files, glob, grep, read) unless KπX explicitly requests it

## Skills

→ `skills/` — domain-specific procedural knowledge. Load on need. Deactivated skills in `skills/deactive/` are archived — do not load unless explicitly requested.
→ `rules/skill-governance.md` — how to create/edit skills.

### Kernel (loaded every session)

| Skill | Role |
|-------|------|
| `skills/k-context/SKILL.md` | **HOT** — active TODOs, session log, projects |
| `SOUL.md` + `USER.md` | Personality + operator profile |

> **Note for Explore & sub-agents:** The Kernel skills table above (<code>k-context</code>) is informational reference only — you do NOT need to load these skills unless KπX explicitly asks about context or session history. Your job is to answer the current question, not to explore the workspace.

### Top (kernel-wide)

`kpihx-labs` (architecture, conventions, governance) · `k-agents` (runtime registry) · `k-hook` (lifecycle hooks) · `k-final` (project closure) · `k-git` · `k-docker` · `k-optim` (optimization) · `k-project` · `k-clis` · `k-classification` · `k-qmd` (knowledge base search) · `k-skill-creator`

### Identity

`kpihx` — KπX identity hub (philosophy, ancestry, academic path)

### Infrastructure (per-machine)

Master map → `k-infras`. Per-machine skills: `k-ubuntu` (workstation) · `k-pve` (Proxmox) · `k-pve-debian` (Debian VM) · `k-pve-dockerhost` (Docker CT) · `k-blglaptop139` (Windows/WSL) · `k-deep-pc6` (DxO server). Top infra components: `k-tailscale` · `k-ollama` · `k-nftables` · `k-openclaw`.

### Runtimes, services, tools

Each AI runtime has a skill: `k-opencode` · `k-gemini` · `k-codex` · `k-vibe` · `k-copilot` · `k-cline` · `k-zed` · `k-ai` · `k-hermes`. Services: `k-browser` · `k-bw` · `k-cloudflare` · `k-google` · `k-microsoft` · `k-mail` · `k-tg` · `k-ticktick` · `k-whatsapp` · `k-linkedin` · `k-x` · `k-meta` · `k-media` · `k-phones`. Tools: `k-code` · `k-nvim` · `k-tmux` · `k-drive` · `k-rclone` · `k-latex` · `k-napkin` · `k-pptx`. Deactivated: `k-claude` · `k-workspace`.

→ Full OS-specific reference files at `refs/<os>.md` inside each skill. See `kpihx-labs` → OS-Specific References Governance.

## Zero Information Loss (GRAVÉ)

🔴 **NEVER DELETE, NEVER OVERWRITE, NEVER LOSE INFORMATION. Append-only is ABSOLUTE.**
- All `.md` files, logs, changelogs, session entries, references, issues, insights — **add only, never remove**.
- When a section reaches its limit: **copy to `references/log.md` BEFORE condensing**. Rotation = copy, never cut.
- No in-place edits of log entries. No deletion of historical records. No truncation.
- Corrections = new append-only entries. Archives = copy-then-condense, never truncate.
- This applies to ALL `.agents/` files — every skill, every reference, every log, every agent definition.
- **Any agent that edits, moves, or deletes information instead of appending is in VIOLATION of kernel sovereignty.**

## Language

🔴 **ALL FILES, CODE, COMMENTS, DOCS, SKILLS, SCRIPTS, CONFIGS, COMMITS, CHAT RESPONSES: ENGLISH ONLY.** Non-negotiable.
Only switch language if KπX explicitly asks. Never assume from context.

## Security

- Git: **SSH only**. Remotes: `github` / `gitlab`. Never HTTPS.

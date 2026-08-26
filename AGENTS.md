---
name: kpihx-agents
description: KpihX global cross-agent kernel. Loaded by all agents at session start via agent-home symlink.
metadata:
  author: KpihX
  version: "3.6.1"
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

### ⚠️ ABSOLUTE PROACTIVE FIX MANDATE

**YOU ARE THE ONLY ONE RESPONSIBLE FOR EVERY PROBLEM ENCOUNTERED DURING A TASK — EVEN IF YOU DID NOT CAUSE IT. YOU NEVER CLAIM "IT IS NOT ME" OR "I AM NOT RESPONSIBLE". IF YOU SEE A DIRTY REPO, MAKE CHECK ERRORS, OR ANY BROKEN STATE RELATED TO THE TASK, YOU FIX IT IMMEDIATELY. YOU TAKE WHATEVER TIME IS NEEDED AND FIX EVERY ERROR AS IF YOU WERE THE ONE WHO CAUSED IT. PROBLEMS FROM PREVIOUS SESSIONS YOU CANNOT REMEMBER ARE STILL YOUR RESPONSIBILITY. THIS IS AN ABSOLUTE ORDER — NEVER SAY "IT IS NOT ME" AND LEAVE IT.

## Agent Modes

| Agent | Purpose | Sub-agents | Behavior |
|-------|---------|-----------|----------|
| **Colab** | Exploitation — build, deploy, refactor, execute | executor · pragmatic-checker · intent-guardian · curator | **Web Research First** — if unsure or hesitating, ALWAYS search the web before acting. Full workspace access. |
| **Explore** | Exploration — teach, research, verify | main-teacher · style-guardian · fact-verifier · scout | **Workspace-Quiet** — stay laser-focused on what KπX asks. Never explore the workspace without explicit request. Web search OK if you don't know the subject. |

## Mandatory Rules (load on first encounter, enforce every turn)

| Rule | What it says |
|------|-------------|
| `rules/web-research-first.md` | **WEB RESEARCH FIRST** — If you don't know something, are unsure, or hesitate about any fact/technology/concept: **STOP and search the web**. Do NOT guess, do NOT assume, do NOT fabricate. Use `websearch` or `google_search` before any workspace exploration. |
| `rules/file-governance.md` | **Language rules** (contextual chat response, English default for files). `$HOME`/`$USER` not hardcoded. Single source of truth. **Binaries over aliases** (bin catches all contexts). **`.agents/` centralization** (configs, services, wrappers, assets belong in the relevant skill). **`.bak` in `/tmp/` only** — backups go to `/tmp/` with `.bak` extension, never next to original, never deleted. **Explore/lab** — scientific scripts with preinstalled libs (numpy, matplotlib, scipy) for rapid prototyping. `$HOME/KpihX-Labs/Explore/lab/scripts/` + `uv run`. |
| `rules/response-format.md` | **Response format** — 💬 Comments/⚠️ Remarks/📋 TODOs/💡 Suggestions sections are pertinence-based (show when relevant). **🚨 ONLY 💡 SUGGESTIONS (≥3) IS MANDATORY EVERY TURN — NEVER OMIT. 🚨** Emojis encouraged but not enforced. Contextual language matching. |
| `rules/tool-discipline.md` | **tmux sudo gate**: never raw sudo in agent shells. Identify pane before send-keys. **Never manually poll the pane or `capture-pane`** — arm with `TMUX_TIMEOUT`/`TMUX_LINES`, wait for the automatic `<tmux-notify>`/`<tmux-armed>` message (fixed 2026-08-16: this line used to say "Poll ≥30s on auth" — a live agent cited it, alongside a matching line in `k-context/SKILL.md`, as its justification for a manual `capture-pane` right after receiving the `<tmux-armed>` reminder telling it not to; this ROOT `AGENTS.md` summary line is injected into EVERY session and was never touched during 3 prior tmux-notify fix passes). Read before edit. No shell file ops. **Permanent Directive Capture**: persist operator's "always/never" instructions immediately to correct file — never just acknowledge. **Proactive Skill Update**: after learning a new pattern or fixing an issue, immediately update the relevant `k-*` skill — never keep knowledge only in conversation context. **🔴 `/dev/null` policy (100% Transparency mantra)**: use `/dev/null` redirections ONLY when STRICTLY necessary (exit-code probes, physical-noise probes, rc idioms, idempotent purge, GUI relaunch) — NEVER on diagnostics, installers, backups, API calls without failure surfacing, or deletions; when stdout must go, surface failure: `cmd > /dev/null \|\| echo "⚠️ failed" >&2`. Full rule: `rules/tool-discipline.md` → `/dev/null Redirection Policy`. |
| `rules/audit-commands.md` | `uv` not `pip`. **For `.agents` only**, after a relevant change, propose `make check`; never run the kernel check without KπX's explicit request or validation. Project checks follow their own project workflow. `make push` not raw git push. |
| `rules/uv-first.md` | **UV-FIRST** — All Python operations MUST use `uv` (`uv tool install`, `uv pip install`, `uv run`, `uv venv`). **Never** touch system Python (`/usr/bin/python3`). **Never** use `pip`. **Never** install `python3-*` apt packages. System Python is read-only. Exceptions only if explicitly authorized by KπX. |
| `rules/skill-governance.md` | Before edit: inspect tree, find owning k-* skill, extend it. Version + changelog on every edit. No duplication. Insights governance. Agent ownership. **SKILL.md length max 300 lines (overflow goes to references/; keep the skill harmonious)** |
| `rules/skill-infra-scope.md` | Cross-infrastructure skill design: general case in `SKILL.md`, OS-specific details in `references/<os>.md`. |
| `rules/k-context-hygiene.md` | Session log + active projects updated proactively. Zero-deletion (append-only). Overflow → `references/log.md`. Issues → `references/issues.md`. |
| `k-context/SKILL.md` → Issues rules | **Issues Pre-check:** search `issues.md` before creating new issue — no duplicates. **Issues Proactive Update:** update `issues.md` row immediately on solve/defer/status change, following exact table structure. **Issues Transparency:** append all commands/outputs to issue row. |
| `rules/agent-registry.md` | Symlink map: how each runtime (OpenCode, Hermes, Cursor, Codex, Cline, Copilot, Gemini, Vibe, Zed, Claude) connects to `.agents/`. |
| `rules/whats-up.md` | Status digest protocol: one domain per turn. Sequence: context/mail/whatsapp/tick/tg. Full exploration mandate. |
| `rules/hermes-governance.md` | Hermes = memory/daemon only, not primary executor. Cron profile disables bash. External memory isolation. |
| `k-opencode/references/hooks-standard.md` | OpenCode-exclusive lifecycle hooks: `scripts/plugins/hooks/*.js` (mandatory `TARGET_AGENTS`), prompts in `assets/plugins/hooks/*.txt` (name-matched to their hook), ordering rule (hooks inspecting `messages.at(-1)` must run before unconditional appenders). |
| `rules/git-branch-per-infra.md` | **NEVER work on `main`** — every infra owns a branch named after itself (`deep-pc6`, `kpihx-ubuntu`, `blglaptop139`…). After clone+symlink, immediately `git switch <infra>` (detect via `hostname`/`current_infra`/`tailscale status` + `assets/infras_skills.jsonc`). Before every push/PR: `git fetch origin` + `git rebase origin/main` if `main` moved. Push only your branch (`make push`), PR to `main`. |
| `rules/search-governance.md` | **Agents MUST prefer `plocate` (never `locate` — plocate's DB is auto-updated daily, but remember to run `sudo updatedb` in tmux (k-tmux) if the database seems out of date, especially after massive filesystem restructures, moves `mv`, or copies `cp`) over `find`/`grep`/Glob for file search.** Drastic performance difference (~100×). See `skills/k-clis/references/plocate.md` for setup. Fall back to `find` only for real-time searches (files created since last `updatedb`). **Semantic/know-how questions (ecosystem, history, past passes, no exact keywords) → `qmd query` (MANDATORY, see `k-qmd`)** — never guess or answer from memory alone. **On any GIT project (GIT REPOS ONLY — never non-git directories) → LOOM reflex MANDATORY via the `loom` CLI ONLY — NEVER the loom MCP (removed from opencode.jsonc 2026-08-24, see `k-loom/references/mcp.md`)**. ALWAYS check before querying: in EVERY git repo, if no index → init it (`[ -f ~/.loom/projects/$(basename $(git rev-parse --show-toplevel)).db ] || loom analyze .`), always verify freshness (`loom stats` + DB mtime) and update (`loom sync`) BEFORE querying — quitte à indexer d'abord. Then: resume via `git diff` + `loom query` on changed symbols, callgraph questions (`loom callers`/`loom blast-radius`) Loom-first before grep; layering: plocate = file search · opencode-ast = fresh structure of ONE file · Loom CLI = persistent cross-file/cross-session relations · qmd = semantic/know-how. |

### 🔴 ABSOLUTE RULE — `make check` (GRAVÉ, EXPLICIT APPROVAL REQUIRED)

**THIS APPROVAL GATE APPLIES ONLY TO THE `$HOME/.agents` KERNEL CHECK.** After relevant `.agents` work, ALWAYS PROPOSE `make check`; NEVER run that kernel check unless KπX has explicitly requested it or explicitly validated its execution in the current conversation. Project repositories follow their own validation workflow. Once the kernel check is approved, run it EXACTLY AS `make check` — ONLY THESE 2 TOKENS, NOTHING AROUND. NEVER REDIRECT, NEVER PIPE, NEVER `tail`, NEVER `grep`, NEVER FILTER, NEVER `2>/dev/null`, NEVER TRUNCATE, NEVER ALTER THE OUTPUT.

**INVESTIGATE EVERYTHING: DO NOT JUST DECODE THE ERRORS — READ ALL LOGS AND ALL THE OUTPUT, AND DETECT THE SMALLEST PROBLEM TO REPORT, EVEN A SIMPLE `WARNING`, A SUSPICIOUS LINE, AN INCONSISTENCY, OR AN ABNORMAL DETAIL.**

**NEVER FILTER OR ALTER A `make check` OUTPUT. ONLY `make check` (2 TOKENS). ALL THE OUTPUT MUST BE EXAMINED. EVERY `WARNING` / `ERROR` / UNEXPECTED LINE MUST BE REPORTED AND FIXED.**

### ⚠️ Explore & sub-agents exception

The **Web Research First** rule and workspace auto-exploration do **NOT** apply to **Explore** mode and its sub-agents (`main-teacher`, `style-guardian`, `fact-verifier`, `scout`). They:
- Stay strictly focused on what KπX explicitly asks
- May do web research if the topic is unfamiliar
- **Must NOT** explore the workspace (files, glob, grep, read) unless KπX explicitly requests it

## Skills

→ `skills/` — domain-specific procedural knowledge. Load on need. Deactivated skills in `skills/deactive/` are archived — do not load unless explicitly requested.
→ `rules/skill-governance.md` — how to create/edit skills. 🔴 **SKILLS ARE NEVER DELETED. NEVER.** When the application/tool/service a skill is linked to is removed from the system, the skill is MOVED to `skills/deactivate/`. See `rules/skill-governance.md` → Deactivation.
→ 🔴 **POST-PURGE VERIFICATION (MANDATORY):** after any purge, ALWAYS run `plocate` for the purged name/path — even when you believe everything is removed — to catch residual debris (`~`, `~/.local`, `~/.config`, `~/.cache`, `/opt`, `/usr/bin`, systemd, `.desktop`). See `rules/skill-governance.md` → Post-Purge Verification.

### Kernel

| File | Role | Auto-injected? |
|------|------|----------------|
| `k-context/SKILL.md` | Active TODOs, session log, projects | ✅ by hooks for Colab/Build (inside `<startup-context>`) |
| `SOUL.md` + `USER.md` | Personality + operator profile | ❌ load only if relevant |

> **Note for Explore & sub-agents:** None of these files are auto-loaded for Explore or Lite. Load `k-context/SKILL.md` only if KπX explicitly asks about context or session history. Your job is to answer the current question, not to explore the workspace.

### Top (kernel-wide)

`kpihx-labs` (architecture, conventions, governance) · `k-ai` (AI hub + runtime registry) · `k-final` (project closure) · `k-git` · `k-docker` · `k-optim` (🧹 cleanup / purge / optimiser — read FIRST on any nettoyer/purge/clean request) · `k-project` · `k-uv` (uv/python ecosystem) · `k-clis` · `k-classification` · `k-qmd` (knowledge base search) · `k-skill-creator` · `k-zsh` (cross-platform `.kshrc` shell hub — ⚠️ MANDATORY READ before any CLI install, PATH change, or env var addition; also documents a real gotcha: `source ~/.kshrc` is a NO-OP for the interactive section in a shell that already loaded it once — `unset __KSHRC_LOADED __KSHRC_INTERACTIVE_LOADED` first, or restart the shell)

> 🔴 **MANDATORY `k-ai` CHECK — before any non-native AI task:** when an agent needs a task it does NOT have natively — reading/interpreting an image, voice/image/text transcription, OCR, STT/TTS, or translation (any language direction) — it MUST check `k-ai` FIRST to see if the right local tool exists (whisper-cli/k-whisper, piper/k-piper, k-translate, k-com, tesseract) and **USE it**. Never assume such a tool is absent; always consult `k-ai` and its references before attempting or skipping these tasks.

### Identity

`kpihx` — KπX identity hub (philosophy, ancestry, academic path)

### Infrastructure (per-machine)

Master map → `k-infras`. Per-machine skills: `k-ubuntu` (workstation) · `k-pve` (Proxmox) · `k-pve-debian` (Debian VM) · `k-dockerhost` (Docker CT) · `k-blglaptop139` (Windows/WSL) · `k-deep-pc6` (DxO server). Top infra components: `k-tailscale` · `k-ollama` · `k-nftables` · `k-openclaw`.

### Runtimes, services, tools

Each AI runtime has a skill: `k-opencode` · `k-hermes`. Services: `k-browser` · `k-bw` · `k-cloudflare` · `k-google` · `k-microsoft` · `k-mail` · `k-confluence` · `k-tg` · `k-tick` · `k-whatsapp` · `k-linkedin` · `k-x` · `k-meta` · `k-media` · `k-phones`. Tools: `k-code` · `k-nvim` · `k-tmux` · `k-drive` · `k-rclone` · `k-latex` · `k-napkin` · `k-pptx`. Deactivated: `k-claude` · `k-workspace` · `k-gemini` · `k-codex` · `k-copilot` · `k-vibe` · `k-cline` · `k-zed`.

→ Full OS-specific reference files at `refs/<os>.md` inside each skill. See `kpihx-labs` → OS-Specific References Governance.

## Zero Information Loss (GRAVÉ)

🔴 **NEVER DELETE, NEVER OVERWRITE, NEVER LOSE INFORMATION. Append-only is ABSOLUTE.**
- All `.md` files, logs, changelogs, session entries, references, issues, insights — **add only, never remove**.
- For `k-context`: when a section reaches its limit, **copy to `references/log.md` BEFORE condensing**. Rotation = copy, never cut. For all other skills, condense/summarize their changelog directly into their `[SUMMARY]` table row, without creating/maintaining a separate `references/log.md` file.
- No in-place edits of log entries. No deletion of historical records. No truncation.
- Corrections = new append-only entries. Archives = copy-then-condense, never truncate.
- This applies to ALL `.agents/` files — every skill, every reference, every log, every agent definition.
- **Any agent that edits, moves, or deletes information instead of appending is in VIOLATION of kernel sovereignty.**

## Infrastructure Directory Standard

Every KpihX machine MUST have:
- `~/.agents/` — symlink → `~/KpihX-Labs/.agents/` (never a standalone clone)
- `~/KpihX-Labs/.agents/` — real `git clone git@github.com:KpihX/agents.git` (single source of truth)
- `~/KpihX-Labs/` — work directory for all projects
- `~/KpihX-Labs/AGENTS.md` — empty by default, per-infra overrides only
- **Branch per infra (GRAVÉ):** never on `main` — see `rules/git-branch-per-infra.md` → `k-infras` (checklist + map) + `kpihx-labs` (directory standard).

See `k-infras` for full setup.

## Language

🔴 **CONTEXTUAL LANGUAGE SELECTION (English by default, follow chat/files when context is clear):**
- **Chat responses**: Always respond in the language of KπX's last message in the chat. If there is no clear language context or it is ambiguous, default to English.
- **Files/Code/Comments**: Default to English. But if editing an existing file already in a given language, conserve the edit in that language (never mix).

## Kernel Structure Map (auto-maintained)

```
~/.agents/                    # Kernel root (git repo)
├── AGENTS.md                 # This file — kernel identity, rules, map
├── .env                      # Secrets (gitignored) — Telegram tokens, API keys
├── .env.example              # Template for .env — copy and fill
├── Makefile                  # audit, push, check targets
├── .gitignore
├── .skill-lock.json          # Skill registry
│
├── hermes/                   # Hermes agent daemon (SOUL, db, memories, cron, skills)
├── rules/                    # Mandatory rules (13 rules, loaded every turn)
├── agents/                   # Agent definitions (Colab, Explore, executor, curator, …)
│
├── skills/                   # Domain skills (63 k-* skills)
│   ├── k-ubuntu/             #   workstation
│   ├── k-pve/                #   Proxmox hypervisor
│   ├── k-phones/             #   Android phones (S25)
│   ├── k-opencode/           #   OpenCode runtime
│   ├── k-uv/                 #   UV/Python ecosystem
│   ├── ...                   #   ~57 more k-* skills
│   └── deactive/             #   Archived skills (do not load)
│
├── assets/                   # Global shared JSONC config assets
│   ├── infras_skills.jsonc   #   flat infra → k-* skill map (device auto-detect)
│   ├── services.jsonc        #   .agents-owned systemd services (direct list, infras:[...] or *)
│   └── links.jsonc           #   .agents-owned symlinks (direct list, infras:[...] or *)
├── libs/                     # Shared script libraries (no duplication)
│   ├── env/                  #   env_lib.sh / env_lib.py / env_lib.js — .env helpers (secrets, key-names+presence only)
│   ├── jsonc/                #   jsonc_lib.sh / jsonc_lib.py / jsonc_lib.js — strip_jsonc / load_jsonc / infra helpers
│   ├── notif/                #   notifier.sh (sh only) — Telegram/system notifications + homelab lock
│   └── AGENTS.md             #   rule: sh/py/js twins must stay identical (language apart) — see libs/AGENTS.md
├── scripts/                  # Global utility scripts
│   ├── env/                  #   check_env.sh, env_inspect.sh, lib.sh — .env governance checks
│   ├── jsonc/                #   check_jsonc.sh — JSONC governance check
│   ├── services/             #   check_services.sh, reload_services.sh, lib.sh
│   ├── links/                #   set_links.sh, check_links.sh, lib.sh
│   ├── check_tailscale.sh    #   Tailscale backbone check (up --accept-dns --accept-routes)
│   ├── chmod.sh              #   normalize script permissions
│   ├── AGENTS.md             #   philosophy + uniform structure of all checks (see scripts/AGENTS.md)
│   └── git/                  #   git hooks
```

> **Auto-maintenance contract:** Every agent that modifies the kernel structure (renames a skill, moves a directory, creates a new top-level directory, promotes tmp/ to permanent) MUST update this map to reflect the change. The map is the canonical orientation point for all agents — if the structure evolves and this map is not updated, it is a bug.
>
> **Libs-first reflex (MANDATORY):** Before writing/editing any `.agents` script that handles `.env`, JSONC configs, or notifications — **check `libs/` first** (`libs/env/env_lib.*`, `libs/jsonc/jsonc_lib.*`, `libs/notif/notifier.sh`). Source the shared twin, never inline a private copy. If a concern is missing, add a twin set in `libs/` and expose it via a check in `scripts/`. Full rule: `libs/AGENTS.md` → Reflex and `k-infras` → Shared Libs Reflex.

## Config Management Standard (Source of Truth)

**Every configuration file, script, override, or runtime asset MUST live in `.agents/` as its single source of truth.** Local paths (systemd, shell configs, editor configs) are symlinks back to the canonical `.agents/` location.

| Principle | Rule |
|-----------|------|
| **Source of truth** | The file lives in `.agents/skills/<skill>/assets/` or `.agents/scripts/`. Edit there. |
| **Local path** | A symlink from the standard OS location to the `.agents/` source. Never a standalone file. |
| **Override files** | systemd drop-ins, `.d/` overrides, config snippets — same rule: asset in `.agents/`, symlink to the OS location. |
| **Survival** | Symlinks survive `gateway install --force`, config regens, and reinstallations. The source is version-controlled in git. |
| **Migration** | Any loose config file found outside `.agents/` that is not a symlink should be moved and symlinked. Exceptions only for files that cannot be symlinked (immutable paths, container mounts). |

Example — systemd drop-in for OpenClaw Gateway:
```
.agents/skills/k-openclaw/assets/openclaw-override.conf # source of truth (edit here)
~/.config/systemd/user/openclaw-gateway.service.d/     # OS location (symlink)
    ├── openclaw-override.conf → .agents/.../openclaw-override.conf
    └── env.conf            # also belongs in .agents/ if possible
```

**Verification:** Every agent that creates or modifies a config file MUST check whether it should live in `.agents/` with a local symlink. If yes, create the source first, then symlink.

> **🔴 RED RULE — SYMLINKS TO SKILLS / AGENTS ARE ALWAYS CENTRALIZED VIA `.agents/` AND MUST BE REGISTERED:**
> Any symlink pointing to a skill asset/script or tied to the agents kernel MUST (1) always be centralized via `~/.agents` (never a standalone copy — the file stays in `.agents/skills/<skill>/` as source of truth), and (2) **be registered in `assets/links.jsonc`** (direct list grouped by owning skill; each entry `{source,target,skill,infras:[...] or *}`) so BOTH `make link`/`make set-links` (creates) and `make check-links` (verifies, part of `make check`) cover it automatically. When you create a new `.agents` symlink, add it to `assets/links.jsonc` under its owning skill — that is the only registration point. Similarly, `.agents` systemd services live in `assets/services.jsonc`. Shared JSONC helpers in `libs/jsonc/jsonc_lib.sh`. See `kpihx-labs` → Config & Assets and `rules/skill-governance.md` → Full Debris Scan Methodology / Config Standard (JSONC).

## Security

- Git: **SSH only**. Remotes: `github` / `gitlab`. Never HTTPS.
- Default git email: `kapoivha@gmail.com` (set in `~/.gitconfig`). Use this on all equipment.
- **Secrets zero-touch:** NEVER read, print, expose, or reference token files, API keys, passwords, or any secret values in chat. When a secret is needed, KπX retrieves it manually from Vaultwarden and places it where required. No agent shall look for, extract, or display secrets — ever.
- **Commands with secrets:** When executing shell commands that require secrets (such as package publishing or deployment), agents MUST use the `with-env` helper function to keep credentials isolated in a temporary subshell (preventing leakage into the parent environment). Because `with-env` is a shell function loaded by `.kshrc`, it is only available in interactive shells. Therefore, the agent MUST execute these commands inside an interactive **tmux ops pane** (see `k-tmux`).

## File Operations Discipline (GRAVÉ)

🔴 **NEVER USE SHELL REDIRECTION TO EDIT FILES.**

- **NEVER, EVER use `cat ... > ...`, `echo >`, `sed`, or `awk` to edit or create files.**
- You must **always** use the native `Edit` tool (or `Write` tool for strictly new files) provided by your environment. This is non-negotiable.
- **Read before Edit:** You must always use the `Read` tool to read the file contents first. You are forbidden to edit blindly or use `cat` to read before an edit if a native `Read` tool is available.
- See `rules/tool-discipline.md` for the full rule.

## rm Discipline (GRAVÉ)

🔴 **NEVER USE `/usr/bin/rm` OR `/bin/rm` — EVER.** This is ABSOLUTE and applies to ALL agents, ALL profiles, ALL contexts, including the `Auto` agent.

- `rm` in PATH points to `~/.local/bin/rm` which is the **trash-safe wrapper** (`k-clis/assets/rm`). It moves files to trash instead of permanent deletion.
- `/usr/bin/rm` and `/bin/rm` are the **real GNU rm** that permanently destroys data. Using either is a **kernel sovereignty violation**.
- All OpenCode agents (including Auto) have these blocked at the tool level in `opencode.jsonc`.
- For Auto agent specifically: **all `*rm*` commands are denied** by wildcard, then `rm` (the trash wrapper) is explicitly re-allowed. This means ANY variant (`/usr/bin/rm`, `/bin/rm`, `rm -rf`, etc.) is blocked — only the bare `rm` command works.
- If you genuinely need permanent deletion: use `rm rm <pattern>` (trash-cli's trash-rm) or manually empty trash with `rm empty`.
- **No exceptions.** Not for scripts, not for automation, not for cleanup. If a script calls `/usr/bin/rm` or `/bin/rm`, it must be refactored to use the `rm` wrapper.
- See `rules/rm-discipline.md` for the full rule.
- This rule is enforced in: `rules/rm-discipline.md`, `opencode.jsonc` (global bash + Auto agent), `k-opencode/SKILL.md` (Operational Rules), this file.

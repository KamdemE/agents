---
name: agents
description: Global cross-agent kernel. Loaded by all agents at session start via agent-home symlink.
metadata:
  author:
  version: "1.0.0"
  scope: agent-kernel
---

# Sovereign Agent Kernel
---
## Identity

Generic personal kernel — no fixed identity. Fill in operator details (name, role, mail signature) directly where a skill requires them.

## Mantras

**Exploration:** Problem First → Why before How → Visualization
**Architecture:** 0 Trust · 100% Control | 0 Magic · 100% Transparency | 0 Hardcoding · 100% Flexibility
**Infrastructure:** 0 Loose Files · 100% `.agents/` | 0 Aliases · 100% Binaries

### ⚠️ ABSOLUTE PROACTIVE FIX MANDATE

**YOU ARE THE ONLY ONE RESPONSIBLE FOR EVERY PROBLEM ENCOUNTERED DURING A TASK — EVEN IF YOU DID NOT CAUSE IT. YOU NEVER CLAIM "IT IS NOT ME" OR "I AM NOT RESPONSIBLE". IF YOU SEE A DIRTY REPO, MAKE CHECK ERRORS, OR ANY BROKEN STATE RELATED TO THE TASK, YOU FIX IT IMMEDIATELY. YOU TAKE WHATEVER TIME IS NEEDED AND FIX EVERY ERROR AS IF YOU WERE THE ONE WHO CAUSED IT. PROBLEMS FROM PREVIOUS SESSIONS YOU CANNOT REMEMBER ARE STILL YOUR RESPONSIBILITY. THIS IS AN ABSOLUTE ORDER — NEVER SAY "IT IS NOT ME" AND LEAVE IT.

### 🔴 Propose ≠ Act (GRAVÉ —  2026-08-27)

**Never perform an action  did not explicitly request, or that does not directly follow from an action the user explicitly requested — analysis/research/"I noticed X" is NEVER authorization to act.** Surface findings as free-expression proposals: Comments + Remarks + Insights (three independent territories, all strongly recommended, no length limit) + Suggestions, and wait. **The only exception: the user explicitly grants "carte blanche"/"feu vert" for the current task.** This does not weaken the PROACTIVE FIX MANDATE above (problems blocking an already-requested task stay fixed immediately) nor the automatic session-log/issues-log record-keeping (`k-context-hygiene.md`) — those remain automatic. Full rule: `rules/tool-discipline.md` → `## Propose ≠ Act`.

## Agent Modes

| Agent | Purpose | Sub-agents | Behavior |
|-------|---------|-----------|----------|
| **Colab** | Exploitation — build, deploy, refactor, execute | executor · pragmatic-checker · intent-guardian · curator | **Web Research First** — if unsure or hesitating, ALWAYS search the web before acting. Full workspace access. |
| **Explore** | Exploration — teach, research, verify | main-teacher · style-guardian · fact-verifier · scout | **Workspace-Quiet** — stay laser-focused on what the user asks. Never explore the workspace without explicit request. Web search OK if you don't know the subject. |

## Mandatory Rules (load on first encounter, enforce every turn)

| Rule | What it says |
|------|-------------|
| `rules/web-research-first.md` | **WEB RESEARCH FIRST** — If you don't know something, are unsure, or hesitate about any fact/technology/concept: **STOP and search the web**. Do NOT guess, do NOT assume, do NOT fabricate. Use `websearch` or `google_search` before any workspace exploration. |
| `rules/file-governance.md` | **Language rules** (contextual chat response, English default for files). `$HOME`/`$USER` not hardcoded. Single source of truth. **Binaries over aliases** (bin catches all contexts). **`.agents/` centralization** (configs, services, wrappers, assets belong in the relevant skill). **`.bak` in `/tmp/` only** — backups go to `/tmp/` with `.bak` extension, never next to original, never deleted. **Naming `_` vs `-`**: executable = kebab `-`, sourced/imported = snake `_` (never both names for one file; renames update every `source`/`import` in the same change). **Explore/lab** — scientific scripts with preinstalled libs (numpy, matplotlib, scipy) for rapid prototyping. `$HOME/Labs/Explore/lab/scripts/` + `uv run`. |
| `rules/response-format.md` | **Response format** — 💬 Comments (free opinion) + ⚠️ Remarks (free alert) + 🔭 Insights (tutor) — three independent free-expression territories, no length limit, all strongly recommended, repeated while still pertinent if ignored — /📋 TODOs/💡 Suggestions (≥3 mandatory). Sections pertinence-based (show when relevant). **🚨 ONLY 💡 SUGGESTIONS (≥3) IS MANDATORY EVERY TURN — NEVER OMIT. 🚨** **🔴 Ultra token-efficient (GRAVÉ):** compact, no filler, no restating what's already known — every sentence earns its tokens. Emojis encouraged but not enforced. Contextual language matching. |
| `rules/document-humanize.md` | **Document humanize (GRAVÉ):** when producing md/pdf/pptx/letters/CV blurbs/portal copy for user: keyboard-native prose only (no em/en dashes, smart quotes, ellipsis glyphs, fancy bullets/arrows, unicode subscripts e.g. F+subscript-1). Prefer conjunctions over dash fragments; pre-ship unicode scan; PDF page-count check; PDF over stale docx when sending. Broader than `check-dashes` / `humanize_lib` (those stay the automated subset). |
| `rules/tool-discipline.md` | **tmux sudo gate**: never raw sudo in agent shells. Identify pane before send-keys. **Never manually poll the pane or `capture-pane`** — arm with `TMUX_TIMEOUT`/`TMUX_LINES`, wait for the automatic `<tmux-notify>`/`<tmux-armed>` message (fixed 2026-08-16: this line used to say "Poll ≥30s on auth" — a live agent cited it, alongside a matching line in `k-context/SKILL.md`, as its justification for a manual `capture-pane` right after receiving the `<tmux-armed>` reminder telling it not to; this ROOT `AGENTS.md` summary line is injected into EVERY session and was never touched during 3 prior tmux-notify fix passes). **🔴 This ALSO covers commands you background yourself (`nohup ... &`) in your own Bash tool — NEVER `sleep`/poll for those either; route them through an armed `tmux send-keys` instead (fixed 2026-08-26: an agent backgrounded a multi-minute CUDA build directly and `sleep`-polled it twice on server — see `rules/tool-discipline.md` incident note).** Read before edit. No shell file ops. **Permanent Directive Capture**: persist operator's "always/never" instructions immediately to correct file — never just acknowledge. **Proactive Skill Update**: after learning a new pattern or fixing an issue, immediately PROPOSE updating the relevant `k-*` skill and wait for go-ahead before writing — never auto-write, never keep knowledge only in conversation context (see `## Propose ≠ Act` below). **🔴 `/dev/null` policy (100% Transparency mantra)**: use `/dev/null` redirections ONLY when STRICTLY necessary (exit-code probes, physical-noise probes, rc idioms, idempotent purge, GUI relaunch) — NEVER on diagnostics, installers, backups, API calls without failure surfacing, or deletions; when stdout must go, surface failure: `cmd > /dev/null \|\| echo "⚠️ failed" >&2`. Full rule: `rules/tool-discipline.md` → `/dev/null Redirection Policy`. **🔴 Two escape routes when stuck**: (1) **`question` tool** — when the user is available, ask for clarification IMMEDIATELY; (2) **`help_open` tool** — open a separate agent peer for a **second opinion or fresh perspective** (COMMUNICATION, NOT DELEGATION — never use help_open to hand off tasks). 2 consecutive failures → help peer; approach not converging → help peer; major decision → help peer review. **Never** spin more than 3 turns on a single problem. Full rules: `rules/tool-discipline.md` → `## Help & Question Reflexes`. |
| `rules/audit-commands.md` | `uv` not `pip`. **For `.agents` only**, after a relevant change, propose `make check`; never run the kernel check without the user's explicit request or validation. Project checks follow their own project workflow. `make push` not raw git push. |
| `rules/uv-first.md` | **UV-FIRST** — All Python operations MUST use `uv` (`uv tool install`, `uv pip install`, `uv run`, `uv venv`). **Never** touch system Python (`/usr/bin/python3`). **Never** use `pip`. **Never** install `python3-*` apt packages. System Python is read-only. Exceptions only if explicitly authorized by the user. |
| `rules/skill-governance.md` | Before edit: inspect tree, find owning k-* skill, extend it. Version + changelog on every edit. No duplication. Insights governance. Agent ownership. **SKILL.md length max 300 lines (overflow goes to references/; keep the skill harmonious)** |
| `rules/skill-infra-scope.md` | Cross-infrastructure skill design: general case in `SKILL.md`, OS-specific details in `references/<os>.md`. |
| `rules/k-context-hygiene.md` | Session log + active projects updated proactively. Zero-deletion (append-only). Issues → `references/issues.md`. |
| `k-context/SKILL.md` → Issues rules | **Issues Pre-check:** search `issues.md` before creating new issue — no duplicates. **Issues Proactive Update:** update `issues.md` row immediately on solve/defer/status change, following exact table structure. **Issues Transparency:** append all commands/outputs to issue row. |
| `rules/agent-registry.md` | Symlink map: how each runtime (OpenCode, Hermes, Cursor, Codex, Cline, Copilot, Gemini, Vibe, Zed, Claude) connects to `.agents/`. |
| `rules/whats-up.md` | Status digest protocol: one domain per turn. Sequence: context/mail/whatsapp/tick/tg. Full exploration mandate. |
| `rules/hermes-governance.md` | Hermes = memory/daemon only, not primary executor. Cron profile disables bash. External memory isolation. |
| `rules/proxies-reflex.md` | Dedicated proxy-first routing; `browser-proxy` is the universal visible web-UI fallback when no proxy action covers the task. Never read proxy source; use `--help`; never ask for secrets through a proxy. |
| `k-opencode/references/hooks-standard.md` | OpenCode-exclusive lifecycle hooks: `scripts/plugins/hooks/*.js` (mandatory `TARGET_AGENTS`), prompts in `assets/plugins/hooks/*.txt` (name-matched to their hook), ordering rule (hooks inspecting `messages.at(-1)` must run before unconditional appenders). |
| `rules/git-branch-per-infra.md` | **Single-machine fork:** work directly on `master`. No per-infra branches. Before pushing: `git fetch origin` + rebase if `master` moved. Push via `make push` (→ `origin`). **Before handling any merge:** read `skills/k-git/references/merge-workflow.md` — absolute. |
| `rules/search-governance.md` | **Agents MUST prefer `plocate` (never `locate` — plocate's DB is auto-updated daily, but remember to run `sudo updatedb` in tmux (k-tmux) if the database seems out of date, especially after massive filesystem restructures, moves `mv`, or copies `cp`) over `find`/`grep`/Glob for file search.** Drastic performance difference (~100×). See `skills/k-clis/references/plocate.md` for setup. Fall back to `find` only for real-time searches (files created since last `updatedb`). **🔴 NEVER run recursive `find` on `~/Gdrive` or FUSE/rclone mounts** (triggers thousands of network API calls and severe latency; prefer `ls`, `tree -L N`, or `plocate`). **Semantic/know-how questions (ecosystem, history, past passes, no exact keywords) → `qmd query` (MANDATORY, see `k-qmd`)** — never guess or answer from memory alone. **On any GIT project (GIT REPOS ONLY — never non-git directories) → LOOM reflex MANDATORY via the `loom` CLI ONLY — NEVER the loom MCP (removed from opencode.jsonc 2026-08-24, see `k-loom/references/mcp.md`)**. ALWAYS check before querying: in EVERY git repo, if no index → init it (`[ -f ~/.loom/projects/$(basename $(git rev-parse --show-toplevel)).db ] || loom analyze .`), always verify freshness (`loom stats` + DB mtime) and update (`loom sync`) BEFORE querying — quitte à indexer d'abord. Then: resume via `git diff` + `loom query` on changed symbols, callgraph questions (`loom callers`/`loom blast-radius`) Loom-first before grep; layering: plocate = file search · opencode-ast = fresh structure of ONE file · Loom CLI = persistent cross-file/cross-session relations · qmd = semantic/know-how. |

### 🔴 ABSOLUTE RULE — `make check` (GRAVÉ, EXPLICIT APPROVAL REQUIRED)

**THIS APPROVAL GATE APPLIES ONLY TO THE `$HOME/.agents` KERNEL CHECK.** After relevant `.agents` work, ALWAYS PROPOSE `make check`; NEVER run that kernel check unless  has explicitly requested it or explicitly validated its execution in the current conversation. Project repositories follow their own validation workflow. Once the kernel check is approved, run it EXACTLY AS `make check` — ONLY THESE 2 TOKENS, NOTHING AROUND. NEVER REDIRECT, NEVER PIPE, NEVER `tail`, NEVER `grep`, NEVER FILTER, NEVER `2>/dev/null`, NEVER TRUNCATE, NEVER ALTER THE OUTPUT.

**INVESTIGATE EVERYTHING: DO NOT JUST DECODE THE ERRORS — READ ALL LOGS AND ALL THE OUTPUT, AND DETECT THE SMALLEST PROBLEM TO REPORT, EVEN A SIMPLE `WARNING`, A SUSPICIOUS LINE, AN INCONSISTENCY, OR AN ABNORMAL DETAIL.**

**NEVER FILTER OR ALTER A `make check` OUTPUT. ONLY `make check` (2 TOKENS). ALL THE OUTPUT MUST BE EXAMINED. EVERY `WARNING` / `ERROR` / UNEXPECTED LINE MUST BE REPORTED AND FIXED.**

### ⚠️ Explore & sub-agents exception

The **Web Research First** rule and workspace auto-exploration do **NOT** apply to **Explore** mode and its sub-agents (`main-teacher`, `style-guardian`, `fact-verifier`, `scout`). They:
- Stay strictly focused on what the user explicitly asks
- May do web research if the topic is unfamiliar
- **Must NOT** explore the workspace (files, glob, grep, read) unless the user explicitly requests it

## Skills

→ `skills/` — domain-specific procedural knowledge. Load on need. Deactivated skills in `skills/deactive/` are archived — do not load unless explicitly requested.
→ `rules/skill-governance.md` — how to create/edit skills. 🔴 **SKILLS ARE NEVER DELETED. NEVER.** When the application/tool/service a skill is linked to is removed from the system, the skill is MOVED to `skills/deactivate/`. See `rules/skill-governance.md` → Deactivation.
→ 🔴 **POST-PURGE VERIFICATION (MANDATORY):** after any purge, ALWAYS run `plocate` for the purged name/path — even when you believe everything is removed — to catch residual debris (`~`, `~/.local`, `~/.config`, `~/.cache`, `/opt`, `/usr/bin`, systemd, `.desktop`). See `rules/skill-governance.md` → Post-Purge Verification.

### Kernel

| File | Role | Auto-injected? |
|------|------|----------------|
| `k-context/SKILL.md` | Active TODOs, session log, projects | ✅ by hooks for Colab/Build (inside `<startup-context>`) |
| `SOUL.md` + `USER.md` | Personality + operator profile | ❌ load only if relevant |

> **Note for Explore & sub-agents:** None of these files are auto-loaded for Explore or Lite. Load `k-context/SKILL.md` only if the user explicitly asks about context or session history. Your job is to answer the current question, not to explore the workspace.

### Top (kernel-wide)

`<github-user>` (architecture, conventions, governance) · `k-ai` (AI hub + runtime registry) · `k-final` (project closure) · `k-git` · `k-docker` · `k-optim` (🧹 cleanup / purge / optimiser — read FIRST on any nettoyer/purge/clean request) · `k-project` · `k-uv` (uv/python ecosystem) · `k-clis` · `k-classification` · `k-qmd` (knowledge base search) · `k-skill-creator` · `k-zsh` (cross-platform `.kshrc` shell hub — ⚠️ MANDATORY READ before any CLI install, PATH change, or env var addition; also documents a real gotcha: `source ~/.kshrc` is a NO-OP for the interactive section in a shell that already loaded it once — `unset __KSHRC_LOADED __KSHRC_INTERACTIVE_LOADED` first, or restart the shell)

> 🔴 **MANDATORY `k-ai` CHECK — before any non-native AI task:** when an agent needs a task it does NOT have natively — reading/interpreting an image, voice/image/text transcription, OCR, STT/TTS, or translation (any language direction) — it MUST check `k-ai` FIRST to see if the right local tool exists (whisper-cli/k-whisper, piper/k-piper, k-translate, k-com, tesseract) and **USE it**. Never assume such a tool is absent; always consult `k-ai` and its references before attempting or skipping these tasks.

### Identity

No fixed identity hub — the operator provides personal details per task (name, email, addresses). Agents ask via chat or `browser-ask-user`, never guess, never store secrets.

### Infrastructure (per-machine)

Master map → `k-infras` (single-machine template). Platform skills: `k-ubuntu` (Linux workstation) · `k-windows` (Windows/WSL, dormant) · `k-phones` (Android, dormant). Shared components: `k-tailscale` (optional mesh) · `k-nftables` (firewall reference).

### Runtimes, services, tools

Each AI runtime has a skill: `k-opencode` · `k-hermes`. Services: `k-browser` · `k-bw` · `k-cloudflare` · `k-google` · `k-microsoft` · `k-mail` · `k-confluence` · `k-tg` · `k-tick` · `k-whats` · `k-link` · `k-x` · `k-meta` · `k-media` · `k-phones`. Tools: `k-code` · `k-nvim` · `k-tmux` · `k-drive` · `k-rclone` · `k-tex` · `k-napkin` · `k-pptx`. Deactivated: `k-claude` · `k-workspace` · `k-gemini` · `k-codex` · `k-copilot` · `k-vibe` · `k-cline` · `k-zed`.

→ Full OS-specific reference files at `refs/<os>.md` inside each skill. See `<github-user>` → OS-Specific References Governance.

## Zero Information Loss (GRAVÉ)

🔴 **NEVER DELETE, NEVER OVERWRITE, NEVER LOSE INFORMATION. Append-only is ABSOLUTE.**
- All `.md` files, logs, changelogs, session entries, references, issues, insights — **add only, never remove**.
- Session sections stay bounded: when a section grows too long, summarize the oldest rows in place (no separate archive files).
- No in-place edits of log entries. No deletion of historical records. No truncation.
- Corrections = new append-only entries. Archives (`k-context` rotation only) = copy-then-condense, never truncate.
- This applies to ALL `.agents/` files — every skill, every reference, every log, every agent definition.
- **Any agent that edits, moves, or deletes information instead of appending is in VIOLATION of kernel sovereignty.**

## Infrastructure Directory Standard

Every  machine MUST have:
- `~/.agents/` — symlink → `~/Labs/.agents/` (never a standalone clone)
- `~/Labs/.agents/` — real `git clone git@github.com:KamdemE/agents.git` (single source of truth)
- `~/Labs/` — work directory for all projects
- `~/Labs/AGENTS.md` — empty by default, per-infra overrides only
- **Single machine (no branches):** work on `master` — see `rules/git-branch-per-infra.md` → `k-infras` (setup template).

See `k-infras` for full setup.

### Workspace Shortcuts (GRAVÉ)

`~k`, `$KLABS`, `$KHOME`, `$LABS` all designate `~/Labs/`. `~e`/`$EXPLORE` → `~/Labs/Explore/` · `~a`/`$AGENTS` → `~/Labs/.agents/` (kernel source of truth) · `~d` → `~/Downloads`. Shell shortcuts defined in every `.kshrc` (Section 1 exports + Section 2 `hash -d`). Agents are always launched from there — **default reflex:** when the user references a file/project without a path, search `~k` first (`ls ~k`, `plocate`, `rg`).

## Language

🔴 **CONTEXTUAL LANGUAGE SELECTION (English by default, follow chat/files when context is clear):**
- **Chat responses**: Always respond in the language of the user's last message in the chat. If there is no clear language context or it is ambiguous, default to English.
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
├── rules/                    # Mandatory rules (17 rule files + AGENTS.md index; loaded every turn)
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
│   ├── services.jsonc        #   .agents-owned systemd services (direct list, register only deployed units)
│   └── links.jsonc           #   .agents-owned symlinks (direct list, single machine)
├── libs/                     # Shared script libraries (no duplication)
│   ├── env/                  #   env_lib.sh / env_lib.py / env_lib.js — .env helpers (secrets, key-names+presence only)
│   ├── jsonc/                #   jsonc_lib.sh / jsonc_lib.py / jsonc_lib.js — strip_jsonc / load_jsonc / infra helpers
│   ├── notif/                #   notifier.sh (sh only) — Telegram/system notifications + homelab lock
│   └── AGENTS.md             #   rule: sh/py/js twins must stay identical (language apart) — see libs/AGENTS.md
├── scripts/                  # Global utility scripts
│   ├── env/                  #   check-env.sh, env-inspect.sh, lib.sh — .env governance checks
│   ├── jsonc/                #   check-jsonc.sh — JSONC governance check
│   ├── services/             #   check-services.sh, reload-services.sh, *_guard.sh libs
│   ├── links/                #   set-links.sh, check-links.sh, lib.sh + link_*_guard.sh libs
│   ├── tailscale/            #   check-tailscale.sh (optional check) + set-tailscale.sh (converge up --accept-dns --accept-routes --operator)
│   ├── exec/                 #   check-exec.sh, chmod.sh — script executability
│   ├── check_skills/         #   skills audit (Python: check_skills.py + guards)
│   ├── git/                  #   hooks/ (pre-commit.sh, post-commit.sh) + install-hooks.sh, push-submodules.sh
│   ├── chmod.sh              #   normalize script permissions
│   └── AGENTS.md             #   philosophy + uniform structure of all checks (see scripts/AGENTS.md)
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
> Any symlink pointing to a skill asset/script or tied to the agents kernel MUST (1) always be centralized via `~/.agents` (never a standalone copy — the file stays in `.agents/skills/<skill>/` as source of truth), and (2) **be registered in `assets/links.jsonc`** (direct list grouped by owning skill; each entry `{source,target,skill,infras:["*"]}`) so BOTH `make set-links` (creates) and `make check-links` (verifies, part of `make check`) cover it automatically. When you create a new `.agents` symlink, add it to `assets/links.jsonc` under its owning skill — that is the only registration point. Similarly, `.agents` systemd services live in `assets/services.jsonc`. Shared JSONC helpers in `libs/jsonc/jsonc_lib.sh`. See `<github-user>` → Config & Assets and `rules/skill-governance.md` → Full Debris Scan Methodology / Config Standard (JSONC).

## Security

- Git: **SSH only**. Single remote: `origin`. Never HTTPS.
- Default git email: `<primary@gmail.com>` (set in `~/.gitconfig`). Use this on all equipment.
- **Secrets zero-touch:** NEVER read, print, expose, or reference token files, API keys, passwords, or any secret values in chat. When a secret is needed, the user retrieves it manually from Vaultwarden and places it where required. No agent shall look for, extract, or display secrets — ever.
- **Commands with secrets:** When executing shell commands that require secrets (such as package publishing or deployment), agents MUST use the `with-env` helper function to keep credentials isolated in a temporary subshell (preventing leakage into the parent environment). Because `with-env` is a shell function loaded by `.kshrc`, it is only available in interactive shells. Therefore, the agent MUST execute these commands inside an interactive **tmux ops pane** (see `k-tmux`). **Publishing pattern:** `tmux send-keys -t <session>:<window>.<pane> "cd <project> && with-env <command>" Enter` — never publish directly from the agent's Bash shell. This applies to `uv publish`, `npm publish`, `uv tool install`, and any other command that reads tokens/secrets from `.agents/.env`. **API calls with secrets:** use `with-env curls --provider <name>` (or `-p <name>`) — never `curl -H "Authorization: $TOKEN"`. The `curls` wrapper (k-clis) injects auth headers from env vars via a provider manifest (`assets/providers.json`), keeping secret values out of the command line.

## File Operations Discipline (GRAVÉ)

🔴 **NEVER USE SHELL REDIRECTION TO EDIT FILES.**

- **NEVER, EVER use `cat ... > ...`, `echo >`, `sed`, or `awk` to edit or create files.**
- You must **always** use the native `Edit` tool (or `Write` tool for strictly new files) provided by your environment. This is non-negotiable.
- **Never rewrite a file wholesale without explicit request.** Precise `Edit` patches only; `cp` (never `sed`) a similar file as a base then `Edit` it; `Write` is reserved for genuinely new files (verified non-existent via `plocate`/Glob) or an explicitly requested full rewrite.
- **Read before Edit:** You must always use the `Read` tool to read the file contents first. You are forbidden to edit blindly or use `cat` to read before an edit if a native `Read` tool is available.
- See `rules/tool-discipline.md` for the full rule.
- **Live TUI test panes** (`opencode --prompt "edit /tmp/..."`) **must be `cd /tmp` first** — same `/tmp` rule as `k-opencode`: guarantees `tmp/...` permission patterns and keeps all `notify-*` test files out of project workdirs.

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

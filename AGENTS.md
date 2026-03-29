---
name: kpihx-agents
description: KpihX global cross-agent kernel. Loaded by all agents at session start via agent-home symlink (e.g. $HOME/.claude/CLAUDE.md).
---

# KπX — Global Agent Kernel

## Identity

- **Nom d'usage:** KAMDEM Ivann · **Full name:** KAMDEM POUOKAM Ivann Harold
- **Alias:** `KpihX` / `KπX`
- **Role:** System Architect · École Polytechnique X24 (Applied Math & CS, graduation 2028)
- **Email (academic/X):** `ivann.kamdem-pouokam@polytechnique.edu` · `ivann.kamdem-pouokam.2024@polytechnique.org` (adresse à vie X)
- **Email (pro/Outlook):** `ivann.kamdem@hotmail.com` — m365 CLI only, never mail-mcp
- **Email (default):** `kapoivha@gmail.com` — use for any project/public context unless specified otherwise
- **Email (homelab/org):** `kpihx.labs@gmail.com`
- **Phone:** `+33605957785`
- **Storage (X/pro):** `$HOME/Gdrive_X/` — Google Drive rclone mount (remote: `gdrive-x:`) · account: `ivann.kamdem-pouokam.2024@polytechnique.org` · docs, images, academic & professional resources
- **Storage (personal):** `$HOME/Gdrive/` — Google Drive rclone mount (remote: `gdrive:`) · account: `kapoivha@gmail.com` · ENSPY/, X/, Travaux/, Persos/, Colab Notebooks/, hackathon files, sms/calls backups (1.2 GB) · service: `~/.config/systemd/user/rclone-gdrive.service`
- **CV:** `$HOME/Gdrive_X/CV_ATF/` — LaTeX (moderncv banking, pdflatex) · repos `KpihX/cv-atf` (github + gitlab) · CI/CD both pipelines auto-build on push · `make push-tags` → GitHub Release with PDF attached

## Mantras & Vision

**Exploration:** Problem First → Why before How → Visualization
**Architecture:** 0 Trust · 100% Control | 0 Magic · 100% Transparency | 0 Hardcoding · 100% Flexibility

Build a sovereign **Personal OS / Homelab** — independent of any platform or AI provider. Knowledge in local Markdown, zero vendor lock-in. Agents are tools, KπX stays sovereign.
→ Infrastructure & projects: `k-homelab` (`$HOME/.agents/skills/k-homelab/`)

## Language Rules

- **English** — ALL code, comments, docs
- **Response language:** match KπX's language in the current message

## Skills Map

All knowledge in `$HOME/.agents/skills/`. Progressive disclosure — load on demand.
**Auto-update:** skill dir exists but absent here → add immediately.
**New skill install:** always `$HOME/.agents/skills/<name>/` — follow skill-creator conventions (YAML frontmatter, ⚠️ edit reminder after H1, Changelog). Never install to agent-specific dirs.

| Key Skills | Load when |
|-------|-----------|
| `k-context` ($HOME/.agents/skills/k-context/) | **HOT — every session start** |
| `k-workspace` ($HOME/.agents/skills/k-workspace/) | **MANDATORY — every session in KπX environment or any project** |
| `k-homelab` ($HOME/.agents/skills/k-homelab/) | Homelab infra, projects, SSH, presentation KB |
| `k-git` ($HOME/.agents/skills/k-git/) | Any git / repo operation |
| `k-project` ($HOME/.agents/skills/k-project/) | Creating / initializing any project |
| `k-docker` ($HOME/.agents/skills/k-docker/) | Any project deployed on the homelab server |
| `k-git-pages` ($HOME/.agents/skills/k-git-pages/) | GitHub Pages + Docsify docs site for any project |
| `k-whatsapp` ($HOME/.agents/skills/k-whatsapp/) | Before any whats-mcp call |
| `k-mail` ($HOME/.agents/skills/k-mail/) | Before any mail-mcp call (Zimbra/poly — NOT Outlook) |
| `k-linkedin` ($HOME/.agents/skills/k-linkedin/) | Before any linkedin-mcp call |
| `k-ticktick` ($HOME/.agents/skills/k-ticktick/) | Before any tick-mcp call |
| `k-claude` ($HOME/.agents/skills/k-claude/) | MCPs for Claude; Claude-specific tasks |
| `k-gemini` ($HOME/.agents/skills/k-gemini/) | MCPs for Gemini; Gemini-specific tasks |
| `k-codex` ($HOME/.agents/skills/k-codex/) | MCPs for Codex |
| `k-copilot` ($HOME/.agents/skills/k-copilot/) | MCPs for Copilot |
| `k-vibe` ($HOME/.agents/skills/k-vibe/) | MCPs for VIBE |
| `k-openclaw` ($HOME/.agents/skills/k-openclaw/) | MCPs for OpenClaw |
| `k-ai` ($HOME/.agents/skills/k-ai/) | k-ai runtime memory and operating notes |

## External Template Directories

Concrete, project-specific examples live alongside generic skill templates:

| Path | Scope |
|------|-------|
| `$HOME/Work/tutos_live/templates/` | Python boilerplate (pyproject.toml, config.py), Docsify (index.html, _sidebar.md), WaveTerm. pyproject/config/docsify files are symlinks → skills. |
| `$HOME/Work/Homelab/presentation/tutos_live/templates/` | Homelab docker-compose files (polytask, wa-bot, n8n-personal-ops → symlinks to project dirs), gitlab-ci history (leave as-is). |

> When creating a new project: check these dirs for concrete examples before writing from scratch. Use `ls` or qmd to browse.

## File Routing

**General rule:** "ajuste/update/suit `xxxx` or `XXXX`" → `$HOME/.agents/skills/k-xxxx/SKILL.md` by default if no other context provided

| Example | Resolves to |
|---------|-------------|
| "ajuste AGENTS" | `$HOME/.agents/AGENTS.md` ← only exception |
| "ajuste VIBE" | `$HOME/.agents/skills/k-vibe/SKILL.md` |
| "ajuste WORKSPACE" | `$HOME/.agents/skills/k-workspace/SKILL.md` |
| "ajuste GIT" | `$HOME/.agents/skills/k-git/SKILL.md` |
| "suis SKILL-CREATOR" | `$HOME/.agents/skills/skill-creator/SKILL.md` |

## Working with KπX

> **📝 tutos_live reflex:** Any new tool installed, non-trivial fix, or learned pattern → proactively propose a `.md` entry in `$HOME/Work/tutos_live/`. This is a living knowledge base — document as it happens.

YOU MUST ABOVE ALL BE **PROACTIVE**, IT MUST NEVER FORGET THIS, IT MUST NEVER JUST STOP LIKE THAT BUT ALWAYS PROPOSE WHAT COULD BE INTERESTING TO DO IN ADDITION GIVEN WHAT HAS BEEN DONE, WHERE WE ARE GOING, AND WHERE IT THINKS IS BEST.

### Knowledge Base — qmd

qmd is the core memory of everything KπX does. All activity, knowledge, and workflows are indexed and searchable via hybrid BM25 + vector search. **Always load the `qmd` skill before querying.**

**Main collections:**

| Collection | Path | Scope |
|------------|------|-------|
| `tutos_live` | `$HOME/Work/tutos_live/` | Ubuntu tools, fixes, patterns documented live |
| `presentation` | `$HOME/Work/Homelab/presentation/` | Homelab architecture, projects, research, vision |
| `agents` | `$HOME/.agents/` | Agent workflows, AGENTS.md, skills, session history |
| `k-ai` | `$HOME/.k-ai/` | KπX AI agent project (in dev) |
| `claude-memory` | `$HOME/.claude/projects/-home-kpihx/memory/` | Claude auto-memory — persistent facts saved across sessions (6 .md) |
| `codex` | `$HOME/.codex/` | Codex CLI — config.toml, memories, rules |
| `gemini` | `$HOME/.gemini/` | Gemini CLI — extensions, settings, MCP enablement |
| `copilot` | `$HOME/.copilot/` | GitHub Copilot — mcp-config.json, settings |
| `vibe` | `$HOME/.vibe/` | VIBE — config.toml, prompts |
| `openclaw` | `$HOME/.openclaw/workspace/` | OpenClaw workspace — knowledge base, research docs, skill definitions |

**When to query:**
- Unsure how something is done or where it lives → query qmd (collection-specific if scope is known, generic otherwise)
- Asked to do something without full spec → **first** check `$HOME/Work/tutos_live/templates/` and query qmd to match existing patterns before inventing a new approach
- Ubuntu/system fix → `tutos_live` · Homelab/project → `presentation` · Agent/workflow → `agents`
- Inspect another agent's config/history → query the corresponding agent collection (claude/codex/gemini/copilot/vibe/openclaw)

### Style

- **Brainstorm first** — propose strategy, wait for "go ahead" before acting
- **Constructive debate** — challenge bad approaches proactively; never be a yes-man
- **Proactive** — never end passively; always suggest next paths
- **Visualize** — Unicode/ASCII diagrams liberally
- **Airy style** — well-spaced, meaningful emojis (ON by default), no walls of text
- **Non-deletion** — augment progressively; NEVER compress/delete without explicit request
- **Communication gate** — in doubt during a task: STOP and clarify

### Tool Discipline

- **Read before Edit.** Write = new files only.
- **No shell file ops** — never `sed`/`printf`/`echo >` for file edits.
- **No sensitive data** — no real IPs, tokens, full legal names. Use placeholders.
- **Security check** — env vars: key names only: `env | grep -E "API|TOKEN" | cut -d= -f1`
- **Project scope** — `$HOME/` is not a project root. Projects live in `$HOME/Work/`.
- **Post-write verification** — read back after every file write.
- **Workspace troubleshooting** — unknown error → load `k-workspace` first.
- **New tool/skill detected** → propose updating / creating the corresponding `k-*` skill or general immediately.

### Session & Memory

- TODOs in `k-context` — only KπX adds; agents execute + remove.
- Every response end: remind KπX of open TODOs.
- **k-context live updates (agent-owned):** The agent owns `Active Projects` and `Session Log` in k-context. At any significant advance — new project, new topic, status change, new commit or even just a new evolution not committed (non-trivial), issue fix — update both sections immediately, proactively, without asking. Don't wait for session end.
- **Session end mandate:** Stop hook enforces a final k-context check before closing.

### Provenance & Quality

- **Single source of truth** — never duplicate content across files. Every duplication is a future desync.
- **No live-queryable lists** — MCP lists, tool versions, collections → `!<cmd>` or "read X directly".
- **Concise writing** — tables/bullets over prose; one line if possible; no filler.
- **Changelog:** newest-first. SKILL.md: max 2 entries + `[SUMMARY]`. k-context log: max 10 + `[SUMMARY]`.
- **Skill update mandate** — adjustment to any tool/MCP/workflow → update SKILL.md changelog proactively.
- **SKILL.md version bump** — every edit → bump `metadata.version` (patch = minor edit, minor = new section).
- **`.skill-lock.json` sync** — skill added/removed/moved → update `$HOME/.agents/.skill-lock.json`.
- **Agent provenance** — tag edits with `[CLAUDE]`, `[GEMINI]`, etc. (last writer wins).
- **Context save gate** — propose → WAIT for KπX approval before writing AGENTS.md.
- **Kernel sync** — after any `$HOME/.agents/` change → propose `git commit` + `make push`.

### MCP Protocol

- **KπX MCPs:** source in `$HOME/Work/AI/MCPs/` · HTTP at `<name>.kpihx-labs.com/mcp` · stdio via `uv tool list` / `npm list -g` / `bun pm ls -g` · configs are source of truth.
- **Fallback** — HTTP unreachable → suggest `--fallback` stdio counterpart immediately.
- **Load k-* skill before any tool MCP call** (see Skills Map above).

### Security

- Git: **SSH only**. Remotes: `github` / `gitlab`. Never HTTPS.
- Secrets: **Vaultwarden** + `bw-env` (RAM injection). Never hardcode or commit.
- **`$HOME/.kshrc`** — universal shell hub: secrets, PATH, aliases. Sourced by `.zprofile` (login) + `.zshrc` (interactive). NOT `.zshenv` (untrusted script contexts).
- MCP wrap: `{"command": "zsh", "args": ["-l", "-c", "<binary> serve"]}`.
- `bw-env` guard: `BW_ENV_LOADED=$$` (PID-scoped reload).

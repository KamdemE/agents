---
name: k-workspace
description: >
  ⚑ MANDATORY — load at the start of ANY session involving KπX environment, projects, or system.
  Directory layout ($HOME/Work/), package managers (uv/bun/npm), shell architecture (.kshrc),
  MCP ecosystem, AI CLI tools, techskills Ubuntu knowledge base, engineering standards.
license: private
metadata:
  author: KpihX
  version: "2.17.4"
allowed-tools: Bash(*), "*"
---

# KπX — Workspace & Engineering

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **IT IS CRITICAL TO ENSURE THIS FILE IS ALWAYS SYNCHRONIZED WITH THE ACTUAL PHYSICAL WORKSPACE.**

## Project finalization

Whenever work on a repo under `$HOME/Work/` (or any KπX project) is **winding down** — explicit release, "clean this up", "we're done", or you would otherwise stop touching the tree — **load `k-final`** (`$HOME/.agents/skills/k-final/SKILL.md`) **before** claiming completion and execute **all** applicable phases (tests, hygiene, docs, semver, `make push`, CI/CD, deploy logs, local install, build/publish). Do not substitute ad-hoc habits for that checklist.

## Directory Layout

> **Routing rule:** $HOME/Work/ dev/prod only (code, infra, scripts).
> For anything **not code-related**, use the standard XDG folders under $HOME:
>
> | Folder | Non-code content |
> |--------|-----------------|
> | $HOME/Pictures/ | Generated visuals (Napkin, Excalidraw exports…), screenshots, images |
> | $HOME/Documents/ | Docs, PDFs, notes, text exports |
> | $HOME/Downloads/ | Temporary downloaded files |
> | $HOME/Videos/ | Recordings, screencasts |

### $HOME/Work/ — Dev & Prod

| Path | Purpose |
|------|---------|
| $HOME/Work/AI/MCPs/ | All MCP servers source code |
| $HOME/Work/AI/gemini_mcps/ | Gemini Extension wrappers |
| $HOME/Work/sh/bw_env/ | Bitwarden env manager — secrets in RAM via /dev/shm |
| $HOME/Work/sh/ | Universal Orchestrator (Phoenix Protocol v2.1.3) — Root Makefile with smart proxies; Multi-Remote sync; **ksh dispatcher (v2.1.0) is the key entrypoint.** |
| $HOME/Work/sh/clean/ | System Cleanup (systemd, every 2 days starting Sun at 21:30) — logs: /var/log/clean-system/workspace_scan.log. |
| $HOME/Work/sh/backup_restore/ | Workstation Backup (systemd, every 2 days starting Sun at 22:00) — archiving to HDD. |
| $HOME/Work/Homelab/ | Infrastructure (Traefik, Vaultwarden, Portainer, Ollama) |
| $HOME/Work/techskills/ | Ubuntu living KB — real fixes documented as they happen. Root: flat .md per tool/topic. |
| $HOME/Work/Others/ | Miscellaneous / Non-project files / Transit zone |
| $HOME/Gdrive/ | Personal Google Drive via rclone (account: kapoivha@gmail.com) |
| $HOME/Gdrive_X/ | Pro/Academic Google Drive via rclone (account: ivann.kamdem-pouokam.2024@polytechnique.org) |
| $HOME/go/ | Go workspace (GOPATH) |

### Agent kernel (`$HOME/.agents/`)

| Path | Role |
|------|------|
| `$HOME/.agents/` | Symlink → `$HOME/KpihX-Labs/.agents/` (git root for the global agent kernel) |
| `$HOME/.agents/AGENTS.md` | Canonical **AGENTS** kernel — always edit this file; **OpenClaw workspace inject** when `agents.defaults.workspace=~/.agents` |
| `$HOME/KpihX-Labs/AGENTS.md` | Symlink → `.agents/AGENTS.md` (workspace-root convenience when the editor opens `KpihX-Labs/`) |
| `$HOME/.openclaw/workspace/AGENTS.md` | Symlink → `.agents/AGENTS.md` (legacy OpenClaw template dir; not the active workspace) |

**Do not** hard-link or maintain a second copy of `AGENTS.md` at the `KpihX-Labs/` root. Full routing table: `$HOME/.agents/AGENTS.md` → **File Routing**.

## Package Management (strict)

| Language | Toolchain | Install pattern |
|----------|-----------|-----------------|
| Python | uv ($HOME/.local/bin/uv) | CLIs: uv tool install --editable . · Scripts: uv run --with |
| JS/TS (owned projects / MCP servers) | **Bun** when runtime-compatible | bun add/run/build/test/publish · bun link / bun install -g |
| JS tools (3rd party) | npm-global ($HOME/.npm-global/) | npm install -g for daily-driver CLIs that must stay version-agnostic |
| Node.js | nvm v22.22.1 | per-project versions only; no MCP/global CLI ownership |

**Never:** pip install globally · npm install -g <local-path> · hatchling/poetry/setuptools

## Shell Architecture

```
$HOME/.kshrc     Universal Hub — secrets (bw-env), PATH, env vars, source calls (shell-agnostic)
$HOME/.zprofile  sources .kshrc → login shells (MCPs, zsh -l, SSH, WaveTerm blocks)
$HOME/.zshrc     sources .kshrc → interactive shells (terminal tabs)
$HOME/.zshenv    deliberately DOES NOT source .kshrc (security: fires for untrusted scripts)
```

bw-env idempotency guard: BW_ENV_LOADED=$$ (PID-scoped — child processes always reload secrets).

## Critical shell — shared tmux (replaces `sui`)

> **`sui` is deprecated** — agents must **not** invoke it. For **`sudo`**, SSH passphrase, or any interactive approval, use the **shared tmux gate**. Short: **`AGENTS.md` → Tool Discipline** · full: **`k-tmux/SKILL.md` → Shared interactive gate**.

### Agent workflow (summary)

1. **`tmux ls`** — reuse a short-named session/window for the topic, or `tmux new -ds <name>` if none fits.
2. **`tmux send-keys -t SESSION:WIN.PANE '<cmd>' Enter`** — run the real command (including `sudo …` or `ssh …`) in the pane.
3. **Poll** `tmux capture-pane` in a loop for **at least 30 seconds** while KπX may approve.
4. **Only after ≥30s without validation** — stop and tell KπX in chat: `tmux attach -t …`, window/tab, exact command, what to type.
5. **Kill** idle panes/sessions when the task is fully done (prudent cleanup).

Agents **never** run raw **`sudo`** in non-interactive agent tool shells; elevation happens in the shared pane.

### Submodule `.git` ownership

If **`git push`** hits **Permission denied** on `.git/refs/remotes/*.lock`, suspect **root-owned** submodule metadata — fix via shared tmux: `chown -R $USER:$USER` on affected `$HOME/Work/sh/<module>/.git` trees (see **`k-workspace/references/insights.md`**).

### Legacy `sui` (archival only)

Repo `$HOME/Work/sh/sui/` remains on disk for history; **not** part of the agent privilege path as of 2026-05-18.

### .kshrc Discipline — No Bloat Rule

> **.kshrc = hub, not a function library.** Keep it thin: env vars, PATH, and source calls only.
> Any non-trivial function or tool-specific logic should live in a real project or installable tool, not inline in .kshrc.

**Pattern:**
```bash
# .kshrc — env and PATH only
export OLLAMA_HOST="http://localhost:11434"
export OLLAMA_URL="$OLLAMA_HOST"
```

**Rules:**
- Prefer installable CLIs (uv tool, bun link, packages) over sourced shell helper files
- Keep .kshrc focused on env vars, PATH, and genuinely global shell behavior
- Ollama backend orchestration now lives in $HOME/Work/AI/ollama/ipex, not in $HOME/Work/sh/

## MCP Ecosystem

> **Source of truth — do not hardcode lists here (desync risk):**
> - Source code: $HOME/Work/AI/MCPs/
> - HTTP endpoints: <name>.kpihx-labs.com/mcp
> - Installed stdio binaries: uv tool list · npm list -g · bun pm ls -g
> - Agent configs (which MCPs are active per agent): read config files directly

> **Ownership rule:** JS/TS MCP servers you own should use Bun when the runtime is compatible and verified; if a package fails Bun verification, keep the stable owner documented in its skill. Python MCPs stay with uv; npm-global is for third-party daily-driver CLIs, not owned MCPs.

Secrets wrap pattern for MCPs needing bw-env: { "command": "zsh", "args": ["-l", "-c", "<binary> serve"] }

## AI CLI Tools

| Tool | Binary | Install method | Purpose |
|------|--------|----------------|---------|
| `claude` | $HOME/.local/bin/claude | Native installer (curl) | AI Chat |
| `gemini` | $HOME/.npm-global/bin/gemini | npm install -g | AI Chat |
| `codex` | $HOME/.npm-global/bin/codex | npm install -g | AI Chat |
| `cline` | $HOME/.npm-global/bin/cline | npm install -g cline | AI Chat |
| `opencode` | $HOME/.opencode/bin/opencode | Official install script (curl \| bash) | AI Chat |
| `vibe` | $HOME/.local/bin/vibe | uv tool install | AI Audio/Voice |
| `whisper-ctranslate2` | $HOME/.local/bin/whisper-ctranslate2 | uv tool install whisper-ctranslate2 | Local speech-to-text (Whisper) |
| `m365` | in PATH | npm install -g @pnp/cli-microsoft365 | CLI for M365 |
| `ksh` | $HOME/.local/bin/ksh | make install (sh root) | Universal Dispatcher |
| `powerpoint` | uv tool | uv tool install | PPTX generation |

WaveTerm widgets: $HOME/.config/waveterm/widgets.json — all use zsh -l -c '...' wrapper.
npm global prefix: $HOME/.npmrc → prefix=$HOME/.npm-global (no EACCES, no sudo needed).

### Speech-to-text baseline (installed)

- **Detected local STT tool:** `whisper-ctranslate2` (`0.5.7`) is available and currently the fastest ready-to-run local path.
- **Intel Arc note:** this CLI currently exposes `cpu`/`cuda`; no direct Arc backend flag, so use optimized CPU settings by default.
- **Recommended command pattern (fast + strong quality):**
```bash
whisper-ctranslate2 "audio.m4a" \
  --model distil-large-v3 \
  --device cpu \
  --compute_type int8 \
  --vad_filter true \
  --output_format txt \
  --output_dir .
```
- **Model quick picks (speed vs quality):**

| Profile | Model | Typical use |
|---------|-------|-------------|
| Fastest practical | `distil-small.en` | English notes and quick drafts |
| Balanced default | `small` | Mixed languages and daily transcripts |
| Best quality (still efficient) | `distil-large-v3` | Long or important recordings |

- **Intel Arc acceleration path (advanced):** if you want GPU acceleration on Arc, use a dedicated Intel path (typically `whisper.cpp` with OpenVINO). Keep `whisper-ctranslate2` as the stable baseline until that backend is installed and benchmarked.

> For hook wiring, permissions, and runtime behavior, read the dedicated runtime skills (k-claude, k-gemini, k-codex, k-vibe, k-copilot) and k-hook rather than duplicating agent-specific snapshots here.
> For optimization posture, QMD hygiene, and cleanup actions, read k-optim rather than duplicating maintenance playbooks here.

## Engineering Standards (quick ref)

- **Build backend:** uv_build only · Bun for JS/TS
- **Architecture:** Independent packages in src/<pkg>/ — no monoliths
- **Pattern:** Directive-Sequential (Executor logic ↔ Orchestrator lifecycle)
- **Python naming:** snake_case local/import · dashes for PyPI/CLI/repo name
- **Makefile:** Every project — make push pushes to ALL remotes simultaneously
- **Docker base:** Python → python:3.12-slim · JS/TS → oven/bun:1-slim
- **GitLab MCPs:** All MCPs in kpihx-labs GitLab group namespace
- **PyPI name ≠ module:** Use [tool.uv.build-backend] module-name = "<import_name>" to decouple

## Homelab & Tailscale

- **SSH:** ssh kpihx-labs / ssh docker-host / ssh docker-host-x (Tailscale Magic DNS — source of truth: $HOME/.ssh/config)
- **Vault:** vault.kpihx-labs.com — private, Tailscale-only
- **Do not hardcode live Tailscale inventory here.** Read the current state directly from:
  - tailscale status or tailscale status --json
  - $HOME/.ssh/config for active host aliases and routing names
  - k-homelab for stable homelab topology and operational access patterns

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-workspace/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-workspace/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-27 | [CURSOR] | v2.17.4 — OpenClaw workspace = `~/.agents`; AGENTS symlink map (KpihX-Labs + legacy openclaw workspace). |
| 2026-05-26 | [AUTO] | v2.17.3 — Added Cline CLI to AI tooling registry (`$HOME/.npm-global/bin/cline`). |
| [SUMMARY] | — | v2.17.2 OpenCode; v2.17.1 Nautilus runbook; v2.17.0 tmux gate; v2.16.9 kernel layout; prior history in git |

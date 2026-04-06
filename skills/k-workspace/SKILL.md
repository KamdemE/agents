---
name: k-workspace
description: >
  ⚑ MANDATORY — load at the start of ANY session involving KπX environment, projects, or system.
  Directory layout ($HOME/Work/), package managers (uv/bun/npm), shell architecture (.kshrc),
  MCP ecosystem, AI CLI tools, tutos_live Ubuntu knowledge base, engineering standards.
license: private
metadata:
  author: KpihX
  version: "2.13.0"
allowed-tools: Bash(*), "*"
---

# KπX — Workspace & Engineering

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG). IT IS CRITICAL TO ENSURE THIS FILE IS ALWAYS SYNCHRONIZED WITH THE ACTUAL PHYSICAL WORKSPACE.**

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
| $HOME/Work/sh/ | Universal Orchestrator (Phoenix Protocol v2.1.2) — Root Makefile with smart proxies; Multi-Remote sync; **ksh dispatcher (v2.1.0) is the key entrypoint.** |
| $HOME/Work/sh/clean/ | Unified Cleanup Suite (systemd, Saturday 10:00) — modules: snap, cache, vscode, work, docker, ai. |
| $HOME/Work/Homelab/ | Infrastructure (Traefik, Vaultwarden, Portainer, Ollama) |
| $HOME/Work/tutos_live/ | Ubuntu living KB — real fixes documented as they happen. Root: flat .md per tool/topic. |
| $HOME/Work/Others/ | Miscellaneous / Non-project files / Transit zone |
| $HOME/Gdrive/ | Personal Google Drive via rclone (account: kapoivha@gmail.com) |
| $HOME/Gdrive_X/ | Pro/Academic Google Drive via rclone (account: ivann.kamdem-pouokam.2024@polytechnique.org) |
| $HOME/go/ | Go workspace (GOPATH) |

## Package Management (strict)

| Language | Toolchain | Install pattern |
|----------|-----------|-----------------|
| Python | uv ($HOME/.local/bin/uv) | CLIs: uv tool install --editable . · Scripts: uv run --with |
| JS/TS | **Bun** (primary) | bun add/run/build/test/publish |
| JS tools (3rd party) | npm-global ($HOME/.npm-global/) | npm install -g → symlink to $HOME/.local/bin/ if needed |
| Node.js | nvm v22.22.1 | Symlink: $HOME/.local/bin/node → $HOME/.nvm/versions/node/v22.22.1/bin/node |

**Never:** pip install globally · npm install -g <local-path> · hatchling/poetry/setuptools

## Shell Architecture

```
$HOME/.kshrc     Universal Hub — secrets (bw-env), PATH, env vars, source calls (shell-agnostic)
$HOME/.zprofile  sources .kshrc → login shells (MCPs, zsh -l, SSH, WaveTerm blocks)
$HOME/.zshrc     sources .kshrc → interactive shells (terminal tabs)
$HOME/.zshenv    deliberately DOES NOT source .kshrc (security: fires for untrusted scripts)
```

bw-env idempotency guard: BW_ENV_LOADED=$$ (PID-scoped — child processes always reload secrets).

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

Secrets wrap pattern for MCPs needing bw-env: { "command": "zsh", "args": ["-l", "-c", "<binary> serve"] }

## AI CLI Tools

| Tool | Binary | Install method | Purpose |
|------|--------|----------------|---------|
| `claude` | $HOME/.local/bin/claude | Native installer (curl) | AI Chat |
| `gemini` | $HOME/.npm-global/bin/gemini | npm install -g | AI Chat |
| `codex` | $HOME/.npm-global/bin/codex | npm install -g | AI Chat |
| `vibe` | $HOME/.local/bin/vibe | uv tool install | AI Audio/Voice |
| `m365` | in PATH | npm install -g @pnp/cli-microsoft365 | CLI for M365 |
| `ksh` | $HOME/.local/bin/ksh | make install (sh root) | Universal Dispatcher |
| `powerpoint` | uv tool | uv tool install | PPTX generation |

WaveTerm widgets: $HOME/.config/waveterm/widgets.json — all use zsh -l -c '...' wrapper.
npm global prefix: $HOME/.npmrc → prefix=$HOME/.npm-global (no EACCES, no sudo needed).

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-06 | [GEMINI] | v2.12.0 — Stability Validation: ENOSPC (Inotify) loops resolved via global `files.watcherExclude`. Workstation synced v2.1.2. |
| 2026-04-06 | [CLAUDE] | v2.11.1 — Session finalize: path tables use bare `$HOME` tokens; `ksh` + Phoenix v2.1.2 row in AI CLI table; committed with `k-tg` |
| 2026-04-05 | [GEMINI] | v2.11.0 — Unified Workstation Orchestrator: Phoenix v2.1.2, ksh dispatcher, multi-remote push standard |
| [SUMMARY] | — | v2.10.0 retired binary cleanup; v2.9.0–v1.0.0: Tailscale SOT pointers, cleanup suite, .kshrc discipline, routing rules, CLI tooling baseline |

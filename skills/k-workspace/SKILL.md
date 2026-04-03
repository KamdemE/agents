---
name: k-workspace
description: >
  ⚑ MANDATORY — load at the start of ANY session involving KπX environment, projects, or system.
  Directory layout ($HOME/Work/), package managers (uv/bun/npm), shell architecture (.kshrc),
  MCP ecosystem, AI CLI tools, tutos_live Ubuntu knowledge base, engineering standards.
license: private
metadata:
  author: KpihX
  version: "2.9.0"
allowed-tools: Bash(*), "*"
---

# KπX — Workspace & Engineering

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Directory Layout

> **Routing rule:** `$HOME/Work/` = dev/prod only (code, infra, scripts).
> For anything **not code-related**, use the standard XDG folders under `$HOME`:
>
> | Folder | Non-code content |
> |--------|-----------------|
> | `$HOME/Pictures/` | Generated visuals (Napkin, Excalidraw exports…), screenshots, images |
> | `$HOME/Documents/` | Docs, PDFs, notes, text exports |
> | `$HOME/Downloads/` | Temporary downloaded files |
> | `$HOME/Videos/` | Recordings, screencasts |

### `$HOME/Work/` — Dev & Prod

| Path | Purpose |
|------|---------|
| `$HOME/Work/AI/MCPs/` | All MCP servers source code |
| `$HOME/Work/AI/gemini_mcps/` | Gemini Extension wrappers |
| `$HOME/Work/sh/bw-env/` | Bitwarden env manager — secrets in RAM via `/dev/shm` |
| `$HOME/Work/sh/` | Personal scripts & system tools |
| `$HOME/Work/sh/clean/` | Unified Cleanup Suite (systemd, Saturday 10:00) — modules: snap, cache, vscode, work, docker, ai. VSCode module: `$HOME/.config/Code/` (VSIX cache, Electron cache, logs, CachedData, WebStorage) |
| `$HOME/Work/Homelab/` | Infrastructure (Traefik, Vaultwarden, Portainer, Ollama) |
| `$HOME/Work/tutos_live/` | Ubuntu living KB — real fixes documented as they happen. Root: flat `.md` per tool/topic (bun, bw-env, qmd, tailscale, gh…). `templates/` — reusable doc templates. `mcps/` — MCP tutorials. `sh/` — shell/scripting. |
| `$HOME/Work/Test/` | Sandbox for new patterns |
| `$HOME/Gdrive_X/` | Google Drive X via rclone (remote: `gdrive-x:`) |

## Package Management (strict)

| Language | Toolchain | Install pattern |
|----------|-----------|-----------------|
| Python | `uv` (`$HOME/.local/bin/uv`) | CLIs: `uv tool install --editable .` · Scripts: `uv run --with` |
| JS/TS | **Bun** (primary) | `bun add/run/build/test/publish` |
| JS tools (3rd party) | npm-global (`$HOME/.npm-global/`) | `npm install -g` → symlink to `$HOME/.local/bin/` if needed |
| Node.js | nvm v22.22.1 | Symlink: `$HOME/.local/bin/node` → `$HOME/.nvm/versions/node/v22.22.1/bin/node` |

**Never:** `pip install` globally · `npm install -g <local-path>` · `hatchling/poetry/setuptools`

## Shell Architecture

```
$HOME/.kshrc     Universal Hub — secrets (bw-env), PATH, env vars, source calls (shell-agnostic)
$HOME/.zprofile  sources .kshrc → login shells (MCPs, zsh -l, SSH, WaveTerm blocks)
$HOME/.zshrc     sources .kshrc → interactive shells (terminal tabs)
$HOME/.zshenv    deliberately DOES NOT source .kshrc (security: fires for untrusted scripts)
```

`bw-env` idempotency guard: `BW_ENV_LOADED=$$` (PID-scoped — child processes always reload secrets).

### `.kshrc` Discipline — No Bloat Rule

> **`.kshrc` = hub, not a function library.** Keep it thin: env vars, PATH, and `source` calls only.
> Any non-trivial function or tool-specific logic → its own `$HOME/Work/sh/<tool>.sh`, sourced from `.kshrc`.

**Pattern:**
```bash
# .kshrc — one-liner per tool
[ -f "$HOME/Work/sh/ollama.sh" ] && source "$HOME/Work/sh/ollama.sh"
[ -f "$HOME/Work/sh/myapp.sh"  ] && source "$HOME/Work/sh/myapp.sh"
```

**Rules:**
- Each `Work/sh/<tool>.sh` owns its functions, local vars (prefixed `_TOOL_*`), and comments
- Guard with `[ -f ... ] && source` — silent no-op if missing
- Template for new tools: `$HOME/.agents/skills/k-ollama/assets/ollama.sh` (reference pattern)
- Existing scripts in `Work/sh/`: `backup_workstation.sh`, `clean_system.sh`, `workspace-scan.sh`, `ollama.sh`

## MCP Ecosystem

> **Source of truth — do not hardcode lists here (desync risk):**
> - Source code: `$HOME/Work/AI/MCPs/`
> - HTTP endpoints: `<name>.kpihx-labs.com/mcp`
> - Installed stdio binaries: `uv tool list` · `npm list -g` · `bun pm ls -g`
> - Agent configs (which MCPs are active per agent): read config files directly

Secrets wrap pattern for MCPs needing bw-env: `{ "command": "zsh", "args": ["-l", "-c", "<binary> serve"] }`

## AI CLI Tools

| Tool | Binary | Install method |
|------|--------|----------------|
| `claude` | `$HOME/.local/bin/claude` | Native installer (curl) |
| `gemini` | `$HOME/.npm-global/bin/gemini` | `npm install -g` |
| `codex` | `$HOME/.npm-global/bin/codex` | `npm install -g` |
| `openclaw` | `$HOME/.local/bin/openclaw` | `npm install -g` + symlink |
| `vibe` | `$HOME/.local/bin/vibe` | `uv tool install` |
| `m365` | in PATH | `npm install -g @pnp/cli-microsoft365` |

### CLI Tools

| Tool | Binary | Install method | Purpose |
|------|--------|----------------|---------|
| `powerpoint` | `uv tool` | `uv tool install` | Generate/manipulate PPTX files |

WaveTerm widgets: `$HOME/.config/waveterm/widgets.json` — all use `zsh -l -c '...'` wrapper.
npm global prefix: `$HOME/.npmrc` → `prefix=$HOME/.npm-global` (no EACCES, no sudo needed).

> For hook wiring, permissions, and runtime behavior, read the dedicated runtime skills (`k-claude`, `k-gemini`, `k-codex`, `k-openclaw`, `k-vibe`, `k-copilot`) and `k-hook` rather than duplicating agent-specific snapshots here.
> For optimization posture, QMD hygiene, and cleanup actions, read `k-optim` rather than duplicating maintenance playbooks here.

## Engineering Standards (quick ref)

- **Build backend:** `uv_build` only · Bun for JS/TS
- **Architecture:** Independent packages in `src/<pkg>/` — no monoliths
- **Pattern:** Directive-Sequential (Executor logic ↔ Orchestrator lifecycle)
- **Python naming:** `snake_case` local/import · dashes for PyPI/CLI/repo name
- **Makefile:** Every project — `make push` pushes to ALL remotes simultaneously
- **Docker base:** Python → `python:3.12-slim` · JS/TS → `oven/bun:1-slim`
- **GitLab MCPs:** All MCPs in `kpihx-labs` GitLab group namespace
- **PyPI name ≠ module:** Use `[tool.uv.build-backend] module-name = "<import_name>"` to decouple

## Homelab & Tailscale

- **SSH:** `ssh kpihx-labs` / `ssh docker-host` / `ssh docker-host-x` (Tailscale Magic DNS — source of truth: `$HOME/.ssh/config`)
- **Vault:** `vault.kpihx-labs.com` — private, Tailscale-only
- **Do not hardcode live Tailscale inventory here.** Read the current state directly from:
  - `tailscale status` or `tailscale status --json`
  - `$HOME/.ssh/config` for active host aliases and routing names
  - `k-homelab` for stable homelab topology and operational access patterns

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.9.0 — removed the live Tailscale/IP snapshot and replaced it with source-of-truth pointers (`tailscale status`, `$HOME/.ssh/config`, and `k-homelab`) so the workspace skill stays stable instead of drifting |
| 2026-04-03 | [CODEX] | v2.8.4 — linked the workspace skill to `k-optim` as the dedicated optimization and cleanup posture map instead of duplicating that maintenance workflow here |
| [SUMMARY] | — | v2.8.4–v1.0.0 kept runtime inventory source-of-truth oriented, normalized paths to `$HOME`, documented the cleanup suite, `.kshrc` discipline, routing rules, Tailscale access patterns, CLI tooling, and the broader workspace baseline |

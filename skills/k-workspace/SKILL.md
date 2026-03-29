---
name: kpihx-workspace
description: >
  ⚑ MANDATORY — load at the start of ANY session involving KπX environment, projects, or system.
  Directory layout (~/Work/), package managers (uv/bun/npm), shell architecture (.kshrc),
  MCP ecosystem, AI CLI tools, tutos_live Ubuntu knowledge base, engineering standards.
license: private
metadata:
  author: KpihX
  version: "2.4.0"
allowed-tools: Bash(*), "*"
---

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

# KπX — Workspace & Engineering

## Directory Layout (`~/Work/`)

| Path | Purpose |
|------|---------|
| `~/Work/AI/MCPs/` | All MCP servers source code |
| `~/Work/AI/gemini_mcps/` | Gemini Extension wrappers |
| `~/Work/sh/bw-env/` | Bitwarden env manager — secrets in RAM via `/dev/shm` |
| `~/Work/sh/` | Personal scripts & system tools |
| `~/Work/sh/clean/` | Unified Cleanup Suite (systemd, Saturday 10:00) |
| `~/Work/Homelab/` | Infrastructure (Traefik, Vaultwarden, Portainer, Ollama) |
| `~/Work/tutos_live/` | Ubuntu living KB — real fixes documented as they happen. Root: flat `.md` per tool/topic (bun, bw-env, qmd, tailscale, gh…). `templates/` — reusable doc templates. `mcps/` — MCP tutorials. `sh/` — shell/scripting. |
| `~/Work/Test/` | Sandbox for new patterns |
| `~/Gdrive_X/` | Google Drive X via rclone (remote: `gdrive-x:`) |

## Package Management (strict)

| Language | Toolchain | Install pattern |
|----------|-----------|-----------------|
| Python | `uv` (`~/.local/bin/uv`) | CLIs: `uv tool install --editable .` · Scripts: `uv run --with` |
| JS/TS | **Bun** (primary) | `bun add/run/build/test/publish` |
| JS tools (3rd party) | npm-global (`~/.npm-global/`) | `npm install -g` → symlink to `~/.local/bin/` if needed |
| Node.js | nvm v22.22.1 | Symlink: `~/.local/bin/node` → `~/.nvm/versions/node/v22.22.1/bin/node` |

**Never:** `pip install` globally · `npm install -g <local-path>` · `hatchling/poetry/setuptools`

## Shell Architecture

```
~/.kshrc     Universal Hub — secrets (bw-env), PATH, aliases, env vars (shell-agnostic)
~/.zprofile  sources .kshrc → login shells (MCPs, zsh -l, SSH, WaveTerm blocks)
~/.zshrc     sources .kshrc → interactive shells (terminal tabs)
~/.zshenv    deliberately DOES NOT source .kshrc (security: fires for untrusted scripts)
```

`bw-env` idempotency guard: `BW_ENV_LOADED=$$` (PID-scoped — child processes always reload secrets).

## MCP Ecosystem

> **Source of truth — do not hardcode lists here (desync risk):**
> - Source code: `~/Work/AI/MCPs/`
> - HTTP endpoints: `<name>.kpihx-labs.com/mcp`
> - Installed stdio binaries: `uv tool list` · `npm list -g` · `bun pm ls -g`
> - Agent configs (which MCPs are active per agent): read config files directly

Secrets wrap pattern for MCPs needing bw-env: `{ "command": "zsh", "args": ["-l", "-c", "<binary> serve"] }`

## AI CLI Tools

| Tool | Binary | Install method |
|------|--------|----------------|
| `claude` | `~/.local/bin/claude` | Native installer (curl) |
| `gemini` | `~/.npm-global/bin/gemini` | `npm install -g` |
| `codex` | `~/.npm-global/bin/codex` | `npm install -g` |
| `openclaw` | `~/.local/bin/openclaw` | `npm install -g` + symlink |
| `vibe` | `~/.local/bin/vibe` | `uv tool install` |
| `m365` | in PATH | `npm install -g @pnp/cli-microsoft365` |

### CLI Tools

| Tool | Binary | Install method | Purpose |
|------|--------|----------------|---------|
| `powerpoint` | `uv tool` | `uv tool install` | Generate/manipulate PPTX files |

WaveTerm widgets: `~/.config/waveterm/widgets.json` — all use `zsh -l -c '...'` wrapper.
npm global prefix: `~/.npmrc` → `prefix=~/.npm-global` (no EACCES, no sudo needed).

## Engineering Standards (quick ref)

- **Build backend:** `uv_build` only · Bun for JS/TS
- **Architecture:** Independent packages in `src/<pkg>/` — no monoliths
- **Pattern:** Directive-Sequential (Executor logic ↔ Orchestrator lifecycle)
- **Python naming:** `snake_case` local/import · dashes for PyPI/CLI/repo name
- **Makefile:** Every project — `make push` pushes to ALL remotes simultaneously
- **Docker base:** Python → `python:3.12-slim` · JS/TS → `oven/bun:1-slim`
- **GitLab MCPs:** All MCPs in `kpihx-labs` GitLab group namespace
- **PyPI name ≠ module:** Use `[tool.uv.build-backend] module-name = "<import_name>"` to decouple

## Homelab

- **SSH:** `ssh homelab` / `ssh kpihx-labs` (Tailscale Magic DNS)
- **Docker host:** `ssh docker-host` or `ssh docker-host-x`
- **Vault:** `vault.kpihx-labs.com` — private, Tailscale-only

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v2.4.0 — description: MANDATORY imperative; tutos_live row expanded (Ubuntu KB, subdirs) |
| [SUMMARY] | — | v2.3.0 +powerpoint tool; v2.2.0 MCP live-query refs; v2.0.0 refonte; v1.0.0 init |

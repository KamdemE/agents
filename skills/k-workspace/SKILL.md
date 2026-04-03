---
name: k-workspace
description: >
  ⚑ MANDATORY — load at the start of ANY session involving KπX environment, projects, or system.
  Directory layout (~/Work/), package managers (uv/bun/npm), shell architecture (.kshrc),
  MCP ecosystem, AI CLI tools, tutos_live Ubuntu knowledge base, engineering standards.
license: private
metadata:
  author: KpihX
  version: "2.8.0"
allowed-tools: Bash(*), "*"
---

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

# KπX — Workspace & Engineering

## Directory Layout

> **Routing rule:** `~/Work/` = dev/prod only (code, infra, scripts).
> For anything **not code-related**, use the standard XDG folders under `$HOME`:
>
> | Folder | Non-code content |
> |--------|-----------------|
> | `~/Pictures/` | Generated visuals (Napkin, Excalidraw exports…), screenshots, images |
> | `~/Documents/` | Docs, PDFs, notes, text exports |
> | `~/Downloads/` | Temporary downloaded files |
> | `~/Videos/` | Recordings, screencasts |

### `~/Work/` — Dev & Prod

| Path | Purpose |
|------|---------|
| `~/Work/AI/MCPs/` | All MCP servers source code |
| `~/Work/AI/gemini_mcps/` | Gemini Extension wrappers |
| `~/Work/sh/bw-env/` | Bitwarden env manager — secrets in RAM via `/dev/shm` |
| `~/Work/sh/` | Personal scripts & system tools |
| `~/Work/sh/clean/` | Unified Cleanup Suite (systemd, Saturday 10:00) — modules: snap, cache, vscode, work, docker, ai. VSCode module: `~/.config/Code/` (VSIX cache, Electron cache, logs, CachedData, WebStorage) |
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
~/.kshrc     Universal Hub — secrets (bw-env), PATH, env vars, source calls (shell-agnostic)
~/.zprofile  sources .kshrc → login shells (MCPs, zsh -l, SSH, WaveTerm blocks)
~/.zshrc     sources .kshrc → interactive shells (terminal tabs)
~/.zshenv    deliberately DOES NOT source .kshrc (security: fires for untrusted scripts)
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

## Homelab & Tailscale

- **SSH:** `ssh kpihx-labs` / `ssh docker-host` / `ssh docker-host-x` (Tailscale Magic DNS — see `~/.ssh/config`)
- **Vault:** `vault.kpihx-labs.com` — private, Tailscale-only

| Device | Tailscale IP | OS | Status |
|--------|-------------|-----|--------|
| `kpihx-ubuntu` | `100.82.95.70` | Linux | this machine |
| `kpihx-labs` | `100.123.81.21` | Linux | homelab server (active, direct) |
| `kpihx-phone` | `100.125.54.1` | Android | active (relay) |
| `kpihx-tablet` | `100.89.79.87` | Android | offline |
| `kpihx-windows` | `100.108.7.86` | Windows | offline |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CLAUDE] | v2.8.0 — clean/ suite: clean_vscode.sh added; ~/Work/sh/clean/ entry enriched with module list + VSCode targets |
| 2026-04-02 | [CLAUDE] | v2.7.0 — `.kshrc` No Bloat Rule: thin hub pattern, Work/sh/<tool>.sh sourcing discipline |
| 2026-03-31 | [CLAUDE] | v2.6.0 — routing rule: ~/Work/ = code only; XDG folders table |
| [SUMMARY] | — | v2.5.0 Tailscale table; v2.4.0 MANDATORY+tutos_live; v2.3.0 +powerpoint; v2.0.0 refonte; v1.0.0 init |

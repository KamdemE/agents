---
name: k-workspace
description: >
  ⚑ MANDATORY — load at the start of ANY session involving KπX environment, projects, or system.
  Directory layout ($HOME/Work/), package managers (uv/bun/npm), shell architecture (.kshrc),
  MCP ecosystem, AI CLI tools, techskills Ubuntu knowledge base, engineering standards.
license: private
metadata:
  author: KpihX
  version: "2.23.0"
allowed-tools: Bash(*), "*"
---

# KπX — Workspace & Engineering

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **IT IS CRITICAL TO ENSURE THIS FILE IS ALWAYS SYNCHRONIZED WITH THE ACTUAL PHYSICAL WORKSPACE.**
> **Static rules:** `rules/tool-discipline.md` (tmux gate, file ops) · `rules/audit-commands.md` (uv, make push) · `rules/file-governance.md` ($HOME paths, language)

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
| $HOME/Work/sh/Vaultwarden/ | Bitwarden env manager — secrets in RAM via /dev/shm |
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
$HOME/.kshrc     Universal Hub — secrets (Vaultwarden), PATH, env vars, source calls (shell-agnostic)
$HOME/.zprofile  sources .kshrc → login shells (MCPs, zsh -l, SSH, WaveTerm blocks)
$HOME/.zshrc     sources .kshrc → interactive shells (terminal tabs)
$HOME/.zshenv    deliberately DOES NOT source .kshrc (security: fires for untrusted scripts)
```

Vaultwarden idempotency guard: secrets_LOADED=$$ (PID-scoped — child processes always reload secrets).

## Critical shell — shared tmux (replaces `sui`)

**`sui` is deprecated.** For `sudo`, SSH passphrase, or any interactive approval → `rules/tool-discipline.md` · `k-tmux/SKILL.md` → Shared interactive gate.

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

Secrets wrap pattern for MCPs needing Vaultwarden: { "command": "zsh", "args": ["-l", "-c", "<binary> serve"] }

## System Services (enabled at boot)

| Service | Role | Notes |
|---------|------|-------|
| `tor@default.service` | Anonymizing overlay network (SOCKS5 proxy on 127.0.0.1:9050) | Used for privacy-sensitive operations. ~112 MB RAM. Disable if not actively using Tor. |
| `docker.service` | Container runtime | Core infra. |
| `tailscaled.service` | Tailscale mesh VPN | Persistent connectivity to homelab and peers. |
| `rclone-gdrive.service` | Google Drive FUSE mount (kapoivha@gmail.com) | `~/Gdrive` mount point. |
| `rclone-gdrive-x.service` | Google Drive FUSE mount (Poly X account) | `~/Gdrive_X` mount point. |
| `open-webui.service` | Purged (2026-05-31). | Launch manually with `docker compose up` if needed. |
| `nftables.service` | Firewall (nftables, remplace ufw) | Voir `k-nftables/SKILL.md` pour le ruleset et la gestion. |

## Neovim RAM Optimization

Idle memory was **2.3 GB** (Lua heap 2003 MB) due to plugins loading at startup. Fixed by:

- `opencode.nvim` + `snacks.nvim` → `event = "VeryLazy"`
- `harpoon` → lazy-load via `keys` (callback functions, not `config`)
- `indent-blankline.nvim` → `event = "VeryLazy"`

**Result:** nvim idle = **21 MB** (Lua heap 35 MB). ~99% reduction.

Full Telescope exclusion map and `find_command` details: `k-vim/references/telescope.md`

Full registry of KπX-added CLIs with routing to dedicated skills: **`k-clis`**.

WaveTerm widgets: $HOME/.config/waveterm/widgets.json — all load their own environment.
npm global prefix: $HOME/.npmrc → prefix=$HOME/.npm-global (no EACCES, no sudo needed).

### System CLIs (npm-global)

| CLI | Install | Purpose |
|-----|---------|---------|
| `fd` | `npm i -g fd-find` | Telescope file-search backend (faster than vim's internal find) |

### System CLIs (uv tool)

| CLI | Install | Purpose |
|-----|---------|---------|
| `asciinema` | `uv tool install asciinema` | Terminal session recorder (text-based `.cast` format, replayable and machine-readable) |

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

## Remote Work — DxO VPN + RDP

> **Asset:** `assets/vpn-dxo` → symlinked to `$HOME/Work/sh/vpn-dxo` (in PATH)

### VPN (GlobalProtect via OpenConnect)

| Commande | Effet |
|----------|-------|
| `vpn-dxo` | Lance le VPN dans tmux session `vpn-dxo` + attach (entre pass sudo) |
| `vpn-dxo` (si déjà lancé) | Ré-attach à la session |
| `vpn-dxo status` | Vérifie si le VPN tourne |
| `vpn-dxo stop` | Tue la session tmux |

**Connexion :** une fenêtre WebKit popup s'ouvre → auth Microsoft (email + MFA). Le tunnel reste actif en arrière-plan.

**Params :** `--ignore-tls-errors --fix-openssl` (certificat auto-signé DxO + OpenSSL 3+ legacy renegotiation)

### RDP (Remmina → BLGLAPTOP139)

| Champ | Valeur |
|-------|--------|
| Server | `BLGLAPTOP139.corp.dxo.com` |
| Username | `ikamdem` (sans domaine) |
| Password | mot de passe DxO |
| Domain | `corp.dxo.com` |

**Profile file :** `~/.local/share/remmina/group_rdp_dxo_blglaptop139-corp-dxo-com.remmina`

**Audio :** `sound=local` + `microphone=local` (son/mic sortent sur l'Ubuntu client)

**Multi-écran :** Edit → Advanced → "Span screen over multiple monitors" + Resolution "Use client resolution"

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-workspace/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-workspace/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-21 | [OPENCODE] | v2.23.0 — Added `nftables.service` to System Services table, ref `k-nftables/SKILL.md`. |
| 2026-06-21 | [OPENCODE] | v2.22.0 — Added Remote Work section (DxO VPN GlobalProtect + RDP Remmina), asset `vpn-dxo` symlinked to `~/Work/sh/`. |
| [SUMMARY] | — | v2.21.0 asciinema CLI; v2.17.2 OpenCode; v2.17.1 Nautilus runbook; v2.17.0 tmux gate; v2.16.9 kernel layout; prior history in git |

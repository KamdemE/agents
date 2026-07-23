---
name: k-clis
description: >
  KπX key CLI registry — routes to dedicated k-* skills.
  Covers only CLIs KπX added (no native linux/ubuntu tools).
  Merger of k-cloud-tools routing hub.
metadata:
  author: KpihX
  version: 1.6.0
  scope: operations
---

# KπX — Key CLI Registry

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

**⚠️ This skill lists only CLIs that KπX added manually (non-native to linux/ubuntu).**
**When creating a new CLI skill, you MUST add an entry here.**

> **⚠️ FIRST SKILL TO READ WHEN SETTING UP A NEW MACHINE:** **`k-zsh`** — shell foundation (.kshrc, zsh, oh-my-zsh) must be in place before any other CLI works correctly. Always load `k-zsh` first.

> **Legacy:** this skill merges and replaces `k-cloud-tools` as the central routing hub.

## Agent Runtime CLIs

> Each runtime also registers in **`k-agents`** (master agent runtime registry: configs, symlinks, MCP wiring, ACP bridges).

| CLI | Skill | Also in | Notes |
|-----|-------|---------|-------|
| `opencode` | **`k-opencode`** | **`k-agents`** | OpenCode — MCP, providers, auth, permissions |
| `codex` | **`k-codex`** | **`k-agents`** | Codex — config.toml, sandbox, MCP TOML format |
| `cline` | **`k-cline`** | **`k-agents`** | Cline — install/update, MCP settings |
| `gemini` | **`k-gemini`** | **`k-agents`** | Gemini — extensions, MCP install, settings.json |
| `vibe` | **`k-vibe`** | **`k-agents`** | VIBE — config.toml, TOML MCP, tool permissions |
| `copilot` | **`k-copilot`** | **`k-agents`** | GitHub Copilot — mcp-config, instructions |
| `hermes` / `hermes-agent` | **`k-hermes`** | **`k-agents`** | Persistent memory daemon — cron-driven, headless |
| `zed` | **`k-zed`** | **`k-agents`** | Zed agent hub — profiles, MCP, ACP bridges |
| `cursor` / `cursor-agent` | **`k-code`** | **`k-agents`** | Cursor — VS Code fork, antigravity sync |

## Cloud & Infrastructure

| CLI | Skill | Notes |
|-----|-------|-------|
| `gcloud` | **`k-google`** | GCP suite (container) |
| `gws` (`gws-kpihx`/`gws-labs`) | **`k-google`** | Google Workspace content |
| `m365` | **`k-microsoft`** | MS365 Graph — sole Microsoft CLI (~~`az`~~ deactivated) |
| `flarectl` | **`k-cloudflare`** | Cloudflare DNS/zones (workstation) |
| `cloudflared` | **`k-cloudflare`** | Tunnel connector (homelab server only) |
| `wrangler` | **`k-cloudflare`** | Off on workstation — IDE only |
| `tailscale` | **`k-tailscale`** | Mesh VPN + Tailscale Serve — port mapping, service hookup |
| `ts-proxy` | _(this skill)_ | Tailscale API + HITL |
| `docker` / `docker-compose` | **`k-docker`** | Container build & deploy |
| `ollama` | **`k-ollama`** | Local LLM serving — Intel Arc GPU |

## Productivity & Communication

| CLI | Skill | Notes |
|-----|-------|-------|
| `qmd` / `qmdr` | **`k-qmd`** | BM25+vector hybrid search on knowledge bases |
| `bw` / `bw-proxy` / `bw-env` | **`k-bw`** | Bitwarden — self-hosted Vaultwarden |
| `rclone` | **`k-rclone`** | Cloud storage FUSE mounts (Google Drive) |
| `tg` | **`k-tg`** | Telegram — Telethon, BotFather, infra-bot |
| `x_cli.py` | **`k-x`** | X (Twitter) API v2 — OAuth 1.0a |
| `meta_cli.py` | **`k-meta`** | Meta Graph API — OAuth smoke tests |
| `powerpoint` (MCP) | **`k-pptx`** | PPTX generation from markdown |
| `broot` | _(this skill)_ | Interactive file explorer — `apt` |
| `whisper-ctranslate2` | _(this skill)_ | Local speech-to-text — Whisper |
| `ksh` | _(this skill)_ | Universal Dispatcher |
| `youtube_cli.py` | **`k-media`** + **`k-google`** | YouTube upload |
| `adb` | **`k-25`** | Android phone wireless debugging |
| `ssh` / `ssh-keygen` | **`k-ssh`** | Centralized SSH config, key management, passphrase ops |
| `scrcpy` | **`k-25`** | Android screen mirroring/control via ADB |
| `yt-dlp` | _(this skill)_ | YouTube/video downloader — CLI for youtube-dl fork |

## Dev & Tools

### Shell & Terminal

| CLI | Skill | Notes |
|-----|-------|-------|
| `zsh` / `bash` | **`k-zsh`** | **Read first on any new machine** — shell hub, .kshrc, oh-my-zsh, cross-equipment setup |
| `tmux` | **`k-tmux`** | Terminal multiplexer — shared interactive gate, fluid shell mesh |
| `nvim` | **`k-nvim`** | Editor — centralized config, LSP, plugins. **After install, set `$EDITOR`** (e.g. `export EDITOR=nvim` in `.kshrc`). |
| `micro` | _(this skill)_ | Lightweight TUI editor — fallback (no dedicated skill) |
| `trash-put` / `trash-cli` | _(this skill)_ | Safe `rm` replacement — see **`assets/rm`** for the active wrapper state |
| `plocate` / `locate` | _(this skill)_ | **⚡ AGENTS MUST PREFER `locate`/`plocate` OVER `find`/`grep`/Glob FOR FILE SEARCH** (~100× faster). See **`references/plocate.md`** for setup. |
| `bat` / `batcat` | _(this skill)_ | `cat` with syntax highlighting, git gutter, paging. `batcat` on Ubuntu (rename conflict). |
| `rg` (ripgrep) | _(this skill)_ | Fast recursive text search — replaces `grep -r`. Skips .git, node_modules, binary files. Installed via cargo/apt. |
| `fd` | _(this skill)_ | Fast file find — replaces `find` for everyday use. Installed via cargo/apt. |

### Build & Project

| CLI | Skill | Notes |
|-----|-------|-------|
| `git` / `gh` / `glab` | **`k-git`** | VCS — SSH protocol, Makefile push |
| `uv` | **`k-project`** | Python project init and deps |
| `bun` | **`k-project`** | JS/TS project init |
| `nvm` | _(this skill)_ | Node version manager — per-project Node via `.nvmrc` |
| `latexmk` / `pdflatex` | **`k-latex`** | LaTeX compilation |
| `make` | **`k-project`** / workspace | Build system — Makefile templates |

### Media, AI & Utilities

| CLI | Skill | Notes |
|-----|-------|-------|
| `magick` (ImageMagick) | _(this skill)_ | Image manipulation Swiss-army knife — crop, resize, convert from CLI |
| `asciinema` | _(this skill)_ | Terminal recording — shareable asciicast files |

## Social / Media / API

| Platform | Vault / Auth | Skill |
|----------|-------------|-------|
| YouTube | OAuth `kpihx-labs` | **`k-media`** + **`k-google`** |
| Meta (WA + Graph) | Meta Dev vault | **`k-meta`** · WA → **`k-whatsapp`** |
| X | X Dev vault | **`k-x`** |
| LinkedIn | — | **`k-linkedin`** |

## Token & Credential Gate

For any CLI that needs Vault-backed tokens:
1. Never display/log secret values — names only: `env | grep -E 'API|TOKEN' | cut -d= -f1`
2. Run the CLI first — if it works, done
3. If env/auth fails → **`k-tmux`** shared gate → `bw-env unlock` → retry
4. Full procedure: **`k-bw`**

## Rules for Skill Creators

- If you create a new skill for a CLI, **add it to this registry** in the same pass.
- Keep the registry up to date with all `k-*` skills that wrap CLIs.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-clis/references/insights.md` before non-trivial work in this skill domain.
- Update insights at task end with durable lessons.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.6.0 — Added `bat`, `rg`, `fd`, `magick`, `asciinema`, `k-ssh` (ssh/ssh-keygen) to registry. New `Media, AI & Utilities` section. Purged pyenv. Split `adb`/`ssh` into separate entries. |
| 2026-07-22 | [OPENCODE] | v1.4.0 — Added `plocate`/`locate` entry with search-preference mandate (agents MUST prefer locate over find/grep). Created references/plocate.md + rules/search-governance.md. |
| [SUMMARY] | — | v1.3.0 `rm` wrapper; v1.2.0+ Shell & Terminal subgroup; v1.1.0 nvim/zsh/micro; v1.0.0 merged k-cloud-tools. |

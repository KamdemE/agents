---
name: k-clis
description: >
  KπX key CLI registry — routes to dedicated k-* skills.
  Covers only CLIs KπX added (no native linux/ubuntu tools).
  Merger of k-cloud-tools routing hub.
metadata:
  author: KpihX
  version: 1.16.3
  scope: operations
---

# KπX — Key CLI Registry

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

**⚠️ This skill lists only CLIs that KπX added manually (non-native to linux/ubuntu).**
**When creating a new CLI skill, you MUST add an entry here.**

> **⚠️ FIRST SKILL TO READ WHEN SETTING UP A NEW MACHINE:** **`k-zsh`** — shell foundation (.kshrc, zsh, oh-my-zsh) must be in place before any other CLI works correctly. Always load `k-zsh` first.

> **Legacy:** this skill merges and replaces `k-cloud-tools` as the central routing hub.

## Agent Runtime CLIs

> Each runtime also registers in **`k-ai`** (master agent runtime registry: configs, symlinks, MCP wiring, ACP bridges).

| CLI | Skill | Also in | Notes |
|-----|-------|---------|-------|
| `opencode` | **`k-opencode`** | **`k-ai`** | OpenCode — MCP, providers, auth, permissions |
| `hermes` / `hermes-agent` | **`k-hermes`** | **`k-ai`** | Persistent memory daemon — cron-driven, headless |
| `cursor` (IDE) | **`k-code`** | **`k-ai`** | Cursor — VS Code fork (IDE conservé, dpkg `cursor`). |

> **Purged CLIs** (`cursor-agent`, `codex`, `cline`, `gemini`, `vibe`, `copilot`, `zed`): see `references/purged.md` (kept for the record, never deleted).

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
| `uv` | **`k-uv`** | UV/Python ecosystem — tool install, venvs, versions |

## Productivity & Communication

| CLI | Skill | Notes |
|-----|-------|-------|
| `qmd` / `qmdr` | **`k-qmd`** | BM25+vector hybrid search on knowledge bases |
| `bw` / `bw-proxy` | **`k-bw`** | Bitwarden — self-hosted Vaultwarden (bw-mcp/bw-admin purged 2026-08-14) |
| `rclone` | **`k-rclone`** | Cloud storage FUSE mounts (Google Drive) |
| `tg` | **`k-tg`** | Telegram — Telethon, BotFather, infra-bot |
| `x_cli.py` | **`k-x`** | X (Twitter) API v2 — OAuth 1.0a |
| `meta_cli.py` | **`k-meta`** | Meta Graph API — OAuth smoke tests |
| `powerpoint` (MCP) | **`k-pptx`** | PPTX generation from markdown |
| `broot` | _(this skill)_ | Interactive file explorer — `apt` |
| `whisper-cli` | **`k-ai`** | Local speech-to-text — Vulkan/C++ Whisper build (ggml 0.19.0, user-local ~/.local/bin + ~/.local/lib, GPU Arc MTL) |
| `k-whisper` | **`k-ai`** | Sovereign wrapper around whisper-cli — ls/pull/rm + transcription |
| `piper` | **`k-ai`** | Local text-to-speech — ONNX/C++ Piper build (v1.2.0, user-local ~/.local/bin + libs) |
| `k-piper` | **`k-ai`** | Sovereign wrapper around piper — ls/pull/rm + synthesis |
| `k-translate` | **`k-ai`** | Sovereign wrapper for text translation (CTranslate2/NLLB-200) |
| `k-com` | **`k-ai`** | Universal communication hub (STT, TTS, Translate, Dubbing) |
| `ksh` | _(this skill)_ | Universal Dispatcher |
| `youtube_cli.py` | **`k-media`** + **`k-google`** | YouTube upload |
| `adb` | **`k-phones`** | Android phone wireless debugging (raw interface) |
| `ssh` / `ssh-keygen` | **`k-ssh`** | Centralized SSH config, key management, passphrase ops |
| `scrcpy` | **`k-phones`** | Android screen mirroring/control via ADB |
| `yt-dlp` | _(this skill)_ | YouTube/video downloader — CLI for youtube-dl fork |

## Dev & Tools

### Shell & Terminal

| CLI | Skill | Notes |
|-----|-------|-------|
| `zsh` / `bash` | **`k-zsh`** | **Read first on any new machine** — shell hub, .kshrc, oh-my-zsh, cross-equipment setup |
| `tmux` | **`k-tmux`** | Terminal multiplexer — shared interactive gate, fluid shell mesh |
| `nvim` | **`k-nvim`** | Editor — centralized config, LSP, plugins. **After install, set `$EDITOR`** (e.g. `export EDITOR=nvim` in `.kshrc`). |
| `micro` | _(this skill)_ | Lightweight TUI editor — fallback (no dedicated skill) |
| `trash-put` / `trash-cli` | _(this skill)_ | Safe `rm` replacement — see **`assets/rm`** for the active wrapper state. Has **bypass patterns** (auto real-delete for tmux pane captures, etc.). |
| `plocate` | _(this skill)_ | **⚡ AGENTS MUST PREFER `plocate` (never `locate` — DB auto-updated daily) OVER `find`/`grep`/Glob FOR FILE SEARCH** (~100× faster). See **`references/plocate.md`** for setup. |
| `bat` / `batcat` | _(this skill)_ | `cat` with syntax highlighting, git gutter, paging. `batcat` on Ubuntu (rename conflict). |
| `rg` (ripgrep) | _(this skill)_ | Fast recursive text search — replaces `grep -r`. Skips .git, node_modules, binary files. Installed via cargo/apt. |
| `fd` | _(this skill)_ | Fast file find — replaces `find` for everyday use. Installed via cargo/apt. |
| `neofetch` | _(this skill)_ | System info summary in terminal — OS version, kernel, RAM, disk, CPU at a glance (`apt`). |

### Build & Project

| CLI | Skill | Notes |
|-----|-------|-------|
| `git` / `gh` / `glab` | **`k-git`** | VCS — SSH protocol, Makefile push |
| `uv` | **`k-uv`** · **`k-project`** | Python tool/venv/package management (k-uv) · Project init (k-project) |
| `bun` | **`k-node`** · **`k-project`** | JS/TS runtime & package manager — sovereign choice for KpihX-owned projects |
| `fnm` / `nvm` | **`k-node`** | Node version manager — `fnm` (Fast Node Manager, Rust). Dynamic PATH via `--use-on-cd`. nvm retained as fallback. |
| `node` / `npm` | **`k-node`** | Node.js runtime & package manager — npm global prefix (`~/.npm-global`), EACCES prevention |
| `latexmk` / `pdflatex` | **`k-latex`** | LaTeX compilation |
| `make` | **`k-project`** / workspace | Build system — Makefile templates |

### Media, AI & Utilities

| CLI | Skill | Notes |
|-----|-------|-------|
| `magick` (ImageMagick) | _(this skill)_ | Image manipulation Swiss-army knife — crop, resize, convert from CLI |
| `gext` / `gnome-extensions-cli` | **`k-ubuntu`** | GNOME extension management (uv tool v0.11.0) — list/enable/disable extensions; feeds the GNOME extensions audit in `k-ubuntu/references/gnome-extensions.md` |
| `litellm` / `litellm-proxy` | **`k-ai`** | LLM gateway / proxy — route requests across local (Ollama) and remote providers |
| `ruff` | **`k-uv`** | Python linter/formatter — ultra-fast, drop-in for flake8/isort/black |
| `pyright` / `basedpyright` | **`k-uv`** | Python static type checkers (+ LSP servers) |
| `jupytext` / `jupyter-nbconvert` | **`k-uv`** | Jupyter notebook conversion/manipulation CLI |
| `oxlint` | **`k-node`** | JS/TS linter — ultra-fast, Rust-based |
| `pnpm` | **`k-node`** | Fast, disk-efficient package manager (npm global) |
| `tree-sitter` | **`k-nvim`** | Incremental parsing tool + CLI — powers nvim LSP/treesitter queries |
| `loom` | **`k-loom`** | Persistent cross-session code index — CLI ONLY (loom-mcp removed from opencode.jsonc 2026-08-24, see `k-loom/references/mcp.md`) |
| `msedge-cdp` | **`k-browser`** | Edge automation via CDP (headless/connected) |
| `k-vpn` | **`k-ai`** | Sovereign VPN wrapper/launcher |
| `mail-proxy` | **`k-mail`** | Mail CLI proxy (tick-proxy ADN, 24 `do` actions) |
| `tick-proxy` | **`k-tick`** | TickTick CLI proxy (tasks/habits/projects) |
| `tg-proxy` | **`k-tg`** | Telegram CLI proxy (admin/raw access) |
| `gopls` | **`k-node`** | Go language server (LSP) — from `~/go/bin` |
| `srt` / `srt-*` | _(this skill)_ | Subtitle toolkit (dedup, shift, mux, normalize, play) |

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
3. If env/auth fails → secrets may need loading via `~/.kshrc` or appropriate env source
4. Full procedure: **`k-bw`**

## rm wrapper — Bypass Patterns

`rm` → `trash-put` by default, but some paths bypass trash and do a real delete.
This prevents cache/temp files from polluting `~/.local/share/Trash/`.

### Active bypass patterns (from `assets/rm`)

| Pattern | Rationale |
|---------|-----------|
| `.tmux/resurrect/save/pane_contents/` | tmux-resurrect pane content snapshots saved every 5 min by continuum auto-save. 1362 files/day in trash without bypass. |
| `.tmux/resurrect/.*\.txt` | Old tmux-resurrect backup files — same reason. |

### How to add a new pattern

Edit `assets/rm` and add a regex to the `bypass_patterns` array in the `*)` case:

```bash
bypass_patterns=(
  # existing patterns...
  "my/cache/dir"
)
```

The pattern is tested with `grep -Eq` against each non-flag argument. If any
argument matches any pattern, `rm` uses `/usr/bin/rm` (real delete) instead of
`trash-put`.

## Rules for Skill Creators

- If you create a new skill for a CLI, **add it to this registry** in the same pass.
- Keep the registry up to date with all `k-*` skills that wrap CLIs.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-clis/references/insights.md` before non-trivial work in this skill domain.
- Update insights at task end with durable lessons.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [COLAB] | v1.16.3 — Registered `neofetch` in Shell & Terminal (system info summary: OS, kernel, RAM, disk, CPU). |
| 2026-08-24 | [COLAB] | v1.16.2 — **Check-skills audit**: rotated changelog to comply with structure rules; no log.md. |
| [SUMMARY] | — | v1.16.1 adb+scrcpy routed to k-phones · v1.16.0 CLI expansion · v1.15.0 agent CLI purge · v1.14.0 whisper-cli Vulkan (→ `references/log.md`) · v1.13.0 and earlier copied to `references/log.md` |

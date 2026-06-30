---
name: k-clis
description: >
  KπX key CLI registry — routes to dedicated k-* skills.
  Covers only CLIs KπX added (no native linux/ubuntu tools).
  Merger of k-cloud-tools routing hub.
metadata:
  author: KpihX
  version: 1.0.0
  scope: operations
---

# KπX — Key CLI Registry

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

**⚠️ This skill lists only CLIs that KπX added manually (non-native to linux/ubuntu).**
**When creating a new CLI skill, you MUST add an entry here.**

> **Legacy:** this skill merges and replaces `k-cloud-tools` as the central routing hub.

## Agent Runtime CLIs

| CLI | Skill | Notes |
|-----|-------|-------|
| `opencode` | **`k-opencode`** | OpenCode — MCP, providers, auth, permissions |
| `codex` | **`k-codex`** | Codex — config.toml, sandbox, MCP TOML format |
| `cline` | **`k-cline`** | Cline — install/update, MCP settings |
| `gemini` | **`k-gemini`** | Gemini — extensions, MCP install, settings.json |
| `vibe` | **`k-vibe`** | VIBE — config.toml, TOML MCP, tool permissions |
| `copilot` | **`k-copilot`** | GitHub Copilot — mcp-config, instructions |

## Cloud & Infrastructure

| CLI | Skill | Notes |
|-----|-------|-------|
| `gcloud` | **`k-google`** | GCP suite (container) |
| `gws` (`gws-kpihx`/`gws-labs`) | **`k-google`** | Google Workspace content |
| `m365` | **`k-microsoft`** | MS365 Graph — sole Microsoft CLI (~~`az`~~ deactivated) |
| `flarectl` | **`k-cloudflare`** | Cloudflare DNS/zones (workstation) |
| `cloudflared` | **`k-cloudflare`** | Tunnel connector (homelab server only) |
| `wrangler` | **`k-cloudflare`** | Off on workstation — IDE only |
| `tailscale` | _(this skill)_ | Mesh VPN — no dedicated skill |
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
| `adb` / `ssh` | **`k-phones`** | Android phone access over Tailscale |
| `scrcpy` | **`k-phones`** | Android screen mirroring/control via ADB |

## Dev & Tools

| CLI | Skill | Notes |
|-----|-------|-------|
| `git` / `gh` / `glab` | **`k-git`** | VCS — SSH protocol, Makefile push |
| `tmux` | **`k-tmux`** | Terminal multiplexer — shared interactive gate |
| `nvim` / `vim` | **`k-vim`** | Editor — config, plugins, LSP |
| `uv` | **`k-project`** | Python project init and deps |
| `bun` | **`k-project`** | JS/TS project init |
| `latexmk` / `pdflatex` | **`k-latex`** | LaTeX compilation |
| `make` | **`k-project`** / workspace | Build system — Makefile templates |

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
| 2026-05-30 | [OPENCODE] | v1.0.1 — Added `scrcpy` (screen mirroring) → k-phones. |
| 2026-05-29 | [OPENCODE] | v1.0.0 — Initial creation. Merged k-cloud-tools routing hub. Key CLIs only (non-native). |
| [SUMMARY] | | |

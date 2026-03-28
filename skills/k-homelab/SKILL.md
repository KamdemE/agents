---
name: k-homelab
description: KπX Homelab — infrastructure, personal projects, SSH access, knowledge base (tutos_live + presentation). Load for any homelab, infrastructure, or project-specific task.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
allowed-tools: Bash(*), "*"
---

# KπX — Homelab & Projects

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## SSH Access

| Target | Command | Notes |
|--------|---------|-------|
| Homelab / kpihx-labs | `ssh kpihx-labs` | Tailscale Magic DNS |
| Docker host (default) | `ssh docker-host` | |
| Docker host (alt) | `ssh docker-host-x` | |

For additional aliases, jump hosts, and port forwards → `~/.ssh/config` is the source of truth.

## Infrastructure (`~/Work/Homelab/kpihx_labs/`)

Main Docker Compose stack — Traefik, Vaultwarden, Portainer, Ollama + personal apps.
Vault: `vault.kpihx-labs.com` (private, Tailscale-only).

## Projects (`~/Work/Homelab/`)

Source code for all kpihx-labs projects lives here. When a KπX project is mentioned, check this directory first.

| Project | Purpose |
|---------|---------|
| `kpihx_labs/` | Main infra stack (Docker Compose) |
| `imhotep/` | — |
| `n8n_personal_ops/` | n8n automation workflows |
| `polytask/` | — |
| `sentinel/` | — |
| `wa-bot/` | WhatsApp bot |
| `sh/` | Homelab shell scripts (backup, boot notify, etc.) |
| `presentation/` | Knowledge / docs project (see below) |

## Knowledge Base

### `~/Work/Homelab/presentation/`

Living knowledge/research project. Key `.md` at root: `README`, `VISION`, `IDEAS`, `STATE_OF_THE_ART`, `EVOLUTION`, `PORTABILITY`. Docsify site (`_sidebar.md`, `index.html`). Sub-structure:
- `tutos_live/` — symlinked to `~/Work/tutos_live/`
- `scripts/` — utility scripts

### `~/Work/tutos_live/`

Ubuntu-focused living knowledge base — real problems, documented after the fact on KπX-Ubuntu (Ubuntu 25.10). See `README.md` at root for the current tutorial index.

Structure:
- Root — flat `.md` tutorials (one topic per file)
- `templates/` — reusable doc templates
- `mcps/` — MCP-specific tutorials
- `sh/` — shell/scripting tutorials
- `assets/` — images and media
- Other subdirs may be added for finer topic groupings

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v1.1.0 — removed duplicate tutos_live reflex (in KERNEL) |
| 2026-03-28 | [CLAUDE] | v1.0.0 — created from Homelab exploration |

---
name: k-homelab
description: KπX Homelab — infrastructure, personal projects, SSH access, presentation knowledge base. Load for any homelab, infrastructure, or project-specific task.
license: private
metadata:
  author: KpihX
  version: "1.3.0"
allowed-tools: Bash(*), "*"
---

# KπX — Homelab & Projects

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## SSH & Tailscale

Full SSH config → `~/.ssh/config` is the source of truth for aliases, jump hosts, port forwards.

| Device | Tailscale IP | SSH alias | Status |
|--------|-------------|-----------|--------|
| `kpihx-ubuntu` | `100.82.95.70` | *(this machine)* | active |
| `kpihx-labs` | `100.123.81.21` | `ssh kpihx-labs` / `ssh docker-host` / `ssh docker-host-x` | active (direct) |
| `kpihx-phone` | `100.125.54.1` | — | active (relay) |
| `kpihx-tablet` | `100.89.79.87` | — | offline |
| `kpihx-windows` | `100.108.7.86` | — | offline |

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

## Knowledge Base — `~/Work/Homelab/presentation/`

Living knowledge/research project. Key `.md` at root: `README`, `VISION`, `IDEAS`, `STATE_OF_THE_ART`, `EVOLUTION`, `PORTABILITY`. Docsify site published at `kpihx-labs.github.io/presentation/` (`_sidebar.md`, `index.html`). Sub-structure:

- **`tutos_live/`** — Step-by-step homelab implementation series, Problem-first approach. Sections:
  - Root: 6 core infra guides (Proxmox/802.1X → Docker host → DevOps/CI → Tailscale/AdGuard → Cloudflare/Zero Trust → Vaultwarden/DNS-01)
  - `n8n/` — n8n deployment + personal ops bridges
  - `security/` — backup 3-2-1, Watchtower, SSH hardening
  - `annexes/` — Network watchdog, Termux toolkit
  - **`templates/`** — Ready-to-use config files for all homelab services: Docker Compose YAMLs + `.env` examples (Traefik, Vaultwarden, Ollama, Tailscale, AdGuard, n8n, Postgres, Watchtower, wa-bot…), GitLab CI deploy pipelines, SSH config template
- **`scripts/`** — utility scripts: `check_links.sh`, `check_templates.sh`, `check_tutos.sh`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v1.3.0 — SSH section → SSH & Tailscale with full devices table (IPs + status) |
| [SUMMARY] | — | v1.2.0 Knowledge Base rewritten; v1.1.0 removed duplicate tutos_live reflex; v1.0.0 created |

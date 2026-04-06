---
name: k-homelab
description: >
  KπX Homelab — server infra (Proxmox, Docker-Host LXC, Traefik, Vaultwarden, Portainer,
  Ollama), self-hosted services (polytask, wa-bot, n8n, sentinel), SSH
  (ssh homelab / docker-host), GitLab CI/CD, presentation/ knowledge base.
  Load for any task involving the homelab server, Docker containers, Traefik reverse proxy,
  CI/CD pipelines, or $HOME/Work/Homelab/ projects. NOT for generic project init (→ k-project).
license: private
metadata:
  author: KpihX
  version: "1.7.0"
allowed-tools: Bash(*), "*"
---

# KπX — Homelab & Projects

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## SSH & Tailscale

Full SSH config → `$HOME/.ssh/config` is the source of truth for aliases, jump hosts, port forwards.

**SSH aliases** (source of truth: `$HOME/.ssh/config`):

| Alias | Target | Route | Use when |
|-------|--------|-------|----------|
| `ssh homelab` | `homelab.local` port 2222 | mDNS (LAN) | On local network |
| `ssh kpihx-labs` | `kpihx-labs` port 2222 | Tailscale Magic DNS | From anywhere via Tailscale |
| `ssh docker-host` | `10.10.10.10` | ProxyJump `kpihx-labs` (Tailscale) | Docker host — Tailscale route |
| `ssh docker-host-x` | `10.10.10.10` | ProxyJump `homelab` (mDNS) | Docker host — eduroam/LAN fallback |

**Tailscale devices:**

| Device | IP | OS | Status |
|--------|----|----|--------|
| `kpihx-ubuntu` | `100.82.95.70` | Linux | this machine |
| `kpihx-labs` | `100.123.81.21` | Linux | active (direct) |
| `kpihx-phone` | `100.125.54.1` | Android | active (relay) |
| `kpihx-tablet` | `100.89.79.87` | Android | offline |
| `kpihx-windows` | `100.108.7.86` | Windows | offline |

## Infrastructure (`$HOME/Work/Homelab/sh/`)

**Phoenix v3.1 Architecture** (Source: `Homelab/sh/README.md`):
- **Proxmox node (`kpihx-labs`)**: /root/proxmox/ (Backup hooks, network watchdog, maintenance)
- **Docker-host node (`docker-host`)**: /root/docker_host/ (Vaultwarden backup/restore)
- **Local Dispatcher**: `hsh` (at root of `sh/` or via `make install`)

Vaultwarden: `vault.kpihx-labs.com` (Tailscale-only).

## Projects (`$HOME/Work/Homelab/`)

Source code for all kpihx-labs projects lives here. When a KπX project is mentioned, check this directory first.

| Project | Purpose |
|---------|---------|
| `kpihx_labs/` | Main infra stack (Docker Compose) |
| `imhotep/` | — |
| `polytask/` | — |
| `sentinel/` | — |
| `wa-bot/` | WhatsApp bot |
| `sh/` | Homelab shell scripts (backup, boot notify, etc.) |
| `presentation/` | Knowledge / docs project (see below) |

## Knowledge Base — `$HOME/Work/Homelab/presentation/`

Living knowledge/research project. Key `.md` at root: `README`, `VISION`, `IDEAS`, `STATE_OF_THE_ART`, `EVOLUTION`, `PORTABILITY`. Docsify site published at `kpihx-labs.github.io/presentation/` (`_sidebar.md`, `index.html`). Sub-structure:

- **`tutos_live/`** — Step-by-step homelab implementation series, Problem-first approach. Sections:
  - Root: 6 core infra guides (Proxmox/802.1X → Docker host → DevOps/CI → Tailscale/AdGuard → Cloudflare/Zero Trust → Vaultwarden/DNS-01)
  - `n8n/` — n8n deployment (private cerveau, PostgreSQL reuse)
  - `security/` — backup 3-2-1, Watchtower, SSH hardening
  - `annexes/` — Network watchdog, Termux toolkit
  - **`templates/`** — Ready-to-use config files for all homelab services: Docker Compose YAMLs + `.env` examples (Traefik, Vaultwarden, Ollama, Tailscale, AdGuard, n8n, Postgres, Watchtower, wa-bot…), GitLab CI deploy pipelines, SSH config template
- **`scripts/`** — utility scripts: `check_links.sh`, `check_templates.sh`, `check_tutos.sh`

## Maintenance Reflex

- for homelab optimization posture, weekly maintenance state, backup rotation, and cross-cutting cleanup guidance, load `k-optim`
- keep this skill focused on homelab topology, SSH routes, projects, and the presentation knowledge base

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-06 | [GEMINI] | v1.7.0 — updated to **Phoenix v3.1** architecture; modularized server paths (/root/proxmox, /root/docker_host) and introduced the `hsh` dispatcher |
| 2026-04-03 | [CODEX] | v1.6.2 — added an explicit pointer to `k-optim` for homelab maintenance and optimization posture |
| [SUMMARY] | — | v1.6.1–v1.0.0 covered path normalization, knowledge-base rewrite, and original baseline |

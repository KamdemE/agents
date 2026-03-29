---
name: k-homelab
description: >
  KπX Homelab — server infra (Proxmox, Docker-Host LXC, Traefik, Vaultwarden, Portainer,
  Ollama), self-hosted services (polytask, wa-bot, n8n, sentinel), SSH
  (ssh homelab / docker-host), GitLab CI/CD, presentation/ knowledge base.
  Load for any task involving the homelab server, Docker containers, Traefik reverse proxy,
  CI/CD pipelines, or ~/Work/Homelab/ projects. NOT for generic project init (→ k-project).
license: private
metadata:
  author: KpihX
  version: "1.6.0"
allowed-tools: Bash(*), "*"
---

# KπX — Homelab & Projects

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## SSH & Tailscale

Full SSH config → `~/.ssh/config` is the source of truth for aliases, jump hosts, port forwards.

**SSH aliases** (source of truth: `~/.ssh/config`):

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

## Infrastructure (`~/Work/Homelab/kpihx_labs/`)

Main Docker Compose stack — Traefik, Vaultwarden, Portainer, Ollama + personal apps.
Vault: `vault.kpihx-labs.com` (private, Tailscale-only).

## Projects (`~/Work/Homelab/`)

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

## Knowledge Base — `~/Work/Homelab/presentation/`

Living knowledge/research project. Key `.md` at root: `README`, `VISION`, `IDEAS`, `STATE_OF_THE_ART`, `EVOLUTION`, `PORTABILITY`. Docsify site published at `kpihx-labs.github.io/presentation/` (`_sidebar.md`, `index.html`). Sub-structure:

- **`tutos_live/`** — Step-by-step homelab implementation series, Problem-first approach. Sections:
  - Root: 6 core infra guides (Proxmox/802.1X → Docker host → DevOps/CI → Tailscale/AdGuard → Cloudflare/Zero Trust → Vaultwarden/DNS-01)
  - `n8n/` — n8n deployment (private cerveau, PostgreSQL reuse)
  - `security/` — backup 3-2-1, Watchtower, SSH hardening
  - `annexes/` — Network watchdog, Termux toolkit
  - **`templates/`** — Ready-to-use config files for all homelab services: Docker Compose YAMLs + `.env` examples (Traefik, Vaultwarden, Ollama, Tailscale, AdGuard, n8n, Postgres, Watchtower, wa-bot…), GitLab CI deploy pipelines, SSH config template
- **`scripts/`** — utility scripts: `check_links.sh`, `check_templates.sh`, `check_tutos.sh`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v1.6.0 — removed all n8n-personal-ops/ops-hooks mentions; n8n/ section updated to pure n8n setup |
| 2026-03-29 | [CLAUDE] | v1.5.0 — description rewritten: explicit service list, NOT for generic project init |
| 2026-03-29 | [CLAUDE] | v1.4.0 — SSH aliases table corrected from ~/.ssh/config (homelab mDNS, kpihx-labs Tailscale, docker-host/x ProxyJump distinction) |
| [SUMMARY] | — | v1.3.0 Tailscale devices; v1.2.0 Knowledge Base rewritten; v1.1.0–v1.0.0 init |

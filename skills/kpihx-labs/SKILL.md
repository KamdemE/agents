---
name: kpihx-labs
description: >
  KπX Homelab — server infra (Proxmox, Docker-Host LXC, Traefik, Vaultwarden, Portainer,
  Ollama), self-hosted services (polytask, wa-bot, n8n, sentinel), SSH
  (ssh homelab / docker-host), GitLab CI/CD, presentation/ knowledge base.
  Load for any task involving the homelab server, Docker containers, Traefik reverse proxy,
  CI/CD pipelines, or $HOME/Work/KpihX-Labs/Homelab/ projects. NOT for generic project init (→ k-project).
license: private
metadata:
  author: KpihX
  version: "1.10.1"
allowed-tools: Bash(*), "*"
---

# KπX — Homelab & Projects

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## SSH & Tailscale

> **Authentication Guard:** SSH keys are managed by the Bitwarden Desktop App (not `bw-env`). When connecting, the Bitwarden Desktop App will spawn an **explicit authorization popup** that MUST be manually approved for `ssh` to succeed (otherwise it fails instantly with `Permission denied (publickey)`).

Full SSH config → `$HOME/.ssh/config` is the source of truth for aliases, jump hosts, port forwards.

**SSH aliases** (source of truth: `$HOME/.ssh/config`):

| Alias | Target | Route | Use when |
|-------|--------|-------|----------|
| `pve` | `pve.local` port 2222 | mDNS (LAN) | Proxmox Node (Hypervisor) |
| `kpihx-pve` | `kpihx-pve` port 2222 | Tailscale | Remote Hypervisor access |
| `pve-ui` | `pve.local` | LAN | Tunnels for Proxmox/Portainer |
| `kpihx-pve-ui`| `kpihx-labs...ts.net`| Tailscale | Remote Tunnels |
| `homelab` | `10.10.10.10` via `pve` | LAN Jump | Docker Host (Local) |
| `kpihx-labs` | `10.10.10.10` via `kpihx-pve` | Tailscale Jump| Docker Host (Remote) |
| `kpihx-s25` | `kpihx-s25` port 8022 | Tailscale | Android Termux access |

**Tailscale devices (Verified via Dashboard):**

| Device | ID | Hostname (OS) | Role |
|--------|----|---------------|------|
| `kpihx-pve` | `7501459151201643` | `pve` | Hypervisor (tag:server) |
| `kpihx-ubuntu`| `2232751499623207` | `KpihX-Ubuntu` | Docker Host (Fluid Cloud) |
| `kpihx-s25` | `833031442555825` | `KπX's Phone` | Mobile Phone |
| `kpihx-tablet` | `7804464580897034` | `KπX's Tablet` | Tablet |

## Infrastructure (`$HOME/Work/KpihX-Labs/`)

**KpihX-Labs Architecture**:
- **Proxmox Node (`kpihx-pve`)**: Physical Node (Hypervisor). Alias `pve` (local) or `kpihx-pve` (remote).
- **Docker Node (`kpihx-ubuntu`)**: Virtual Node (Sovereign Cloud). Alias `homelab` (local) or `kpihx-labs` (remote).
- **Local Dispatcher**: `hsh` (at root of `sh/` or via `make install`)

**PVE Network Topology (`kpihx-pve`)**:
- `vmbr0`: Public WAN interface (DHCP). External gateway to the campus network.
- `vmbr1`: Private LAN bridge (`10.10.10.1/24`). PVE acts as a NAT router (masquerade) for all isolated VMs/Containers.
- **Port Forwards**: TCP 80, 443, 9443 from `vmbr0` are DNAT-redirected to `10.10.10.10` (the Traefik/Portainer ingress node, usually CT 100).

Vaultwarden: `vault.kpihx-labs.com` (Tailscale-only).

## Projects (`$HOME/Work/KpihX-Labs/Homelab/`)

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

## Knowledge Base — `$HOME/Work/KpihX-Labs/Homelab/presentation/`

Living knowledge/research project. Key `.md` at root: `README`, `VISION`, `IDEAS`, `STATE_OF_THE_ART`, `EVOLUTION`, `PORTABILITY`. Docsify site published at `kpihx-labs.github.io/presentation/` (`_sidebar.md`, `index.html`). Sub-structure:

- **`techskills/`** — Step-by-step homelab implementation series, Problem-first approach. Sections:
  - Root: 6 core infra guides (Proxmox/802.1X → Docker host → DevOps/CI → Tailscale/AdGuard → Cloudflare/Zero Trust → Vaultwarden/DNS-01)
  - `n8n/` — n8n deployment (private cerveau, PostgreSQL reuse)
  - `security/` — backup 3-2-1, Watchtower, SSH hardening
  - `annexes/` — Network watchdog, Termux toolkit
  - **`templates/`** — Ready-to-use config files for all homelab services: Docker Compose YAMLs + `.env` examples (Traefik, Vaultwarden, Ollama, Tailscale, AdGuard, n8n, Postgres, Watchtower, wa-bot…), GitLab CI deploy pipelines, SSH config template
- **`scripts/`** — utility scripts: `check_links.sh`, `check_templates.sh`, `check_tutos.sh`

## Maintenance Reflex

- for homelab optimization posture, weekly maintenance state, backup rotation, and cross-cutting cleanup guidance, load `k-optim`
- keep this skill focused on homelab topology, SSH routes, projects, and the presentation knowledge base

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/kpihx-labs/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/kpihx-labs/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-08 | [CODEX] | v1.10.1 — Added the CT-vs-VM DNS lesson: CT `100` works with Proxmox-managed static resolvers, while Debian cloud VMs can lose DNS if `systemd-resolved` is masked before `/etc/resolv.conf` is replaced. |
| 2026-05-08 | [ANTIGRAVITY] | v1.10.0 — Documented exact PVE network topology (vmbr0/vmbr1 NAT rules). |
| 2026-04-29 | [ANTIGRAVITY] | v1.9.0 — Standardized prefix-based nomenclature (kpihx-) across Tailscale and SSH. |
| [SUMMARY] | — | +3 older changelog entries kept in file history; condensed for table limits |

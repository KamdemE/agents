---
name: k-pve-debian
description: >
  KpihX-PVE-Debian — Debian VM running on the kpihx-pve Proxmox hypervisor.
  Primary Docker deployment host: runs Traefik, Portainer, Vaultwarden, and
  all Docker Compose stacks. Also hosts GitLab CI pipelines and the Homelab
  project stack. Sub-infra of k-pve.
  Load for Debian VM tasks, Docker stack management, Traefik config,
  GitLab CI operations, or Vaultwarden maintenance.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KpihX-PVE-Debian — Debian VM

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-pve` (hypervisor — parent infra) · `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-docker` (generic Docker patterns) · `k-tailscale` (mesh VPN) · `k-optim` (maintenance/cleanup)
> **Source:** Content migrated from `kpihx-labs` v1.x (Docker/deployment sections) and `k-docker` (Ubuntu-specific deployment notes)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | Debian VM on kpihx-pve |
| Short name (tmux) | `pve-debian` |
| Tailscale | `kpihx-pve-debian` (`100.117.171.4`) |
| LAN IP | `10.10.10.101` (vmbr1) |
| SSH OS | Linux (Debian) |
| Role | Docker deployment host, GitLab CI runner, service hosting |

---

## SSH Access

| Alias | Target | Route | Key | Notes |
|-------|--------|-------|-----|-------|
| `pve-debian` | `10.10.10.101` via `pve` | LAN jump | `id_ed25519_pve` | Local (campus network) via PVE |
| `kpihx-pve-debian` | `10.10.10.101` via `kpihx-pve` | Tailscale jump | `id_ed25519_pve` | Remote via Tailscale |

---

## Docker Deployment

This VM runs Docker containers. For generic Docker patterns (multi-stage builds, docker-compose, Traefik labels, best practices), load **`k-docker`**.

### Host Access

The Docker host is accessed via `homelab` / `kpihx-cloud` SSH aliases (CT 100 at `10.10.10.10` — the main Docker host).

| Alias | Target | Route | Key |
|-------|--------|-------|-----|
| `homelab` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `id_ed25519_homelab` |
| `kpihx-cloud` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `id_ed25519_homelab` |

> **Note:** `homelab` (CT 100) denies direct access to `/var/run/docker.sock` for user `kpihx`. Operational container inventory must use `sudo docker ...` or an equivalent privileged path.
> Live stack discovery is more reliable through Docker labels (`com.docker.compose.project` / `service`) than through compose-file search alone, because several active stacks no longer have an obvious compose file under `/root`.

---

## Services Running

| Service | Access | Notes |
|---------|--------|-------|
| Traefik | `traefik.kpihx-labs.com` (or via port forward) | Reverse proxy, ingress for all HTTP/S services |
| Portainer | `localhost:9443` (via tunnel from kpihx-pve-ui) | Container management UI |
| Vaultwarden | `vault.kpihx-labs.com` | Password manager, Tailscale-only |
| (Other stacks) | Via Traefik routes | See Homelab project registry in `kpihx-labs` |

---

## GitLab CI

GitLab CI pipelines deploy containers and manage infrastructure. Related configuration:
- All MCPs in kpihx-labs GitLab group namespace
- CI pipeline templates: `$HOME/Work/KpihX-Labs/Homelab/presentation/techskills/templates/`

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-pve-debian/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-pve-debian/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.0.0 — Created k-pve-debian from kpihx-labs Docker/deployment content. SSH access, Docker deployment patterns, Traefik/Portainer/Vaultwarden services, GitLab CI reference. |
| [SUMMARY] | — | — |

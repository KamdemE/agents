---
name: k-pve-dockerhost
description: >
  KpihX-PVE-Dockerhost — Docker host CT (LXC container 100) running on the
  kpihx-pve Proxmox hypervisor. Main ingress node running Traefik reverse
  proxy and Portainer. Hosts all Docker Compose stacks for KpihX-Labs
  services. This CT is in the process of being migrated to k-pve-debian.
  The skill reflects the actual current state of this host.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KpihX-PVE-Dockerhost — Docker Host CT

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-pve` (hypervisor — parent infra) · `k-pve-debian` (migration target) · `k-docker` (generic Docker patterns) · `k-optim` (maintenance)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Host Identity

| Property | Value |
|----------|-------|
| Type | LXC container (CT 100) on kpihx-pve |
| LAN IP | `10.10.10.10` (vmbr1) |
| Role | Docker host — Traefik, Portainer, all Docker Compose stacks |
| Status | In migration to `k-pve-debian` |

---

## SSH Access

| Alias | Target | Route | Key |
|-------|--------|-------|-----|
| `homelab` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `id_ed25519_homelab` |
| `kpihx-cloud` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `id_ed25519_homelab` |

---

## Services

This CT is the ingress node for all KpihX-Labs services:

| Service | Access | Notes |
|---------|--------|-------|
| Traefik | Ports 80/443 from vmbr0 forwarded to this CT | Reverse proxy for all HTTP/S services |
| Portainer | `localhost:9443` (via tunnel from kpihx-pve-ui) | Container management UI |

All port forwards from PVE (TCP 80, 443, 9443) target this CT.

---

## Docker Operations

- Docker socket is **restricted**: `kpihx` user cannot access `/var/run/docker.sock` directly
- Use `sudo docker ...` for container operations
- Live stack discovery: use Docker labels (`com.docker.compose.project` / `service`) rather than compose-file search alone (several active stacks no longer have obvious compose files)

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.0.0 — Created k-pve-dockerhost. Docker host CT 100 on PVE. Traefik/Portainer ingress node. Docker socket restriction documented. |
| [SUMMARY] | — | — |

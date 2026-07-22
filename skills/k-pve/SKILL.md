---
name: k-pve
description: >
  KpihX-PVE — Proxmox VE hypervisor (kpihx-pve). Physical node running the
  KpihX-Labs virtual infrastructure. Covers PVE configuration, network
  topology (vmbr0/vmbr1), VMs/CTs, storage, and SSH access patterns.
  Load for any PVE-specific task: VM/CT management, network config,
  storage operations, or hypervisor maintenance.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KpihX-PVE — Proxmox VE Hypervisor

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map) · `k-pve-debian` (Debian VM — sub-infra) · `k-pve-dockerhost` (Docker host CT — sub-infra) · `k-tailscale` (mesh VPN)
> **Source:** Content migrated from `kpihx-labs` v1.x (PVE-specific sections)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `pve` (local) / `kpihx-pve` (Tailscale) |
| Tailscale | `kpihx-pve` — tagged device (`tagged-devices`) |
| Tailscale IP | `100.123.81.21` |
| SSH OS | Linux (Proxmox VE) |
| Role | Hypervisor — runs all VMs and CTs |

---

## SSH Access

| Alias | Target | Route | Key | Use case |
|-------|--------|-------|-----|----------|
| `pve` | `pve.local:2222` | LAN (mDNS) | default key | Local (campus network) |
| `kpihx-pve` | `kpihx-pve:2222` | Tailscale | `id_ed25519_pve` | Remote via Tailscale |
| `pve-ui` | `pve.local:2222` + tunnels | LAN | default key | Port forwarding for web UIs |
| `kpihx-pve-ui` | `kpihx-pve:2222` + tunnels | Tailscale | `id_ed25519_pve` | Remote port forwarding |

**Port forwarding tunnels (pve-ui / kpihx-pve-ui):**
- `localhost:8006` → Proxmox web UI (port 8006 on PVE)
- `localhost:9443` → Portainer (`10.10.10.10:9443` on Docker host)
- (Commented out) `8443` → Traefik, `3000` → AdGuard

**All SSH config entries are defined in `$HOME/.ssh/config`. Authentication uses Bitwarden Desktop App (SSH key popup).**

---

## Network Topology

### Interfaces

| Interface | Type | Subnet | Role |
|-----------|------|--------|------|
| `vmbr0` | Bridge | DHCP (WAN) | Public, campus network. External gateway. |
| `vmbr1` | Bridge | `10.10.10.1/24` | Private LAN. PVE acts as NAT router (masquerade) for all isolated VMs/CTs. |

### Port Forwards (DNAT on vmbr0 → vmbr1)

| External Port | Destination | Service |
|--------------|-------------|---------|
| TCP 80 | `10.10.10.10:80` | Traefik HTTP |
| TCP 443 | `10.10.10.10:443` | Traefik HTTPS |
| TCP 9443 | `10.10.10.10:9443` | Portainer |

All forwarded to `10.10.10.10` (Docker host CT 100 — the Traefik/Portainer ingress node).

---

## VMs & Containers

| Hostname | Type | LAN IP | SSH alias | Role |
|----------|------|--------|-----------|------|
| Docker host (CT 100) | LXC (container) | `10.10.10.10` | `homelab` / `kpihx-cloud` | Traefik, Portainer, Docker stacks |
| Debian VM | QEMU (VM) | `10.10.10.101` | `pve-debian` / `kpihx-pve-debian` | Docker deployment, GitLab CI |

### VM/CT Management

- **CT (Container):** Lightweight LXC. DNS managed by Proxmox static resolvers in CT config — generates static `/etc/resolv.conf`.
- **VM (Virtual Machine):** Full QEMU/KVM. DNS via cloud-init or manual config. If `systemd-resolved` is masked before `/etc/resolv.conf` is replaced, the guest ends up with `No DNS servers known` even when `qm config` has a nameserver set.

> **Lesson (CT-vs-VM DNS):** CT `100` works with Proxmox-managed static resolvers. Debian cloud VMs need explicit `/etc/resolv.conf` management — masking `systemd-resolved` without replacing the symlink breaks DNS resolution.

---

## Services

| Service | Access | Notes |
|---------|--------|-------|
| Proxmox web UI | `https://pve.local:8006` (LAN) / tunnel via `pve-ui` | Hypervisor management |
| Vaultwarden | `vault.kpihx-labs.com` | Tailscale-only |

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-pve/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-pve/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.0.0 — Created k-pve from kpihx-labs PVE content. Network topology, SSH access, VM/CT inventory, DNS lessons. |
| [SUMMARY] | — | Historical entries from kpihx-labs v1.x migrated here (CT-vs-VM DNS, PVE network topology, prefix nomenclature) — full context in git history |

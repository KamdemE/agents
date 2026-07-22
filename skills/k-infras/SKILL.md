---
name: k-infras
description: >
  KπX master infrastructure map — lists all equipment, Tailscale identities,
  SSH access, and hierarchical relationships. Each infra entry maps to its
  dedicated k-* skill. Load this skill first when dealing with any
  infrastructure to get the full picture before diving into specifics.
license: private
metadata:
  author: KpihX
  version: "1.0.1"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Infrastructure Master Map

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (workstation) · `k-pve` (hypervisor) · `k-pve-debian` (Debian VM) · `k-pve-dockerhost` (Docker host) · `k-blglaptop139` (Windows+WSL) · `k-deep-pc6` (Linux server) · `k-phones` (Android phones)
> **Source skills:** `k-infra` (low-level hardware: disk, BIOS, filesystem) · `k-nftables` (firewall) · `k-tailscale` (mesh VPN config)
> This skill is the **implicit hierarchy** — not reflected in filesystem sub-folders. Skills are flat under `skills/`.

---

## Equipment Inventory

Source of truth for live state: `tailscale status --json` or `tailscale status`.

| Tailscale name | Tailscale IP | OS | Status | Skill | Notes |
|---------------|-------------|----|--------|-------|-------|
| `kpihx-ubuntu` | `100.82.95.70` | Linux | online | **`k-ubuntu`** | Primary workstation. Ubuntu-specific skill. |
| `blglaptop139` | `100.99.196.32` | Windows | online | **`k-blglaptop139`** | Internship PC (Grenoble). Windows + WSL. |
| `kpihx-pve` | `100.123.81.21` | Linux (PVE) | idle | **`k-pve`** | Proxmox VE hypervisor. Tagged device. |
| `kpihx-pve-debian` | `100.117.171.4` | Linux (Debian) | offline | **`k-pve-debian`** | Debian VM on PVE. Sub-infra of k-pve. |
| `kpihx-pve-dockerhost` | — | Linux | — | **`k-pve-dockerhost`** | Docker host VM on PVE. Sub-infra of k-pve. |
| `kpihx-s25` | `100.125.54.1` | Android | offline | **`k-phones`** | Samsung S25 phone. |
| `kpihx-tablet` | `100.89.79.87` | Android | offline | **`k-phones`** | Tablet. |

---

## Implicit Hierarchy

The infrastructure follows this logical structure. It is documented here only — skills remain flat under `skills/`.

```
kpihx-labs (kernel top reference)
│
├── k-context    (HOT context — session log, active projects)
├── k-infras     (this skill — master map)
│   ├── k-ubuntu          (Ubuntu workstation)
│   ├── k-blglaptop139       (Windows + WSL — internship)
│   ├── k-deep-pc6        (Linux server — internship)
│   ├── k-pve             (Proxmox VE hypervisor)
│   │   ├── k-pve-debian     (Debian VM)
│   │   └── k-pve-dockerhost (Docker host VM)
│   └── k-phones          (Android phones)
│
├── k-clis       (CLI registry — routes to all skills)
└── [all other top skills]
```

---

## SSH Access Map

Source of truth: `$HOME/.ssh/config`. Each infra skill documents its own SSH specifics.

| Alias | Target | Route | Skill |
|-------|--------|-------|-------|
| `pve` | `pve.local:2222` | LAN (mDNS) | `k-pve` |
| `kpihx-pve` | `kpihx-pve:2222` | Tailscale | `k-pve` |
| `pve-ui` | `pve.local:2222` + port forwards | LAN | `k-pve` |
| `kpihx-pve-ui` | `kpihx-pve:2222` + port forwards | Tailscale | `k-pve` |
| `homelab` | `10.10.10.10` via `kpihx-pve` | LAN jump | `k-pve-debian` |
| `kpihx-cloud` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `k-pve-debian` |
| `pve-debian` | `10.10.10.101` via `pve` | LAN jump | `k-pve-debian` |
| `kpihx-pve-debian` | `10.10.10.101` via `kpihx-pve` | Tailscale jump | `k-pve-debian` |
| `deep-pc6` | `172.16.150.163` | Direct (DxO VPN) | `k-deep-pc6` |
| `kpihx-s25` | `kpihx-s25:8022` | Tailscale | `k-phones` |

---

## PVE Network Topology

Defined in `k-pve` (this is a summary reference). Full details in `kpihx-labs` (current) and `k-pve`.

| Interface | Subnet | Role |
|-----------|--------|------|
| `vmbr0` | DHCP (WAN) | Public, campus network |
| `vmbr1` | `10.10.10.1/24` | Private LAN, NAT (masquerade) |
| Port forwards | TCP 80, 443, 9443 → `10.10.10.10` | Traefik/Portainer ingress |

| PVE internal host | LAN IP | SSH alias |
|-------------------|--------|-----------|
| Docker host (CT 100) | `10.10.10.10` | `homelab` / `kpihx-cloud` |
| Debian VM | `10.10.10.101` | `pve-debian` / `kpihx-pve-debian` |

---

## Servies Exposure

| Service | Domain | Access |
|---------|--------|--------|
| Vaultwarden | `vault.kpihx-labs.com` | Tailscale only |
| Traefik dashboard | Via port forward | LAN / Tailscale tunnel |
| Portainer | Via port forward | LAN / Tailscale tunnel |

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-infras/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-infras/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.0.1 — Removed "Replaces k-workspace" reference (k-workspace deactivated). |
| 2026-07-22 | [OPENCODE] | v1.0.0 — Created k-infras as master infrastructure map. Lists all equipment, hierarchy, SSH access, PVE topology. No info removed from any existing skill. |
| [SUMMARY] | — | — |

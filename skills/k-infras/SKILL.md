---
name: k-infras
description: >
  KπX master infrastructure map — lists all equipment, Tailscale identities,
  SSH access, and hierarchical relationships. Each infra entry maps to its
  dedicated k-* skill. Load this skill first when dealing with any
  infrastructure to get the full picture before diving into specifics.
  Also documents the required init skills for setting up a new infra.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Infrastructure Master Map

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (workstation) · `k-pve` (hypervisor) · `k-pve-debian` (Debian VM) · `k-dockerhost` (Docker host) · `k-blglaptop139` (Windows+WSL) · `k-deep-pc6` (Linux server) · `k-25` (Android phones) · **`k-clis`** (CLI registry — routing to all per-CLI skills)
> **Scope also covers:** low-level hardware (disk partitioning, BIOS/UEFI, filesystem recovery, dual-boot, interrupted ntfsresize recovery) — see `references/ntfs-shrink-dual-boot.md`. Firewall: `k-nftables`. Mesh VPN: `k-tailscale`.
> **Init skills:** see **New Infra Setup Checklist** below — these apply to every infra skill.
> This skill is the **implicit hierarchy** — not reflected in filesystem sub-folders. Skills are flat under `skills/`.

---

## Equipment Inventory

Source of truth for live state: `tailscale status --json` or `tailscale status`.

| Tailscale name | Tailscale IP | OS | Status | Skill | Notes |
|---------------|-------------|----|--------|-------|-------|
| Tailscale name | Short name | Tailscale IP | OS | Status | Skill | Notes |
|---------------|-----------|-------------|----|--------|-------|-------|
| `kpihx-ubuntu` | `ubuntu` | `100.82.95.70` | Linux | online | **`k-ubuntu`** | Primary workstation. |
| `blglaptop139` | `blglaptop139` | `100.99.196.32` | Windows | online | **`k-blglaptop139`** | Internship PC (Grenoble). |
| `kpihx-pve` | `pve` | `100.123.81.21` | Linux (PVE) | idle | **`k-pve`** | Proxmox VE hypervisor. |
| `kpihx-pve-debian` | `pve-debian` | `100.117.171.4` | Linux (Debian) | offline | **`k-pve-debian`** | Debian VM on PVE. |
| `kpihx-pve-dockerhost` | `dockerhost` | — | Linux | — | **`k-dockerhost`** | Docker host VM on PVE. |
| `kpihx-s25` | `s25` | `100.125.54.1` | Android | offline | **`k-25`** | Samsung S25 phone. |
| `kpihx-tablet` | — | `100.89.79.87` | Android | offline | **`k-25`** | Tablet (not configured). |

---

## New Infra Setup Checklist

When setting up a **new infrastructure** (any equipment running a shell), an agent MUST load and follow these skills **in order** before writing any config:

| Order | Skill | Purpose |
|-------|-------|---------|
| 1 | **`k-zsh`** | Shell setup: 5 shared files (zshrc, zshenv, zprofile, bashrc, profile) symlinked from `k-zsh/assets/`. PATH, env vars, hub pattern. |
| 1b | **Infra skill** | **`~/.kshrc`** source of truth = `assets/kshrc` in the infra skill (e.g. `k-ubuntu/assets/kshrc`). Infra skills have ONLY `kshrc` — the 5 other files are shared from `k-zsh`. If infra skill has no `assets/kshrc`, copy `kshrc.base`, customize, then symlink. |
| 2 | **`k-tailscale`** | Mesh VPN: install, authenticate, verify connectivity. |
| 3 | **`k-tmux`** | Tmux session per equipment: standard 3-window layout (agents/default/tmp), shared interactive gate. |
| 4 | **`k-ssh`** | SSH config: canonical `assets/ssh.conf`, key generation, Bitwarden agent, passphrase rules. |
| 5 | **`k-clis`** | CLI registry: which CLIs to install on this infra type. |
| 6 | **`k-nvim`** | Neovim config (when applicable — skip if Termux/headless). |
| 7 | **`k-opencode`** | OpenCode runtime (when applicable — does not run on Termux). |

**Exception:** Termux/Android phones (`k-25`) skip `k-nvim` and `k-opencode` — they do not run on Termux.

### Tmux session name — short name convention

Every infra skill MUST document both the **Tailscale name** (e.g. `kpihx-ubuntu`) and the **short name** (e.g. `ubuntu`) in its `## Host Identity` table. The short name is the tmux session name (see `k-tmux` → Standard session per equipment).

| Equipment | Tailscale name | Short name (tmux session) |
|-----------|---------------|--------------------------|
| Workstation | `kpihx-ubuntu` | `ubuntu` |
| Internship laptop | `blglaptop139` | `blglaptop139` |
| DxO server | — | `deep-pc6` |
| PVE hypervisor | `kpihx-pve` | `pve` |
| Debian VM | `kpihx-pve-debian` | `pve-debian` |
| Docker host | — | `dockerhost` |
| S25 phone | `kpihx-s25` | `s25` |

When setting up `kshrc.base` → `~/.kshrc`, the agent reads the infra skill to find the **short name** and replaces `<INFRA_SESSION>` in the auto-tmux block with that value.

---

## Implicit Hierarchy

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
│   │   └── k-dockerhost (Docker host VM)
│   └── k-25          (Android phones)
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
| `kpihx-s25` | `kpihx-s25:8022` | Tailscale | `k-25` |

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
| 2026-07-26 | [OPENCODE] | v1.4.0 — **k-infra merged into k-infras**. ntfs-shrink-dual-boot.md + insights.md moved here. k-infra purged. Low-level hardware now covered by k-infras. |
| [SUMMARY] | — | v1.1.0–v1.3.0 New Infra Setup Checklist + dockerhost rename + kshrc pattern; v1.0.1–v1.0.0 master map created. |

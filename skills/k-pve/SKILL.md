---
name: k-pve
description: Proxmox VE hypervisor (kpihx-pve) — network, backup, maintenance, and automation scripts.
metadata:
  author: KpihX
  version: "2.1.0"
  scope: infrastructure
---

# KπX — Proxmox VE (kpihx-pve)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-dockerhost` (Docker host VM) · `k-pve-debian` (Debian VM) · `k-ubuntu` (workstation) · `k-infras` (master map) · `k-tmux` (session gate) · `k-ssh` (canonical SSH config)

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `kpihx-pve` |
| Short name (tmux) | `pve` |
| Tailscale | `kpihx-pve` (`100.123.81.21`) |
| SSH alias | `pve` / `kpihx-pve` (port 2222) |

## Setup (once per machine)

Source of truth is `.agents/`. On PVE:

```bash
# 1. Clone .agents repo (as user kpihx or $USER)
git clone git@github.com:KpihX/agents.git ~/.agents

# 2. ksh dispatcher
cp ~/.agents/skills/k-pve/scripts/ksh ~/.local/bin/ksh

# 3. Secrets
# Create ~/.agents/.env from ~/.agents/.env.example
# Then edit it with TELEGRAM_PVE_TOKEN + TELEGRAM_CHAT_ID
```

## ksh — PVE Dispatcher

```bash
ksh maintenance          # PVE node maintenance
ksh backup               # Backup PVE → cloud (Google Drive)

ksh restore              # Restore PVE from cloud
ksh watchdog             # Network watchdog status
ksh network              # Switch WiFi/Wired interfaces
ksh setup-eduroam        # Configure eduroam 802.1X
```

## Scripts

All scripts live in `k-pve/scripts/` (this skill). They are deployed via `~/.agents/` clone — no more scp/rsync.

### Network

| Script | Purpose |
|--------|---------|
| `network/network_switch.sh` | Switch between WiFi (eduroam) and wired (Polytechnique 802.1X) |
| `network/network_watchdog.sh` | Monitor network connectivity, notify on failure |
| `network/boot_notify.sh` | Telegram notification on PVE boot |
| `network/setup_eduroam.sh` | Automated eduroam configuration (Ecole Polytechnique) |

### Backup

| Script | Purpose |
|--------|---------|
| `backup/backup` | Push PVE backup to Google Drive |

| `backup/restore.sh` | Restore PVE from Google Drive backup |
| `backup/vzdump-hook.sh` | Auto-sync hook after Proxmox vzdump job |

### Maintenance

| Script | Purpose |
|---------|---------|
| `maintenance.sh` | Node maintenance tasks |

### Assets (systemd units — source of truth in `.agents/`, deploy via `sudo cp`)

| Asset | Purpose | Symlink target |
|-------|---------|---------------|
| `assets/network/pve-watchdog.service` | Watchdog: runs `network_watchdog.sh` | `/etc/systemd/system/pve-watchdog.service` |
| `assets/network/pve-watchdog.timer` | Watchdog: every 5 minutes | `/etc/systemd/system/pve-watchdog.timer` |
| `assets/network/pve-boot-notify.service` | Boot: runs `boot_notify.sh` | `/etc/systemd/system/pve-boot-notify.service` |
| `assets/backup/vzdump.conf` | Registers vzdump hook (no service — called by Proxmox) | `/etc/vzdump.conf` (copy) |

Backup auto-sync is handled by `vzdump-hook.sh` → `backup` — no systemd timer needed. See `scripts/backup/README.md`.

### Module docs (setup instructions)

Each sub-module README contains its OWN complete setup procedure — install, dependencies, verify — specific to that module. Read the relevant README before deploying.

| Module | README | Covers |
|--------|--------|--------|
| All modules (general) | `scripts/README.md` | Prerequisites, general setup, symlinks, ksh |
| Backup | `scripts/backup/README.md` | Backup scripts, vzdump hook registration, rclone, verify |
| Network | `scripts/network/README.md` | Watchdog, boot notify, interface switch, eduroam, logs |

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial PVE work.
- Update it at the end of each task.

## Secrets

`TELEGRAM_PVE_TOKEN` and `TELEGRAM_CHAT_ID` from `~/.agents/.env`. All scripts load these vars via `scripts/notifier.sh`. See module READMEs for detailed setup.

## Assets (configs, not scripts)

| File | Purpose |
|------|---------|
| `assets/network/interfaces.wired` | PVE network interfaces config — wired mode (vmbr0/vmbr1, bridge NAT) |
| `assets/network/interfaces.wifi` | PVE network interfaces config — WiFi mode (wlo1) |
| `assets/network/network.conf.d/polytechnique.conf` | wpa_supplicant config for Polytechnique wired 802.1X |
| `assets/network/network.conf.d/eduroam.conf` | wpa_supplicant config for eduroam (WPA-EAP) |
| `assets/network/eduroam-linux-Ecole_Polytechnique-...py` | Official eduroam setup script (1372 lines) |
| `assets/backup/vzdump.conf` | Default Proxmox vzdump configuration |


## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-25 | [OPENCODE] | v2.1.0 — Sub-module READMEs updated with full setup procedures (scripts/, backup/, network/). SKILL.md: vue générale + renvois vers READMEs. Delta analysis: k-pve structure already correct, minimal adjustments needed. |
| 2026-07-24 | [OPENCODE] | v2.0.0 — Refactored with ksh dispatcher, scripts + assets from Homelab/sh/proxmox/ centralized here. Stop copies: source of truth in `.agents/`. |
| [SUMMARY] | — | v1.x original PVE skill. |


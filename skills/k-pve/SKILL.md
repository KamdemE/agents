---
name: k-pve
description: Proxmox VE hypervisor (kpihx-pve) — network, backup, maintenance, and automation scripts.
metadata:
  author: KpihX
  version: "2.0.0"
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

# 2. Symlink ksh dispatcher
ln -sf ~/.agents/skills/k-pve/scripts/ksh ~/.local/bin/ksh

# 3. Secrets
cp ~/.agents/.env.example ~/.agents/.env
# Edit ~/.agents/.env with TELEGRAM_UBUNTU_BOT + TELEGRAM_CHAT_ID
```

## ksh — PVE Dispatcher

```bash
ksh maintenance          # PVE node maintenance
ksh backup server        # Backup PVE → cloud (Google Drive)

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
| `backup/backup_server.sh` | Push PVE backup to Google Drive |

| `backup/restore.sh` | Restore PVE from Google Drive backup |
| `backup/vzdump-hook.sh` | Auto-sync hook after Proxmox vzdump job |

### Maintenance

| Script | Purpose |
|--------|---------|
| `maintenance.sh` | Node maintenance tasks |

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial PVE work.
- Update it at the end of each task.

## Secrets

`TELEGRAM_UBUNTU_BOT` and `TELEGRAM_CHAT_ID` from `~/.agents/.env`.

## Assets (configs, not scripts)

| File | Purpose |
|------|---------|
| `assets/network/interfaces.wired` | PVE network interfaces config — wired mode (vmbr0/vmbr1, bridge NAT) |
| `assets/network/interfaces.wifi` | PVE network interfaces config — WiFi mode (wlo1) |
| `assets/network/network.conf.d/polytechnique.conf` | wpa_supplicant config for Polytechnique wired 802.1X |
| `assets/network/network.conf.d/eduroam.conf` | wpa_supplicant config for eduroam (WPA-EAP) |
| `assets/network/eduroam-linux-Ecole_Polytechnique-...py` | Official eduroam setup script (1372 lines) |
| `assets/backup/vzdump.conf` | Default Proxmox vzdump configuration |
| `assets/.env.example` | Template for `~/.agents/.env` |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-24 | [OPENCODE] | v2.0.0 — Refactored with ksh dispatcher, scripts + assets from Homelab/sh/proxmox/ centralized here. Stop copies: source of truth in `.agents/`. |
| [SUMMARY] | — | v1.x original PVE skill. |


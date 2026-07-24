---
name: k-dockerhost
description: Docker host (LXC 100) — Vaultwarden backup, Docker management, and automation scripts.
metadata:
  author: KpihX
  version: "2.0.0"
  scope: infrastructure
---

# KπX — Docker Host (kpihx-pve LXC 100)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-pve` (PVE hypervisor) · `k-pve-debian` (Debian VM) · `k-ubuntu` (workstation) · `k-infras` (master map) · `k-bw` (Bitwarden vault) · `k-ssh` (canonical SSH config)

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `kpihx-pve-dockerhost` |
| Short name (tmux) | `dockerhost` |
| SSH alias | `homelab` / `kpihx-cloud` |
| User | `kpihx` (or `$USER`) |

## Setup (once per machine)

Source of truth is `.agents/`. On the Docker host:

```bash
# 1. Clone .agents repo
git clone git@github.com:KpihX/agents.git ~/.agents

# 2. Symlink ksh dispatcher
ln -sf ~/.agents/skills/k-dockerhost/scripts/ksh ~/.local/bin/ksh

# 3. SSH config — Include canonical
echo "Include ~/.agents/skills/k-ssh/assets/ssh.conf" > ~/.ssh/config

# 4. Secrets
cp ~/.agents/.env.example ~/.agents/.env
# Edit ~/.agents/.env with TELEGRAM_DOCKERHOST_TOKEN + TELEGRAM_CHAT_ID
```

## ksh — Docker Host Dispatcher

```bash
ksh vault backup         # Backup Vaultwarden (encrypted, to Google Drive)
ksh vault restore        # Restore Vaultwarden from backup
ksh status               # Docker host status
```

## Scripts

All scripts live in `k-dockerhost/scripts/` (this skill).

### Vaultwarden Backup

| Script | Purpose |
|--------|---------|
| `vault/backup.sh` | Automated Vaultwarden backup (runs via cron on docker-host) |
| `vault/backup_local.sh` | Manual local pull of Vaultwarden backup |
| `vault/restore.sh` | Restore Vaultwarden from encrypted backup |

### Library

| Script | Purpose |
|--------|---------|
| `lib/notifier.sh` | Shared notification functions (Telegram) |
| `lib/gen_encrypt_key.sh` | Deterministic key derivation from Bitwarden Master Password |

## Secrets

`TELEGRAM_DOCKERHOST_TOKEN` and `TELEGRAM_CHAT_ID` from `~/.agents/.env`.

## Assets

| File | Purpose |
|------|---------|
| `assets/.env.example` | Template for `~/.agents/.env` |

## References

| File | Purpose |
|------|---------|
| `references/README.md` | Vaultwarden backup documentation (original from Homelab/sh/) |
| `references/insights.md` | Runtime lessons |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-24 | [OPENCODE] | v2.0.0 — Renamed from k-pve-dockerhost, refactored with ksh dispatcher, scripts + assets from Homelab/sh/docker_host/ centralized here. Stop copies: source of truth in `.agents/`. |
| [SUMMARY] | — | v1.x original k-pve-dockerhost skill. |


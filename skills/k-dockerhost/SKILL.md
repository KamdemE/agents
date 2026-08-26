---
name: k-dockerhost
description: Docker host (LXC 100) — Vaultwarden backup, Docker management, and automation scripts.
metadata:
  author: KpihX
  version: "2.2.0"
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

> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to understand the setup rule: everything lives in `.agents/` (single source of truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own `assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized).

Source of truth is `.agents/`. On the Docker host:

```bash
# 1. Clone .agents repo (canonical location; ~/.agents is only a symlink)
mkdir -p ~/KpihX-Labs
[ -d ~/KpihX-Labs/.agents ] || git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents
[ -e ~/.agents ] || ln -sfn ~/KpihX-Labs/.agents ~/.agents
# 1b. Branch per infra: cd ~/KpihX-Labs/.agents && git switch <infra>  (ubuntu stays on master)

# 2. kshrc — symlink ($HOME item), source of truth is k-dockerhost/assets/kshrc
ln -sf ~/.agents/skills/k-dockerhost/assets/kshrc ~/.kshrc

# 3. Symlink ksh dispatcher ($HOME item)
ln -sf ~/.agents/skills/k-dockerhost/scripts/ksh ~/.local/bin/ksh

# 4. SSH config — Include canonical
echo "Include ~/.agents/skills/k-ssh/assets/ssh.conf" > ~/.ssh/config

# 5. Secrets
cp ~/.agents/.env.example ~/.agents/.env
# Edit ~/.agents/.env with TELEGRAM_DOCKERHOST_TOKEN + TELEGRAM_CHAT_ID
```

**Systemd units (vault backup):** `sudo ln -sf ~/.agents/skills/k-dockerhost/scripts/vault/systemd/vault-backup.service /etc/systemd/system/` + `.timer`, then `sudo systemctl daemon-reload && sudo systemctl enable --now vault-backup.timer`.

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
| 2026-08-26 | [CLAUDE] | v2.2.0 — Persistent SSH agent (gpg-agent ssh-emulation, socket-activated) added to `assets/kshrc` Section 1 — verify `systemctl --user status gpg-agent-ssh.socket` on this LXC before relying on it (containers can lack a full systemd --user instance). See `k-zsh` v2.5.0 for the mechanism; mirrored here per the SYNC RULE. |
| 2026-08-14 | [COLAB] | v2.1.0 — **Service real-name simplification (per KπX services-key restructure)**: `dockerhost-vault-backup.service`/`.timer` → `vault-backup.service`/`.timer`. Assets renamed + `scripts/vault/{install.sh,purge.sh}` updated; `services.jsonc` keys simplified to `vault-backup-service-dockerhost` / `vault-backup-timer-dockerhost` with `unit` = new real names. Originals archived `/tmp/*.bak-20260814`. |
| [SUMMARY] | — | v2.0.0 renamed from k-pve-dockerhost, ksh dispatcher refactor · v1.x original k-pve-dockerhost skill. |


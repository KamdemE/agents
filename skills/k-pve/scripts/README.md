# PVE Automation Scripts

This skill contains all PVE-specific scripts: maintenance, network, backup.

For cross-infra PVE backup operations (rsync from workstation), see `k-ubuntu/scripts/backup_restore_pve/`.

## Sub-modules

| Module | Contents | README |
|--------|----------|--------|
| `backup/` | Cloud push, restore, vzdump hook | `backup/README.md` |
| `network/` | Watchdog, boot notify, interface switch, eduroam setup | `network/README.md` |

## Prerequisites

- **Source of truth:** `~/.agents/` (cloned git repo) deployed on PVE
- **Environment:** `TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` in `~/.agents/.env`
- **rclone:** Configured as root with `gdrive-x:` remote for cloud backups
- **ksh:** Symlinked from `~/.agents/skills/k-pve/scripts/ksh` → `~/.local/bin/ksh` (`ln -sf`)
- **kshrc:** Symlinked from `~/.agents/skills/k-pve/assets/kshrc` → `~/.kshrc` (`ln -sf`)
- **Scripts executable:** `chmod +x ~/.agents/skills/k-pve/scripts/**/*.sh ~/.agents/skills/k-pve/scripts/backup/backup ~/.agents/skills/k-pve/scripts/notifier.sh`

## Setup (general, applies to all sub-modules)

**Critical infrastructure principle:** systemd unit files are deployed via `sudo cp` (copy, **never** `ln` — PVE critical, system paths). But items in the **current user's `$HOME`** or `/root/` (e.g. `~/.local/bin/ksh`, `~/.kshrc`) are **symlinks** (`ln -sf`) to the `.agents/` asset. The source of truth lives in `.agents/`. If you modify a system unit here, you must `sudo cp` it to the system path again.

```bash
# 0. MANDATORY — read k-infras → New Infra Setup Checklist first (setup rule)

# 1. On PVE: clone the kernel (canonical location; ~/.agents is only a symlink)
mkdir -p ~/KpihX-Labs
[ -d ~/KpihX-Labs/.agents ] || git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents
[ -e ~/.agents ] || ln -sfn ~/KpihX-Labs/.agents ~/.agents

# 2. Environment
cp ~/.agents/.env.example ~/.agents/.env
# Edit: TELEGRAM_PVE_TOKEN=xxx, TELEGRAM_CHAT_ID=xxx

# 3. Make scripts executable
sudo chmod +x ~/.agents/skills/k-pve/scripts/**/*.sh
sudo chmod +x ~/.agents/skills/k-pve/scripts/backup/backup
sudo chmod +x ~/.agents/skills/k-pve/scripts/notifier.sh
chmod +x ~/.agents/skills/k-pve/scripts/ksh

# 4. Copy systemd unit files (cp, not ln — PVE critical)
sudo cp ~/.agents/skills/k-pve/assets/network/watchdog.service  /etc/systemd/system/
sudo cp ~/.agents/skills/k-pve/assets/network/watchdog.timer   /etc/systemd/system/
sudo cp ~/.agents/skills/k-pve/assets/network/boot-notify.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now watchdog.timer boot-notify.service

# 5. Register vzdump hook (backup auto-sync — no systemd service needed)
sudo cp ~/.agents/skills/k-pve/assets/backup/vzdump.conf /etc/vzdump.conf

# 6. ksh dispatcher (optional, for convenience) — symlink ($HOME item)
ln -sf ~/.agents/skills/k-pve/scripts/ksh ~/.local/bin/ksh

# 7. kshrc — symlink ($HOME item), source of truth is k-pve/assets/kshrc
ln -sf ~/.agents/skills/k-pve/assets/kshrc ~/.kshrc
```

> **No more scp/rsync.** All files live in `.agents/skills/k-pve/` — update once, deploy via git pull on PVE. System units → `sudo cp`; `$HOME`/`/root` items → `ln -sf`.

## Secrets

All modules load `TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` from `~/.agents/.env` (symlinked or copied to `/root/.agents/.env` if running as root).

## Maintenance (weekly cron)

`maintenance.sh` handles system updates, Docker cleanup, and reboot. It runs **every Saturday at 04:00** via root crontab — the same timing as on the current PVE (after the vzdump backup at 03:00).

### Crontab entry (root)
```cron
0 4 * * 6 /home/kpihx/.agents/skills/k-pve/scripts/maintenance.sh >> /var/log/maintenance.log 2>&1
```

### What it does
1. `apt-get update && apt-get upgrade -y`
2. `apt-get autoremove && apt-get autoclean`
3. `docker system prune -a -f --volumes` (on CT 100 via pct exec)
4. Telegram notification (OK or ERROR)
5. `/sbin/reboot`

### Install
```bash
# Add to root crontab
sudo crontab -e
# Then paste:
0 4 * * 6 /home/kpihx/.agents/skills/k-pve/scripts/maintenance.sh >> /var/log/maintenance.log 2>&1
```

### Logs
- `/var/log/maintenance.log` — apt and Docker output

# Centralized Scripts Modules — ksh, Clean, Backup, PVE Backup, tg-bot

## ksh — Universal Dispatcher

`ksh` is the central CLI entrypoint for all workstation modules. It delegates to `make` targets in each module directory.

**Install (once per machine):**
```bash
ln -sfn "$HOME/.agents/skills/k-ubuntu/scripts/ksh.sh" "$HOME/.local/bin/ksh"
chmod +x "$HOME/.agents/skills/k-ubuntu/scripts/ksh.sh"
```

**Usage:**
```bash
ksh -h                    # show full usage

# Clean module
ksh clean --safe -y       # safe cleanup, auto-confirm
ksh clean --purge         # deep purge
ksh clean-admin status    # systemd status
ksh clean-admin log       # last 50 journal lines
ksh clean-admin install   # symlink systemd + enable timer (sudo)
ksh clean-admin purge     # remove symlinks (sudo)

# Backup module
ksh backup --preview      # dry-run estimate
ksh backup                # full backup to default HDD
ksh backup-admin status   # systemd status
ksh backup-admin log      # last 50 journal lines
ksh backup-admin install  # symlink systemd + enable timer (sudo)
ksh backup-admin purge    # remove symlinks (sudo)

# Restore (bare-metal)
ksh restore <backup.tar.zst>

# Global audit
ksh status                # clean + backup + QMD health
```

## Clean — Automated System Cleanup

Modular cleanup suite with systemd timer (every 2 days at 21:30).

**Via ksh:**
```bash
ksh clean -s -y              # safe + auto-confirm
ksh clean -p --system        # deep purge + system (sudo)
ksh clean --help             # all flags
ksh clean-admin status       # systemd status
ksh clean-admin log          # journal output
ksh clean-admin install      # symlink units + enable timer (sudo)
ksh clean-admin purge        # remove symlinks (sudo)
```

**6 stages:** snap → cache → editors → work → docker → AI.

**Permissions:** scripts must be executable (`chmod +x *.sh` in each module dir) or services fail silently with `exit-code`/`203/EXEC`.

**Systemd units** in `.agents/skills/k-ubuntu/assets/clean/` (symlinked to `/etc/systemd/system/`): `clean.service` (root, oneshot) · `clean.timer` (every 2d @21:30, Persistent)

## Backup & Restore — Phoenix Protocol

Archives `$HOME` + `/etc` to external HDD via tar+zstd. Timer: every 2 days at 22:00.

**Via ksh:**
```bash
ksh backup --preview         # dry-run estimate
ksh backup                   # full backup
ksh backup-admin status/log  # systemd monitoring
ksh backup-admin install     # symlink units + enable timer (sudo)
ksh backup-admin purge       # remove symlinks (sudo)
ksh restore <archive>        # bare-metal restore
```

**Phases:** metadata export → size estimate → tar+zstd → keep 2.

**Systemd units** in `.agents/skills/k-ubuntu/assets/backup_restore/` (symlinked to `/etc/systemd/system/`): `backup-restore.service` (root, oneshot) · `backup-restore.timer` (every 2d @22:00, Persistent)

## PVE Backup — Phoenix Protocol

Pulls Proxmox backups from PVE via rsync, stores on HDD + Google Drive.
Smart restore: auto-selects HDD or Cloud (newer archive wins).

**Via ksh:**
```bash
ksh backup-pve                  # full backup: rsync → HDD → Cloud
ksh restore-pve                 # restore (auto-select newest source)
ksh backup-pve-admin status/log # systemd monitoring
ksh backup-pve-admin install    # symlink units + enable timer (sudo)
ksh backup-pve-admin purge      # remove symlinks (sudo)
```

**Paths:** HDD `/media/kpihx/KpihX-Backup/Backups/PVE/` (keep 3) · Cloud `gdrive-x:Backups/PVE/` (keep 1)

**Systemd units** in `.agents/skills/k-ubuntu/assets/backup_restore_pve/`

## tg-bot — Telegram Ubuntu Bot

User systemd service. Polls Telegram, dispatches commands via `ksh`.

| Command | Action |
|---------|--------|
| `/clean [flags]` | Run cleaner (safe mode default) |
| `/backup` | Preview backup |
| `/status` | Global system audit |
| `/help` | List commands |

**Setup (symlink from `.agents`):**
```bash
systemctl --user stop tg-ubuntu.service    # stop old if exists
rm -f ~/.config/systemd/user/tg-ubuntu.service
ln -sf ~/.agents/skills/k-ubuntu/assets/tg-bot.service ~/.config/systemd/user/tg-bot.service
systemctl --user daemon-reload
systemctl --user enable --now tg-bot.service
```

**Source of truth:** `k-ubuntu/scripts/tg-bot.py` + `k-ubuntu/assets/tg-bot.service` in `.agents/`.

**Purge:**
```bash
systemctl --user stop tg-bot.service
systemctl --user disable tg-bot.service
rm -f ~/.config/systemd/user/tg-bot.service
systemctl --user daemon-reload
```

**Secrets:** sourced from `~/.agents/.env` — needs `TELEGRAM_UBUNTU_TOKEN` + `TELEGRAM_CHAT_ID`.

**Logs:** `journalctl --user -u tg-bot.service -f`

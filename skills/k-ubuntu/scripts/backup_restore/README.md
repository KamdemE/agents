# backup-restore — Workstation Backup & Restore (Phoenix Protocol)

Automated backup and bare-metal restore suite for Ubuntu workstation.
Archives `$HOME` + `/etc` to external HDD via tar+zstd; sends Telegram report.
Runs automatically every 2 days at 22:00 via systemd timer.

## Usage

```bash
# Run backup directly
ksh backup --help            # see options
ksh backup --preview         # dry-run: estimate size, show what would be backed up
ksh backup /mnt/other       # backup to custom destination
ksh backup                   # backup to default HDD mount

# Full bare-metal restore (interactive, needs HDD)
sudo bash ~/.agents/skills/k-ubuntu/scripts/backup_restore/restore.sh

# Admin operations (systemd lifecycle)
ksh backup-admin help        # list admin targets
ksh backup-admin status      # service + timer status
ksh backup-admin log         # last 50 journal lines
ksh backup-admin install     # symlink systemd units + enable timer (sudo)
ksh backup-admin purge       # remove symlinks, disable timer (sudo)
```

## Architecture

```
backup-restore/
├── backup.sh          # Backup: metadata export → tar+zstd → rotation
├── restore.sh         # Restore: extract → reinstall packages → rsync home
├── excludes.conf      # Additional tar exclusion patterns (one per line)
├── install.sh         # Symlink systemd units + enable timer + test run (sudo)
├── purge.sh           # Remove symlinks, disable timer (sudo)
├── Makefile           # Admin targets (status, log, install, purge, check)
└── systemd/
    ├── backup-restore.service   # oneshot, runs backup.sh as root
    └── backup-restore.timer     # every 2 days at 22:00, Persistent=true
```

## Install

```bash
sudo make install   # or: sudo bash install.sh
```

Creates symlinks in `/etc/systemd/system/` → `.agents/` (source of truth stays in repo),
enables timer, runs backup once to verify.

## Secrets

Requires `~/.agents/.env` with:
- `TELEGRAM_UBUNTU_TOKEN` — bot token for notifications
- `TELEGRAM_CHAT_ID` — Telegram chat ID

## Preview mode

`--preview` or `-p` estimates backup size and lists what would be archived
without creating the archive. Useful to verify excludes before a real run.

## Notes

- Backup destination: external HDD mounted at `/media/kpihx/KpihX-Backup/`
- Keeps last 2 backups (`KEEP_BACKUPS`), older ones are pruned automatically
- Excludes: caches, trash, node_modules, venvs, build artifacts, large VMs
- Uses `pv` for progress bar and `zstd --fast=1` for compression

# backup-restore-sh — Workstation Backup & Restore (Phoenix Protocol)

Automated backup and bare-metal restore suite for Ubuntu workstations.
Archives `/home` + `/etc` to an external HDD via tar+zstd; sends a Telegram report.
Runs automatically every 2 days via systemd timer.

## Architecture

```
backup-restore-sh/
├── backup_workstation.sh    # Backup: metadata export → tar+zstd → rotation
├── restore_workstation.sh   # Restore: extract → reinstall packages → rsync home
├── install.sh               # Install systemd units + secure .env (sudo required)
├── purge.sh                 # Disable timer, remove units (sudo required)
├── systemd/
│   ├── backup-restore.service  # Template — @SCRIPT_DIR@ replaced by install.sh
│   └── backup-restore.timer    # Every 2 days at 22:00, persistent
├── .env                     # Machine config + secrets (gitignored)
└── .env.example             # Keys only — copy to .env and fill in
```

## Quick Start

```bash
# 1. Ensure ~/.agents/.env defines TELEGRAM_UBUNTU_TOKEN and TELEGRAM_CHAT_ID
#    (copy from ~/.agents/.env.example if not done yet)

# 2. Edit machine config at the top of backup_workstation.sh
#    USER_BACKUP, PC_NAME, HDD_DEST_DIR, KEEP_BACKUPS

# 3. Install
sudo make install

# 4. Verify
make log                                      # journalctl -u backup-restore
sudo systemctl start backup-restore.service  # run immediately
```

## Configuration

### Secrets — `~/.agents/.env` (kernel secrets file)

This module sources `~/.agents/.env` at runtime for all secrets.
Add these keys to `~/.agents/.env` (template: `~/.agents/.env.example`):

| Variable | Description |
|----------|-------------|
| `TELEGRAM_UBUNTU_TOKEN` | Bot token for success/error notifications |
| `TELEGRAM_CHAT_ID` | Telegram chat ID to send notifications to |

### Machine config — top of `backup_workstation.sh`

Non-secret machine-specific values are hardcoded at the top of the script:

| Variable | Description |
|----------|-------------|
| `USER_BACKUP` | Username whose /home is archived |
| `PC_NAME` | Label in archive name: `backup-<PC_NAME>-<date>.tar.zst` |
| `HDD_DEST_DIR` | Destination path on external HDD |
| `KEEP_BACKUPS` | Archives to keep before rotation (default: `2`) |

> Cloud mount exclusion is handled automatically via `findmnt` at runtime — no variable needed.

## Machine-Specific Excludes (excludes.conf)

Machine-specific paths to exclude from the backup are kept outside the script in `excludes.conf` (gitignored — never committed).

```bash
cp excludes.conf.example excludes.conf
# Edit excludes.conf — add/remove paths specific to this machine
```

**Format:** one path per line, `#` for comments.
- Lines starting with `/` → absolute path
- Other lines → relative to `/home/$USER_BACKUP`

Universal excludes (caches, build artifacts, `.git`, etc.) remain hardcoded in the script.

## Backup

```bash
# Automatic: every 2 days at 22:00 via systemd timer
# Manual:
sudo bash backup_workstation.sh                          # uses HDD_DEST_DIR from .env
sudo bash backup_workstation.sh /media/user/Disk/Backups # custom destination
```

**What gets backed up:**
- `/home/$USER_BACKUP` (minus caches, node_modules, .venv, build artifacts, cloud mounts)
- `/etc`
- Metadata: APT packages, Snap list, VSCode extensions, GNOME settings, crontabs, disk layout

## Restore (Phoenix Protocol)

For use after a fresh Ubuntu install or hardware migration.

```bash
sudo bash restore_workstation.sh /path/to/backup-xxx.tar.zst [username]
```

**What gets restored:**
1. APT repos + keys → reinstall all APT packages
2. Snap packages
3. VSCode extensions
4. `/home/$USER_RESTORE` (rsync)
5. GNOME preferences
6. SSH config, VPN (Wireguard/Nekoray), network connections, crontabs

> **Not restored:** `/etc/fstab`, `/etc/shadow` — machine-specific, would break the new system.

## Scheduling

| What | Detail |
|------|--------|
| Unit | `backup-restore.timer` |
| Schedule | Every 2 days at 22:00 (`OnCalendar=*-*-1/2 22:00:00`) |
| Persistent | Yes — if the machine was off at 22:00, runs immediately at next boot |
| Boot delay | None — fires at 22:00 only, or immediately on boot if a run was missed |

## Logging

```bash
make log                            # last 50 lines (journald)
journalctl -u backup-restore        # full history
journalctl -u backup-restore -f     # follow live
```

## Makefile

```bash
make install    # sudo: install systemd units, secure .env, enable timer
make purge      # sudo: disable timer and remove unit files
make status     # systemctl status backup-restore.service + timer
make log        # journalctl -u backup-restore -n 50
make run        # sudo: run a backup immediately (drive must be mounted)
make preview    # sudo: estimate size only — no compression
make lint       # shellcheck all .sh files
```

> `backup_restore/` is part of the `.agents/` kernel repo — it has no standalone git.
> To push changes, run `make push` from `~/.agents/` (the repo root).

## Prerequisites

```bash
sudo apt install zstd pv dselect rsync curl libnotify-bin
```

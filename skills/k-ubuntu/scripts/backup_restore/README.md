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
# 1. Configure
cp .env.example .env
# Edit .env: set USER_BACKUP, PC_NAME, HDD_DEST_DIR, TELEGRAM tokens

# 2. Install
sudo make install

# 3. Verify
make log                          # journalctl -u backup-restore
sudo systemctl start backup-restore.service  # run immediately
```

## Configuration (.env)

| Variable | Description |
|----------|-------------|
| `USER_BACKUP` | Username whose /home is backed up |
| `PC_NAME` | Used in archive filename: `backup-<PC_NAME>-<date>.tar.zst` |
| `HDD_DEST_DIR` | External HDD backup directory |
| `KEEP_BACKUPS` | Number of archives to keep (default: 2) |
| `CLOUD_MOUNT_NAME` | rclone mount dir to exclude (default: `gdrive`) |
| `TELEGRAM_UBUNTU_TOKEN` | Telegram bot token for notifications |
| `CHAT_ID` | Telegram chat ID |

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
| Schedule | Every 2 days at 22:00 |
| Persistent | Yes — catches missed runs |
| Boot delay | 15 min after boot (+ up to 5 min random) |

## Logging

```bash
make log                            # last 50 lines (journald)
journalctl -u backup-restore        # full history
journalctl -u backup-restore -f     # follow live
```

## Makefile

```bash
make install    # sudo: install units, secure .env, enable timer
make purge      # sudo: disable and remove units
make status     # systemctl status backup-restore.service + timer
make log        # journalctl -u backup-restore -n 50
make run   # sudo: run a backup immediately (drive must be mounted)
make push       # push to all remotes
make lint       # shellcheck all .sh files
```

## Prerequisites

```bash
sudo apt install zstd pv dselect rsync curl libnotify-bin
```

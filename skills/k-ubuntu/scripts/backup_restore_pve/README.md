# backup_restore_pve — PVE Backup & Restore

Pulls Proxmox backups from PVE via rsync, stores on HDD + Google Drive.
Smart restore: auto-selects HDD or Cloud (whichever has the newer archive).

## Usage

```bash
sudo bash backup_pve.sh                 # full backup: rsync → HDD → Cloud
sudo bash restore_pve.sh                # restore (auto-select newest source)
```

## Paths

- HDD: `/media/kpihx/KpihX-Backup/Backups/PVE/` (keep 3)
- Cloud: `gdrive-x:Backups/PVE/` (keep 1)

## Permissions

Script must be executable (+x) for the service to run:
```bash
chmod +x backup_pve.sh restore_pve.sh
```

## Systemd timer

Runs every Saturday at 03:30 (`OnCalendar=Sat *-*-* 03:30:00`), `Persistent=true`.

**Install:** `sudo bash install.sh` · **Purge:** `sudo bash purge.sh`

## Secrets

`TELEGRAM_UBUNTU_BOT` + `TELEGRAM_CHAT_ID` from `~/.agents/.env`.

## Makefile targets

```bash
make help     # show targets
make log      # journalctl -n 50
make install  # symlink units + enable timer (sudo)
make purge    # remove symlinks (sudo)
make check    # shellcheck
```

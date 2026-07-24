# backup_restore_pve — PVE Backup & Restore

Pulls PVE backups via rsync, stores on HDD + Google Drive.
Smart restore: picks the most recent backup from HDD or Cloud.

## Usage

```bash
ksh backup-pve             # full backup: rsync from PVE → HDD → Cloud
ksh restore-pve            # restore: auto-select HDD or Cloud (newer wins)
ksh backup-admin-pve help  # admin targets
ksh backup-admin-pve log   # last 50 journal lines
```

## Backup path

```
HDD:  /media/kpihx/KpihX-Backup/Backups/PVE/   (keep 3)
Cloud: gdrive-x:Homelab/Backups/PVE/             (keep 1)
```

## Install

```bash
sudo make install   # or: sudo bash install.sh
```

## Restore logic

1. Scan HDD and Cloud for the most recent archive (by mtime)
2. Pick whichever is newer (if one source is empty, use the other)
3. Copy to /tmp/pve_restore/ and display instructions for scp to PVE

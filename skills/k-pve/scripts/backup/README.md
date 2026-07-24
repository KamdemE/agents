# backup — PVE Hypervisor Backup

Pushes Proxmox vzdump archives from PVE to Google Drive.
Also includes a vzdump hook for automatic sync after each backup job.

## Usage

```bash
sudo bash backup_server.sh              # push latest archive to cloud
sudo bash restore.sh                    # download latest from cloud
```

## Systemd timer

Runs weekly (`OnCalendar=weekly`), `Persistent=true`.

**Network watchdog** is in `../network/` with its own install/purge.

## Paths

- Source: `/var/lib/vz/dump/` (on PVE)
- Cloud: `gdrive-x:Backups/PVE/` (keep 1)

## Secrets

`TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` from `/root/.agents/.env` (on PVE).

## Install

```bash
sudo bash install.sh   # symlink systemd units + enable timer
sudo bash purge.sh     # remove symlinks
```

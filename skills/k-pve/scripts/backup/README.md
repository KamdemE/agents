# backup — PVE Hypervisor Backup

Pushes Proxmox vzdump archives from PVE to Google Drive.
Also includes a vzdump hook for automatic sync after each backup job.

## Scripts

| Script | Purpose | Schedule |
|--------|---------|----------|
| `backup` | Push latest vzdump archive to Google Drive | Manual or via vzdump hook |
| `restore.sh` | Pull latest archive from cloud to PVE (disaster recovery) | Manual |
| `vzdump-hook.sh` | Auto-sync to cloud after every Proxmox vzdump job | Triggered by Proxmox at `job-end` |

## Trigger

`vzdump-hook.sh` is the ONLY automatic push mechanism. It is called by Proxmox itself via `/etc/vzdump.conf` at backup `job-end` phase. No systemd timer needed.

| Mechanism | Trigger | Schedule |
|-----------|---------|----------|
| `vzdump-hook.sh` (auto) | Proxmox via `/etc/vzdump.conf` | After every vzdump (Sat 03:00 + manual) |
| `backup` (manual) | `sudo bash backup` or `ksh backup` | On demand |

## Paths

- Source (PVE): `/var/lib/vz/dump/`
- Cloud (rclone): `gdrive-x:Backups/PVE/` (keep 1 most recent)
- Hook log: `/var/log/vzdump-rclone.log`

## Full Setup (on PVE)

### 1. Prerequisites
Before deploying backup scripts, ensure:
- `~/.agents/` is cloned on PVE
- rclone configured as root with `gdrive-x:` remote
- `TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` in `~/.agents/.env`
- Scripts are executable: `chmod +x ~/.agents/skills/k-pve/scripts/backup/* ~/.agents/skills/k-pve/scripts/notifier.sh`

### 2. Register vzdump hook
```bash
cp ~/.agents/skills/k-pve/assets/backup/vzdump.conf /etc/vzdump.conf
```
This registers `vzdump-hook.sh` as a post-backup hook in Proxmox. No other service needed — Proxmox calls the hook directly at `job-end`.

### 3. Verify
```bash
# Test cloud push manually
sudo bash backup

# Test restore (will download latest from cloud)
sudo bash restore.sh

# Check hook log
tail -f /var/log/vzdump-rclone.log
```

## Local workstation backup (Ubuntu)

For mirroring PVE backups to an external HDD (from the Ubuntu workstation), see `k-ubuntu/scripts/backup_restore_pve/backup_pve.sh`.

## Secrets

`TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` from `/root/.agents/.env` (on PVE).

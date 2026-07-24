# network — PVE Network Management

Network watchdog, boot notification, interface switching, and eduroam setup for Proxmox VE.

## Scripts

| Script | Purpose |
|--------|---------|
| `network_watchdog.sh` | Monitor connectivity, notify on failure |
| `boot_notify.sh` | Telegram notification on PVE boot |
| `network_switch.sh` | Switch between WiFi (eduroam) and Wired (802.1X) |
| `setup_eduroam.sh` | Automated eduroam configuration (École Polytechnique) |

## Systemd units

| Unit | Purpose |
|------|---------|
| `systemd/pve-watchdog.service` | Watchdog check |
| `systemd/pve-watchdog.timer` | Every 5 minutes |
| `systemd/pve-boot-notify.service` | Boot notification |

## Install

```bash
sudo bash install.sh   # symlink watchdog + boot-notify units
sudo bash purge.sh     # remove symlinks
```

## Secrets

`TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` from `/root/.agents/.env` (on PVE).

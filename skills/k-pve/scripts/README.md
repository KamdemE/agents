# PVE Automation Scripts

This skill contains all PVE-specific scripts: maintenance, network, backup.

For cross-infra PVE backup operations (rsync from workstation), see `k-ubuntu/scripts/backup_restore_pve/`.

## Sub-modules

| Module | Contents |
|--------|----------|
| `backup/` | Cloud push, restore, vzdump hook |
| `network/` | Watchdog, boot notify, interface switch, eduroam setup |

## Secrets

All modules load `TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` from `~/.agents/.env`.

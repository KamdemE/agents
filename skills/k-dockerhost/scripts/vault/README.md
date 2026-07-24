# vault — Vaultwarden Backup

Encrypted Vaultwarden backup suite for Docker host. Backups pushed to Google Drive.

## Usage

```bash
sudo bash backup.sh                     # backup + encrypt + upload
sudo bash restore.sh                    # download + decrypt + restore
```

## Systemd timer

Runs weekly (`OnCalendar=weekly`), `Persistent=true`.

**Install:** `sudo bash install.sh` · **Purge:** `sudo bash purge.sh`

## Secrets

`TELEGRAM_DOCKERHOST_TOKEN` + `TELEGRAM_CHAT_ID` from `~/.agents/.env`.

## Encryption

Key derived deterministically from Bitwarden Master Password via `lib/gen_encrypt_key.sh`.

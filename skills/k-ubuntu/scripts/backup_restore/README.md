# backup-restore — Workstation Backup (Phoenix Protocol)

Archives `$HOME` + `/etc` to external HDD via tar+zstd. Sends Telegram report.

## Usage

```bash
sudo bash backup.sh --help              # see flags (--preview, custom dest)
sudo bash backup.sh                     # backup to default HDD
sudo bash backup.sh --preview           # dry-run estimate only
```

## Permissions

All `.sh` scripts must be executable (+x) for services to run them:
```bash
chmod +x *.sh
```

## Systemd timer

Runs every 2 days at 22:00 (`OnCalendar=*-*-1/2 22:00:00`), `Persistent=true`.

**Install:** `sudo bash install.sh` · **Purge:** `sudo bash purge.sh`

## Destination

`/media/kpihx/KpihX-Backup/Backups/Ubuntu/` — keeps last 2 archives.

## Secrets

Requires `~/.agents/.env` with `TELEGRAM_UBUNTU_TOKEN` + `TELEGRAM_CHAT_ID`.

## Makefile targets

```bash
make help     # show targets
make status   # systemd status
make log      # journalctl -n 50
make install  # symlink units + enable timer (sudo)
make purge    # remove symlinks (sudo)
make check    # shellcheck
```

# clean — Automated System Cleanup Suite

Modular cleanup suite for Ubuntu workstation. 6 stages: snap → cache → editors → work → docker → AI.

## Usage

```bash
sudo bash clean_all.sh --help           # see all flags
sudo bash clean_all.sh -s -y            # safe mode, auto-confirm
sudo bash clean_all.sh -p --system -y   # deep purge + system, auto-confirm
```

## Systemd timer

Runs every 2 days at 21:30 (`OnCalendar=*-*-1/2 21:30:00`), `Persistent=true`.

**Install:** `sudo bash install.sh` · **Purge:** `sudo bash purge.sh`

## Logs

```bash
journalctl -u clean-system -n 50        # service logs
cat /var/log/clean-system/workspace_scan.log  # last workspace scan
```

## Secrets

`TELEGRAM_UBUNTU_TOKEN` + `TELEGRAM_CHAT_ID` from `~/.agents/.env`.

## Makefile targets

```bash
make help     # show targets
make status   # systemd service + timer status
make log      # journalctl -n 50
make install  # symlink units + enable timer (sudo)
make purge    # remove symlinks (sudo)
make check    # shellcheck
```

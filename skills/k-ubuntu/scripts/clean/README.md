# clean — Weekly System Cleanup Suite

Automated cleanup and disk-analysis suite for KπX Ubuntu workstation.
Runs every 2 days at 21:30 via systemd timer; sends a Telegram report.

## Architecture

```
clean/
├── auto_clean.sh       # Root automation: orchestrates, analyzes, notifies Telegram
├── clean_all.sh        # Orchestrator: calls all module scripts in order
├── clean_snap.sh       # Module: snap revision cleanup
├── clean_cache.sh      # Module: APT, pip, npm, bun, uv, browser caches
├── clean_editors.sh    # Module: Wrapper for VSCode, Cursor, and Antigravity caches, logs, CachedData
├── clean_work.sh       # Module: $HOME/Work/ pycache, build artifacts (dist/build/target/.next)
├── clean_docker.sh     # Module: docker prune (images, containers, volumes)
├── clean_ai.sh         # Module: AI model caches, unused weights
├── workspace_scan.sh   # Scanner: .env git status, venvs, node_modules, build artifacts, large files
├── install.sh          # Generate + install systemd units, create log dir (sudo required)
├── purge.sh            # Disable timer, remove units (sudo required)
├── systemd/
│   ├── clean-system.service   # Template — @SCRIPT_DIR@ replaced by install.sh
│   └── clean-system.timer     # Bi-daily 21:30
└── .env                # Secrets + config (gitignored)
```

## Scheduling

| What | Detail |
|------|--------|
| Unit | `clean-system.timer` |
| Schedule | Every 2nd day at 21:30 (`OnCalendar=Sat *-*-* 10:00:00`) |
| Persistent | Yes — catches missed runs if machine was off |
| Installed at | `/etc/systemd/system/` |

## Logging

Service output → systemd journal. Workspace scan → `/var/log/clean-system/workspace_scan.log`.

```bash
make log        # journalctl -u clean-system -n 50
make log-scan   # cat /var/log/clean-system/workspace_scan.log
```

## Secrets

`auto_clean.sh` sources `.env` from the same directory at runtime.
Required keys: `TELEGRAM_UBUNTU_TOKEN`, `CHAT_ID`, `USER`.
If token is unavailable, cleanup still runs — only the Telegram notification is skipped.

Copy `.env.example` → `.env` and fill in values before running `make install`.

## Makefile

```bash
make install    # sudo: generate service (resolves @SCRIPT_DIR@) + enable timer
make purge      # sudo: disable and remove units
make run   # sudo: simulate the weekly run (reads USER from .env)
make log        # journalctl -u clean-system -n 50
make log-scan   # last workspace scan log (/var/log/clean-system/)
make push       # push to all remotes
make lint       # shellcheck on all .sh files
```

## Install

```bash
sudo make install
# or directly:
sudo bash install.sh
```

`install.sh` resolves `@SCRIPT_DIR@` in the service template, copies units to
`/etc/systemd/system/`, creates `/var/log/clean-system/`, and enables the timer.

## Purge (uninstall)

```bash
sudo make purge
```

Stops timer/service, removes unit files, daemon-reload.
Logs preserved in `/var/log/clean-system/` — remove manually if needed.

## Notes

- `workspace_scan.sh` detects `.env` files in 3 tiers: `TRACKED IN GIT` / `NOT gitignored` / `gitignored ✓`
- `clean_work.sh --safe` removes `__pycache__`, `.pytest_cache`, and build artifacts (`dist/`, `build/`, `target/`, `.next/`)
- `TOP_ROOT` targets `/var /usr /home /opt` only — avoids full `/` scan and RAM spike
- `DU_EXCLUDES` in `.env` — space-separated subdirs to skip from du analysis (rclone mounts)
- Auto-confirm in `auto_clean.sh` uses `printf 'y%.0s' {1..100}` — compatible with `read -n 1` in all module confirm prompts

# clean — Weekly System Cleanup Suite

Automated cleanup and disk-analysis suite for KπX Ubuntu workstation.
Runs every 2 days at 21:30 via systemd timer; sends a Telegram report.

## Usage

```bash
# Run cleanup directly — sudo used internally only when needed
ksh clean --help                  # see options
ksh clean -s                      # safe mode, interactive
ksh clean -s -y                   # safe mode, auto-confirm
ksh clean -p --system             # deep purge + system (sudo for system ops)
ksh clean -p --system -y          # deep purge + system, auto-confirm

# Admin operations (systemd lifecycle, monitoring, logs) — via Makefile
ksh clean-admin help              # list available admin targets
ksh clean-admin status            # service + timer status
ksh clean-admin log               # last 50 journal lines
ksh clean-admin install           # install systemd units (sudo)
ksh clean-admin purge             # remove systemd units (sudo)
```

## Architecture

```
clean/
├── auto_clean.sh       # Root automation: orchestrates, analyzes, notifies Telegram
├── clean_all.sh        # Orchestrator: calls all module scripts in order  ← ksh clean
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
└── excludes.conf       # (optional) Machine-specific du exclusions
```

## Scheduling

| What | Detail |
|------|--------|
| Unit | `clean-system.timer` |
| Schedule | Every 2 days at 21:30 (`OnCalendar=*-*-1/2 21:30:00`) |
| Persistent | Yes — catches missed runs if machine was off |

## Logging

Service output → systemd journal. Workspace scan → `/var/log/clean-system/workspace_scan.log`.

```bash
make log        # journalctl -u clean-system -n 50
make log-scan   # cat /var/log/clean-system/workspace_scan.log
```

## Secrets

Secrets are sourced from `~/.agents/.env` (kernel secrets file) at runtime.
Add these keys to `~/.agents/.env` (template: `~/.agents/.env.example`):

| Variable | Description |
|----------|-------------|
| `TELEGRAM_UBUNTU_TOKEN` | Bot token for success/failure notifications |
| `TELEGRAM_CHAT_ID` | Telegram chat ID to send notifications to |

If token is unavailable, cleanup still runs — only the Telegram notification is skipped.

## Machine config

Non-secret values are hardcoded at the top of `auto_clean.sh`:

| Variable | Description |
|----------|-------------|
| `USER_BACKUP` | Username whose /home is cleaned |
| `PC_NAME` | Label in Telegram report |
| `DU_EXCLUDES` | Array of subdirs to skip from du analysis (rclone mounts, etc.) |

## Makefile (admin — via `ksh clean-admin`)

The Makefile handles **meta operations only** (systemd lifecycle, monitoring).  
Actual cleanup is done by `clean_all.sh` via `ksh clean`.

```bash
make help       # show available admin targets
make status     # service + timer status
make log        # journalctl -u clean-system -n 50
make install    # sudo: symlink systemd units from .agents/ + enable timer + test run
make purge      # sudo: remove symlinks, disable timer
make check      # shellcheck on all .sh files
```

## Install

Systemd units are **symlinked** from `.agents/` (source of truth stays in the repo):

```bash
sudo make install
# or directly:
sudo bash install.sh
```

The service unit in `systemd/clean-system.service` now has the full absolute path to
`auto_clean.sh` (no `@SCRIPT_DIR@` sed substitution needed). The timer stays on its
canonical schedule (every 2 days at 21:30).

## Purge (uninstall)

```bash
sudo make purge
```

Removes symlinks from `/etc/systemd/system/`, stops timer, daemon-reload.
Logs preserved in `/var/log/clean-system/`.

> `clean/` is part of the `.agents/` kernel repo — it has no standalone git.
> To push changes, run `make push` from `~/.agents/` (the repo root).

## Notes

- `workspace_scan.sh` detects `.env` files in 3 tiers: `TRACKED IN GIT` / `NOT gitignored` / `gitignored ✓`
- `clean_work.sh --safe` removes `__pycache__`, `.pytest_cache`, and build artifacts (`dist/`, `build/`, `target/`, `.next/`)
- `TOP_ROOT` targets `/var /usr /home /opt` only — avoids full `/` scan and RAM spike
- `du -x` (one filesystem) automatically skips all mount points (rclone, bind mounts). `EXCLUDE_DIRS` at the top of `auto_clean.sh` handles large same-fs dirs (`.ollama`, `.ollama-ipex`).
- `-y` or `--yes` flag auto-confirms all prompts in `clean_all.sh` and all sub-scripts

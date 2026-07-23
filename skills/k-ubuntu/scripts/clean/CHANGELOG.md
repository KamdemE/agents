# Changelog — clean-sh

All notable changes to this project are documented here.
Format: newest-first.

## [Unreleased]

## [2026-04-05]

### Fixed
- `auto_clean.sh`: replace `printf "y\ny\n..."` with `printf 'y%.0s' {1..100}` — fixes `read -n 1` stdin alternating bug where every other confirm was silently answered `n`
- `clean_work.sh`: replace all `~/Work` with `$HOME/Work` — fixes execution as root via systemd
- `workspace_scan.sh`: fix `.env` git check to 3-tier detection (`TRACKED IN GIT` / `NOT gitignored` / `gitignored ✓`) using `git ls-files --error-unmatch`; remove duplicate ALERT print

### Added
- `clean_work.sh`: interactive removal of `dist/`, `build/`, `target/`, `.next/` in `--safe` mode (with size preview)
- `auto_clean.sh`: `LOG_DIR=/var/log/clean-system`; workspace scan logged to `/var/log/clean-system/workspace_scan.log` via `tee` (verbose to stdout + file); fix awk keyword `SUMMARY` → `Summary`
- `Makefile`: `log-scan` target — `cat /var/log/clean-system/workspace_scan.log`
- `install.sh`: generate service from `@SCRIPT_DIR@` placeholder via `sed`; create `/var/log/clean-system/`
- `purge.sh`: update log path reference to `/var/log/clean-system/`
- `systemd/clean-system.service`: replace hardcoded `ExecStart` with `@SCRIPT_DIR@/auto_clean.sh`; remove `Environment=HOME=...` (handled by `auto_clean.sh` at runtime)

## [2026-04-04]

### Added
- Initial suite: `auto_clean.sh`, `clean_all.sh`, modules (`clean_snap`, `clean_cache`, `clean_vscode`, `clean_work`, `clean_docker`, `clean_ai`)
- `workspace_scan.sh`: bloat scanner (venvs, node_modules, build artifacts, large files, .env git status)
- `systemd/` units + `install.sh` / `purge.sh`
- `Makefile` with `install`, `purge`, `log`, `push`, `test-run`, `lint`
- Telegram notification in `auto_clean.sh`
- `DU_EXCLUDES` support for rclone mounts

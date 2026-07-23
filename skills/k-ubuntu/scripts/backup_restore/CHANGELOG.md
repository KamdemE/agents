# Changelog — backup-restore-sh

All notable changes are documented here. Newest-first.

## [2026-04-05] — v1.2.0

### Added
- `backup_workstation.sh`: Added Telegram notifications (`alert "ERROR"`) when the backup drive is missing or read-only, including manual recovery instructions.

## [2026-04-05] — v1.1.0

### Changed
- `backup_workstation.sh`: machine-specific excludes moved out of script into `excludes.conf` (gitignored); universal excludes remain hardcoded
- `Makefile`: `status` now checks `systemctl` service+timer; `git-status` for git; added `test-run` target
- `README.md`: added Machine-Specific Excludes section; updated Makefile docs
- `excludes.conf.example`: created with annotated machine-specific examples
- `.gitignore`: added `excludes.conf`

## [2026-04-05] — v1.0.0

### Changed
- Full refactor for portability and agnosticism:
  - Externalized `PC_NAME`, `USER_BACKUP`, `HDD_DEST_DIR`, `KEEP_BACKUPS`, `CLOUD_MOUNT_NAME` to `.env`
  - `backup_workstation.sh`: validates required env vars, arg overrides `.env` default, `set -euo pipefail`, English comments, fixed `alert()` ICON-before-case bug
  - `restore_workstation.sh`: sources `.env` for `USER_BACKUP`, interactive username fallback, English comments
- Added `install.sh`: generates service via `sed @SCRIPT_DIR@`, removes legacy `backup-pc` units, secures `.env`
- Added `purge.sh`: idempotent, removes `backup-restore` units
- Added `systemd/backup-restore.service` + `systemd/backup-restore.timer` (templates)
- Added `Makefile` with `install`, `purge`, `log`, `push`, `lint`
- Renamed `BACKUP_RESTORE.md` → `README.md` (full rewrite in English)
- Added `CHANGELOG.md`, `TODO.md`, `.env.example`, `.gitignore`
- Created standalone git repo: `backup-restore-sh` (github + gitlab)

## [2026-03-21]

### Added
- Initial scripts: `backup_workstation.sh`, `restore_workstation.sh`, `BACKUP_RESTORE.md`

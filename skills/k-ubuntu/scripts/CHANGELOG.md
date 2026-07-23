# Changelog — Workstation Orchestrator (sh)

All notable changes to this project will be documented in this file.

## [2.1.4] - 2026-04-17

### Changed
- **README / submodule `sui`:** document **`sui -r`** (shorthand for **`--reason`**) and bump tracked **`sui/`** to **v3.1.23**.

## [2.1.3] - 2026-04-16

### Changed
- **README:** `sui` section updated for **v3.1.22** (Zenity `--forms`, `make test` in submodule, changelog link).
- **Submodule `sui`:** pointer advanced to **v3.1.22** (stub test suite, CI, documentation sync; interactive `live-smoke` removed upstream).

## [2.1.2] - 2026-04-05 — Multi-Remote Sync
### Added
- **Multi-Remote Push**: Root `Makefile` now explicitly pushes to `github` and `gitlab` remotes for all submodules.
- **Improved ksh status**: Added Bitwarden Vault deep audit in the global dispatcher.
- **Smart Proxies**: Root `Makefile` uses pattern rules (`clean-%`, `backup-%`) to delegate commands.

### Fixed
- **Submodule Push Errors**: Resolved "No configured push destination" by specifying remotes in the orchestrator.
- **Telegram Undertow**: Fixed underscore parsing in backup notifications.
- **Git Metadata Ownership**: Restored user access to all submodule git folders.

## [1.1.0] - 2026-04-05
- Standardized `make run` targets and repo structure.

## [1.0.0] - 2026-04-05
- Initial project restructuring (k-project spec).

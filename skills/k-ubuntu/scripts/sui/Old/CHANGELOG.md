# Changelog

All notable changes to `sui` are documented in this file.

The format is inspired by Keep a Changelog and this project follows Semantic Versioning.

## [3.2.1] - 2026-04-29

### Added
- **Shell Strings Support** — Automatically detect and wrap single-argument commands containing spaces or shell metacharacters (e.g. `sui "apt update && apt upgrade"`) in `bash -c`.

## [3.2.0] - 2026-04-22

### Added
- **Modernized POSIX Argument Parser** — Complete refactor of `parse_args` to align with standard Unix conventions.
- **Combined Flags** — Group multiple flags (e.g., `sui -dr "Rationale" command`).
- **Sticky Arguments** — Support for combined prefix and value (e.g., `sui -r"Rationale" command`).
- **Universal Aliases** — Short aliases for all options: `-p` (polkit), `-d` (dry-run), `-D` (doctor), `-j` (json), `-s` (sudo-cache), `-S` (no-sudo-cache), `-v` (version), `-h` (help).
- **Sticky -r=VAL** — Preserved backward compatibility for `--reason=VAL` and `-r=VAL` formats.

### Changed
- **Zero-Regression Parser** — Positional arguments and `@target` detection logic fully preserved and isolated from option parsing.
- **Strict Consumables** — Options no longer consume flags as values (e.g., `sui -r -d ls` now correctly identifies `-d` as a flag).
- **Cleaned Feature Creep** — Removed `SUI_ZENITY_STDERR` and `pkexec` TTY fallback to maintain core focus and stability.
- **Audit Logging** — Improved `sui_audit` consistency across local and remote scopes.

## [3.1.23] - 2026-04-17

### Added
- **`-r` / `-r=…`** — shorthand for **`--reason`** / **`--reason=…`** (same validation and audit behavior).

## [3.1.22] - 2026-04-16

### Added
- **`make test`** — runs `lint` (including `bash -n` on `tests/run-stub-tests.sh`) plus **`test-stubs`**.

### Changed
- **README:** features, CI steps, Zenity troubleshooting, and exit codes aligned with current `--forms` auth UX and audit behavior.
- **`sui.sh`:** header comment documents **`make test`** / **`make test-stubs`** for contributors.

### Removed
- **`tests/live-smoke.sh`** — interactive manual smoke script removed; **`make test-stubs`** / `tests/run-stub-tests.sh` is the supported automated regression path.

## [3.1.21] - 2026-04-16

### Added
- **Stub test suite:** `tests/run-stub-tests.sh` with `tests/stubs/{zenity,sudo,ssh,logger}` — exercises local/remote auth flows, operator-comment tags, exit codes (130 / 77 / 127 / 2), and `reason=present` audit redaction without real GUI or privilege. Run via `make test-stubs` or CI.

## [3.1.20] - 2026-04-16

### Changed
- **Audit:** when `--reason` is set, syslog / `SUI_LOG` record `reason=present` (SIEM-friendly flag) instead of `reason=[REDACTED]`. Still no free-text rationale in audit.

## [3.1.19] - 2026-04-16

### Security / Changed
- **Audit redaction:** `sui_audit` syslog and `SUI_LOG` file no longer embed the `--reason` string; they record a non-text marker when a reason was provided, else `reason=<none>`. Full text remains in the Zenity dialog only. Operator comments unchanged (stderr only, not in audit).

## [3.1.9] - 2026-04-13

### Changed
- Zenity auth uses `--password --username`: first field = operator comment, second = password (GTK sets **Enter** on the password field to activate **OK**).
- Shell footer order on cancel/abort: cancellation line, then `sui: rationale:` (when `--reason` is set), then `sui: operator-comment:` last.
- After a plain **Cancel** (no stdout from Zenity), optional follow-up entry captures a shell note.
- **OK** with empty password aborts without sudo and still prints rationale + comment.

### Notes
- Zenity prints `comment|password` with a fixed `|`; avoid `|` in the comment field.

## [3.1.8] - 2026-04-13

### Changed
- Zenity auth form now places **comment first, password last** to improve `Enter`→OK flow from the password field.
- `sui` now parses form output even when Zenity exits on cancel and prints `operator-comment` when available before cancellation messages.

## [3.1.7] - 2026-04-13

### Changed
- Zenity auth uses one `--forms` dialog again: **password + optional operator comment** (RS `0x1e` output separator instead of `|` for safer parsing).
- TTY fallback: hidden password prompt plus one optional comment line (no second GUI popup).

## [3.1.6] - 2026-04-13

### Changed
- Missing `--reason` now hard-fails immediately in shell (exit 2) with a clear retry instruction.
- Removed rationale popup prompting path: agents must provide rationale before execution; humans only validate auth popup.

## [3.1.5] - 2026-04-13

### Changed
- Restored fast Enter-to-OK behavior on password input by using `zenity --entry --hide-text` for authentication.
- Operator comment capture now uses a follow-up optional UI entry (`Save`/`Skip`) and is still echoed in shell when provided.

## [3.1.4] - 2026-04-13

### Added
- Authentication popup now includes an optional **operator comment** field.
- If provided, the operator comment is always echoed in shell output (`sui: operator-comment: ...`) when the dialog is validated.

### Changed
- Switched auth input collection to Zenity forms mode (password + comment in one dialog).

## [3.1.3] - 2026-04-13

### Added
- Mandatory rationale enforcement path (default ON): privileged execution now requires `--reason` or an interactive rationale prompt.
- Interactive rationale retry loop (max 3 attempts) before abort.
- Hidden internal toggles for advanced automation:
  - `--__require-reason`
  - `--__no-require-reason`

## [3.1.2] - 2026-04-13

### Added
- `--reason` (and `--reason=...`) option to attach a human rationale displayed in the privilege dialog.
- Audit trail now records the provided rationale (`reason=...`) for traceability.
- `tests/live-smoke.sh` interactive smoke suite covering rich local/remote privileged scenarios.

### Changed
- Dialog context block now shows `Rationale:` prominently before password entry.

### Fixed
- Local sudo flow now executes in the same `sudo -S` invocation (robust with `sudo-rs`).
- Remote sudo flow now executes in the same `sudo -S` invocation (avoids ticket loss across SSH calls).
- Filtered remote auth noise (`Sorry, try again`) from shell while preserving non-auth stderr.
- Fixed local `--polkit` path (`pkexec "$@"` instead of executing literal `--`).

## [3.1.1] - 2026-04-13

### Added
- `--json` output mode for doctor diagnostics (`sui --doctor --json` and `sui doctor --json`).
- Machine-readable runtime fields (tool availability, GUI/TTY capability, cache mode, fallback order).

### Changed
- `doctor` now routes through one dispatcher that supports both text and JSON outputs.

## [3.1.0] - 2026-04-13

### Added
- Distinct exit codes for authentication outcomes:
  - `130` for user cancellation.
  - `77` for max-attempts authentication failure.
- Attempt counter in dialog titles (`[1/3]`, `[2/3]`, ...).
- Configurable sudo cache policy:
  - `--no-sudo-cache` (secure default).
  - `--sudo-cache` (allow timestamp reuse).
- Controlled retry loop with explicit shell + popup feedback on failures.

### Changed
- Strengthened local/remote auth UX and terminal feedback consistency.

## [3.0.6] - 2026-04-13

### Fixed
- Password prompt UX: Enter reliably validates the dialog.
- Forced strict password validation path (`sudo -k`) to prevent false-positive auth from cached sudo tickets.

## [3.0.5] - 2026-04-13

### Added
- `doctor` / `--doctor` runtime diagnostics.
- Auto-fallback when Zenity/GUI is unavailable:
  - local: `pkexec`, then TTY prompt.
  - remote: TTY prompt.

### Changed
- Zenity calls use `GSK_RENDERER=cairo` and stderr suppression by default.

## [3.0.4] - 2026-04-13

### Fixed
- Removed problematic separator characters that broke Zenity markup parsing.

## [3.0.3] - 2026-04-13

### Changed
- Command line is always shown prominently in the dialog body.

## [3.0.1] - 2026-04-13

### Fixed
- Switched to Zenity forms mode to keep full command details visible on Zenity 4.x.

## [3.0.0] - 2026-04-13

### Added
- First public standalone release of `sui`:
  - unified local/remote privilege flow,
  - command preview in GUI,
  - audit hooks,
  - `--polkit` and `--dry-run`.

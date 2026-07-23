# sui — Sudo User Interface

Unified graphical gateway for **local** and **remote** privileged commands on Linux desktops (Zenity + `sudo` / `pkexec`, SSH for remote hosts). Preserves full `argv` (no fragile `"$*`" over SSH).

## Features

- Single Zenity **`--forms`** dialog: **full argv** in the dialog body; fields are **Action** (RUN or ABORT), optional **operator comment**, and **sudo password** (hidden). Internal field separator is ASCII **RS** (`0x1e`), not `|` — you can use `|` in the comment.
- `--polkit` for desktop users who prefer Polkit (`pkexec`) locally.
- `--dry-run` to preview without elevation.
- `doctor` / `-D` / `--doctor` runtime diagnostic mode (GUI/TTY/tools availability + fallback order).
- `--json` machine-readable output for `doctor` mode.
- **`--reason "…"`** or **`-r "…"`** for a human rationale in the elevation dialog (full text in the GUI only; audit logs use `reason=present` or `reason=<none>`).
- **Combined Flags & Sticky Args** — Supports POSIX-style grouping (e.g., `-dr"Test"`) and sticky arguments (`-r"Reason"`).
- Optional **operator comment** in the same form: when non-empty, a single stderr line per dialog, e.g. `Sui: OPERATOR-COMMENT (dialog N/3, <tag>): **...**` (not copied into syslog / `audit.log`).
- `--sudo-cache` / `--no-sudo-cache` to control sudo timestamp behavior (default: secure no-cache).
- Optional `SUI_LOG=1` for `${XDG_STATE_HOME}/sui/audit.log`.
- Syslog audit via `logger -p authpriv.notice` (often merged into `/var/log/auth.log` on traditional setups).

## Requirements

- Bash, `sudo`, `zenity`, `ssh` (remote), optional `pkexec` (`--polkit`).
- A graphical session (`DISPLAY` or `WAYLAND_DISPLAY`) for password prompts.

### Install `zenity` (if missing)

- Ubuntu/Debian:
  ```bash
  sudo apt update && sudo apt install -y zenity
  ```
- Fedora:
  ```bash
  sudo dnf install -y zenity
  ```
- Arch:
  ```bash
  sudo pacman -S --needed zenity
  ```

## Install (recommended: `install(1)`)

Use **`install`** so permissions and ownership are set in one atomic, explicit step. Installing to `/usr/local/bin` requires **root** (use your normal elevation path, e.g. `sudo` once for the install only).

### From a clone of this repository

```bash
cd /path/to/sui
sudo install -o root -g root -m 0755 sui.sh /usr/local/bin/sui
```

Why this shape:

- **`-o root -g root`** — the installed binary is owned by root (expected for system-wide tools under `/usr/local`).
- **`-m 0755`** — owner read/write/execute; group and others read/execute (standard for public executables).
- **`install`** creates/overwrites the destination file in one shot; fewer mistakes than separate `cp` + `chmod` + `chown`.

### Optional: backup existing binary

If `/usr/local/bin/sui` already exists:

```bash
sudo install -b -o root -g root -m 0755 sui.sh /usr/local/bin/sui
```

`-b` creates a backup (e.g. `sui~`) before replacing.

### Verify

```bash
command -v sui
sui --help
```

## Usage (short)

```text
sui [options] [@ssh-host] <command> [args...]
sui doctor
sui --doctor --json
sui --reason "why this needs privilege" <command>
sui -r "short rationale" <command>
```

Cache mode examples:

```bash
# secure default (no sudo timestamp reuse)
sui --no-sudo-cache apt update

# allow sudo timestamp cache (fewer prompts)
sui --sudo-cache apt update

# provide rationale visible in the popup (--reason or equivalent -r)
sui --reason "Refresh package metadata before maintenance window" apt update
sui -r "Refresh package metadata before maintenance window" apt update
```

See `sui --help` or the header of `sui.sh`.

## Repositories

- **GitHub:** `git@github.com:KpihX/sui.git`
- **GitLab:** `git@gitlab.com:kpihx/sui.git`
- **Changelog:** see `CHANGELOG.md`.

### Remotes when embedded in `KpihX/sh`

The parent `sh` Makefile runs `git push` on each submodule using remotes named **`github`** and **`gitlab`**. After a plain clone of only `sui`, the default remote is often `origin` pointing at GitHub. Align with:

```bash
git remote rename origin github
git remote add gitlab git@gitlab.com:kpihx/sui.git
```

Then `make push` from the `sui` repo root pushes both hosts.

## CI and Release Discipline

This project is security/ops-sensitive, so keep release hygiene strict:

- CI (`.github/workflows/ci.yml`) runs:
  - `bash -n sui.sh tests/run-stub-tests.sh`
  - `shellcheck sui.sh`
  - smoke checks: `./sui.sh --help` and `./sui.sh --doctor`
  - **`tests/run-stub-tests.sh`** (stubbed zenity/sudo/ssh/logger — no real GUI or privilege)
- SemVer policy:
  - **MAJOR**: breaking CLI/behavior changes.
  - **MINOR**: backward-compatible features.
  - **PATCH**: backward-compatible fixes/docs/internal reliability.
- Every versioned change must update:
  - `readonly SUI_VERSION` in `sui.sh`
  - `CHANGELOG.md` with a new top entry.
- Tag releases as `vX.Y.Z` after CI is green on `main`.

## Troubleshooting

### Password dialog does not show the command (Zenity 4.x)

Older examples used `zenity --password --text=…`. On Zenity **4.x**, that mode often **drops `--text`**.

Current `sui` uses **`zenity --forms`** with a large `--text=` body so the full argv briefing stays visible, plus RUN/ABORT, optional comment, and a password field.

### What if `zenity` is absent or no GUI is available?

`sui` **v3.0.5+** falls back automatically:

- **Local:** try `pkexec` first, then interactive TTY password prompt for `sudo` if needed.
- **Remote:** interactive TTY password prompt, then SSH + remote `sudo -S`.

This keeps privilege elevation usable on headless/minimal systems.

### `MESA-INTEL` lines in the terminal when the dialog opens

Launching the GTK/Zenity stack may print **harmless** Intel Vulkan driver warnings to **stderr**. They are **not** from `apt` or `sudo`. After you confirm the dialog, normal command output should follow.

From **v3.0.5+**, `sui` forces `GSK_RENDERER=cairo` for Zenity and suppresses Zenity stderr by default.
To re-enable stderr for debugging:

```bash
SUI_ZENITY_STDERR=1 sui apt update
```

## Test Matrix

| Scenario | Expected password UX | Expected execution path |
|---|---|---|
| Zenity installed + GUI available (local) | Zenity forms dialog | `sudo -S -- <cmd>` |
| Zenity missing/no GUI + `pkexec` available (local) | Polkit native dialog | `pkexec -- <cmd>` |
| Zenity missing/no GUI + no `pkexec` + interactive TTY (local) | TTY hidden prompt | `sudo -S -- <cmd>` |
| Zenity missing/no GUI + no TTY (local) | Clear error | abort |
| Zenity installed + GUI available (remote) | Zenity forms dialog | `ssh ... 'sudo -S ... bash -s'` |
| Zenity missing/no GUI + interactive TTY (remote) | TTY hidden prompt | `ssh ... 'sudo -S ... bash -s'` |
| Zenity missing/no GUI + no TTY (remote) | Clear error | abort |

Quick checks:

```bash
sui doctor
sui --dry-run apt update
sui --dry-run @docker-host systemctl restart nginx
sui --doctor --json
```

Automated tests (stubs — no real GUI or sudo):

```bash
make test          # lint + stub suite (local CI-equivalent)
make test-stubs    # stub tests only
# or: tests/run-stub-tests.sh
```

Authentication retry behavior:

- After a wrong password, `sui` reopens the prompt (up to 3 attempts by default).
- This avoids the raw repeated `sudo: Authentication failed, try again.` spam in terminal.
- Popup title shows retry progress (`[1/3]`, `[2/3]`, ...).

Exit codes:

- `0`   → success (or `--help` / `doctor` / `-v`).
- `2`   → usage / missing command / missing required `--reason` (when enforced).
- `77`  → authentication failed after max attempts.
- `127` (or other non-zero) → command failed after successful auth (e.g. missing binary on target).
- `130` → authentication cancelled by user (ABORT, empty password, closed dialog, etc.).

## License

Private / personal tooling — see repository owner policy.

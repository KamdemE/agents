# k-project — Project Init: Bash/Shell (no package manager)

For pure shell scripts, CLI wrappers, or systemd-managed tools with no `uv`/`npm`/`bun`:

```
<project-name>/
├── <scripts>.sh         # Main scripts at root or in a flat structure
├── systemd/             # Unit files (source of truth) — copied by install.sh
│   ├── *.service
│   └── *.timer
├── scripts/
│   ├── install.sh       # Install units, create dirs, enable timer/service
│   └── purge.sh         # Disable + remove units (idempotent)
├── .env.example         # Required env vars (keys only, no values)
├── README.md
├── CHANGELOG.md
└── .agents/
    └── AGENTS.md
```

**Mandatory scripts:**
- `scripts/install.sh` — installs the project (systemd units, directories, symlinks, etc.)
- `scripts/purge.sh` — fully removes the project (idempotent, no side effects)

Templates: `k-project/assets/install.sh` and `k-project/assets/purge.sh`.
Both must be kept in sync with the project as it evolves.
For simple projects (no `systemd/`), scripts can live at project root instead of `scripts/`.

**Makefile:** use `k-git/assets/Makefile.git` as base — includes `install`, `purge`, `log`, `status`, and `run` targets.

**`make status`** → `systemctl status <project>.service <project>.timer` (NOT git status — use `git-status` for that).
**`make run`** → run `<main-script>.sh` via **shared tmux** if it needs elevation; otherwise normal shell.
**`make install`** → `make install` only — privilege stays in install targets; KπX approves `sudo` in tmux when needed (`k-tmux`). Never `sui` (deprecated). Running the whole Makefile as root pollutes `.git/` via `git rev-parse` in Makefile variables.

**Machine-specific config** (excludes, paths) that varies per deployment must go in a gitignored conf file (e.g. `excludes.conf`) rather than being hardcoded in scripts. Ship an `.example` variant tracking the expected keys.

**Logging:** use `StandardOutput=journal` in systemd units — do **not** create a custom `logs/` directory or `tee` pipeline. Log access via `journalctl -u <project>`. Expose this in the Makefile as a `log` target:
```makefile
log:  ## Show recent logs (journald)
	@journalctl -u <project> -n 50 --no-pager
```
Document the `make log` / `journalctl` commands in the README — that is the only log admin needed.

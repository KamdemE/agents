# k-final Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- `make check` being green is necessary but not sufficient for `.agents` closure; run a final `rg` sweep for hardcoded home paths (`/home/<user>`, `~/`) and operational raw-`sudo` examples before the commit/push step.
- **Sovereign Installation Lessons**: 
    - Always use `REAL_HOME` and `REAL_USER` (detected via `getent` / `SUDO_USER`) in Makefiles to ensure path resolution remains correct under elevation.
    - `uv tool install` must specify `--tool-bin-dir $(REAL_HOME)/.local/bin` to prevent binary placement in `/root`.
    - Explicitly fix ownership of user resources created by root (data dir, log dir, and symlinks in `.local/bin` using `chown -h`).
    - Privileged installs:  runs `make install` steps needing `sudo` via **shared tmux** (`k-tmux`); remove internal `sudo` from Makefile targets. **`sui` deprecated** for agents.

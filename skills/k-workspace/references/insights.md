# k-workspace Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- **`make push` + Permission denied on `refs/remotes/*.lock` inside a submodule:** often **root-owned** files under `$HOME/Work/sh/<submodule>/.git` (e.g. after a root-driven git maintenance). One-shot fix: `sui -r "Restore user ownership on submodule .git metadata after root git ops"` then `chown -R "$USER:$USER" $HOME/Work/sh/backup_restore/.git $HOME/Work/sh/clean/.git $HOME/Work/sh/bw_env/.git` (adjust list to affected trees only).
- **`uv run pytest` can fail with `Failed to spawn: pytest` even when the project venv is present:** use `uv run python -m pytest ...` as the reliable fallback when the console-script entrypoint is not exposed on PATH.
- **Ubuntu boot-notification storm can be multi-cause but deterministic:** if startup shows repeated crash popups, check `/var/crash` plus `systemctl --failed` and `systemctl --user --failed` first; on KpihX laptop, top recurrent roots were Bitwarden Electron sandbox mode (`/opt/Bitwarden/chrome-sandbox` must be `root:root` + `4755`), a broken hourly Fluid trigger path in `/etc/fluid/continuity/bin/backup-trigger.sh`, and user Hypr services (`hypridle`/`hyprsunset`) crashing outside Hyprland sessions.

|# k-optim Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- **Homelab dispatcher path:** `$HOME/Work/Homelab/sh/` is stale on this workstation — use `$HOME/Work/Labs/Homelab/sh/hsh` when `hsh` is missing from PATH.
- **Phoenix backup false-negative:** `backup_workstation.sh` uses `mkdir -p || exit 1`; if the archive folder path is occupied by a non-directory, `journalctl` shows `mkdir: Already exists` even when the parent mount looks fine — always `ls -la` the exact destination component before blaming automount.
- **Telegram CLI in agent shells:** `tg bots` may be empty until `TELEGRAM_*_TOKEN` vars are injected — use `tg send --bot …` (not `tg user send`) for bot-origin reports; fall back to notifying  if tokens are absent.
- **QMD collection drift (2026-05-24):** After repo moves, `index.yml` paths can silently break (`_Labs` vs `Labs`). Run `$HOME/.agents/skills/k-qmd/scripts/check_collections.sh` — also auto-runs in weekly `auto_clean.sh` and `ksh status`.
- **Home debris patterns (2026-05-22):** stray shell typo dir `` `${XDG_STATE_HOME:-$HOME` ``, empty `CascadeProjects`/`mkdir`/`results`, post-purge Cursor `globalStorage/backups/`, Zed `backups/`, `ai_dispatcher/tmp/ollama*.zst`.
- **Deleted-image recovery (2026-05-26):** After Trash empty, GNOME `recently-used.xbel` + `~/.cache/thumbnails/` recover **previews with original names** without sudo. PhotoRec 7.2 `/cmd`: never use `jpeg`/`webp`/`heic`; keep `/cmd` on one line; output may land in `photorec.1` not `photorec/`. `extundelete` fails on mounted `/`. Sudo recovery: **tmux `default:0.0` only — no split-window**.
- **2026-05-27 optimization audit:** `/var/log` shows normal syslog rotation (max 107M gzip), journald 120M, root fs 212G/276G (81%). No log consumption issues. Governance audit failed: bundled `references/sexemodel-insights.md` not mentioned in `k-browser/SKILL.md` under Provenance & Quality. ksh command unavailable (PATH issue or service not running). Cleanup stack scripts exist but require manual intervention when automated dispatchers are unreachable.
- **Backup mount trap (2026-07-21):** `backup_workstation.sh` tar traversed rclone mounts (Gdrive, Gdrive, Deep-PC6) as local dirs → archive ballooned to 434 GiB instead of 84 GiB, stalled 3 days with 3.9GB RAM. Fix: `_find_mounts_under()` function detects all mount points under `$USER_HOME` and `/etc` via `findmnt -l` (not `findmnt -R` — `/home/` is not a mount point) and excludes them with `--exclude`. Always preview tar before long backups: `tar cf /dev/null ...` or `tar -a ...` dry run. 
- **Interface purges (2026-08-20):** remove wrapper symlinks, persistent local state, registry entries, and editor debris together; then distinguish intentional historical logs from active references with identifier-specific `plocate` and `rg` sweeps.
- **Kernel runtime logging (2026-08-24):** `.agents/` is configuration and operational knowledge, never a runtime log sink. Let the owning operating system retain, rotate, and query service output through its native logging facilities.

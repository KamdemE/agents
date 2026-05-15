# k-optim Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- **Homelab dispatcher path:** `$HOME/Work/Homelab/sh/` is stale on this workstation — use `$HOME/Work/KpihX-Labs/Homelab/sh/hsh` when `hsh` is missing from PATH.
- **Phoenix backup false-negative:** `backup_workstation.sh` uses `mkdir -p || exit 1`; if the archive folder path is occupied by a non-directory, `journalctl` shows `mkdir: Already exists` even when the parent mount looks fine — always `ls -la` the exact destination component before blaming automount.
- **Telegram CLI in agent shells:** `tg bots` may be empty until `TELEGRAM_*_TOKEN` vars are injected — use `tg send --bot …` (not `tg user send`) for bot-origin reports; fall back to notifying KπX if tokens are absent.

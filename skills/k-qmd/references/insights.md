# k-qmd Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- **Presentation collection 0 files (2026-05-24):** After Homelab move to `$HOME/Work/KpihX-Labs/`, `index.yml` still pointed at the old typo path `KpihX_Labs` (underscore). Symptom: `qmd collection list` shows `Files: 0` for `presentation`. Fix: set path to `$HOME/Work/KpihX-Labs/Homelab/presentation`, then `qmd update presentation` + `qmd embed presentation`. Always verify with `qmd ls presentation` and a scoped search before trusting the collection.
- **Automated drift detection (2026-05-24):** Run `$HOME/.agents/skills/k-qmd/scripts/check_collections.sh` (also in `ksh status` and `auto_clean.sh` Telegram report). It compares `index.yml` paths + on-disk doc counts vs QMD file counts; flags `EMPTY_INDEX` and `MISSING_PATH`.
- Initial baseline created automatically from insights governance standard.

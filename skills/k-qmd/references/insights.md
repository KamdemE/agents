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
- **better-sqlite3 Node mismatch (2026-05-31):** After npm global reinstall or Node upgrade, QMD may fail with `ERR_DLOPEN_FAILED` (NODE_MODULE_VERSION 137 vs 127). `npm rebuild -g @tobilu/qmd` alone does NOT fix it — the native module path is wrong. Fix: `npm install -g @tobilu/qmd@<version> --force`. Verify with `qmd status` showing GPU and collections. The `check_collections.sh` script reports `UNKNOWN_QMD` for all collections when QMD is broken — this is a false positive, not a real config drift.
- **Embed warning then clean rerun (2026-05-25):** After kernel commit, manual `qmd embed agents` can show `Embedded 0 chunks` + `N chunks failed` while the post-commit hook embed runs in parallel (`/tmp/qmd-embed-agents.log`). If the next `qmd embed agents` prints `All content hashes already have embeddings` and `qmdr query` hits the collection, treat as **healthy** — no `--force` needed. Persistent failures: check Vulkan (`qmd status` GPU), avoid parallel embeds, then one explicit `qmd embed agents`.
- Initial baseline created automatically from insights governance standard.
- **Standalone QMD hook copies (2026-08-24):** The local post-commit hooks for Homelab/presentation, techskills, and k_ai are executable copies of `references/post-commit-hook.sh`, not `.agents` symlinks and not `links.jsonc` entries. Update each copy deliberately when the template changes.

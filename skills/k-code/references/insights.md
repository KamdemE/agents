# k-code Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- Cursor agent conversation recovery does not live in the VSCode-style `User/workspaceStorage` tree: use `$HOME/.cursor/projects/<workspace-slug>/agent-transcripts/<session-id>/<session-id>.jsonl`, and inspect sibling `agent-tools/` files when the thread references fetched web pages or tool artifacts.
- **2026-05-15 (Cursor install):** Migrated off AppImage extract (`~/Applications/cursor-app`, `~/.local/bin/cursor --no-sandbox`) to official `.deb` (`/usr/bin/cursor`). Old path caused perpetual in-app update prompts because the launcher still ran 3.0.16 while `dpkg` had 3.4.20. Do not recreate `install_cursor.sh` or a user `cursor.desktop` override.

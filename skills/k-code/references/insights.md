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
- **2026-05-16 (Antigravity + Continue):** Treat Google Antigravity as the VS Code fork that already symlinks to `$HOME/.config/Code/User/*` via `sync_agy.sh`. Continue reads global YAML at `$HOME/.continue/config.yaml` and resolves `${{ secrets.NAME }}` from `$HOME/.continue/.env` (preferred for GUI launches) in addition to workspace `.env`. For Bitwarden → IDE, either populate `MISTRAL_API_KEY` in that file securely or source `$HOME/.kshrc` before `antigravity` (the bootstrap desktop entry + `--launch` path does both). Never store raw provider keys inside YAML checked into git; rotate any key that ever lived in plaintext config or editor history.

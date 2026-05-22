# k-codex Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- Codex remote HTTP MCP auth is configured with `bearer_token_env_var = "ENV_NAME"` next to `url = "https://.../mcp"`; the CLI equivalent is `codex mcp add <name> --url <url> --bearer-token-env-var <ENV_NAME>`.
- **Shared tmux gate (2026-05-18):** `sui` deprecated. For `sudo`/SSH, use `k-tmux` — poll pane **≥30s** before chat handoff; only then give `tmux attach` + full instructions.
- Password prompts are not stop conditions before 30s — keep `capture-pane` looping.

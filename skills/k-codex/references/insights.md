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
- When KπX explicitly requests a shared interactive tmux workflow, a password prompt is not a stopping point. Keep polling the pane and resume automatically after KπX authenticates instead of ending the turn on the prompt.

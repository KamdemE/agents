# k-git Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- If `SSH_AUTH_SOCK` points to `$HOME/.bitwarden-ssh-agent.sock` and `ssh-add -l` returns `Error connecting to agent: Connection refused`, the socket path existing is **not** enough: Bitwarden Desktop / its SSH agent is not actually serving yet, so `git push` will still fail with `Permission denied (publickey)`.

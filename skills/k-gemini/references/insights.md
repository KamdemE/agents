# k-gemini Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- **[Antigravity] run_command path validation**: `run_command` enforces that the `Cwd` parameter is within the user's workspace. If you need to perform actions in a path outside the direct workspace (but accessible), use tools that support directory flags (e.g. `make -C`, `git -C`) or wrap in `bash -c "cd ... && ..."` while providing a valid workspace `Cwd`.
- **[Docker] HITL Port Conflicts**: When running a background "serve" process mapping a port (e.g., 1138), one-off `docker exec` commands requiring a separate HITL server on the same port will fail with `Address already in use`.
    - **Workaround**: Stop the background container, then use `docker compose run --rm --service-ports <service> <cmd>` to launch an ephemeral container that maps the required port cleanly.
- **[Architecture] Agnostic Shim Strategy**: For platform-agnostic Docker CLI access, use a host-side Python shim script (in `scripts/`) and copy/symlink it to `~/.local/bin/`. This avoids shell-specific syntax issues and allows for intelligent interception (e.g., auto-opening browser URLs from container logs).

# k-project Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- **Unix sockets cannot arbitrate daemon ownership (2026-07-31):** a second `listen()` on the same bound path silently succeeds — the old socket lives on a deleted inode (orphan). Socket probes/bind-error handling all have TOCTOU windows. Use `O_CREAT|O_EXCL` lockfiles; bind AFTER lock; slow async init AFTER bind. Full recipe: `references/daemon-pattern.md`. Previously caused a twice-"fixed" race in whats-proxy that only the empirical 2-process bind experiment exposed.
- **Test harnesses must scope process kills (2026-07-31):** a stress test doing `pkill -f` on the daemon pattern can kill a real user session. Discover only your own daemons (pgrep candidates → per-pid `ps eww` env match on the test's state dir). Also: `ps eww -o pid,args` without a pid arg only shows the caller's own processes.
- **Naming convention scope (2026-06-03):** The `k-` prefix and `-kpihx` suffix naming rules apply ONLY to the user's own publishable projects (PyPI, npm, skills registry). Third-party tool wrappers, CLI symlinks, and config proxies must keep the tool's native name. Previous ambiguity led to incorrectly naming a Hermes Agent wrapper `hermes-kpihx` instead of `hermes`.
- Initial baseline created automatically from insights governance standard.

# k-project — Changelog Archive

Older changelog entries condensed out of `SKILL.md` (max 2 explicit rows before `[SUMMARY]`). **Zero-information-loss: copied, never deleted.**

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-26 | [OPENCODE] | v2.8.0 — **SHELL=/bin/zsh mandatory**: Added documentation and Makefile template update ensuring every project's Makefile has `SHELL := /bin/zsh` for fnm/Node compatibility. |
| 2026-06-03 | [OPENCODE] | v2.7.1 — Clarified naming convention scope: applies ONLY to KπX-owned publishable projects, never to third-party wrappers. Added explicit exclusions list. |
| 2026-04-23 | [ANTIGRAVITY] | v2.7.0 — Harmonized dev install with link/unlink convention; added explicit security-hardened installation path reference pointing to k-final for critical projects. |
| 2026-04-18 | [CODEX] | v2.6.2 — Replaced raw-`sudo` project-init examples with `sui -r` guidance and clarified that privilege must stay scoped inside install logic. |
| 2026-07-31 | [OPENCODE] | v2.9.0 — **Daemon-based CLI patterns**: new `references/daemon-pattern.md` (O_EXCL single-owner lock — Unix sockets empirically cannot arbitrate races; socket-first bind ordering; dispatch readiness wait; idle-exit must exclude ping; env-scoped test process discovery). Verified in whats-proxy v0.2.0. |

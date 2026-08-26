# k-project — Changelog Archive

Older changelog entries condensed out of `SKILL.md` (max 2 explicit rows before `[SUMMARY]`). **Zero-information-loss: copied, never deleted.**

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-14 | [COLAB] | v2.10.0 — **Config Standard (JSONC)**: KπX config-file standard is now **JSONC** (JSON + comments) for `.agents/` config assets and non-code config; `config.py`/`config.ts` (plain, no import) for code projects; `.env` for secrets. Documented in Architecture Philosophy. |
| 2026-07-26 | [OPENCODE] | v2.8.0 — **SHELL=/bin/zsh mandatory**: Added documentation and Makefile template update ensuring every project's Makefile has `SHELL := /bin/zsh` for fnm/Node compatibility. |
| 2026-06-03 | [OPENCODE] | v2.7.1 — Clarified naming convention scope: applies ONLY to KπX-owned publishable projects, never to third-party wrappers. Added explicit exclusions list. |
| 2026-04-23 | [ANTIGRAVITY] | v2.7.0 — Harmonized dev install with link/unlink convention; added explicit security-hardened installation path reference pointing to k-final for critical projects. |
| 2026-04-18 | [CODEX] | v2.6.2 — Replaced raw-`sudo` project-init examples with `sui -r` guidance and clarified that privilege must stay scoped inside install logic. |
| 2026-07-31 | [OPENCODE] | v2.9.0 — **Daemon-based CLI patterns**: new `references/daemon-pattern.md` (O_EXCL single-owner lock — Unix sockets empirically cannot arbitrate races; socket-first bind ordering; dispatch readiness wait; idle-exit must exclude ping; env-scoped test process discovery). Verified in whats-proxy v0.2.0. |
| 2026-08-15 | [COLAB] | v2.11.0 — **Template → gitlab URL unification**: updated `## Templates` — `assets/pyproject.toml` + `assets/config.py` are the source of truth; external repos (techskills/𝛱/TechSkills `templates/`) that referenced them via local symlinks were unplugged 2026-08-15 and now use the gitlab URL `https://gitlab.com/kpihx/agents/-/blob/main/skills/k-project/assets/<file>` instead. |
| 2026-08-15 | [COLAB] | v2.12.0 — **Proxy relocation reference updated**: `references/daemon-pattern.md` path updated (`~/KpihX-Labs/whats_proxy/` → `~/KpihX-Labs/proxies/whats-proxy/`) after the `*_proxy` family moved into `proxies/` and aligned to kebab-case naming. |

# Rules Index — Quick Reference

> Load this file to know WHICH rule file to read for a given scenario.

## Rule Files

| File | Covers | Read when |
|------|--------|-----------|
| `response-format.md` | Footer sections, emoji-led format, interaction style | EVERY response you send |
| `file-governance.md` | EN-only files, `$HOME` paths, single source of truth | ANY file operation |
| `audit-commands.md` | `make check`, `uv`, never `pip` | BEFORE finalizing any work |
| `tool-discipline.md` | tmux sudo gate, read-before-edit, no shell file ops, **help reflex** (stuck/spinning → open a peer via `help_open` for a **second opinion**, NOT for task delegation), **question tool reflex** (any doubt → ask KπX) | ANY bash/tool usage |
| `skill-governance.md` | Skill creation, version bumps, changelog, no duplication | Before editing ANY `k-*` skill |
| `skill-infra-scope.md` | Cross-infrastructure skill design, OS-specific refs pattern | Creating or updating ANY `k-*` skill with OS-specific content |
| `k-context-hygiene.md` | Session log, active projects, zero-deletion, k-context updates | EVERY session, after any significant work |
| `agent-registry.md` | Symlink map, per-agent config paths | When setting up or debugging an agent runtime |
| `whats-up.md` | Status digest protocol, domain ordering | When KπX asks "what's up" |
| `hermes-governance.md` | Hermes daemon isolation, cron safety | Before any Hermes work |
| `proxies-reflex.md` | Dedicated proxy-first routing; browser-proxy as the universal web-UI fallback; `--help`-only and secrets boundary | ANY proxy-mediated or browser-driving task |
| **🔴 browser-proxy MANDATORY** | **BEFORE any `browser-proxy do` call: (1) load `k-browser` skill, (2) check `k-browser/references/sites/<domain>.md` for the target site, (3) check `k-browser/scripts/presets/` for an existing preset that covers the task — never redo manually what a preset already automates. NEVER navigate blind.** | EVERY browser-proxy task |

## Who Reads What

| Agent | Must read |
|-------|-----------|
| **Colab** (primary) | All rules (enforced through checker) |
| **Explore** (primary) | `response-format`, `file-governance` |
| **executor** | `file-governance`, `audit-commands`, `tool-discipline` |
| **pragmatic-checker** | **ALL listed rules** — mandatory before every check pass |
| **curator** | `agent-registry`, `skill-governance`, `k-context-hygiene` |
| **intent-guardian** | `k-context-hygiene` |
| **fact-verifier** | `file-governance` (for source indexing) |

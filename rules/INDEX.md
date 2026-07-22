# Rules Index — Quick Reference

> Load this file to know WHICH rule file to read for a given scenario.

## Rule Files

| File | Covers | Read when |
|------|--------|-----------|
| `response-format.md` | Footer sections, emoji-led format, interaction style | EVERY response you send |
| `file-governance.md` | EN-only files, `$HOME` paths, single source of truth | ANY file operation |
| `audit-commands.md` | `make audit`, `make check`, `uv`, never `pip` | BEFORE finalizing any work |
| `tool-discipline.md` | tmux sudo gate, read-before-edit, no shell file ops | ANY bash/tool usage |
| `skill-governance.md` | Skill creation, version bumps, changelog, no duplication | Before editing ANY `k-*` skill |
| `k-context-hygiene.md` | Session log, active projects, zero-deletion, k-context updates | EVERY session, after any significant work |
| `agent-registry.md` | Symlink map, per-agent config paths | When setting up or debugging an agent runtime |
| `whats-up.md` | Status digest protocol, domain ordering | When KπX asks "what's up" |
| `hermes-governance.md` | Hermes daemon isolation, cron safety | Before any Hermes work |

## Who Reads What

| Agent | Must read |
|-------|-----------|
| **Colab** (primary) | All rules (enforced through checker) |
| **Explore** (primary) | `response-format`, `file-governance` |
| **executor** | `file-governance`, `audit-commands`, `tool-discipline` |
| **pragmatic-checker** | **ALL 9 rules** — mandatory before every check pass |
| **curator** | `agent-registry`, `skill-governance`, `k-context-hygiene` |
| **intent-guardian** | `k-context-hygiene` |
| **fact-verifier** | `file-governance` (for source indexing) |

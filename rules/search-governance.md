# Search Tool Preference — plocate/locate

**Scope:** All agents interacting with the KπX filesystem

## Mandate

**Agents MUST prefer `plocate`/`locate` over `find`/`grep`/Glob for file search.**

- `locate <pattern>` → milliseconds (pre-built index)
- `find / -name <pattern>` → seconds to minutes (full scan)
- Typical speedup: **~100×**

## When to use locate

| Situation | Tool |
|-----------|------|
| Find a file anywhere on disk | `locate` |
| Find a file by name pattern | `locate -b <basename>` |
| Case-insensitive search | `locate -i <pattern>` |
| Regex search on path | `locate --regex '<pattern>'` |
| Limit results | `locate -l 20 <pattern>` |

## When NOT to use locate (fall back to `find`)

- **Real-time**: files created or renamed since last `updatedb` won't appear
- **Very recent files**: prefer `find` with narrow scope (e.g. `find /home/kpihx/Work/`)
- **Readability edge**: `locate` respects file permissions

## Setup

Install + DB setup: `skills/k-clis/references/plocate.md`

## Enforcement

Agents that default to `find`/`grep`/Glob for general file search are in violation of this rule.

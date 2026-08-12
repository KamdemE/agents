# Search Tool Preference — plocate

**Scope:** All agents interacting with the KπX filesystem

## Mandate

**Agents MUST prefer `plocate` (never `locate` — plocate's DB is auto-updated daily) over `find`/`grep`/Glob for file search.**

- `plocate <pattern>` → milliseconds (pre-built index)
- `find / -name <pattern>` → seconds to minutes (full scan)
- Typical speedup: **~100×**

## When to use plocate

| Situation | Tool |
|-----------|------|
| Find a file anywhere on disk | `plocate` |
| Find a file by name pattern | `plocate -b <basename>` |
| Case-insensitive search | `plocate -i <pattern>` |
| Regex search on path | `plocate --regex '<pattern>'` |
| Limit results | `plocate -l 20 <pattern>` |

## When NOT to use plocate (fall back to `find`)

- **Real-time**: files created or renamed since last `updatedb` won't appear
- **Very recent files**: prefer `find` with narrow scope (e.g. `find /home/kpihx/Work/`)
- **Readability edge**: `plocate` respects file permissions

## Setup

Install + DB setup: `skills/k-clis/references/plocate.md`

## Complementary tools

In addition to `plocate` for file search, agents MUST use the following code analysis tools when relevant:

| Tool | When to use | How |
|------|-------------|-----|
| **opencode-ast_outline** | Before reading any file >50 lines — get its structure first | Plugin (always fresh, zero config) |
| **opencode-ast_get_symbol** | Find a specific symbol (function, class, variable) definition | Plugin |
| **opencode-ast_get_definitions** | Get definitions of all symbols at a location | Plugin |
| **opencode-ast_references** | Find references to a symbol in the same file | Plugin |
| **loom query** | Cross-session code search — find symbols across indexed projects | MCP (needs `loom analyze .` first) |
| **qmd** / **qmdr** | Search KπX knowledge base (past sessions, skills, configs) | CLI (see `k-qmd` skill) |

## Enforcement

Agents that default to `find`/`grep`/Glob for general file search without first considering `plocate` or the code analysis tools above are in violation of this rule.

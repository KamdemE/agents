# Search Tool Preference — plocate

**Scope:** All agents interacting with the KπX filesystem

## Mandate

**Agents MUST prefer `plocate` (never `locate` — plocate's DB is auto-updated daily, but remember to run `sudo updatedb` in tmux (k-tmux) if the database seems out of date, especially after massive filesystem restructures, moves `mv`, or copies `cp`) over `find`/`grep`/Glob for file search.**

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

- **Real-time**: files created or renamed since last `updatedb` won't appear (run `sudo updatedb` in tmux (k-tmux) if the database seems out of date, especially after massive filesystem restructures, moves `mv`, or copies `cp`)
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
| **loom** | Cross-session code references on GIT repos ONLY (never non-git dirs): callgraph ("who calls X"), blast-radius before refactors, dead-code sweeps, cross-session delta | MCP tools or CLI (see `k-loom`; needs `loom analyze .` first) |
| **qmd** / **qmdr** | Search KπX knowledge base (past sessions, skills, configs) + semantic/textual md content | CLI (see `k-qmd` skill) |

## Loom reflex on git projects (MANDATORY)

🔴 **Loom is GIT-PROJECTS-ONLY (KπX directive 2026-08-24): it applies to GIT repos EXCLUSIVELY — NEVER `loom analyze` or query a non-git directory.** On any GIT project containing code, agents MUST use the Loom layer (MCP tools or `loom` CLI) — not just grep/read.

1. **Session start on an indexed project:** MCP `get_status` → if stale or missing index → `loom sync`, re-check; propose/run `loom analyze .` if still unindexed.
2. **Resume work:** MCP `get_delta` — see ONLY what changed since the last session; never re-read unchanged functions.
3. **Callgraph questions = Loom FIRST:** "who calls X", "what breaks if I change X" (`callers`/`callees`/`blast-radius`), dead-code sweeps (`dead-code`). Grep only confirms afterwards.
4. **End of meaningful passes:** persist understanding via MCP `store_understanding` so future sessions skip re-reads.
5. **Layering:** `plocate` = syntactic FILE search · `opencode-ast` = fresh structure of ONE file · **Loom** = persistent cross-file/cross-session relations · `qmd` = semantic/know-how (md, past sessions).
6. Freshness caveat: after heavy un-committed edits run `loom sync` before trusting the graph; AST/grep stay the source of truth for un-synced edits.

## Semantic / Know-how questions → `qmd query` (MANDATORY)

🔴 **For SEMANTIC questions — understanding the KπX ecosystem, its history, past sessions/passes, or "how did we do X before" WITHOUT clear keywords — agents MUST use `qmd query` (or `qmdr`).**

| Situation | Tool |
|-----------|------|
| Understand the ecosystem / how things connect | `qmd query` (BM25+vector hybrid over past sessions, skills, configs) |
| Recover history / past sessions / previous passes on a topic | `qmd query` |
| Semantic questions WITHOUT exact keywords ("pourquoi", "comment on a fait", know-how) | `qmd query` |
| Find a specific fact you know the wording of | `qmd query` with that wording |

- **Never guess or answer from memory alone** for ecosystem/history questions — run `qmd query` first (see `k-qmd` skill for CLI usage and collections).
- `qmd query` is the FIRST tool for semantic/know-how questions; `plocate` stays for file search; `loom` for cross-session code search; `opencode-ast` for fresh file structure.
- Same rule enforced in `AGENTS.md` → Code search workflow.

## Enforcement

Agents that default to `find`/`grep`/Glob for general file search without first considering `plocate` or the code analysis tools above are in violation of this rule.

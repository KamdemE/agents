# Loom MCP — NON-RECOMMENDED (removed 2026-08-24)

> 🔴 **STATUS: REMOVED / NON-RECOMMENDED.** The `loom` MCP server (`loom-mcp`) was removed from
> `opencode.jsonc` on 2026-08-24 by KπX directive. **NEVER re-add it, NEVER call loom via MCP tools,
> NEVER mention loom MCP in rules/skills/agents — always the `loom` CLI binary.**
> This file is the historical registry: what the MCP exposed and its exact CLI equivalent.

## Why removed

- stdio model = 1 process per AI session → 16 concurrent instances observed ≈ **790M RSS total**, 0% CPU each.
- The `loom` CLI opens the SQLite DB read-only per invocation and exits — **~0 resident RAM**.
- All MCP data is reachable from the CLI or direct read-only `sqlite3` queries on `~/.loom/projects/<name>.db`.

## MCP tool → CLI equivalent (authoritative table)

| MCP tool | CLI equivalent |
|----------|----------------|
| `_status` (Fraîcheur) | `loom stats --db ~/.loom/projects/.agents.db` + `stat ~/.loom/projects/.agents.db` (mtime = last_indexed) + `ps aux \| rg loom` |
| `list_projects` | `ls -lh ~/.loom/projects/*.db` + for each DB: `sqlite3 "$db" "SELECT count(*) FROM nodes"` |
| `get_delta` (what changed since session) | `git diff --name-only HEAD~1 HEAD` crossed with `SELECT path FROM files WHERE content_hash != <sha256>` (WAL) — this is what `loom sync` does |
| `start_session` | no CLI — just a marker: `date -Iseconds > ~/.loom/last_session` (for get_delta bookkeeping) |
| `get_context` (full packet) | `loom query "<symbol>" --db ... --limit 1` + `loom callers <target> --db ...` + `loom callees <target>` combined |
| `get_neighbors` (generic traversal) | `sqlite3 ~/.loom/projects/.agents.db "SELECT * FROM edges WHERE source='X' OR target='X' LIMIT 10"` — direct graph access |
| `shortest_path` | recursive `sqlite3` `WITH RECURSIVE` over `edges WHERE kind='CALLS'` (no direct CLI) |
| `god_nodes` (Top in-degree) | `sqlite3 ~/.loom/projects/.agents.db "SELECT target, count(*) AS c FROM edges WHERE kind='CALLS' GROUP BY target ORDER BY c DESC LIMIT 10"` |
| `get_surprising_connections` | `sqlite3` + join on `nodes.community_id` (Loom score = peripheral→hub) — no CLI, direct WAL query |
| `search_code` | `loom query "<text>" --limit N` |
| `get_architecture` | `loom stats` + `loom communities` + `loom context` combined |
| `get_community` | `loom communities` (cluster listing), then sqlite join `nodes.community_id` for members |
| `get_blast_radius` | `loom blast-radius <name>` |
| `suggest_questions` / `get_work_plan` | `loom dead-code` + `loom communities` + manual synthesis (no exact equivalent) |
| `store_understanding` / `store_tags` | NO CLI equivalent — write findings into skills/context docs instead |
| `get_savings` | `loom savings` |
| `get_status` (live indexing) | `loom stats` + DB mtime |

## Historical RAM measurement (2026-08-24)

16 `loom-mcp` stdio processes: ~3M to ~93M RSS each, ~790M cumulative.
HTTP-gateway alternative (shared daemon ≈120M) was studied but rejected: extra service + port +
config drift; CLI gives ~0M with zero infrastructure. Decision: **CLI only**.

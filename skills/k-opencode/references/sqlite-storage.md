# Session Storage (SQLite)

OpenCode stores all conversation history in a single SQLite database, not JSON files.

- **Database:** `$HOME/.local/share/opencode/opencode.db`
- **Size:** ~525 MB (as of 2026-07-21, ~15K messages across ~200 sessions)
- **WAL mode:** `opencode.db` + `opencode.db-wal` + `opencode.db-shm`

## Schema (core tables)

```sql
-- One row = one conversation
session(id, project_id, parent_id, slug, directory, title, version,
        time_created, time_updated, time_compacting, time_archived,
        workspace_id, path, agent, model,
        cost, tokens_input, tokens_output, tokens_reasoning,
        tokens_cache_read, tokens_cache_write, metadata)

-- One row = one message turn
session_message(id, session_id, type, time_created, time_updated,
                seq, data)
```

- `session.data` → `metadata` JSON column for extra session-level info.
- `session_message.data` → full message JSON text (tool calls, responses, file contents — the bulk of the 525 MB).
- `session_message.seq` → monotonically ordered per session.
- `session_message.type` → e.g. `"user"`, `"assistant"`, `"tool"`.
- All session data is cascade-deleted when a `session` row is removed.

## Query examples

```bash
# Session count, token totals, model usage
sqlite3 ~/.local/share/opencode/opencode.db "
  SELECT model, count(*) as sessions,
         sum(tokens_input) as total_input,
         sum(tokens_output) as total_output,
         sum(cost) as total_cost
  FROM session GROUP BY model ORDER BY total_cost DESC;"

# Recent sessions with message counts
sqlite3 ~/.local/share/opencode/opencode.db "
  SELECT s.id, s.title, s.model, s.time_created,
         (SELECT count(*) FROM session_message sm WHERE sm.session_id = s.id) as msgs
  FROM session s ORDER BY s.time_created DESC LIMIT 10;"
```

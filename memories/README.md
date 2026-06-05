# Memories — Shared Agent State

memories/ is the shared mutable state between agents. Every agent reads and writes here.
Think of it as the "RAM" of the agent system — ephemeral, session-scoped, never committed.

## Structure

| File | Who writes | Who reads | Description |
|------|-----------|-----------|-------------|
| `current-intent.md` | intent-guardian | executor, all agents | Current goal, project, decisions |
| `session-state.md` | any agent | all agents | Ephemeral session context |
| `learned-patterns.md` | any agent (append) | all agents | Durable cross-session patterns |

## Rules

1. Append-only for durable state (never delete, only add)
2. Session-scoped for ephemeral state (reset each session)
3. Files are plain markdown — no special format needed
4. Always prefix entries with `[agent-name]` for traceability

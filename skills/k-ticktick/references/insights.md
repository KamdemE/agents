# k-ticktick Insights

Purpose: durable behavioral memory to improve proactive planning support and reduce corrections.

## Planning Style

- Prefer concise overviews before deep dives.
- Expect combined calendar + tasks summaries for operational planning.
- Prefer practical next actions over abstract commentary.

## Usage Patterns

- Common overview flow: week snapshot, then today's tasks, then today's events, then upcoming/overdue.
- Planning context spans multiple folders (academic, personal, tech/dev, homelab, flow).
- User preference: when asking for an overview, use live MCP data (not static skill memory) and report concrete counts.

## Tooling Patterns

- Use tick-mcp (`http` or `stdio`) for all TickTick reads/writes.
- For writes, verify state after each change due to known V1/V2 silent failure patterns.

## Open Behavior Rules

- Always read this file before composing a planning summary.
- After each TickTick task, append any new reusable pattern (planning preference, categorization preference, correction pattern, recurring priorities).
- End each TickTick task with a full-folder reality check (`SKILL.md` + `references/*.md`) and update proactively if drift is detected.


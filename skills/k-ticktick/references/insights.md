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
- For academic milestones (PSC), prefer `🎓 X/📅 Agenda` for dated deadline/event tracking.
- For deadline-sensitive items, apply reminder triple by default: `-7 days`, `-1 day`, `-1 hour` (`[10080, 1440, 60]`).
- When a precise soutenance date already exists in TickTick, update that task instead of duplicating, and add a separate period-range task only if requested.
- If a dated academic task is found in `🎓 X/✅ Todos`, move it to `🎓 X/📅 Agenda` to keep planning views clean.

## Tooling Patterns

- Use tick-mcp (`http` or `stdio`) for all TickTick reads/writes.
- For writes, verify state after each change due to known V1/V2 silent failure patterns.

## Open Behavior Rules

- Always read this file before composing a planning summary.
- After each TickTick task, append any new reusable pattern (planning preference, categorization preference, correction pattern, recurring priorities).
- End each TickTick task with a full-folder reality check (`SKILL.md` + `references/*.md`) and update proactively if drift is detected.


# k-context General Insights

Purpose: autonomous cross-domain runtime memory to reduce repeated mistakes, repeated dead-end searches, and repeated ineffective actions across sessions.

## Governance (mandatory)

- This file is agent-managed and can be updated autonomously at any time without prior user approval.
- Preferred operations are additive and evolutionary: add, refine, reorganize, and prune stale entries to keep signal high.
- Record only durable, reusable insights (not temporary chatter).
- Every new insight should help avoid a future repeat error, repeat search loop, or repeat failed operation pattern.
- When a skill-specific insight is discovered and the target skill has no `references/insights.md`, create it immediately and write first insights in the same workstream.
- When new insights are added during a task, inform KpihX briefly in the same response.

## Current Seed Insights

- What’s up slices must run as batch deep-dives and stop only after materially complete information coverage.
- For mail-mcp stdio, accented query strings can fail with ASCII codec errors; use ASCII-safe fallback queries and resolve target UIDs with `get_message`.
- For TickTick destination resolution, trust live `workspace_map` names (for example `🎓 X`) over stale naming assumptions.
- For TickTick checklist writes, fallback to markdown checklist content when native checklist creation path fails.
- Historical reference docs inside `$HOME/.agents/` should still respect the `$HOME` generalization rule; normalize `~` and hardcoded `/home/<user>` paths even when the file is archival or visionary.

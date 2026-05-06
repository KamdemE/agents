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
- Workspace naming drift note: current live folder is `🎓 X` (not `Scolaire X` literal). Always resolve destination with `workspace_map` before writing.
- Current stdio behavior note: `create_task` with `checklist_items` can fail with `TaskStatus` runtime error; reliable fallback is creating a normal task then writing markdown checklist boxes in `content`.
- For deadline-sensitive items, apply reminder triple by default: `-7 days`, `-1 day`, `-1 hour` (`[10080, 1440, 60]`).
- For daily prep loops requiring two times per day (morning + evening), a single recurring task can encode both by using due time at evening and dual reminders (example: `20:00` due with reminders `[810, 0]` => `06:30` + `20:00`).
- For exam-day morning reminders (e.g., target 07:30 on a 09:00 slot), keep one timed event at exam time and encode morning alert using `reminder_minutes` offset (`90` for 07:30 when due is 09:00), combined with long-horizon offsets (`10080`, `2880`, `1440`).
- When user asks for a "print-ready synthesis", enrich the main dated task `content` directly (format, CEFR alignment, pitfalls, section strategy) and combine both `-90min` and `0` reminders for the final execution window.
- When a precise soutenance date already exists in TickTick, update that task instead of duplicating, and add a separate period-range task only if requested.
- If a dated academic task is found in `🎓 X/✅ Todos`, move it to `🎓 X/📅 Agenda` to keep planning views clean.
- **Exam/Certification Annotation:** For proctored exam tasks, always include the technical support number and a specific "Environment Warning" if native hardware/OS constraints exist (e.g., "No Linux support"). Add Gdrive archival links for manuals/installers directly in the task content.
- **Course Duo-Task Pattern:** For academic projects with both a submission (Rendu) and an oral (Soutenance), create two separate tasks in `📅 Agenda`. The Rendu task should target the submission deadline (e.g., 23:59), while the Soutenance task tracks the precise oral slot. Cross-link both to a master course note in `📒 Notes` for centralized official instructions.
- **Checklist Allocation:** Distribute "Action Checklist" items logically: Rendu focuses on mechanics (verify Moodle, binôme confirmation), while Soutenance focuses on performance (pitch prep, anticipating questions).

## Tooling Patterns

- Use tick-mcp (`http` or `stdio`) for all TickTick reads/writes.
- For writes, verify state after each change due to known V1/V2 silent failure patterns.

## Open Behavior Rules

- Always read this file before composing a planning summary.
- After each TickTick task, append any new reusable pattern (planning preference, categorization preference, correction pattern, recurring priorities).
- End each TickTick task with a full-folder reality check (`SKILL.md` + `references/*.md`) and update proactively if drift is detected.


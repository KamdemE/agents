# k-ticktick Runtime Log

Purpose: detailed runtime execution log for TickTick operations (different from `SKILL.md` changelog).

## Entry Format

| Timestamp (UTC) | Agent | Channel | Action | Inputs | Outcome | IDs / Links | Notes |
|-----------------|-------|---------|--------|--------|---------|-------------|-------|
| 2026-04-08T11:20:00Z | [CODEX] | tick-mcp http | `week_overview` | days=7 | overview returned | n/a | planning snapshot |
| 2026-04-08T11:20:10Z | [CODEX] | tick-mcp http | `tasks_of_today` | local_date=today | tasks returned | task ids | daily execution view |
| 2026-04-08T11:20:15Z | [CODEX] | tick-mcp http | `events_of_today` | local_date=today | events returned | event ids | daily calendar view |
| 2026-04-08T11:31:50Z | [CODEX] | tick-mcp http | `ticktick_guide` | no args | tool map returned | 71 tools | selected overview workflow |
| 2026-04-08T11:32:05Z | [CODEX] | tick-mcp http | `week_overview` | days=7, limit_per_section=20 | events=0, due=2, overdue=20 | week snapshot | key planning signal |
| 2026-04-08T11:32:06Z | [CODEX] | tick-mcp http | `tasks_of_today` | local_date=today, limit=30 | count=0 | today slice | no scheduled tasks today |
| 2026-04-08T11:32:07Z | [CODEX] | tick-mcp http | `events_of_today` | local_date=today, limit=30 | count=0 | today slice | no timed events today |
| 2026-04-08T11:32:08Z | [CODEX] | tick-mcp http | `upcoming_tasks` | days=7, limit=50 | count=2 | week due list | two upcoming deliverables |
| 2026-04-08T11:32:12Z | [CODEX] | tick-mcp http | `workspace_map` | include_counts=true | 6 folders, 31 projects | structure map | highest active project `🤖 Agent OS` (26) |
| 2026-04-08T11:32:13Z | [CODEX] | tick-mcp http | `overdue_tasks` | limit=20 | count=20 | overdue top20 | recurring overdue backlog detected |
| 2026-04-08T13:10:20Z | [CODEX] | tick-mcp stdio | `workspace_map` | default args | folder/project map returned | folder `🎓 X`, project `📅 Agenda` | destination discovery before writes |
| 2026-04-08T13:10:27Z | [CODEX] | tick-mcp stdio | `query_tasks` | folder=`🎓 X`, query=`PSC soutenance rapport final` | count=3 | found `Soutenance PSC` id `692085ad65701fd391a367c3` | reused existing soutenance date |
| 2026-04-08T13:10:40Z | [CODEX] | tick-mcp stdio | `query_tasks` | query=`Rapport final` in `🎓 X` | no existing PSC report task found | n/a | safe to create new deadline task |
| 2026-04-08T13:10:53Z | [CODEX] | tick-mcp stdio | `create_task` | title=`📘 PSC — Rapport final...`, due=`2026-04-24` reminders `-7d/-1d/-1h` | created | id `69d653dd8f089081627cb56b` | deadline tracked in `🎓 X/📅 Agenda` |
| 2026-04-08T13:11:00Z | [CODEX] | tick-mcp stdio | `update_task` | task=`Soutenance PSC`, reminders `-7d/-1d/-1h` | updated | id `692085ad65701fd391a367c3` | normalized reminders and added context |
| 2026-04-08T13:11:05Z | [CODEX] | tick-mcp stdio | `create_task` | title=`🎤 PSC — Période de soutenances...`, span=`2026-05-01..2026-05-31` reminders `-7d/-1d/-1h` | created | id `69d653e98f08ab5f35b7afdb` | soutenance period added |
| 2026-04-08T13:11:15Z | [CODEX] | tick-mcp stdio | `query_tasks` | query=`PSC rapport final soutenance` | count=5 | ids include new tasks + updated soutenance | post-write verification passed |
| 2026-04-08T13:18:40Z | [CODEX] | tick-mcp stdio | `query_tasks` | folder=`🎓 X`, query=`Soutenance PSC` | found task in `✅ Todos` | id `692085ad65701fd391a367c3` | prepared project move request |
| 2026-04-08T13:18:48Z | [CODEX] | tick-mcp stdio | `move_tasks` | move `Soutenance PSC` from `✅ Todos` to `📅 Agenda` | moved | task id `692085ad65701fd391a367c3` | centralized academic event into agenda project |
| 2026-04-08T13:38:06Z | [CURSOR] | tick-mcp http | `create_task` | title=`PSC — Rediger ma partie rapport final (Overleaf)`, due=`2026-04-11T20:00+02`, project=`🎓 X/📅 Agenda`, prio=5, tags=[PSC,rapport], reminders [-1d,-1h,0] | created | id `69d65a3e8f089081627daec0` | Graph Tool + Heuristic Reranking writing session |


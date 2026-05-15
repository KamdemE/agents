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
| 2026-04-09T02:49:05Z | [CURSOR] | tick-mcp http | `workspace_map`, `query_projects`, `build_recurrence_rule`, `create_task`×3 | destination `🎓 X/📅 Agenda`; windows 13-17 + 20-24 Apr; daily prep reminder 06:30 & 20:00 until 2026-04-25; Moodle URL | created and verified | ids `69d7131c8f08660f9f047377`, `69d7131c8f08110d3a62b582`, `69d713278f08110d3a62b725`; rrule `RRULE:FREQ=DAILY;UNTIL=20260425T235959Z` | user waiting assignment from certification mail UID 8323 |
| 2026-04-09T12:00:00Z | [CURSOR] | TickTick (session) | course calendar sync | `LEN_43314_EP` course note + 3 calendar events (2026-04-24, 2026-05-16, 2026-05-24) | recorded | n/a | timestamp approximate — English course planning |
| 2026-04-13T15:06:00Z | [CODEX] | tick-mcp stdio | `workspace_map`, `create_task`, `get_task_detail` | created Ninja Race event in `🎓 X/📅 Agenda`, due Thu 2026-04-23 with reminder `-1 day` | created + verified | task id `69dd066f8f0855303b63b58f` | user requested Thursday-next-next scheduling with J-1 reminder |
| 2026-04-13T15:17:00Z | [CODEX] | tick-mcp stdio | `query_notes`, `update_task`, `create_task`, `update_task` | patched CSC_43042 course note with exam-material policy; created standalone exam compliance checklist task | note updated + checklist task created | note id `69adf1418f084c504642117b`; checklist task id `69dd08eb8f081c109b747541` | native checklist creation path failed (`TaskStatus` undefined), fallback used: markdown checklist content in standard task |
| 2026-04-13T16:06:42Z | [CODEX] | tick-mcp stdio | `workspace_map`, `create_task` | user requested kickoff task for Dify/CrewAI/AutoGen/LangChain mini-project onboarding next Saturday 15:00 | created + reminders set | task id `69dd14928f0874a239c6d8c7` in `🛠️ Tech & Science/🗂️ Projets` | due `2026-04-18T15:00 Europe/Paris`; reminders `-1 day`, `-1 hour`; includes mini-project brief in content |
| 2026-04-15T12:59:00Z | [CODEX] | tick-mcp stdio | `workspace_map`, `query_tasks`, `update_task`×2, `complete_task`, `get_task_detail`×3 | Linguaskill reschedule normalization after slot confirmation screenshot | updated + verified | main task id `69d7131c8f08660f9f047377`; prep loop id `69d713278f08110d3a62b725`; completed fallback id `69d7131c8f08110d3a62b582` | reminders now include `-7d/-2d/-1d/-90min` for exam and daily `06:30+20:00` loop until 2026-04-30 |
| 2026-04-15T13:15:00Z | [CODEX] | tick-mcp stdio | `get_task_detail`, `update_task`, verify `get_task_detail` | user requested print-ready Linguaskill synthesis + final reminder enrichment | updated + verified | main task id `69d7131c8f08660f9f047377` | added synthesis block (format/CEFR/pitfalls/section strategy) and added at-time final reminder (`TRIGGER:PT0S`) while keeping 07:30 (`-90min`) |
| 2026-05-04T14:11:52Z | [ANTIGRAVITY] | tick-mcp stdio | `create_task` | title=`🚀 Rendu TP Optimisation — Notebook Python`, due=`2026-05-18T23:59`, project=`📅 Agenda`, reminders `-2d/-1d/-1h/-30min` | created | id `69f8a9288f086d028b4d7b74` | tracking Moodle submission |
| 2026-05-04T14:11:53Z | [ANTIGRAVITY] | tick-mcp stdio | `create_task` | title=`🎤 Soutenance TP Optimisation — PC 3`, due=`2026-06-04T15:15`, project=`📅 Agenda`, reminders `-2d/-1d/-1h/-30min` | created | id `69f8a9298f0885d1c6763497` | tracking final oral defense |
| 2026-05-04T14:23:28Z | [ANTIGRAVITY] | tick-mcp stdio | `update_task` | task=`🎤 Soutenance TP Optimisation — PC 3`, due=`2026-06-04T13:15+00` (15:15 local), start=`2026-06-04T13:15+00` | updated | id `69f8a9298f0885d1c6763497` | corrected UTC offset for 15:15 local time in Paris |
| 2026-05-04T14:23:44Z | [ANTIGRAVITY] | tick-mcp stdio | `query_tasks`, `get_task_detail` | verification of Optimisation tasks and note | verified | multiple ids | post-write state check |
| 2026-05-06T14:33:56Z | [ANTIGRAVITY] | tick-mcp stdio | `complete_task` | task=`🇬🇧 Linguaskill confirmé...` | completed | id `69d7131c8f08660f9f047377` | results received (C1), archived in Gdrive_X |
| 2026-05-06T14:33:58Z | [ANTIGRAVITY] | tick-mcp stdio | `complete_task` | task=`📘 PSC — Rapport final...` | completed | id `69d653dd8f089081627cb56b` | final report layout and branding finalized |
| 2026-05-06T14:34:00Z | [ANTIGRAVITY] | tick-mcp stdio | `complete_task` | task=`🇺🇸🇨🇦🇬🇧 4A International...` | completed | id `69adef188f08b6786d8d3cd8` | DRI presentation completed in April |
| 2026-05-06T14:34:05Z | [ANTIGRAVITY] | tick-mcp stdio | `complete_task` | task=`🧪 CSC_43042_EP — TD5...` | completed | id `69d642168f089081627a31a4` | past session from April marked done |

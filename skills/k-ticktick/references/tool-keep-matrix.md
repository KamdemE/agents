# TickTick MCP Tool Keep Matrix

| Tool | Necessary (YES/NO) | Justification |
|---|---|---|
| batch_create_tasks | YES | Efficient multi-item planning writes |
| batch_delete_tasks | YES | Explicitly requested to keep |
| batch_update_tasks | YES | Needed for safe batch edits |
| build_recurrence_rule | YES | Core for recurring planning |
| build_reminder | YES | Core for reminder strategy |
| check_v2_availability | NO | Debug/admin only |
| complete_task | YES | Closure hygiene mandatory |
| create_habit | YES | Explicitly requested to keep |
| create_project | YES | Explicitly requested to keep |
| create_subtask | YES | Common decomposition workflow |
| create_tag | YES | Explicitly requested (`create_tage`) |
| create_task | YES | Core task creation |
| delete_habit | YES | Explicitly requested to keep |
| delete_project | YES | Explicitly requested to keep |
| delete_query_preset | NO | Optional preset management |
| delete_tag | NO | Tag admin optional |
| events_of_today | YES | Core daily agenda |
| full_sync | NO | Explicitly discouraged in skill |
| get_all_tasks | NO | Heavy; usually unnecessary |
| get_completed_tasks | NO | Secondary reporting |
| get_deleted_tasks | NO | Recovery/admin only |
| get_focus_stats | NO | Metrics nice-to-have |
| get_habit_records | NO | Habit-only reporting |
| get_inbox | NO | Optional; query/workspace tools suffice |
| get_productivity_stats | NO | Metrics not core execution |
| get_project_detail | YES | Needed for destination/project validation |
| get_project_tasks | YES | Project-scoped reads are practical |
| get_task_detail | YES | Needed for precise edits/validation |
| get_user_status | NO | Account status only |
| habit_checkin | NO | Habit-only |
| list_columns | NO | Kanban detail non-core |
| list_habit_sections | NO | Habit-only |
| list_habits | YES | Explicitly requested to keep |
| list_project_folders | YES | Destination discovery support |
| list_projects | YES | Destination discovery support |
| list_query_presets | NO | Optional preset management |
| list_tags | NO | Tag admin optional |
| manage_columns | NO | Structural feature not core |
| manage_project_folders | NO | Structural admin, occasional |
| merge_tags | NO | Tag hygiene optional |
| move_tasks | YES | Core reorganization |
| overdue_tasks | YES | Core planning triage |
| priority_dashboard | YES | Useful prioritization snapshot |
| query_agenda | YES | Useful agenda-centric query layer |
| query_folders | YES | Core workspace mapping |
| query_notes | YES | Explicitly requested to keep |
| query_projects | YES | Core workspace mapping |
| query_task_history | NO | Auditing only |
| query_tasks | YES | Core search/verification tool |
| rename_tag | NO | Tag admin optional |
| reopen_task | YES | Needed for corrected closures |
| run_query_preset | NO | Optional convenience layer |
| save_query_preset | NO | Optional convenience layer |
| set_subtask_parent | YES | Needed for subtask reliability |
| stale_tasks | YES | Useful cleanup/prioritization |
| tasks_of_today | YES | Core daily planning |
| ticktick_guide | YES | Tool bootstrap reference |
| upcoming_tasks | YES | Core near-horizon planning |
| update_habit | NO | Habit-only |
| update_project | NO | Structural admin |
| update_tag | NO | Tag admin |
| update_task | YES | Core task lifecycle |
| verified_assign_project_folder | NO | Structural admin, low frequency |
| verified_batch_move | NO | Duplicate family; base tools sufficient |
| verified_create_project | NO | Duplicate family; base tools sufficient |
| verified_move_tasks | NO | Duplicate family; base tools sufficient |
| verified_set_subtask_parent | NO | Duplicate family; base tools sufficient |
| week_agenda | YES | Core weekly planning |
| week_overview | YES | Core weekly planning |
| workspace_map | YES | First-step discovery tool |

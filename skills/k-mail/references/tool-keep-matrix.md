# Mail MCP Tool Keep Matrix

| Tool | Necessary (YES/NO) | Justification |
|---|---|---|
| archive_messages | YES | Core closure hygiene |
| check_inbox | YES | Fast preflight/status check |
| create_folder | NO | Folder architecture stable; rare need |
| daily_digest | YES | Useful summary accelerator |
| delete_folder | NO | Destructive admin, low value |
| delete_messages | NO | Hard-delete rarely needed |
| download_attachment | YES | Needed for attachment workflows |
| find_unread | YES | Core unread triage |
| forward_message | YES | Explicitly requested to keep |
| get_message | YES | Deep thread/content read |
| get_thread | YES | Thread-level context needed |
| list_folders | YES | Navigation/validation baseline |
| list_labels | YES | Tag inventory maintenance |
| list_messages | YES | Primary mailbox listing |
| mail_guide | YES | Tool bootstrap reference |
| mark_as_spam | YES | Explicitly requested to keep |
| mark_messages | YES | Core flags/read state workflows |
| move_messages | YES | Core organization and closure |
| rename_folder | NO | Folder admin, rare |
| reply_message | YES | Core communication action |
| save_draft | YES | Useful for validated workflows |
| search_messages | YES | Core targeted retrieval |
| send_message | YES | Core outbound action |
| set_labels | YES | Core priority/label hygiene |
| trash_messages | NO | Destructive step not mandatory |

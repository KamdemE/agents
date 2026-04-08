# k-mail Runtime Log

Purpose: detailed runtime execution log for mail operations (different from `SKILL.md` changelog).

## Entry Format

| Timestamp (UTC) | Agent | Channel | Action | Inputs | Outcome | IDs / Links | Notes |
|-----------------|-------|---------|--------|--------|---------|-------------|-------|
| 2026-04-08T11:09:25Z | [CODEX] | mail-mcp http | `send_message` | to=hotmail, subject=`[mail-mcp test] 2026-04-08T11:09:03Z` | sent=true, saved_to_sent=true | message_id=`<177564656546.1.16546049869132564538@f547e4f98890>` | signature default |
| 2026-04-08T11:09:30Z | [CODEX] | mail-mcp http | `search_messages` | folder=`Sent`, subject_filter exact | 1 hit | uid=8425 | sent-copy check passed |
| 2026-04-08T11:09:35Z | [CODEX] | m365 Graph | mailbox verification | subject exact match | received in Hotmail | internetMessageId matched | delivery check passed |


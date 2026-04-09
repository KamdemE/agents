# k-mail Runtime Log

Purpose: detailed runtime execution log for mail operations (different from `SKILL.md` changelog).

## Entry Format

| Timestamp (UTC) | Agent | Channel | Action | Inputs | Outcome | IDs / Links | Notes |
|-----------------|-------|---------|--------|--------|---------|-------------|-------|
| 2026-04-08T11:09:25Z | [CODEX] | mail-mcp http | `send_message` | to=hotmail, subject=`[mail-mcp test] 2026-04-08T11:09:03Z` | sent=true, saved_to_sent=true | message_id=`<177564656546.1.16546049869132564538@f547e4f98890>` | signature default |
| 2026-04-08T11:09:30Z | [CODEX] | mail-mcp http | `search_messages` | folder=`Sent`, subject_filter exact | 1 hit | uid=8425 | sent-copy check passed |
| 2026-04-08T11:09:35Z | [CODEX] | m365 Graph | mailbox verification | subject exact match | received in Hotmail | internetMessageId matched | delivery check passed |
| 2026-04-08T11:40:00Z | [CODEX] | mail-mcp http | `search_messages` + `get_message` | since=`2026-04-07`, folders=`INBOX,Archive`, then detailed reads by UID | 16 received emails analyzed | uids=8426..8407 | built actionable response + TickTick proposals |
| 2026-04-09T00:20:00Z | [CURSOR] | mail-mcp http | `send_message` | to=`ivann.kamdem@hotmail.com`, verify_bounce_window_seconds=10 | smtp_accepted=true, delivery_status=delivered_hint, saved_to_sent=true | message_id from response | k-final closure test after mail_mcp 0.2.4 deploy |
| 2026-04-09T00:21:00Z | [CURSOR] | mail-mcp http | `send_message` | to=`pauline.alessandra@polytechnique.fr` (wrong TLD probe), verify_bounce_window_seconds=25 | smtp_accepted=true, delivery_status=delivered_hint, bounce_details=null | message_id from response | no MAILER-DAEMON match in 25s window |
| 2026-04-09T12:00:00Z | [CURSOR] | mail-mcp http | `search_messages` | folder=`INBOX`, since=`2026-04-08`, before=`2026-04-09`, limit=200 | 3 hits | uids 8449,8445,8444 | user digest poly INBOX only |
| 2026-04-09T12:00:05Z | [CURSOR] | mail-mcp http | `search_messages` | folders=`INBOX,Archive`, since=`2026-04-08`, before=`2026-04-09`, limit=200 | 13 hits | uids 8457..8435 | full-day received digest for user triage |
| 2026-04-09T14:30:00Z | [CURSOR] | mail-mcp http | `archive_messages` | source=`INBOX`, uids=`8444,8445,8449` | archived=3 → `Archive` | user: archive all 2026-04-08 INBOX; Archive-folder Apr8 already filed |
| 2026-04-09T14:30:10Z | [CURSOR] | mail-mcp http | `search_messages` | folder=`INBOX`, since=`2026-03-25`, limit=300 | 48 hits | uids 8460..8260 | post-archive INBOX inventory for user |
| 2026-04-09T16:00:00Z | [CURSOR] | mail-mcp http | `get_message` | uid=`8323`,`8318`, folder=`INBOX` | bodies retrieved | certification + MT180 | user summary |
| 2026-04-09T16:00:10Z | [CURSOR] | mail-mcp http | `archive_messages` | source=`INBOX`, 56 uids (all since 2026-03-25 **except** 8323, 8318) | archived=56 | — | user keep certif + MT180 |
| 2026-04-09T18:45:00Z | [CURSOR] | mail-mcp stdio + m365 Graph | `list_messages`, `search_messages`, `get_message`, `m365 request` | poly INBOX + Outlook/Graph `$search` | what's-up briefing (FR) | uids 8323, 8318, 8462, 8463; Clément Liu thread | user: quoi de neuf mail |
| 2026-04-09T20:15:00Z | [CURSOR] | m365 Graph | `outlook message list` + `m365 request` POST `$batch` | folder=`Inbox` → `Archive` | moved=2126, inbox_count_after=0 | 107 batches × 20; `--content-type application/json` required on `m365 request` when using `-b` | user: archive all Hotmail Inbox on m365 only (poly already cleaned via mail-stdio earlier) |


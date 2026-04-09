# k-mail Insights

Purpose: durable behavioral memory to improve proactive drafting and reduce user corrections.

## Communication Style

- Default tone preference in peer exchanges: concise, neutral, respectful, low-excitement wording.
- Avoid over-enthusiastic phrasing unless explicitly requested.
- Keep follow-ups practical and action-oriented.

## Message Patterns

- Important workflows often involve: detect thread context (mail/whatsapp), draft, user validation, send, then verify sent and delivered state.
- For verification requests, user expects both source-side (`Sent` in Zimbra) and target-side reception checks.
- For inbox reviews, user expects exhaustive detail plus concrete next actions (reply / relaunch / ticktick task suggestion), not only summaries.

## Tooling Patterns

- Use mail-mcp (`http` or `stdio`) for Zimbra account operations (`poly`).
- Use `m365`/Graph for Hotmail mailbox verification.
- Bulk Outlook folder moves: list ids via `m365 outlook message list --folderName Inbox`, resolve Archive id via `m365 request -u 'https://graph.microsoft.com/v1.0/me/mailFolders/archive' -m get`, then POST Graph `$batch` (max 20 sub-requests) with `m365 request ... -b @file.json --content-type application/json` (body-only POSTs **require** explicit JSON content-type).
- Treat Outlook forwarding notifications from `postmaster@zimbra.polytechnique.fr` as delivery receipts, not conversational messages.
- On poly/mail-mcp stdio, `Important` behaves as a keyword label queryable via `search_messages(keyword="Important")`; favorites/star state is the IMAP `\\Flagged` flag queryable via `flagged_only=true` and editable via `mark_messages(flagged=...)`.
- User expects active tag hygiene: when triaging open threads, prioritize `Important`, suggest tag cleanup proactively, and keep `SKILL.md` tag inventory aligned with observed Zimbra labels.
- Certification follow-up pattern: when user confirms form submission for UID `8323`, keep thread open with `Message-ID`, session windows (13-17 and 20-24 Apr), and explicit "waiting assignment" state until WeFit slot is received.
- Large mailbox cleanup pattern: fetch full INBOX snapshot, compute exclusion list for protected sender(s), archive in deterministic UID batches, then verify with `list_messages` to ensure only protected messages remain.
- For custom label hygiene (`AI`, `Important`, etc.), use `search_messages(keyword=...)` across `INBOX` + `Archive`, apply `set_labels(add=false)`, then re-run the same keyword search to prove zero residue.

## Open Behavior Rules

- Always read this file before composing any significant email reply.
- After each mail task, append any new reusable pattern (tone, correction, workflow preference, recurring contacts, recurring topics).


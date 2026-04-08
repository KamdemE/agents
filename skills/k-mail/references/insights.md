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
- Treat Outlook forwarding notifications from `postmaster@zimbra.polytechnique.fr` as delivery receipts, not conversational messages.

## Open Behavior Rules

- Always read this file before composing any significant email reply.
- After each mail task, append any new reusable pattern (tone, correction, workflow preference, recurring contacts, recurring topics).


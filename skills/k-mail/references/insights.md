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
- For current Hotmail auth with app `bf3e4ec4-fd28-48aa-89f0-c6d8ae7c6906`, force `--tenant consumers` on `m365 login --authType deviceCode`; `/common` triggers `AADSTS9002346`.
- On CLI for Microsoft 365 v11.5.0, prefer `m365 outlook message list` (not `m365 outlook mail list`) for inbox reads; use Graph `m365 request` when precise search filters (`$search`, `$select`) are needed.
- On Linux sessions, set `autoOpenLinksInBrowser=false` and `copyDeviceCodeToClipboard=false` to avoid callback-side instability; this is a stability guard, not the root fix for `AADSTS9002346`.
- `m365 status` can show empty `connectedAs` even after successful token acquisition; verify with `m365 request …/v1.0/me` or `outlook message list` **without** `--folderName Inbox` when MSA Inbox `totalItemCount` is 0.
- **m365 v11 token cache:** `$HOME/.cli-m365-msal.json` + `~/.cli-m365-connection.json` — not `~/.config/m365`. Refresh token ~90d idle; access ~1h auto-refresh. Persist CLI config: `authType=deviceCode`, `tenantId=consumers`. Logout: `m365 logout` only.
- **@kpihx-labs.com inbound (LIVE 2026-05-25):** Worker + **prime rules**. Anti-spam: Gmail filter `to:<alias>` → `removeLabelIds: ["SPAM"]` on **kapoivha + Labs** (all aliases); Hotmail **inbox** `messageRules` (`sentToAddresses` → moveTo inbox) — `apply-inbound-antispam-filters.sh`. Graph **cannot** POST rules on `junkemail`. **Traps:** Hotmail→`ivann@` NDR; kapoivha self-send **SENT only**. **m365 POST:** `-b @file.json` + `--content-type application/json`.
- Bulk Outlook folder moves: list ids via `m365 outlook message list --folderName Inbox`, resolve Archive id via `m365 request -u 'https://graph.microsoft.com/v1.0/me/mailFolders/archive' -m get`, then POST Graph `$batch` (max 20 sub-requests) with `m365 request ... -b @file.json --content-type application/json` (body-only POSTs **require** explicit JSON content-type).
- Treat Outlook forwarding notifications from `postmaster@zimbra.polytechnique.fr` as delivery receipts, not conversational messages.
- On poly/mail-mcp stdio, `Important` behaves as a keyword label queryable via `search_messages(keyword="Important")`; favorites/star state is the IMAP `\\Flagged` flag queryable via `flagged_only=true` and editable via `mark_messages(flagged=...)`.
- mail-mcp stdio search may throw ASCII codec errors on accented query strings; fallback strategy: retry with ASCII-safe keywords (`authentification`, `breve`, sender/domain filters, or `subject_filter` without accents), then open target UIDs with `get_message`.
- `mail_guide` currently rejects unknown args (including `account_id`); call it with `{}` only, then pass `account_id` on other tools (`search_messages`, `get_message`, etc.).
- User expects active tag hygiene: when triaging open threads, prioritize `Important`, suggest tag cleanup proactively, and keep `SKILL.md` tag inventory aligned with observed Zimbra labels.
- Certification follow-up pattern: when user confirms form submission for UID `8323`, keep thread open with `Message-ID`, session windows (13-17 and 20-24 Apr), and explicit "waiting assignment" state until WeFit slot is received.
- Certification assignment pattern: once WEFIT confirms an exact slot (example UID `10071`, Thu 2026-04-30 09:00), immediately set that message to both `Important` and `\Flagged`, then update `k-mail/SKILL.md` open-thread row with the confirmed datetime and both Message-IDs.
- Large mailbox cleanup pattern: fetch full INBOX snapshot, compute exclusion list for protected sender(s), archive in deterministic UID batches, then verify with `list_messages` to ensure only protected messages remain.
- For custom label hygiene (`AI`, `Important`, etc.), use `search_messages(keyword=...)` across `INBOX` + `Archive`, apply `set_labels(add=false)`, then re-run the same keyword search to prove zero residue.
- **Certification Credential Extraction:** Confirmation emails for exams (Linguaskill, IT certifications) often contain three separate credential types: personal username, temporary password, and Institution/Center ID. Extract all three and store in a dedicated Gdrive folder + TickTick task content to ensure they are available even without mail access during the test.

## Open Behavior Rules

- Always read this file before composing any significant email reply.
- After each mail task, append any new reusable pattern (tone, correction, workflow preference, recurring contacts, recurring topics).

- **Campaign Triage Insight:** Academic or professional campaigns (e.g., PA Choice, Prize registration) often involve an "Erratum" follow-up email that corrects a specific field (e.g., contact address, URL) while keeping other deadlines intact. Always check for the latest UID in the subject thread before creating tasks.
- **Deadline Accuracy:** For choice campaigns, always extract precise opening and closing times (down to the minute) and record them in TickTick `start_date` and `due_date` with the correct `timeZone` (Europe/Paris) to avoid late submissions.

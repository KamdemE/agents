# webmail.polytechnique.fr (Zimbra — Polytechnique mail)

**Category:** Webmail. **Account:** X24 student mailbox. **Profile:** `default`.

## Login

Same Egide/Shibboleth ecosystem as SynapseS (see `synapses.polytechnique.fr.md`) — usually already authenticated if another Polytechnique service session is active. Auth cookies: `ZM_AUTH_TOKEN`, `JSESSIONID` (path `/modern/...`), plus a non-standard `ZM_TEST` cookie.

## Auth internals (verified live)

- **`csrfToken`** lives in `localStorage`, NOT a cookie — Zimbra's own CSRF protection deliberately avoids cookies (a cookie would be sent automatically by the browser even on a forged cross-site request, defeating the protection). If ever scripting a direct POST/DELETE against Zimbra's REST endpoints, this token must be read via `storage-local-get` and attached to a custom header — a plain cookie-based request will be rejected.
- `colorModePreference` (light/dark) also lives alongside it in `localStorage` — harmless UI preference, not auth-related.

## Structure / navigation

- Inbox: `/modern/email/Inbox/conversation/<id>` (conversation view, not flat message list by default)
- Reading the inbox list is easiest via `page-evaluate` scraping the DOM directly (`document.querySelectorAll` on the conversation-list rows) rather than trying to drive Zimbra's own AJAX/SPA UI element by element — it's a heavy legacy webapp, snapshot trees can be large.

## Known quirks

- Zimbra is a legacy Ajax-heavy SPA — `page-snapshot` accessibility trees can be large/slow; prefer targeted `page-evaluate` DOM queries when only specific data (sender, subject, unread count) is needed.

## Changelog

| Date | Note |
|------|------|
| 2026-08-30 | Created after live inbox parsing (`page-evaluate` DOM scrape) + cookie/localStorage audit (`csrfToken` in localStorage explained: prevents automatic cross-site cookie replay). |

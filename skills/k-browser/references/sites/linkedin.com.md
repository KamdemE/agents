# linkedin.com (LinkedIn — Professional network)

**Category:** Social/Professional Network. **Account:** ivann.kamdem@hotmail.com (KπX main). **Profile:** `default`.

## Login

Primary account: `ivann.kamdem@hotmail.com`. `kapoivha@gmail.com` is registered as a Google SSO login option (used for convenience/passwordless) — NOT the primary LinkedIn email. The default Edge profile is usually already authenticated via SSO; no separate login needed unless the session expired.

## Structure / navigation

- **Feed:** `linkedin.com/feed/` — main timeline, "Focused" + "Other" tabs
- **Messaging:** `linkedin.com/messaging/` — conversation list (left) + thread (right)
- **Profile:** `linkedin.com/in/ivann-kamdem/`
- **Notifications:** `linkedin.com/notifications/`

### Feed structure
- Posts are grouped by relevance ("Les plus pertinents d'abord")
- Right sidebar: LinkedIn Actualités (news) + Les casse-têtes du jour
- Left sidebar: profile card (views, impressions, saved, groups, newsletters, events)
- Each post has: author, timestamp, content, reactions, comments, republications

### Messaging structure
- Conversation list on left: shows sender name, last message preview, timestamp
- Thread on right: chronological messages, with sender avatars and timestamps
- "Prioritaire" / "Emplois" / "Non lus" / "Relations" / "InMail" / "Importants" filter tabs
- LinkedIn notifications ("Shuxian LI via LinkedIn") land in the email inbox as forwarded notifications — separate from the actual LinkedIn messaging UI

### InMail vs Messages
- **Messages** = direct LinkedIn messaging (real conversations)
- **InMail** = recruiter/outreach messages (cold outreach, job offers)
- InMail notifications also appear in Outlook as "X via LinkedIn" emails — these are NOT the actual messages, just notification forwards

## Known quirks

- LinkedIn is a heavy SPA — `page-snapshot` accessibility trees can be large; prefer targeted `page-evaluate` DOM queries for specific data
- **Feed content is dynamic** — scrolling loads more posts via infinite scroll; use `window.scrollBy(0, N)` then `document.body.innerText.substring(start, end)` to capture sections
- **Messaging uses shadow DOM** for some elements — standard CSS selectors may not work; prefer `page-evaluate` with `document.querySelectorAll` or coordinate-based clicks
- **LinkedIn notification emails in Outlook** are grouped under "Other Emails (X)" — they are notification forwards, NOT the actual messages; always check the real LinkedIn messaging UI for actual conversations
- The "Focused" vs "Other" inbox split applies to both LinkedIn notifications and other low-priority emails

## Changelog

| Date | Note |
|------|------|
| 2026-08-30 | Created after live LinkedIn session: feed parsing (infinite scroll, post extraction), messaging UI (Shuxian LI conversation), InMail vs Message distinction, LinkedIn notification emails in Outlook. |

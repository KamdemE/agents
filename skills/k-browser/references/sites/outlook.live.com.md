# outlook.live.com (Microsoft Outlook — Hotmail inbox)

**Category:** Webmail. **Account:** ivann.kamdem@hotmail.com (KπX personal). **Profile:** `default`.

## Login

Microsoft account with **passwordless authentication** (Microsoft Authenticator app). Login flow:
1. Navigate to `outlook.live.com/mail/0/`
2. Redirects to `login.microsoftonline.com` with `prompt=select_account`
3. **Account picker** shows saved accounts — "Ivann KAMDEM" (kapoivha@gmail.com) may appear but is WRONG (Google account, not Microsoft)
4. Click "Use another account" → enter `ivann.kamdem@hotmail.com` → click "Next"
5. **"Get a sign-in request"** → "Send request" → notification sent to Microsoft Authenticator on phone
6. KπX must approve the sign-in request on their phone (number matching)
7. After approval → redirects to `outlook.live.com/mail/?deeplink=mail%2F0%2F`

### ⚠️ Auth gotcha
- The email input field is inside a **cross-origin iframe** (login.microsoftonline.com) — standard `page-type` with CSS selectors does NOT work
- Use `page-click-coordinates` to focus the input, then `page-type` (without selector, types to focused element) or `page-evaluate` with CDP keyboard events
- The "Send request" button and "Other ways to sign in" link are also inside the shadow DOM — use coordinate clicks
- The Authenticator request expires after ~2 minutes; if it times out, click "Send another request"

## Structure / navigation

- **Inbox:** `outlook.live.com/mail/0/` — main inbox
- **Focused tab:** important/primary emails (default view)
- **Other tab:** low-priority, notifications, LinkedIn alerts
- **Left sidebar:** Favourites (Inbox, Sent Items, Drafts) + account folders (Inbox, Junk Email, Drafts, Sent Items, Deleted Items, Archive, Conversation History, Notes)
- **Inbox stats:** unread count shown next to "Inbox" in sidebar

### Focused vs Other
- Outlook automatically sorts emails into "Focused" (important) and "Other" (low-priority)
- LinkedIn notification emails ("X via LinkedIn") land in **Other** tab
- Job alerts (Alertes LinkedIn Jobs) land in **Other** tab
- Academic/school emails (Scolarite, Polytechnique) land in **Focused**
- "Other Emails (X)" is a grouped notification cluster at the top of Focused — clicking it expands to show individual LinkedIn/job alert emails

### Email structure
- Each email shows: sender avatar (colored circle with initials), sender name, subject (blue if unread), timestamp, preview text
- Attachments shown as chips below the preview (PDF icons, Excel icons)
- Thread/conversation view: multiple emails from same sender grouped with expand arrow

## Known quirks

- **Cross-origin login form** — the Microsoft login page (login.microsoftonline.com) renders its form in a way that blocks standard CSS selectors; coordinate-based clicking is the only reliable interaction method
- **Passwordless accounts** — Microsoft Authenticator required; agent cannot enter a password (there is none). KπX must approve the sign-in on their phone
- **SPA navigation** — Outlook Web is a React SPA; `page-evaluate` DOM queries work but the DOM is large; prefer `document.body.innerText.substring(start, end)` for bulk text extraction
- **"Other" tab button** — clicking it via `page-evaluate` sometimes fails with CDP_ERROR; use coordinate-based clicks instead
- **Notification forwarding** — LinkedIn, job alerts, and other social notifications appear as emails in Outlook but are just notification forwards, not the actual messages (see `linkedin.com.md` for the real messaging UI)

## Changelog

| Date | Note |
|------||------|
| 2026-08-30 | Created after live Outlook session: passwordless Authenticator login flow (cross-origin iframe gotcha), Focused/Other inbox split, LinkedIn notification email pattern, DOM extraction approach for SPA. |

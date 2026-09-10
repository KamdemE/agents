# Gmail Folders & Filters Reference (`@<yourdomain.com>`)

**Status:** Updated **2026-09-04** · **Profiles:** `gws-primary` (`<primary@gmail.com>`), `gws-labs` (`<labs@gmail.com>`)

---

## 1. Concept : Nested Labels = Folders in Gmail

In Gmail, there are no physical subfolders. Folder hierarchy is simulated via **nested labels** using `/` as a delimiter:

- `Labs/You/In`
- `Labs/You/Out`
- `Labs//In`
- `Labs//Out`
- `Labs/Contact/In`
- `Labs/Contact/Out`

> ⚠️ **UI Pitfall:** For nested labels to render properly in the Gmail web sidebar, the parent label `Labs` should also exist as a standalone root label if visual hierarchy is required.

---

## 2. Inbound & Outbound Filter Logic

### Inbound (IN)
Incoming forwarded mails arrive with `To: <alias>@<yourdomain.com>` preserved in headers.
Filter condition: `query: "to:<alias>@<yourdomain.com>"` → Action: `addLabelIds: ["<LABEL_ID>"]`.
The mail remains in `INBOX` AND receives the nested label.

### Outbound (OUT)
Mails sent via Gmail Send-as carry `From: <alias>@<yourdomain.com>`.
Filter condition: `query: "from:<alias>@<yourdomain.com>"` → Action: `addLabelIds: ["<LABEL_ID>"]`.
When sent, Gmail places the copy in `[Gmail]/Messages envoyés` (Sent) AND applies the OUT label automatically.

---

## 3. Current Live State (2026-09-04)

### kapoivha Gmail (`<primary@gmail.com>` / `gws-primary`)

#### Labels Inventory (5 nested labels created)

| Label Name | ID | Purpose |
|------------|----|---------|
| `Labs/You/In` | `Label_12` | Inbound `personal@<yourdomain.com>` |
| `Labs/You/Out` | `Label_13` | Outbound Send-as `personal@<yourdomain.com>` |
| `Labs//In` | `Label_14` | Inbound `mail@<yourdomain.com>` |
| `Labs//Out` | `Label_15` | Outbound Send-as `mail@<yourdomain.com>` |
| `Labs/Contact/In` | `Label_16` | Inbound `contact@<yourdomain.com>` |

#### Filters Inventory (18 active filters)

| # | Condition | Action | Notes |
|---|-----------|--------|-------|
| 1 | `to:contact@<yourdomain.com>` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 2 | `to:mail@<yourdomain.com>` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 3 | `to:you@<yourdomain.com>` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 4 | `to:you@<yourdomain.com>` | `addLabelIds: ["Label_12"]` | Auto-tag `You/In` |
| 5 | `to:mail@<yourdomain.com>` | `addLabelIds: ["Label_14"]` | Auto-tag `/In` |
| 6 | `to:contact@<yourdomain.com>` | `addLabelIds: ["Label_16"]` | Auto-tag `Contact/In` |
| 7 | `from:you@<yourdomain.com>` | `addLabelIds: ["Label_13"]` | Auto-tag `You/Out` |
| 8 | `from:mail@<yourdomain.com>` | `addLabelIds: ["Label_15"]` | Auto-tag `/Out` |
| 9 | `from:linkedin.com` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 10 | `from:notifications@github.com` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 11 | `from:noreply@github.com` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 12 | `from:<alumni@gmail.com>` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 13-18 | Newsletters (socgen, carrefour, lebara, etc.) | `removeLabelIds: ["UNREAD", "INBOX"]` | Archive noise |

### Labs Gmail (`<labs@gmail.com>` / `gws-labs`)

#### Labels Inventory (2 nested labels created)

| Label Name | ID | Purpose |
|------------|----|---------|
| `Labs/Contact/In` | `Label_1` | Inbound `contact@<yourdomain.com>` |
| `Labs/Contact/Out` | `Label_2` | Outbound Send-as `contact@<yourdomain.com>` |

#### Filters Inventory (5 active filters)

| # | Condition | Action | Notes |
|---|-----------|--------|-------|
| 1 | `to:contact@<yourdomain.com>` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 2 | `to:mail@<yourdomain.com>` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 3 | `to:you@<yourdomain.com>` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 4 | `to:contact@<yourdomain.com>` | `addLabelIds: ["Label_1"]` | Auto-tag `Contact/In` |
| 5 | `from:contact@<yourdomain.com>` | `addLabelIds: ["Label_2"]` | Auto-tag `Contact/Out` |

---

## 4. Deleted Filters Ledger (2026-09-04 Audit)

The following dangerous filters were permanently purged during the 2026-09-04 audit:

- **3× `subject:(OUT-E2E OR E2E-)` → `addLabelIds: ["TRASH"]`** on kapoivha: Trailing `-` caused broad wildcard matching that trashed all test mails.
- **1× `to:@<yourdomain.com>` → `removeLabelIds: ["UNREAD", "INBOX"]`** on kapoivha: Stripped INBOX label from all inbound alias mails, causing them to land in All Mail only.
- **1× `from:noreply@ip-paris.fr` → `removeLabelIds: ["UNREAD", "INBOX"]`** on kapoivha: Archived academic emails.

---

## 5. How to Automate & Manage via CLI

### Inspect labels & filters
```bash
$HOME/.agents/skills/k-mail/scripts/inspect_gmail_filters_labels.sh --profile kpihx
$HOME/.agents/skills/k-mail/scripts/inspect_gmail_filters_labels.sh --profile labs
```

### Setup alias folders & filters (idempotent)
```bash
$HOME/.agents/skills/k-mail/scripts/setup_alias_folders_filters.sh --profile kpihx
$HOME/.agents/skills/k-mail/scripts/setup_alias_folders_filters.sh --profile labs
```

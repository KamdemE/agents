# Gmail Folders & Filters Reference (`@kpihx-labs.com`)

**Status:** Updated **2026-09-04** · **Profiles:** `gws-kpihx` (`kapoivha@gmail.com`), `gws-labs` (`kpihx.labs@gmail.com`)

---

## 1. Concept : Nested Labels = Folders in Gmail

In Gmail, there are no physical subfolders. Folder hierarchy is simulated via **nested labels** using `/` as a delimiter:

- `KpihX-Labs/Ivann/In`
- `KpihX-Labs/Ivann/Out`
- `KpihX-Labs/KpihX/In`
- `KpihX-Labs/KpihX/Out`
- `KpihX-Labs/Contact/In`
- `KpihX-Labs/Contact/Out`

> ⚠️ **UI Pitfall:** For nested labels to render properly in the Gmail web sidebar, the parent label `KpihX-Labs` should also exist as a standalone root label if visual hierarchy is required.

---

## 2. Inbound & Outbound Filter Logic

### Inbound (IN)
Incoming forwarded mails arrive with `To: <alias>@kpihx-labs.com` preserved in headers.
Filter condition: `query: "to:<alias>@kpihx-labs.com"` → Action: `addLabelIds: ["<LABEL_ID>"]`.
The mail remains in `INBOX` AND receives the nested label.

### Outbound (OUT)
Mails sent via Gmail Send-as carry `From: <alias>@kpihx-labs.com`.
Filter condition: `query: "from:<alias>@kpihx-labs.com"` → Action: `addLabelIds: ["<LABEL_ID>"]`.
When sent, Gmail places the copy in `[Gmail]/Messages envoyés` (Sent) AND applies the OUT label automatically.

---

## 3. Current Live State (2026-09-04)

### kapoivha Gmail (`kapoivha@gmail.com` / `gws-kpihx`)

#### Labels Inventory (5 nested labels created)

| Label Name | ID | Purpose |
|------------|----|---------|
| `KpihX-Labs/Ivann/In` | `Label_12` | Inbound `ivann@kpihx-labs.com` |
| `KpihX-Labs/Ivann/Out` | `Label_13` | Outbound Send-as `ivann@kpihx-labs.com` |
| `KpihX-Labs/KpihX/In` | `Label_14` | Inbound `kpihx@kpihx-labs.com` |
| `KpihX-Labs/KpihX/Out` | `Label_15` | Outbound Send-as `kpihx@kpihx-labs.com` |
| `KpihX-Labs/Contact/In` | `Label_16` | Inbound `contact@kpihx-labs.com` |

#### Filters Inventory (18 active filters)

| # | Condition | Action | Notes |
|---|-----------|--------|-------|
| 1 | `to:contact@kpihx-labs.com` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 2 | `to:kpihx@kpihx-labs.com` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 3 | `to:ivann@kpihx-labs.com` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 4 | `to:ivann@kpihx-labs.com` | `addLabelIds: ["Label_12"]` | Auto-tag `Ivann/In` |
| 5 | `to:kpihx@kpihx-labs.com` | `addLabelIds: ["Label_14"]` | Auto-tag `KpihX/In` |
| 6 | `to:contact@kpihx-labs.com` | `addLabelIds: ["Label_16"]` | Auto-tag `Contact/In` |
| 7 | `from:ivann@kpihx-labs.com` | `addLabelIds: ["Label_13"]` | Auto-tag `Ivann/Out` |
| 8 | `from:kpihx@kpihx-labs.com` | `addLabelIds: ["Label_15"]` | Auto-tag `KpihX/Out` |
| 9 | `from:linkedin.com` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 10 | `from:notifications@github.com` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 11 | `from:noreply@github.com` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 12 | `from:enspyalumni.abroad@gmail.com` | `removeLabelIds: ["SPAM"]` | Adjusted (keep in INBOX) |
| 13-18 | Newsletters (socgen, carrefour, lebara, etc.) | `removeLabelIds: ["UNREAD", "INBOX"]` | Archive noise |

### Labs Gmail (`kpihx.labs@gmail.com` / `gws-labs`)

#### Labels Inventory (2 nested labels created)

| Label Name | ID | Purpose |
|------------|----|---------|
| `KpihX-Labs/Contact/In` | `Label_1` | Inbound `contact@kpihx-labs.com` |
| `KpihX-Labs/Contact/Out` | `Label_2` | Outbound Send-as `contact@kpihx-labs.com` |

#### Filters Inventory (5 active filters)

| # | Condition | Action | Notes |
|---|-----------|--------|-------|
| 1 | `to:contact@kpihx-labs.com` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 2 | `to:kpihx@kpihx-labs.com` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 3 | `to:ivann@kpihx-labs.com` | `removeLabelIds: ["SPAM"]` | Anti-spam baseline |
| 4 | `to:contact@kpihx-labs.com` | `addLabelIds: ["Label_1"]` | Auto-tag `Contact/In` |
| 5 | `from:contact@kpihx-labs.com` | `addLabelIds: ["Label_2"]` | Auto-tag `Contact/Out` |

---

## 4. Deleted Filters Ledger (2026-09-04 Audit)

The following dangerous filters were permanently purged during the 2026-09-04 audit:

- **3× `subject:(OUT-E2E OR E2E-)` → `addLabelIds: ["TRASH"]`** on kapoivha: Trailing `-` caused broad wildcard matching that trashed all test mails.
- **1× `to:@kpihx-labs.com` → `removeLabelIds: ["UNREAD", "INBOX"]`** on kapoivha: Stripped INBOX label from all inbound alias mails, causing them to land in All Mail only.
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

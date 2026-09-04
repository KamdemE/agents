# Outlook / Hotmail Folders & Rules Reference (`ivann.kamdem@hotmail.com`)

**Status:** Updated **2026-09-04** · **Tool:** `m365` (Microsoft Graph API) · **Account:** `ivann.kamdem@hotmail.com`

---

## 1. Folder Hierarchy & Delimiter Constraints

Unlike Gmail labels, Outlook/Exchange uses real physical mail folders (`mailFolders`).

> ⚠️ **Graph API Pitfall:** `POST /me/mailFolders` with `displayName: "KpihX-Labs/Ivann/In"` returns **HTTP 400 Bad Request**. Microsoft Graph prohibits `/` in folder display names because `/` is the Exchange hierarchy delimiter.

### Correct Creation Pattern: Nested `childFolders`

To build a nested hierarchy (`KpihX-Labs` ▸ `Ivann` ▸ `In`), folders must be created recursively using `childFolders`:

```bash
# 1. Create root folder
ROOT_ID=$(m365 request -u "https://graph.microsoft.com/v1.0/me/mailFolders" -m post -b '{"displayName":"KpihX-Labs"}' --content-type "application/json" -o json | jq -r .id)

# 2. Create subfolder under root
IVANN_ID=$(m365 request -u "https://graph.microsoft.com/v1.0/me/mailFolders/$ROOT_ID/childFolders" -m post -b '{"displayName":"Ivann"}' --content-type "application/json" -o json | jq -r .id)

# 3. Create leaf folder under subfolder
IN_ID=$(m365 request -u "https://graph.microsoft.com/v1.0/me/mailFolders/$IVANN_ID/childFolders" -m post -b '{"displayName":"In"}' --content-type "application/json" -o json | jq -r .id)
```

---

## 2. Current Live Folders (2026-09-04)

| Folder Path | Folder ID | Purpose |
|-------------|-----------|---------|
| `KpihX-Labs` | `AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAABUUtZjgAAAA==` | Root folder |
| `KpihX-Labs/Ivann` | `AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAABUUtZjwAAAA==` | Subfolder Ivann |
| `KpihX-Labs/Ivann/In` | `AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAABUUtZkAAAAA==` | Inbound target for `ivann@kpihx-labs.com` |
| `KpihX-Labs/KpihX` | `AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAABUUtZkQAAAA==` | Subfolder KpihX |
| `KpihX-Labs/KpihX/In` | `AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAABUUtZkgAAAA==` | Inbound target for `kpihx@kpihx-labs.com` |

---

## 3. Inbox Rules (`messageRules`) & `copyToFolder`

To keep incoming alias mails in `INBOX` while making a copy in the dedicated subfolder, rules must use `copyToFolder` alongside `moveToFolder` or keep the mail in `INBOX`.

> ⚠️ **Sequence Pitfall:** When creating rules via Graph API, omitting `sequence` causes **HTTP 400 (`MessageRuleValidationError: Field Sequence Value '0'`)**. Always supply an explicit `sequence: N`.
> ⚠️ **StopProcessing Pitfall:** Rules with `stopProcessingRules: true` halt processing for subsequent rules. If a rule moves to INBOX and stops at `sequence: 1`, rules `4` and `5` will **never execute**. `copyToFolder` must be merged directly into the matching rule actions.

### Current Live Rules (2026-09-04)

| Seq | Rule Display Name | Rule ID | Conditions | Actions |
|-----|-------------------|---------|------------|---------|
| 1 | `KpihX inbound contact (inbox)` | `AQAAAREMtq0=` | `sentToAddresses: contact@kpihx-labs.com` | `moveToFolder: INBOX`, `stopProcessingRules: true` |
| 2 | `KpihX inbound kpihx (inbox)` | `AQAAAREMtq4=` | `sentToAddresses: kpihx@kpihx-labs.com` | `moveToFolder: INBOX`, **`copyToFolder: KpihX-Labs/KpihX/In`**, `stopProcessingRules: true` |
| 3 | `KpihX inbound ivann (inbox)` | `AQAAAREMtq8=` | `sentToAddresses: ivann@kpihx-labs.com` | `moveToFolder: INBOX`, **`copyToFolder: KpihX-Labs/Ivann/In`**, `stopProcessingRules: true` |

---

## 4. How to Automate & Manage via CLI

### Inspect Hotmail folders & rules
```bash
$HOME/.agents/skills/k-mail/scripts/inspect_outlook_rules_folders.sh
```

### Setup Hotmail folders & rules (idempotent)
```bash
$HOME/.agents/skills/k-mail/scripts/setup_alias_folders_filters.sh --provider hotmail
```

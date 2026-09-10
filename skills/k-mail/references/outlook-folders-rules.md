# Outlook / Hotmail Folders & Rules Reference (`ivann.kamdem@hotmail.com`)

**Status:** Updated **2026-09-09** · **Tool:** `m365` (Microsoft Graph API) · **Account:** `ivann.kamdem@hotmail.com`

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

### Current Live Rules (2026-09-09)

#### Alias routing rules (seq 1–3)

| Seq | Rule Display Name | Rule ID | Conditions | Actions |
|-----|-------------------|---------|------------|---------| 
| 1 | `KpihX inbound contact (inbox)` | `AQAAAREMtq0=` | `sentToAddresses: contact@kpihx-labs.com` | `moveToFolder: INBOX`, `stopProcessingRules: true` |
| 2 | `KpihX inbound kpihx (inbox)` | `AQAAAREMtq4=` | `sentToAddresses: kpihx@kpihx-labs.com` | `moveToFolder: INBOX`, **`copyToFolder: KpihX-Labs/KpihX/In`**, `stopProcessingRules: true` |
| 3 | `KpihX inbound ivann (inbox)` | `AQAAAREMtq8=` | `sentToAddresses: ivann@kpihx-labs.com` | `moveToFolder: INBOX`, **`copyToFolder: KpihX-Labs/Ivann/In`**, `stopProcessingRules: true` |

#### Admins institutional copy rules (seq 4–15) — created 2026-09-09

> **Design:** `copyToFolder: Admins` + `stopProcessingRules: false` — mail stays in Inbox AND gets copied to Admins. Mirrors Gmail filter `ANe1BmjBAHPqNX8ssOZKEjFbfjn178UOWxTGpg` (k-mail v3.3.0).

| Seq (live) | Rule Display Name | Rule ID | `senderContains` | Entity |
|------------|-------------------|---------|-----------------|--------|
| 4 | `Admins: DGFiP` | `AQAAAVfbCvM=` | `dgfip.finances.gouv.fr` | Impôts / DGFiP |
| 5 | `Admins: impots.gouv.fr` | `AQAAAVfbCvQ=` | `impots.gouv.fr` | Impôts (portail + OTP) |
| 6 | `Admins: Ameli` | `AQAAAVfbCvU=` | `ameli.fr` | Assurance Maladie / CPAM |
| 7 | `Admins: CROUS` | `AQAAAVfbCvY=` | `lescrous.fr` | CROUS / bourses / logement |
| 8 | `Admins: Izly` | `AQAAAVfbCvc=` | `izly.fr` | Izly (CROUS paiement) |
| 9 | `Admins: Solidarité Transport` | `AQAAAVfbCvg=` | `solidaritetransport.fr` | AST / Navigo solidarité |
| 10 | `Admins: IDF Mobilités` | `AQAAAVfbCvk=` | `idfmobilites.fr` | IDF Mobilités / Navigo |
| 11 | `Admins: SG notificationsclients` | `AQAAAVfbCvo=` | `notificationsclients.socgen.com` | Société Générale (notifs) |
| 12 | `Admins: SG societegenerale.fr` | `AQAAAVfbCvs=` | `societegenerale.fr` | Société Générale (officiel) |
| 13 | `Admins: Lebara` | `AQAAAVfbCvw=` | `lebara.` | Lebara (lebara.fr + lebara.com) |
| 14 | `Admins: Heyme` | `AQAAAVfbCv0=` | `heyme.care` | Heyme mutuelle santé |
| 15 | `Admins: MesServices etudiant` | `AQAAAVfbCv4=` | `messervices.etudiant.gouv.fr` | MesServices / CVEC / étudiant gouv |

**Admins folder ID:** `AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAABVkDn8gAAAA==`

> **Note:** Graph API normalizes `senderContains` values to uppercase internally — functionally case-insensitive. `lebara.` (with trailing dot) covers both `lebara.fr` and `lebara.com` in one rule.

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

---
name: k-mail
description: >
  Unified mail via mail-proxy. Zimbra, Hotmail, Gmail (kapoivha+Labs), Google Workspace .2024.
  Load before any mail workflow or What's up mail slice.
license: private
metadata:
  author: KpihX
  version: "3.4.1"
allowed-tools: Bash(*), *
---

# KπX — Mail

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **mail-proxy is the sole transport.** No MCP, no mail-mcp. Run `mail-proxy do <action>` for everything.

## ⛔ Signature & Body Rule (CRITICAL — GRAVÉ)

1. **NEVER include `signature` in payload** unless KπX explicitly names one. Absent = default. **NEVER** `signature: ""`.
2. **NEVER include ANY personal info in `body_text`.** The default signature block is auto-appended by the transport after the closing line — it already contains name, EIX, school, address, phone, and email. Body must end with a closing formula only:
   - ✅ `"Cordialement,"` / `"Bien cordialement,"` / `"Cdt,"` / `"Best regards,"` / `"Kind regards,"` / `"Yours sincerely,"`
   - ❌ Name, EIX, school name, address, phone number, email — ALL belong in the signature block, NEVER in body_text
3. When asked "include signature", don't add `signature:"default"` — it's the default when omitted.
4. **Pattern:** `body_text` = greeting + message + closing formula. NOTHING ELSE. The transport appends everything after that automatically.

## Name Convention

| Context | Format | Example |
|---------|--------|---------|
| Academic / Professional | 4 parts: `SURNAME SURNAME2 Firstname Middle` | `KAMDEM POUOKAM Ivann Harold` |
| Casual / Personal / Internal | 2 parts: `SURNAME Firstname` | `KAMDEM Ivann` |

> **Rule:** All official documents, emails to institutions, companies, or academic
> bodies use the **4-part name**. Personal correspondence, internal notes, and
> non-official contexts use the **2-part name**.

## Runtime Discipline

- **Sole transport:** `mail-proxy do <action>`. No MCP, no HTTP backend.
- **Zimbra password pattern (GRAVÉ):** Zimbra requires password entry on first use (keyring caches ~20min). The **first** Zimbra command of a session MUST go through tmux ops pane so KπX can type the password. **All subsequent** mail-proxy commands — including all non-Zimbra accounts — run directly in the agent's shell. Pattern:
  1. First Zimbra call → `tmux send-keys -t ubuntu:1.0 'mail-proxy do ...' Enter` → KπX types password
  2. All following calls (Zimbra or not) → `mail-proxy do ...` directly in agent shell
- **Never pipe/redirect** mail-proxy commands (hooks will block). If output truncated → read autosave at `~/.config/mail-proxy/autosave/`.
- **`message-archive` over `message-move`** — auto-detects folder name (Archive, [Gmail]/Tous les messages, [Gmail]/All Mail).
- Read `references/insights.md` before mail tasks. Append to `references/log.md`.
- **Post-send verification:** wait ~5s, check Sent + INBOX for bounces (mandatory).
- **Closure hygiene:** archive after handling; nudge if still in INBOX on subsequent turns.
- **M365 auth:** never `m365 login` / `logout`. Auth is KπX-owned. If token expired → ask KπX to re-auth manually.

### message-search — CRITICAL RULES

`message-search` **defaults to INBOX only** — always specify `folders` to search across Archive, Sent, INBOX. **Mandatory: search at least 3 folders** (`INBOX`, `Archive`, `Sent`).

```bash
# WRONG — only searches INBOX:
mail-proxy do message-search '{"account_id":"ivann.kamdem-pouokam","query":"stage"}'
# CORRECT — searches all 3:
mail-proxy do message-search '{"account_id":"ivann.kamdem-pouokam","query":"stage","folders":["INBOX","Archive","Sent"]}'
```

| Field | Type | What it does |
|-------|------|-------------|
| `query` | string | Raw text match in **subject OR body** (IMAP server-side) |
| `sender` | string | FROM exact substring match |
| `sender_pattern` | regex | Regex on From address — use when `sender` returns nothing |
| `to_filter` | string | TO substring match |
| `body_pattern` | regex | Regex on body (expensive — fetches full bodies) |

> **Rule:** If `sender:"name"` returns 0 → ALWAYS retry `sender_pattern:"name"` (regex catches everything sender misses).

### message-send — CRITICAL RULES

**Never include `signature` in payload** (default handles it). **NEVER** `signature: ""`.
**Never include name/school/address in `body_text`** — the transport auto-appends the signature block after the closing line.

| Field | Correct | WRONG |
|-------|---------|-------|
| `to` | `["email@domain.edu"]` (list) | `"email@domain.edu"` (string) |
| body | `body_text` (string) | `body` (ignored, produces empty body) |

```json
// ✅ CORRECT — body ends with closing formula, signature auto-appended
{"account_id":"ivann.kamdem-pouokam","to":["x@polytechnique.edu"],"subject":"Subject","body_text":"Bonjour,\n\nCordialement."}

// ❌ WRONG — name/school/address in body = DUPLICATE with auto-signature
{"body_text":"Bonjour,\n\nCordialement,\n\nIvann KAMDEM\nEIX X2024\nÉCOLE POLYTECHNIQUE"}
```

## mail-proxy Commands

> Run `mail-proxy do <action> --help` for full docs + examples. Never read source code.

### `do` actions (37)

| Group | Actions | HITL? |
|---|---|---|
| Inbox | `inbox-check` · `inbox-digest` | — |
| Messages | `message-list` · `message-info` · `message-search` · `message-thread` · `message-mark` · `message-move` · **`message-archive`** · `message-trash` · `message-spam` · `message-delete` | archive/trash/spam/delete = ✅ |
| Compose | `message-send` · `message-reply` · `message-forward` · `message-draft` | all ✅ |
| Folders | `folder-list` · `folder-create` · `folder-rename` · `folder-delete` | delete = ✅ |
| Attach | `attachment-download` | — |
| Labels | `label-list` · `label-set` · `label-delete` | — |
| Signatures | `signature-list` · `signature-create` · `signature-update` · `signature-delete` · `signature-default` · `signature-get` | — |
| Zimbra | `zimbra-tag-list` · `zimbra-tag-items` · `zimbra-tag-create` · `zimbra-tag-delete` · `zimbra-tag-apply` · `zimbra-tag-remove` | delete/apply/remove = ✅ |
| Escape | `raw` (IMAP/SMTP/gmail-api/zimbra-soap) | ✅ |

### `admin` commands

| Command | Description | HITL? |
|---|---|---|
| `admin doctor` | Scan config, auto-fix permissions | — |
| `admin status` | Complete status: accounts, auth, probes | — |
| `admin auth login` | Set login credentials for an account | ✅ |
| `admin auth status` | Check auth status for an account | — |
| `admin auth logout` | Clear password for an account | ✅ |
| `admin reset` | Empty all passwords from .env | ✅ |
| `admin purge` | Delete entire config directory | ✅ |

### How to get help

```bash
mail-proxy do message-send --help    # Full docs + examples for any action
mail-proxy do message-search --help  # All search params
mail-proxy admin --help              # Admin commands
```
Never read source code — `--help` is the single source of truth (docstring-driven).

---

## Accounts

### 1. Zimbra — `ivann.kamdem-pouokam@polytechnique.edu` (PRIMARY — Pro + Perso)

> **Most-used account.** Academic, professional, and personal mail.
> Account ID: `ivann.kamdem-pouokam` | Auth: password (tmux only, keyring 20min)

- **Folders:** INBOX · Sent · Archive · Drafts · Outbox · Junk · Trash (7 flat)
- **Native tags:** `Important` · `Dx0` (stage DXO) · `Hi-ParisAI:FLAG7760` (IPAI) · `4A` · `Stage` · `Eco`
- **Cmds:** `zimbra-tag-list` to view tags, `zimbra-tag-create/delete/apply/remove` to manage
- **Signature:** Ivann KAMDEM · ÉCOLE POLYTECHNIQUE · EIX X2024
- **Full name (academic/pro):** `KAMDEM POUOKAM Ivann Harold`
- **Short name (casual):** `KAMDEM Ivann`

**Key contacts:**

**Key contacts:** see `references/key-contacts.md`

**Key knowledge:**
- **Absence request template:** search `Archive` for subject containing "demande d'absence" — the full model (recipient, subject, body with dates) is in an old email, reusable as-is.
- **Addressing rule:** `@polytechnique.edu` ONLY — `.fr` = SMTP 550 Non-existent address.
- **Position:** X24, EIX — pro signature: Ivann KAMDEM · ÉCOLE POLYTECHNIQUE · EIX X2024

### 2. Hotmail — `ivann.kamdem@hotmail.com` (Personal non-academic)

> **Secondary.** Personal non-academic mail. Receives CF Worker forwards for `kpihx@` and `ivann@`.
> Account ID: `ivann.kamdem` | Auth: OAuth2 device code (tokens `~/.cli-m365-*`)

- **Folders:** Inbox · Sent · Archive · Drafts · Junk · Deleted (6)
- **Rules:** 3 KpihX inbound (`contact@`/`kpihx@`/`ivann@` → moveToFolder + copyToFolder dossier)
- **Dossiers `@kpihx-labs.com`:** `KpihX-Labs/Ivann/In` + `KpihX-Labs/KpihX/In`
- **Routing:** receives `kpihx@` + `ivann@` via CF Worker

**Frequent contacts:** `clement.liu@lokad.com` (PSC INF01 coordinator, CC on Hotmail), `info@ax.polytechnique.org` (newsletter AX), `financialaid@polytechnique.fr` (CROUS notifications), `vincent.beurel@polytechnique.edu` (DFHM directives)

### 3. `.2024` — `ivann.kamdem-pouokam.2024@polytechnique.org` (AX Workspace)

> **Google Workspace account provided by AX** — 100 GB, all Google services.
> Account ID: `ivann.kamdem-pouokam.2024`

- **Redirection:** all received emails automatically **redirected to Hotmail + Zimbra**
- **Usage:** tests, validation sends, routing testing
- **Folders:** INBOX · Sent Mail · [Gmail] standard

### 4. kapoivha — `kapoivha@gmail.com` (Test / Quick solutions)

> **Test account.** Quick solutions, CF Worker forwarding, inbox checks.
> Account ID: `kpihx`

- **Labels:** `KpihX-Labs/{Ivann,KpihX,Contact}/In` + `{Ivann,KpihX,Contact}/Out`
- **Routing:** receives `kpihx@` + `contact@` + `ivann@` via CF Worker
- **Anti-spam:** 3 filters `to:<alias>` → removeLabelIds ["SPAM"] on 3 aliases

### 5. Labs — `kpihx.labs@gmail.com` (Ecosystem)

> **Ecosystem account.** Reports, GitHub/CI notifications, contact@ forwarding.
> Account ID: `kpihx.labs`

- **Labels:** `KpihX-Labs/Contact/In` + `KpihX-Labs/Contact/Out`
- **Routing:** receives `contact@` via CF Worker
- **Anti-spam:** 3 filters `to:<alias>` → removeLabelIds ["SPAM"] on 3 aliases

---

## Email Strategy

| Role | Account | Domain |
|---|---|---|
| Prof + perso | Zimbra (`ivann.kamdem-pouokam@polytechnique.edu`) | @polytechnique.edu |
| Personal non-academic | Hotmail (`ivann.kamdem@hotmail.com`) | @hotmail.com |
| Test / quick | kapoivha (`kapoivha@gmail.com`) | @gmail.com |
| Ecosystem | Labs (`kpihx.labs@gmail.com`) | @gmail.com |
| AX Workspace | `.2024` (`ivann.kamdem-pouokam.2024@polytechnique.org`) | @polytechnique.org |

## @kpihx-labs.com Routing

| Alias | Destinations | Via |
|---|---|---|
| `kpihx@` | Hotmail + kapoivha | CF Worker |
| `contact@` | Labs + kapoivha | CF Worker |
| `ivann@` | Hotmail | CF Worker |

**Send-as from Gmail:** kapoivha → `from_address:"kpihx@kpihx-labs.com"` · Labs → `from_address:"contact@kpihx-labs.com"` · Hotmail: no Send-as.

For details → `k-cloudflare/references/inbound-email-e2e.md`, `gmail-folders-filters.md`, `outlook-folders-rules.md`.

### Future Address Plan

| Address | Current | Future |
|---|---|---|
| `contact@` | Ecosystem/routing | → KpihX org |
| `kpihx@` | Test/quick | → perso+pro |
| `ivann@` | Restrictive | Inner circles only |

---

## What's up (mail briefing)

Timezone: **Europe/Paris**. **Preflight:** `mail-proxy admin status` + `mail-proxy do inbox-check '{"account_id":"ivann.kamdem"}'`. If fails → STOP.

**Steps:**
1. **Open pipelines** (flagged + Important) — `message-search` on INBOX, Archive, Sent
2. **Today poly/Zimbra** — sort by contact, blocks Admin/Academic/Professional (interest lens)
3. **Hotmail m365** — dedup with poly, highlight net-new
4. **Key contacts pulse** — Clément Liu Lokad, other recent threads
5. **Backward window** — yesterday + 7j unread
6. **Proactive close** — archive + TickTick proposals

Max exhaustiveness, 1 response per turn.

---

## Zimbra Tags

| Tag | Type | Scope |
|---|---|---|
| `Important` | IMAP keyword | Priority triage |
| `Hi-ParisAI:FLAG7760` | IMAP keyword | IPAI/HIPARIS |
| `Dx0` | IMAP keyword | Stage DXO |
| `Eco` | IMAP keyword | ECO |
| `\\Flagged` | System flag | Short-term follow-up |

## Attention Triggers

`@polytechnique.edu` · `@polytechnique.fr` · `@ip-paris.fr` · `@dxo.com` · `@lokad.com` · `@dgfip.finances.gouv.fr` · `@impots.gouv.fr` · `@ameli.fr` · `@idfmobilites.fr` · `@heyme.care` · `@lebara.fr` · `@notificationsclients.socgen.com` · `@societegenerale.fr` · DFHM

## Admins Unified Folder & Filter Standard

Single canonical folder `Admins` created on Gmail (`kapoivha` / `kpihx`) and Outlook (`ivann.kamdem@hotmail.com`) to track ultra-important administrative correspondence:
1. **Impôts / DGFiP / SIP** (`@dgfip.finances.gouv.fr`, `@impots.gouv.fr`, `timbres.impots.gouv.fr`, PayFiP)
2. **Services Publics / Gouv.fr** (`*.gouv.fr`, FranceConnect)
3. **Assurance Maladie / Ameli** (`@ameli.fr`, `@assurance-maladie.fr`, CPAM)
4. **Île-de-France Mobilités / Transports** (`@idfmobilites.fr`, `@iledefrance-mobilites.com`, `@agencenavigo.fr`, `@solidaritetransport.fr`)
5. **CROUS / Bourses & Logement** (`@lescrous.fr`, `@national.lescrous.fr`, Izly, MesServices)
6. **Heyme (Responsabilité Civile & Mutuelle Santé Étudiante)** (`@heyme.care`, Paybox HEYME, Universign)
7. **Lebara (Ligne Télécom mobile)** (`@lebara.fr`, `@lebara.com`)
8. **Société Générale (SG / Banque & Épargne)** (`@notificationsclients.socgen.com`, `@societegenerale.fr`, `@sg.fr`)

**Rule:** Non-destructive labelling (always keep a copy in Inbox, never auto-archive). Filter `ANe1BmjBAHPqNX8ssOZKEjFbfjn178UOWxTGpg` enforces auto-labeling on Gmail `kpihx`.

## Closure hygiene

Handled → **archive** via `message-archive`. 1:1 closed → archive thread. Still in INBOX → surface *Still to archive*.

## Open Threads

| Thread | Contacts | State |
|---|---|---|
| English certification | `certification-anglais-dlc@polytechnique.fr` | ✅ COMPLETED |
| IPAI Hackathon prize | `hannah.conrad@join-nxtgn.com` | Payout pending |
| Prix Gerondeau-Safran | `charlotte.milone@polytechnique.edu` | Candidature avec KUETE |
| Tax / Impôts (DGFiP / SIP Arpajon) | `sip.arpajon@dgfip.finances.gouv.fr` (Odile Dodinet), `ne-pas-repondre@dgfip.finances.gouv.fr` | Registered (9 Bd Maréchaux Palaiseau); `Admins` label & filter active on kapoivha & Hotmail |

## References & Scripts

- `references/gmail-folders-filters.md` · `references/outlook-folders-rules.md` · `references/insights.md` · `references/log.md`
- `inspect_gmail_filters_labels.sh` · `inspect_outlook_rules_folders.sh` · `setup_alias_folders_filters.sh`
- `references/mcp.md` — `mail-mcp` purged 2026-08-14. `mail-proxy` is sole transport.
- `references/tool-keep-matrix.md` — keep/drop matrix for mail tooling (what stays, what was purged and why).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-10 | [LIVE] | v2.86.0 humanize gate: humanize-guard.js hard PROSE dash gate, check-dashes.sh extended. |
| 2026-09-09 | [LIVE] | v2.85.x OpenCode Labs + AGY + Cursor providers, Copilot picker fix, account discovery, go-proxy purged. |
| [SUMMARY] | -- | v2.82.x footer refonte . v2.81.0 startup capped . v2.80.0 tmux SSH opt-in . v2.79.x claude-auth purged + Go 2nd account . older in references/log.md |


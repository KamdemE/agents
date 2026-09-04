---
name: k-mail
description: >
  Unified mail via mail-proxy. Zimbra, Hotmail, Gmail (kapoivha+Labs), Google Workspace .2024.
  Load before any mail workflow or What's up mail slice.
license: private
metadata:
  author: KpihX
  version: "3.0.0"
allowed-tools: Bash(*), *
---

# KπX — Mail

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **mail-proxy is the sole transport.** No MCP, no mail-mcp. Run `mail-proxy do <action>` for everything.

## ⛔ Signature & Body Rule (CRITICAL — GRAVÉ)

1. **NEVER include `signature` in payload** unless KπX explicitly names one. Absent = default. **NEVER** `signature: ""`.
2. **NEVER include personal info** in body. End with **"Cordialement,"**, **"Bien cordialement,"**, **"Cdt,"** / **"Best regards,"**, **"Kind regards,"**, **"Yours sincerely,"** — signature block handles the rest.
3. When asked "include signature", don't add `signature:"default"` — it's the default when omitted.

## Runtime Discipline

- **Sole transport:** `mail-proxy do <action>`. No MCP, no HTTP backend.
- **tmux ONLY for Zimbra** (password prompt needed). All other accounts → run directly in agent shell (no tmux).
- **Never pipe/redirect** mail-proxy commands (hooks will block). If output truncated → read autosave at `~/.config/mail-proxy/autosave/`.
- **`message-archive` over `message-move`** — auto-detects folder name (Archive, [Gmail]/Tous les messages, [Gmail]/All Mail).
- Read `references/insights.md` before mail tasks. Append to `references/log.md`.
- **Post-send verification:** wait ~5s, check Sent + INBOX for bounces (mandatory).
- **Closure hygiene:** archive after handling; nudge if still in INBOX on subsequent turns.
- **M365 auth:** never `m365 login` / `logout`. Auth is KπX-owned. If token expired → ask KπX to re-auth manually.

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

> **L'account utilisé le plus souvent.** Mail académique, pro, et perso.
> Account ID: `ivann.kamdem-pouokam` | Auth: password (tmux only, keyring 20min)

- **Folders:** INBOX · Sent · Archive · Drafts · Outbox · Junk · Trash (7 flat)
- **Native tags:** `Important` · `Dx0` (stage DXO) · `Hi-ParisAI:FLAG7760` (IPAI) · `4A` · `Stage` · `Eco`
- **Cmds:** `zimbra-tag-list` pour voir les tags, `zimbra-tag-create/delete/apply/remove` pour gérer
- **Signature:** Ivann KAMDEM · ÉCOLE POLYTECHNIQUE · EIX X2024

**Key contacts:**

| Address | Role | Pri |
|---------|------|-----|
| `scolarite.1a-2a@polytechnique.fr` | Admin PSC/stages/examens | CRIT |
| `noreply@ip-paris.fr` | Moodle notes/QCM | CRIT |
| `henry.develey@polytechnique.edu` | Cdt DEVELEY DFHM | HIGH |
| `mathieu.lesoualch@polytechnique.edu` | Adj LESOUALCH DFHM | HIGH |
| `vincent.beurel@polytechnique.edu` | Directives/évaluations | HIGH |
| `camille.challant@polytechnique.edu` | Notes/calendrier | HIGH |
| `anne.taupin@polytechnique.edu` | Career Center stage 2A | HIGH |
| `stages.x2a@polytechnique.fr` | Bureau stages officiel | HIGH |
| `pauline.alessandra@polytechnique.edu` | IME (⚠️ @polytechnique.edu only, .fr invalid) | HIGH |
| `rsapaico@dxo.com` | DXO stage | ACTIVE |
| `mschermann@dxo.com` | DXO CEO | ACTIVE |
| `charlotte.milone@polytechnique.edu` | Prix Gerondeau-Safran | IMP |
| `johannes.lutzeyer@polytechnique.edu` | PSC Lokad supervisor | PSC |

**Frequent contacts:** `info@ax.polytechnique.org` (newsletter AX/X-IA), `messages-noreply@linkedin.com`, `jobalerts-noreply@linkedin.com` (offres stage), `financialaid@polytechnique.fr` (CROUS), `alexis.ruel@polytechnique.edu` (badges)

**Key knowledge:**
- **Template demande d'absence** : chercher dans `Archive` le mail avec sujet contenant "demande d'absence" — le modèle complet (destinataire, objet, corps avec dates) est dans un mail ancien réutilisable tel quel.
- **Adressing rule:** `@polytechnique.edu` UNIQUEMENT — `.fr` = SMTP 550 Non-existent address.
- **Poste:** X24, EIX — signature pro : Ivann KAMDEM · ÉCOLE POLYTECHNIQUE · EIX X2024

### 2. Hotmail — `ivann.kamdem@hotmail.com` (Perso non-acad)

> **Secondaire.** Mail perso non-académique. Reçoit les forwards CF Worker pour `kpihx@` et `ivann@`.
> Account ID: `ivann.kamdem` | Auth: OAuth2 device code (tokens `~/.cli-m365-*`)

- **Folders:** Inbox · Sent · Archive · Drafts · Junk · Deleted (6)
- **Rules:** 3 KpihX inbound (`contact@`/`kpihx@`/`ivann@` → moveToFolder + copyToFolder dossier)
- **Dossiers `@kpihx-labs.com` :** `KpihX-Labs/Ivann/In` + `KpihX-Labs/KpihX/In`
- **Routing:** reçoit `kpihx@` + `ivann@` via CF Worker

**Frequent contacts:** `clement.liu@lokad.com` (PSC INF01 coordinator, CC on Hotmail), `info@ax.polytechnique.org` (newsletter AX), `financialaid@polytechnique.fr` (CROUS notifications), `vincent.beurel@polytechnique.edu` (DFHM directives)

### 3. `.2024` — `ivann.kamdem-pouokam.2024@polytechnique.org` (AX Workspace)

> **Compte Google Workspace offert par l'AX** — 100 Go, tous les services Google (Gmail, Drive, Calendar, Meet).
> Account ID: `ivann.kamdem-pouokam.2024`

- **Redirection:** tous les mails reçus sont automatiquement **redirectés vers Hotmail + Zimbra** (configuré sur le site `polytechnique.org`, pas sur Gmail lui-même)
- **Usage:** tests, envois de validation, comptes de service. Utile comme « source neutre » pour tester le routing @kpihx-labs
- **Folders:** INBOX · Sent Mail · [Gmail] standard

**Frequent contacts:** principalement des notifications Google (sign-in alerts, data sharing), des notifications npmjs/Oracle Cloud, et les emails de test que l'on envoie pour valider le routing.

### 4. kapoivha — `kapoivha@gmail.com` (Test / Quick solutions)

> **Compte de test.** Solutions rapides, forwarding CF Worker, vérifications inbox.
> Account ID: `kpihx`

- **Labels:** `KpihX-Labs/{Ivann,KpihX,Contact}/In` + `{Ivann,KpihX,Contact}/Out`
- **Routing:** reçoit `kpihx@` + `contact@` + `ivann@` via CF Worker
- **Anti-spam:** 3 filtres `to:<alias>` → removeLabelIds ["SPAM"] sur les 3 aliases

**Frequent contacts:** notifications GitHub, npmjs (packages), OpenCode receipts, security alerts Google, newsletters (Towards Data Science, Meta Connect), Oracle Cloud.

### 5. Labs — `kpihx.labs@gmail.com` (Écosystème)

> **Compte écosystème.** Rapports, notifications GitHub/CI, forwarding contact@.
> Account ID: `kpihx.labs`

- **Labels:** `KpihX-Labs/Contact/In` + `KpihX-Labs/Contact/Out`
- **Routing:** reçoit `contact@` via CF Worker
- **Anti-spam:** 3 filtres `to:<alias>` → removeLabelIds ["SPAM"] sur les 3 aliases

---

## Email Strategy

| Rôle | Compte | Domaine |
|---|---|---|
| Prof + perso | Zimbra (`ivann.kamdem-pouokam@polytechnique.edu`) | @polytechnique.edu |
| Perso non-acad | Hotmail (`ivann.kamdem@hotmail.com`) | @hotmail.com |
| Test / quick | kapoivha (`kapoivha@gmail.com`) | @gmail.com |
| Écosystème | Labs (`kpihx.labs@gmail.com`) | @gmail.com |
| AX Workspace | `.2024` (`ivann.kamdem-pouokam.2024@polytechnique.org`) | @polytechnique.org |

## @kpihx-labs.com Routing

| Alias | Destinations | Via | Refs |
|---|---|---|---|
| `kpihx@` | Hotmail + kapoivha | CF Worker | `k-cloudflare/references/inbound-email-e2e.md` |
| `contact@` | Labs + kapoivha | CF Worker | `k-cloudflare/references/inbound-email-e2e.md` |
| `ivann@` | Hotmail | CF Worker | `k-cloudflare/references/inbound-email-e2e.md` |

**Envoyer depuis les 2 Gmail (Send-as aliases) :**
- kapoivha : `from_address:"kpihx@kpihx-labs.com"` ou `"ivann@kpihx-labs.com"`
- Labs : `from_address:"contact@kpihx-labs.com"`
- Hotmail : pas de Send-as configuré

Pour plus de détails sur le Worker, filtres, dossiers → `k-cloudflare/references/inbound-email-e2e.md`, `gmail-folders-filters.md`, `outlook-folders-rules.md`.

### Future Address Plan

| Adresse | Actuel | Futur |
|---|---|---|
| `contact@` | Ecosystem/routing | → orga KpihX |
| `kpihx@` | Test/quick | → perso+pro (remplacer Hotmail) |
| `ivann@` | Restrictive | Cercles serrés uniquement |

---

## What's up (mail briefing)

Timezone: **Europe/Paris**. **Preflight:** `mail-proxy admin status` + `mail-proxy do inbox-check '{"account_id":"ivann.kamdem"}'`. Si échoue → STOP.

**Steps:**
1. **Open pipelines** (flagged + Important) — `message-search` sur INBOX, Archive, Sent
2. **Today poly/Zimbra** — tri par contact, blocs Admin/Academic/Professional (interest lens)
3. **Hotmail m365** — dedup avec poly, highlight net-new
4. **Key contacts pulse** — Clément Liu Lokad, autres threads récents
5. **Backward window** — yesterday + 7j unread
6. **Proactive close** — archive + TickTick proposals

Max exhaustivité, 1 seule réponse par tour.

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

`@polytechnique.edu` · `@polytechnique.fr` · `@ip-paris.fr` · `@dxo.com` · `@lokad.com` · DFHM

## Closure hygiene

Handled → **archive** via `message-archive`. 1:1 closed → archive thread. Still in INBOX → surface *Still to archive*.

## Open Threads

| Thread | Contacts | State |
|---|---|---|
| English certification | `certification-anglais-dlc@polytechnique.fr` | ✅ COMPLETED |
| IPAI Hackathon prize | `hannah.conrad@join-nxtgn.com` | Payout pending |
| Prix Gerondeau-Safran | `charlotte.milone@polytechnique.edu` | Candidature avec KUETE |

## References

- `references/gmail-folders-filters.md` — Gmail labels & filters SOT
- `references/outlook-folders-rules.md` — Hotmail folders & rules SOT
- `references/insights.md` · `references/log.md` · `references/mcp.md` (LEGACY) · `references/tool-keep-matrix.md`

## Scripts

`inspect_gmail_filters_labels.sh` · `inspect_outlook_rules_folders.sh` · `setup_alias_folders_filters.sh`

## Legacy

`references/mcp.md` — `mail-mcp` purged 2026-08-14. `mail-proxy` is sole transport.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-04 | [LIVE] | v3.0.0 — Mail-proxy sole transport; signature/body rule; 5 accounts; routing + future plan; command reference; Gmail/Outlook SOTs. |
| [SUMMARY] | — | v2.3.0 Gmail/Outlook SOTs + scripts · v2.2.5 MCP purge · older → `references/log.md` |

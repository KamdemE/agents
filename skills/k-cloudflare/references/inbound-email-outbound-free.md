# Outbound `@<yourdomain.com>` — free tier (Gmail Send-as)

> **Inbound** is live (CF Email Routing + Worker). **Cloudflare does not provide outbound SMTP.**  
> This doc covers the **zero-subscription** path so replies look like they come from `personal@`, `mail@`, or `contact@`.

## Target UX

| Alias | Typical mailbox you use | Inbound (done) | Outbound (this doc) |
|-------|-------------------------|----------------|---------------------|
| `personal@<yourdomain.com>` | Hotmail (read) | → Hotmail | Send-as on **<primary@gmail.com>** |
| `mail@<yourdomain.com>` | Hotmail + kapoivha (read) | → both | Send-as on **<primary@gmail.com>** |
| `contact@<yourdomain.com>` | Labs Gmail | → Labs + kapoivha | Send-as on **`<labs@gmail.com>`** |

**Illusion for the other party:** they only see `@<yourdomain.com>` in From/Reply-To when you pick that identity at compose time (and on reply, if “Reply from same address” is configured).

## Method — Gmail SMTP “Send mail as” (free)

Works with **free Gmail** (not Google Workspace). Same pattern for **Gmail web**, **Outlook.com** (SMTP custom send), and **m365**-adjacent clients that accept SMTP.

### Per mailbox

1. **2FA** on the backing Gmail (or Google account tied to the client).
2. **App password:** Google Account → Security → App passwords → Mail.
3. **Add send-as address** (Gmail: Settings → Accounts → *Send mail as* → Add another email address):
   - Name: public identity (e.g. ``)
   - Address: `contact@<yourdomain.com>` (or `mail@`, `personal@`)
   - **Untick** “Treat as an alias” if you want separate sent-folder behaviour (optional).
4. **SMTP (not Cloudflare):**

   | Field | Value |
   |-------|--------|
   | Server | `smtp.gmail.com` |
   | Port | `587` |
   | Security | TLS |
   | Username | full Gmail login (`<labs@gmail.com>` or `<primary@gmail.com>`) |
   | Password | **App password** from step 2 |

5. **Verification:** Gmail sends a code to the alias → CF forwards to the inbox that already receives that alias → open link / enter code.

6. **Compose:** choose the `@<yourdomain.com>` address in **From**; on **Reply**, Gmail/Outlook usually pre-selects the address the message was sent to.

### Outlook / Hotmail (consumer)

Outlook on the web: **Settings → Mail → Forwarding and IMAP** or **Sync email** → add the same SMTP send account (provider “Gmail” / custom SMTP with `smtp.gmail.com`).  
**Limitation:** Graph `m365 outlook mail send --from` does **not** override From on personal tenants (403). Use the Outlook UI or Gmail with send-as.

## DNS (deliverability)

Update apex **SPF** on `<github-user>.com` (merge, do not duplicate TXT records):

```txt
v=spf1 include:_spf.google.com include:_spf.mx.cloudflare.net ~all
```

Optional **DMARC** (monitoring first):

```txt
_dmarc.<github-user>.com  TXT  "v=DMARC1; p=none; rua=mailto:<primary@gmail.com>"
```

**DKIM caveat (free Gmail SMTP):** Google signs with `gmail.com` unless you use a relay with domain DKIM (Brevo, SES, Postmark). Recipients may see “via gmail.com” — still fine for personal/pro use; upgrade to **Brevo free tier** (domain DKIM) if you need stricter alignment (Path A in `sovereign-email-universe-vision.md`).

## Alternative — Brevo free (better From: alignment)

| Item | Detail |
|------|--------|
| Cost | Free tier (~300 emails/day) |
| Setup | Domain + DKIM in Brevo; SMTP creds in Gmail/Outlook send-as **or** Brevo UI |
| When | You want minimal “via gmail.com” and slightly stronger deliverability |

Not required while inbound-only + occasional replies via Gmail send-as.

## What not to use for outbound

| Approach | Why |
|----------|-----|
| Cloudflare Email Routing | Receive/forward only — no send SMTP |
| Hotmail → `personal@` → Hotmail loop test | NDR / S3150 — routing works; test from external sender |
| `m365 login` as agent | User-owned auth only |

##  layout (recommended)

| Alias | Send-as UI | SMTP login | App password account |
|-------|------------|------------|----------------------|
| `contact@` | **Labs Gmail** | `<labs@gmail.com>` | Labs Google account |
| `mail@` | **Outlook Hotmail** | `<primary@gmail.com>` | kapoivha Google account |
| `personal@` | **kapoivha Gmail** send-as (read on Hotmail) | `<primary@gmail.com>` | A2 — **not** outlook.live.com web (Connected accounts removed) |
| `mail@` | **kapoivha Gmail** send-as (read on Hotmail) | `<primary@gmail.com>` | A2 |

**Live checklist:** `references/outbound-setup-status.md`

## DNS (agent-applied 2026-05-25)

- **SPF apex:** `v=spf1 include:_spf.google.com include:_spf.mx.cloudflare.net ~all`
- **_dmarc:** ✅ LIVE `v=DMARC1; p=none; rua=mailto:<primary@gmail.com>`

## Checklist ()

- [ ] App passwords (Labs + kapoivha) — see `outbound-setup-status.md` Phase A
- [ ] `contact@` send-as on **Labs Gmail**
- [x] `personal@` + `mail@` send-as on **kapoivha Gmail** (`accepted`)
- [x] `contact@` send-as on **Labs Gmail** (`accepted`)
- [x] Agent verify + test send (gws); m365 = Hotmail default only (no `--from`)

## QMD keywords

`outbound`, `send mail as`, `Gmail SMTP`, `spf google cloudflare`, `Brevo free`, `contact@`, `personal@`, `mail@`

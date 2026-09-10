# Inbound email — E2E verification (`@<yourdomain.com>`)

> **Status:** validated **2026-09-04** (Worker + prime rules + anti-spam + folders/labels on all mailboxes).  
> **Routing SOT:** `email-routing-ops.md` · **Deploy:** `scripts/deploy-inbound-email-full.sh` · **Anti-spam:** `scripts/apply-inbound-antispam-filters.sh` · **Verify:** `scripts/verify-inbound-e2e.sh`

## Live route map

| Alias | Destinations | Do not test with |
|-------|----------------|------------------|
| `mail@<yourdomain.com>` | Hotmail + `<primary@gmail.com>` | Hotmail → `mail@` (loop / S3150 risk) |
| `contact@<yourdomain.com>` | Labs + `<primary@gmail.com>` | — |
| `personal@<yourdomain.com>` | Hotmail + `<primary@gmail.com>` | Hotmail → `personal@` (NDR loop) |

**Internal (do not publish):** `_prime-labs@`, `_prime-kapoivha@`, `_prime-hotmail@` — native `forward` so Worker `message.forward()` sees verified destinations.

## Anti-spam (all mailboxes)

**Goal:** any sender → alias `@<yourdomain.com>` → forward must not stay in spam/junk.

| Mailbox | Mechanism | Aliases covered |
|---------|-----------|-----------------|
| **<primary@gmail.com>** | Gmail filter `to:<alias>` → `removeLabelIds: ["SPAM"]` | contact, mail, personal |
| **<labs@gmail.com>** | Same | contact, mail, personal |
| **<personal@hotmail.com>** | Outlook **inbox** `messageRule` — `sentToAddresses` → `moveToFolder` inbox | contact, mail, personal |

**Apply / refresh (idempotent):**

```bash
"$HOME/.agents/skills/k-cloudflare/scripts/apply-inbound-antispam-filters.sh"
```

**Hotmail limit:** Graph returns **400** for `junkemail/messageRules` — inbox rules only. If mail still lands in *Courrier indésirable*, add a manual Junk rule in Outlook (same `to:` aliases) or mark once + rely on sender reputation.

### Gmail filter IDs (2026-05-25)

| Mailbox | Query | Filter id |
|---------|-------|-----------|
| **kapoivha** | `to:contact@<yourdomain.com>` | `ANe1BmgYXyGbQ9yOGe52rcu1ikbMelX0SKC01g` |
| **kapoivha** | `to:mail@<yourdomain.com>` | `ANe1BmiarfGeNFaEQCS87eFEzqEhwzWMKbkNvg` |
| **kapoivha** | `to:you@<yourdomain.com>` | `ANe1BmhDyzgYP1vvbdZ0Jlmrt90XoDqjqcLgJw` |
| **Labs** | `to:contact@<yourdomain.com>` | `ANe1Bmgdn_LuaYZcQaxwmQF7jf93BvQAQIPwuw` |
| **Labs** | `to:mail@<yourdomain.com>` | `ANe1Bmj4ZDOSoKsGOvrMbxlOGUY0aEb6w1UIrg` |
| **Labs** | `to:you@<yourdomain.com>` | `ANe1Bmg-Ueqm0ORnsKSvZQUsmYreT_AfwITFeQ` |

### Outlook inbox rule IDs (2026-05-25)

| Rule | Graph id |
|------|----------|
|  inbound contact (inbox) | `AQAAAREMtq0=` |
|  inbound kpihx (inbox) | `AQAAAREMtq4=` |
|  inbound ivann (inbox) | `AQAAAREMtq8=` |

List: `m365 request -u 'https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules' -m get`

## Recommended send matrix (avoids false negatives)

| Goal | Sender | Target alias |
|------|--------|--------------|
| Hotmail inbox | `<primary@gmail.com>` | `personal@`, `mail@` |
| kapoivha inbox | `<personal@hotmail.com>` | `mail@`, `contact@` |
| Labs inbox | `<primary@gmail.com>` or Hotmail | `contact@` |

**Self-send traps:** kapoivha → alias → kapoivha often shows **SENT only** (no second Inbox). Hotmail → alias → Hotmail → **Undeliverable** / S3150.

## Tooling prerequisites

| Tool | Requirement |
|------|-------------|
| **Gmail API** | `command gws` or `$HOME/.npm-global/bin/gws` + profile env (see `k-google`) |
| **Hotmail** | `m365 request` after user device login — never `m365 login` / `m365 logout` as agent |
| **m365 POST** | `-b @body.json` **`--content-type application/json`** |

Strip CLI banner before `jq`: `awk '/^\{/{p=1} p'`

## Quick verify (read-only)

```bash
"$HOME/.agents/skills/k-cloudflare/scripts/verify-inbound-e2e.sh" "E2E-BILAN"
```

## QMD keywords

`inbound E2E`, `anti-spam filter`, `apply-inbound-antispam-filters`, `gws-labs`, `gws-primary`, `messageRules`, `verify-inbound-e2e`

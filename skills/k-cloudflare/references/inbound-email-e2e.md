# Inbound email — E2E verification (`@kpihx-labs.com`)

> **Status:** validated **2026-09-04** (Worker + prime rules + anti-spam + folders/labels on all mailboxes).  
> **Routing SOT:** `email-routing-ops.md` · **Deploy:** `scripts/deploy-inbound-email-full.sh` · **Anti-spam:** `scripts/apply-inbound-antispam-filters.sh` · **Verify:** `scripts/verify-inbound-e2e.sh`

## Live route map

| Alias | Destinations | Do not test with |
|-------|----------------|------------------|
| `kpihx@kpihx-labs.com` | Hotmail + `kapoivha@gmail.com` | Hotmail → `kpihx@` (loop / S3150 risk) |
| `contact@kpihx-labs.com` | Labs + `kapoivha@gmail.com` | — |
| `ivann@kpihx-labs.com` | Hotmail + `kapoivha@gmail.com` | Hotmail → `ivann@` (NDR loop) |

**Internal (do not publish):** `_prime-labs@`, `_prime-kapoivha@`, `_prime-hotmail@` — native `forward` so Worker `message.forward()` sees verified destinations.

## Anti-spam (all mailboxes)

**Goal:** any sender → alias `@kpihx-labs.com` → forward must not stay in spam/junk.

| Mailbox | Mechanism | Aliases covered |
|---------|-----------|-----------------|
| **kapoivha@gmail.com** | Gmail filter `to:<alias>` → `removeLabelIds: ["SPAM"]` | contact, kpihx, ivann |
| **kpihx.labs@gmail.com** | Same | contact, kpihx, ivann |
| **ivann.kamdem@hotmail.com** | Outlook **inbox** `messageRule` — `sentToAddresses` → `moveToFolder` inbox | contact, kpihx, ivann |

**Apply / refresh (idempotent):**

```bash
"$HOME/.agents/skills/k-cloudflare/scripts/apply-inbound-antispam-filters.sh"
```

**Hotmail limit:** Graph returns **400** for `junkemail/messageRules` — inbox rules only. If mail still lands in *Courrier indésirable*, add a manual Junk rule in Outlook (same `to:` aliases) or mark once + rely on sender reputation.

### Gmail filter IDs (2026-05-25)

| Mailbox | Query | Filter id |
|---------|-------|-----------|
| **kapoivha** | `to:contact@kpihx-labs.com` | `ANe1BmgYXyGbQ9yOGe52rcu1ikbMelX0SKC01g` |
| **kapoivha** | `to:kpihx@kpihx-labs.com` | `ANe1BmiarfGeNFaEQCS87eFEzqEhwzWMKbkNvg` |
| **kapoivha** | `to:ivann@kpihx-labs.com` | `ANe1BmhDyzgYP1vvbdZ0Jlmrt90XoDqjqcLgJw` |
| **Labs** | `to:contact@kpihx-labs.com` | `ANe1Bmgdn_LuaYZcQaxwmQF7jf93BvQAQIPwuw` |
| **Labs** | `to:kpihx@kpihx-labs.com` | `ANe1Bmj4ZDOSoKsGOvrMbxlOGUY0aEb6w1UIrg` |
| **Labs** | `to:ivann@kpihx-labs.com` | `ANe1Bmg-Ueqm0ORnsKSvZQUsmYreT_AfwITFeQ` |

### Outlook inbox rule IDs (2026-05-25)

| Rule | Graph id |
|------|----------|
| KpihX inbound contact (inbox) | `AQAAAREMtq0=` |
| KpihX inbound kpihx (inbox) | `AQAAAREMtq4=` |
| KpihX inbound ivann (inbox) | `AQAAAREMtq8=` |

List: `m365 request -u 'https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules' -m get`

## Recommended send matrix (avoids false negatives)

| Goal | Sender | Target alias |
|------|--------|--------------|
| Hotmail inbox | `kapoivha@gmail.com` | `ivann@`, `kpihx@` |
| kapoivha inbox | `ivann.kamdem@hotmail.com` | `kpihx@`, `contact@` |
| Labs inbox | `kapoivha@gmail.com` or Hotmail | `contact@` |

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

`inbound E2E`, `anti-spam filter`, `apply-inbound-antispam-filters`, `gws-labs`, `gws-kpihx`, `messageRules`, `verify-inbound-e2e`

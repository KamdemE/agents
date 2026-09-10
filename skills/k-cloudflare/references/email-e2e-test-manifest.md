# E2E / outbound test mail manifest (2026-05-25)

> **Archive:** `"$HOME/.agents/skills/k-cloudflare/scripts/archive-inbound-e2e-tests.sh"`  
> **Do not delete** — archive only (Gmail: remove `INBOX`; Hotmail: move to Archive).

## Subject patterns (agent + )

| Pattern | Purpose |
|---------|---------|
| `E2E …` | Inbound routing matrix (Worker, prime rules) |
| `E2E-FINAL*` / `E2E-FINAL2`–`4` | Batch routing validation |
| `E2E-BILAN …` | Proof `personal@` → Hotmail |
| `OUT-E2E-*` | Outbound send-as verification (gws / m365) |
| `Gmail Confirmation … <github-user>.com` | Send-as verify (forwarded to Hotmail) |
| `Undeliverable: E2E` | Hotmail loop / S3150 (expected failure) |

## Counts archived (2026-05-25 run)

| Mailbox | Archived | Notes |
|---------|----------|--------|
| **<primary@gmail.com>** | **31** | E2E/OUT-E2E + forwards; excludes unrelated "Bilan" newsletters |
| **<labs@gmail.com>** | **18** | Mostly `contact@` routing tests |
| **<personal@hotmail.com>** | **13** | E2E-FINAL*, OUT-E2E-M365, Gmail Confirmation |

Re-run inventory: tight Gmail query in archive script header.

## QMD keywords

`E2E archive`, `OUT-E2E`, `test mail manifest`, `archive-inbound-e2e-tests`

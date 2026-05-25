# Meta Graph + WhatsApp Cloud — KπX (`Meta Dev`)

> **Skill:** `k-meta` · **WA messaging:** `k-whatsapp` (whats-mcp) · **Registry:** `k-cloud-tools/references/social-dev-platforms.md`

## Secrets JSON

**Path:** `$HOME/.config/kpihx/meta/credentials.json` · `chmod 600` · **never commit** (outside `.agents/` repo)

| JSON key | Vault **Meta Dev** field |
|----------|--------------------------|
| `app_id` | `META_APP_ID` |
| `app_secret` | `META_APP_SECRET` |
| `business_id` | `META_BUSINESS_ID` |
| `wa_phone_number_id` | `META_WA_PHONE_NUMBER_ID` |
| `wa_number` | `META_WA_NUMBER` (E.164, e.g. `+33605957785`) |
| `waba_id` *(optional)* | `META_WA_BUSINESS_ACCOUNT_ID` |
| `system_user_access_token` *(optional)* | `META_SYSTEM_USER_ACCESS_TOKEN` (Business Manager System User) |

**Sync from bw-env (if env complete):**

```bash
cd "$HOME/.agents/skills/k-meta/scripts"
uv run python sync_creds_from_env.py
```

## Smoke test

```bash
uv sync
uv run python meta_cli.py --creds-file "$HOME/.config/kpihx/meta/credentials.json"
```

**Tiers:**

| Tier | Steps | Token |
|------|--------|-------|
| **Core** (exit 0 if OK) | app token → app name | App (`client_credentials`) |
| **Extended** | WA phone, WABA phone list, business | **System User** access token |

Live status: `references/smoke-status.md`.

## Scope split

| Layer | Skill / tool |
|-------|----------------|
| Graph app token, WA phone metadata | **`k-meta`** · `meta_cli.py` |
| Send/receive WhatsApp messages | **`k-whatsapp`** · whats-mcp |
| FB Page / IG publish | Graph endpoints (future `meta_cli` subcommands) |

## QMD keywords

`Meta Dev`, `Graph API`, `credentials.json`, `wa_phone_number_id`

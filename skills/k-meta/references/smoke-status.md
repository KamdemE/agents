# Meta smoke status (KπX)

| Date | Layer | Result |
|------|--------|--------|
| 2026-05-25 | **Core** (app token + app `KpihX-Labs`) | ✅ HTTP 200 |
| 2026-05-25 | **WA phone** (Graph on `wa_phone_number_id`) | ⚠️ HTTP 400 with **app** token — needs **System User** token |
| 2026-05-25 | **Business** (`business_id`) | ⚠️ Skipped / 400 with app token — same token class |

## JSON

**Path:** `$HOME/.config/kpihx/meta/credentials.json` · mode `600` · **filled** (2026-05-25).

## Optional keys (extended smoke)

| JSON key | Env fallback | Purpose |
|----------|--------------|---------|
| `system_user_access_token` | `META_SYSTEM_USER_ACCESS_TOKEN` | WA phone + business Graph reads |
| `waba_id` | `META_WA_BUSINESS_ACCOUNT_ID` | `GET /{waba_id}/phone_numbers` |

Generate System User token: Meta Business Manager → **System users** → generate token with `whatsapp_business_management` (+ messaging if needed).

## Messaging

Live WhatsApp send/receive → **`k-whatsapp`** / whats-mcp (not `meta_cli`).

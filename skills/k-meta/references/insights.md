# k-meta insights

## 2026-05-25 — [CURSOR] bootstrap

- **Graph app token:** `GET /oauth/access_token` with `client_credentials` — use **app_id** + **app_secret** from JSON, not user password.
- **WA ops:** Phone Number ID in JSON is for Cloud API; live chat → **`k-whats`** / whats-proxy.
- **Vaultwarden mutation:** prefer `$HOME/.config/kpihx/meta/credentials.json` + `sync_creds_from_env.py` when only partial META_* in env.
- **Smoke 2026-05-25:** JSON filled — **core** (app + `Labs`) ✅; **WA phone / business** need **System User** token, not app token (Graph code 102 / 100).
- **WABA list:** `GET /{waba_id}/phone_numbers` may fail if `META_WA_BUSINESS_ACCOUNT_ID` is not a WABA node id — confirm in Business Manager → WhatsApp accounts.

# k-x insights

## 2026-05-25 — [CURSOR] X Dev bootstrap

- **`GET /2/users/me`:** OAuth **1.0a** (API key + user access token) works; **Bearer alone returns 403** on this endpoint.
- **Account:** `@KPIHX7` · user id `1643990993983926280`.
- **402 CreditsDepleted:** `POST /2/tweets` and timeline reads fail until credits are added on https://developer.x.com/ — not a wrong secret.
- **Secrets:** `bw-env` from Vault **X Dev** is enough; optional `$HOME/.config/kpihx/x/credentials.json` for non-bw shells (see `x-dev-setup.md`).
- **Do not use** `X_BEARER_TOKEN` for user-context automation; keep for app-only endpoints if documented in X portal.

# k-media insights

## 2026-05-25 — [CURSOR] YouTube on <github-user>

- **`youtube.googleapis.com`** enable via `gcloud services enable` — idempotent; project number `747851806672`.
- **OAuth client already exists** for `gws-labs` (Desktop, `http://localhost`) — do not create a second client unless rotating secrets.
- **`gws` CLI** does not list YouTube in Discovery — uploads need **`google-api-python-client`** or REST, not `gws youtube …`.
- **Consent screen scopes** are console-only; existing `gws-labs` token lacks `youtube.upload` until  re-auths with new scopes.
- **Google Auth Platform UI (2025+):** scopes live under **Data access**, not **Branding**. `gcloud iap oauth-*` is IAP-only — do not use for YouTube Desktop client.
- **Verification:** External app + `youtube.upload` → Google app review before non–test-user production use.
- **CLI (2026-05-25):** `k-media/scripts/youtube_cli.py` + `uv sync` — token at `youtube_token.json`; channel `UCtPBmyE3EO1zHwL3UY_-H0A` (`@kpihx`). Prefer **minimal** consent scopes (`readonly`+`upload`) even if console allows more.
- **Upload quota:** ~1600 units per upload; smoke video 2s black MP4 via ffmpeg OK.

## 2026-05-25 — [CURSOR] Meta + X JSON

- **Meta JSON core:** app `client_credentials` + `GET /{app_id}` ✅; WA phone + business need **System User** token (not app token).
- **X JSON:** OAuth1 quad in `$HOME/.config/kpihx/x/credentials.json` — `me` ✅; `POST /2/tweets` still **402** until developer credits purchased.

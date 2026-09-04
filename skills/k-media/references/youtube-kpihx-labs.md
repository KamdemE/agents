# YouTube Data API v3 — project `kpihx-labs`

> **Owner skill:** `k-media` · **GCP/gws:** `k-google` (`gws-labs`) · **Registry:** `k-clis/references/social-dev-platforms.md`

## Agent-done (2026-05-25)

| Step | Status |
|------|--------|
| Project `kpihx-labs` active | ✅ `747851806672` |
| `youtube.googleapis.com` enabled | ✅ |
| OAuth consent scopes (KπX console) | ✅ YouTube scopes added (Data access) |
| OAuth token (YouTube) | ✅ `$HOME/.config/gws/kpihx-labs/youtube_token.json` |
| `channels.list` | ✅ `@kpihx` · id `UCtPBmyE3EO1zHwL3UY_-H0A` |
| Upload smoke (unlisted) | ✅ `Ij_75ESPV3U` · title `KpihX API smoke 20260525-0915` |

**CLI:** `"$HOME/.agents/skills/k-media/scripts/README.md"`

Re-run checks: `youtube_gcp_bootstrap.sh` · `uv run python youtube_cli.py channels`

## KπX manual procedure (console) — ✅ done 2026-05-25

### 1 — OAuth consent screen (scopes) — done

> **Not in `gcloud`:** Google has **no public API** to add consent-screen scopes for normal OAuth apps (only IAP-specific `gcloud iap oauth-brands`, which does **not** apply to your Desktop `gws-labs` client). Scopes = **console only**.

**New UI (Google Auth Platform)** — you are on **Branding**; scopes are elsewhere:

1. Same project: https://console.cloud.google.com/auth?project=kpihx-labs  
2. Left menu → **Data access** (not Branding / not Clients).  
3. **Add or remove scopes** → filter **YouTube Data API v3** → tick:
   - `.../auth/youtube.upload`
   - `.../auth/youtube.readonly`
4. **Audience** (left menu) → **Test users** → add `kpihx.labs@gmail.com` (+ `kapoivha@gmail.com` if channel owner).  
5. **Branding** (optional): privacy policy URL helps later verification — can use `https://kpihx-labs.com` when ready.

Legacy path (if UI differs): APIs & Services → OAuth consent screen → Scopes.

### 2 — OAuth client (usually done)

- https://console.cloud.google.com/apis/credentials?project=kpihx-labs  
- Type **Desktop app** — same client as `gws-labs` / `client_secret.json`.  
- If you create a **new** client → replace `client_secret.json` and re-run `gws auth` for labs profile.

### 3 — YouTube channel

- Log in with the Google account that should **own** the KπX channel (likely `kpihx.labs@gmail.com`).  
- https://www.youtube.com/account → create channel or confirm existing.

### 4 — First OAuth with YouTube scopes

`gws` Discovery CLI may not expose YouTube — use one of:

**A — Recommended:** small Python script in `$HOME/Work/AI/` using `google-api-python-client` + same `client_secret.json` (installed-app flow, localhost redirect).

**B — OAuth Playground** (quick test only): https://developers.google.com/oauthplayground/ · use own client · select YouTube v3 scopes · exchange refresh token → store in Vault item **YouTube Dev** (custom fields, no commit).

### 5 — Smoke tests (after token has YouTube scopes)

| Test | API | Quota cost |
|------|-----|------------|
| List my channel | `channels.list` `mine=true` | low |
| Upload **unlisted** short test | `videos.insert` | **~1600 units** |

### 6 — Production / public app

- Scope `youtube.upload` on **External** apps → Google **verification** (2–4 weeks).  
- Until verified: stay in **Testing** + test users, uploads **unlisted/private** only.

## Quota (free tier)

- **10 000 units/day** · upload ≈ **1600** → ~**6 uploads/day**.

## Vault (optional)

BW item **YouTube Dev** (suggested path: `KpihX-Labs/Dev/Media`):

- `YOUTUBE_CLIENT_ID` / `YOUTUBE_CLIENT_SECRET` (if split from gws file)
- `YOUTUBE_REFRESH_TOKEN` (after first consent)
- `YOUTUBE_CHANNEL_ID` (after `channels.list`)

Prefer **reuse** `kpihx-labs` OAuth client; inject via environment.

## Division of skills (no duplication)

| Concern | Skill |
|---------|-------|
| Enable API, project id, bootstrap script | **`k-media`** (this file) |
| `gcloud`, `gws-labs`, GCP profiles | **`k-google`** |
| Meta / X / LinkedIn registry | **`k-clis`** → `social-dev-platforms.md` |
| Cross-platform publish vision | **`k-context/.../social-media-apis.md`** |

## QMD keywords

`YouTube`, `kpihx-labs`, `youtube.upload`, `gws-labs`, `OAuth consent`

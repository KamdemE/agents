# Social / video dev platforms — KπX registry

> **Secrets:** Vaultwarden → **`Vaultwarden`** (primary). **JSON fallbacks** live under `$HOME/.config/kpihx/` — **never commit** (outside `.agents/` git).  
> **Hub skill:** **`k-media`** (human entry point) · **no `k-publish` skill** — cross-post automation is vision-only → `k-context/references/vision/social-media-apis.md`.

## Skill map (no duplication)

| Platform | Operational skill | Secrets file (optional, mode 600) | Messaging |
|----------|-------------------|-------------------------------------|-----------|
| **YouTube** | **`k-media`** + **`k-google`** | `$HOME/.config/gws/kpihx-labs/youtube_token.json` | — |
| **X** | **`k-x`** | `$HOME/.config/kpihx/x/credentials.json` | — |
| **Meta Graph / WA Cloud** | **`k-meta`** | `$HOME/.config/kpihx/meta/credentials.json` | **`k-whats`** (whats-proxy) |
| **LinkedIn** | **`k-linkedin`** | Vault / MCP config | linkedin-mcp |
| **Registry** | **`k-clis`** (this file) | — | — |

**`k-media`** = hub + YouTube runbooks — **not** a second publish stack. **`k-publish`** in vision docs = future mono-repo idea only.

## Vault items

| BW item | Env fields (custom) | JSON fallback |
|---------|---------------------|---------------|
| **Meta Dev** | `META_APP_ID`, `META_APP_SECRET`, `META_BUSINESS_ID`, `META_WA_PHONE_NUMBER_ID`, `META_WA_NUMBER` | `meta/credentials.json` |
| **X Dev** | `X_API_KEY`, `X_API_KEY_SECRET`, `X_ACCESS_TOKEN`, `X_ACCESS_TOKEN_SECRET` | `x/credentials.json` |

Inject via **`Vaultwarden`** — gate: `references/token-gate.md`. While `Vaultwarden` mutates, agents **must use JSON** (`--creds-file` on CLIs), not skip them.

## Live status (2026-05-25)

| Platform | Check | Blocker |
|----------|-------|---------|
| YouTube `@kpihx` | ✅ upload smoke | — |
| X `@KPIHX7` | ✅ `me` via JSON | tweet → **402 credits** |
| Meta app **KpihX-Labs** | ✅ core Graph via JSON | WA phone Graph → **System User** token |
| WA chat | ✅ whats-mcp | separate from `k-meta` |

## Runbooks

| Topic | Path |
|-------|------|
| YouTube | `k-media/references/youtube-kpihx-labs.md` |
| X | `k-x/references/x-dev-setup.md` |
| Meta | `k-meta/references/meta-dev-setup.md` · `k-meta/references/smoke-status.md` |
| Vision / future `k-publish` | `k-context/references/vision/social-media-apis.md` |

## Program order (remaining)

1. X — purchase API credits → test tweet.
2. Meta — add System User token to JSON → extended smoke.
3. Meta — optional FB Page / IG publish (Graph).
4. Vision — `k-publish` scripts repo **if** cross-post automation is prioritized.

## QMD keywords

`Meta Dev`, `X Dev`, `YouTube`, `k-media`, `k-meta`, `k-x`, `credentials.json`, `social dev`

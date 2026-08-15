# Cloudflare CLI setup (KπX)

> **Skill:** `k-cloudflare/SKILL.md` · **Secrets:** local config / env (no longer injected via `k-bw` — purged 2026-08-14).

## 1 — `flarectl` (API / DNS)

### Install

```bash
go install github.com/cloudflare/cloudflare-go/cmd/flarectl@latest
ln -sf "$HOME/go/bin/flarectl" "$HOME/.local/bin/flarectl"
flarectl --version
```

### API token (dashboard)

1. [dash.cloudflare.com](https://dash.cloudflare.com/profile/api-tokens) → **Create Token**.
2. **Homelab minimum:** template **Edit zone DNS** → zone `kpihx-labs.com`.
3. **Email Routing (API):** custom token on `kpihx-labs.com` + account (full runbook: **`email-routing-ops.md`**):
   - Account: **Email Routing Addresses** → Edit
   - Zone: **Email Routing Rules** → Edit · **Zone Settings** → Edit (enables `GET/POST …/email/routing` + `enable` + DNS wizard)
   - Zone: **DNS** → Edit (already required for `flarectl`)
4. **Optional (+ tunnels):** Account **Cloudflare Tunnel** Edit.
5. Copy token **only when creating** a new token → Vault `CF_API_TOKEN=…`. **Editing** an existing token’s permissions does **not** change the secret — no Vault update.

**Edit vs roll:** Dashboard “Token updated” after permission edit = same `CF_API_TOKEN` value. **Roll** or **Create** = new secret shown once → update Vault + ensure env is loaded.

### Activate session

```bash
# Ensure environment is loaded (secrets available)
# Then use flarectl or cf-proxy
env | grep -E '^CF_' | cut -d= -f1    # names only
flarectl zone list
flarectl dns list --zone kpihx-labs.com
curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $CF_API_TOKEN" | head -5
```

## 2 — `cloudflared` (homelab server only — quarantined on workstation)

**Workstation:** do **not** install. Future dev uses → `cloudflared-quarantine.md`.

**Homelab server:** connector for tunnel `kpihx-labs`.

### Path A — Remotely-managed tunnel (prod homelab)

1. Zero Trust → **Networks** → **Connectors** → **Cloudflare Tunnels** → create or select tunnel.
2. Copy install command: `cloudflared tunnel run eyJ...` (token only — store in Vault / compose env).
3. Run on docker-host (systemd or compose) — **no** `tunnel login` required for this path.
4. DNS: CNAME hostname → `<tunnel-id>.cfargotunnel.com` (dashboard or `flarectl dns create`).

### Path B — Locally-managed / laptop (not current KπX prod)

See `cloudflared-quarantine.md` — includes **quick tunnel** for localhost previews.

## 3 — `wrangler` (explicitly off)

- **Do not** `npm install -g wrangler` on KπX workstation.
- If present: `npm uninstall -g wrangler` and verify `command -v wrangler` is empty.
- Workers/Pages work stays in **IDE** contexts only — not agent homelab ops.

## Smoke checklist

| Check | Command | OK when |
|-------|---------|---------|
| flarectl auth | `flarectl zone list` | zones listed |
| token valid | `curl .../user/tokens/verify` | `"status":"active"` |
| tunnel running | Zero Trust dashboard **`kpihx-labs` Healthy** | on **server**, not laptop |

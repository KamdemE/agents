# Cloudflare CLI setup ()

> **Skill:** `k-cloudflare/SKILL.md` · **Secrets:** local config / env (no longer injected via `k-bw` — purged 2026-08-14).

## 1 — `flarectl` (API / DNS)

### Install

```bash
go install github.com/cloudflare/cloudflare-go/cmd/flarectl@latest
ln -sf "$HOME/go/bin/flarectl" "$HOME/.local/bin/flarectl"
flarectl --version
```

### API token — complete permissions (reference)

If the token is lost, recreate it at https://dash.cloudflare.com/profile/api-tokens with **exactly these permissions**:

| Scope | Permission | Level |
|-------|-----------|-------|
| Email Routing Addresses | Edit | Account |
| Cloudflare Tunnel | Edit | Account |
| Zero Trust | Edit | Account |
| Workers Scripts | Edit | Account |
| Access: Apps and Policies | Edit | Account |
| Email Routing Rules | Edit | Zone (`<github-user>.com`) |
| Zone Settings | Edit | Zone (`<github-user>.com`) |
| Zone | Edit | Zone (`<github-user>.com`) |
| DNS | Edit | Zone (`<github-user>.com`) |
| User Details | Read | User |

**After creating:** copy token → Vault `CF_API_TOKEN=…`. Editing an existing token's permissions does **not** change the secret — no Vault update needed. Roll or Create = new secret shown once → update Vault + ensure env is loaded.

### Activate session

```bash
# Ensure environment is loaded (secrets available via with-env in tmux)
# Then use flarectl or curls
with-env flarectl zone list
with-env flarectl dns list --zone <github-user>.com
with-env curls -p cloudflare "https://api.cloudflare.com/client/v4/user/tokens/verify"
```

## 2 — `cloudflared` (homelab server only — quarantined on workstation)

**Workstation:** do **not** install. Future dev uses → `cloudflared-quarantine.md`.

**Homelab server:** connector for tunnel `<github-user>`.

### Path A — Remotely-managed tunnel (prod homelab)

1. Zero Trust → **Networks** → **Connectors** → **Cloudflare Tunnels** → create or select tunnel.
2. Copy install command: `cloudflared tunnel run eyJ...` (token only — store in Vault / compose env).
3. Run on docker-host (systemd or compose) — **no** `tunnel login` required for this path.
4. DNS: CNAME hostname → `<tunnel-id>.cfargotunnel.com` (dashboard or `with-env flarectl dns create`).

### Path B — Locally-managed / laptop (not current  prod)

See `cloudflared-quarantine.md` — includes **quick tunnel** for localhost previews.

## 3 — `wrangler` (explicitly off)

- **Do not** `npm install -g wrangler` on  workstation.
- If present: `npm uninstall -g wrangler` and verify `command -v wrangler` is empty.
- Workers/Pages work stays in **IDE** contexts only — not agent homelab ops.

## Smoke checklist

| Check | Command | OK when |
|-------|---------|---------|
| flarectl auth | `with-env flarectl zone list` | zones listed |
| token valid | `with-env curls -p cloudflare "https://api.cloudflare.com/client/v4/user/tokens/verify"` | `"status":"active"` |
| tunnel running | Zero Trust dashboard **`<github-user>` Healthy** | on **server**, not laptop |

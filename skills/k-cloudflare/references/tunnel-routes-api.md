# Tunnel published routes (ingress) — API vs tools

> **Tunnel `<github-user>`:** routes like `vaultwarden`, `sentinel`, etc. = **ingress** on remote-managed tunnel.  
> **Dashboard:** Zero Trust → tunnel → **Configure** / **Published application routes**.

## Can you avoid the dashboard?

| Method | Published routes (ingress) | DNS records |
|--------|---------------------------|-------------|
| **Cloudflare dashboard** | ✅ Add route UI | ✅ Often auto |
| **REST API** | ✅ **Yes** — open, documented | ✅ `POST /zones/{zone_id}/dns_records` |
| **`flarectl`** | ❌ **No** — DNS/zones only | ✅ `flarectl dns *` |
| **`cloudflared` CLI** | ❌ Not for remote-managed ingress (config in cloud) | — |
| **Cursor Cloudflare MCP** | ❌ Workers/KV/D1 — not tunnel routes | ❌ |
| **Terraform** | ✅ `cloudflare_zero_trust_tunnel_cloudflared_config` ( not using) | ✅ |
| **`cf-proxy` (future)** | Target for CLI+MCP+HITL | — |

**Answer:** API is **open**. You do **not** need the dashboard for changes — but you need a **broader API token** than DNS-only and you must use **API or curl**, not `flarectl`, for routes.

## API (remote-managed tunnel `<github-user>`)

**Read current ingress:**

```http
GET /accounts/{account_id}/cfd_tunnel/{tunnel_id}/configurations
Authorization: Bearer $CF_API_TOKEN
```

**Replace full ingress** (PUT sends **entire** list — always include catch-all last):

```http
PUT /accounts/{account_id}/cfd_tunnel/{tunnel_id}/configurations
```

```json
{
  "config": {
    "ingress": [
      {
        "hostname": "sentinel.<github-user>.com",
        "service": "http://127.0.0.1:PORT",
        "originRequest": {}
      },
      {
        "hostname": "vaultwarden.<github-user>.com",
        "service": "http://TRAEFIK_OR_ORIGIN:PORT",
        "originRequest": {}
      },
      { "service": "http_status:404" }
    ]
  }
}
```

**Token permissions (minimum for routes):**

- Account: **Cloudflare Tunnel** Edit (or Cloudflare One Connector cloudflared Write)
- Zone: **DNS** Edit (if creating CNAMEs separately)

**DNS** (if not auto-created by dashboard flow):

```bash
flarectl dns create --zone <github-user>.com \
  --name sentinel --type CNAME \
  --content "<TUNNEL_UUID>.cfargotunnel.com" --proxy
```

Use **Tunnel ID** (`db6721cb-…`) for CNAME target — not tunnel name `<github-user>`.

##  split (today)

| Layer | Tool | Where |
|-------|------|-------|
| Ingress routes | Dashboard (historical) or **API curl** | Cloud / laptop |
| DNS | **`flarectl`** | Laptop + `CF_API_TOKEN` |
| Connector | `cloudflared tunnel run` | **Homelab server only** |
| Internal admin | **Tailscale** | Not CF tunnel |

## Safe automation notes

- **PUT = full replace** — GET first, merge one hostname, PUT back with catch-all `http_status:404` at end.
- Wrong ingress can **break all** public hostnames until fixed.
- Future **`cf-proxy`**: read/modify ingress with HITL before destructive PUT.

## Related

- **Email Routing (inbound alias):** `references/email-routing-ops.md` — separate from tunnel ingress; uses zone Email Routing API + MX.

## QMD keywords

`tunnel routes`, `published application`, `ingress`, `<github-user>`, `cfd_tunnel configurations`, `flarectl DNS only`, `API tunnel write`, `vaultwarden`, `sentinel`, `email routing ops`

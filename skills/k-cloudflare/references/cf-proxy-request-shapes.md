# cf-proxy / API request shapes (reference — not implemented)

> **PIPO** in chat = **API** HTTP requests today, or future **`cf-proxy do <cmd> '<json>'`** (same contract family as `ts-proxy`).
> **Tunnel routes** = published ingress · **Sophisticated origin** = per-route `originRequest` · **Precedence** = Access policy order (lower number = evaluated first).

## Token injection (never in chat)

| Layer | Mechanism |
|-------|-----------|
| **SOT** | Vaultwarden `GLOBAL_ENV_VARS` → environment on login/tmux |
| **Env vars** | `CF_API_TOKEN`, `CF_ACCOUNT_ID`, optional `CF_ZONE_ID` |
| **Agent shells** | Often empty → **`k-cloud-tools/references/token-gate.md`** (tmux `default`/`remote` first) |
| **cf-proxy (future)** | Read env only; optional `~/.cf_proxy/config.yaml` for IDs, **no** token on disk |

**Verify (safe):**

```bash
env | grep -E '^CF_' | cut -d= -f1
curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $CF_API_TOKEN"
```

## API token scopes (by operation)

| Operation | Account / Zone permissions |
|-----------|----------------------------|
| Tunnel ingress GET/PUT | Cloudflare Tunnel **Edit** |
| DNS CRUD | Zone DNS **Edit** |
| Access apps/policies | Access: Apps and Policies **Edit** |
| Gateway network policies | Account Gateway **Edit** |
| Read-only audit | respective **Read** only |

Use **separate tokens** for agents (read) vs human HITL (write) when possible.

---

## 1) Published routes (tunnel ingress)

**GET** (read all routes + origin settings):

```http
GET https://api.cloudflare.com/client/v4/accounts/{CF_ACCOUNT_ID}/cfd_tunnel/{TUNNEL_ID}/configurations
Authorization: Bearer $CF_API_TOKEN
```

**PUT** (full replace — merge locally first):

```json
{
  "config": {
    "ingress": [
      {
        "hostname": "vaultwarden.kpihx-labs.com",
        "service": "http://127.0.0.1:8080",
        "originRequest": {
          "httpHostHeader": "vaultwarden.kpihx-labs.com",
          "noTLSVerify": false,
          "connectTimeout": 30,
          "keepAliveConnections": 100
        }
      },
      {
        "hostname": "sentinel.kpihx-labs.com",
        "service": "http://127.0.0.1:9000",
        "originRequest": {}
      },
      { "service": "http_status:404" }
    ]
  }
}
```

**Actions:** `list-routes` (GET), `replace-routes` (PUT, HITL), `upsert-route` (GET→merge→PUT, HITL).

---

## 2) Access application (who can hit a hostname)

**POST** self-hosted app:

```http
POST https://api.cloudflare.com/client/v4/accounts/{CF_ACCOUNT_ID}/access/apps
Authorization: Bearer $CF_API_TOKEN
Content-Type: application/json
```

```json
{
  "name": "Vaultwarden",
  "type": "self_hosted",
  "domain": "vaultwarden.kpihx-labs.com",
  "session_duration": "24h",
  "auto_redirect_to_identity": true,
  "allowed_idps": [],
  "policies": ["<REUSABLE_POLICY_UUID>"]
}
```

**PUT** app (must include full body from prior GET — e.g. enable tunnel JWT check):

```json
{
  "domain": "vaultwarden.kpihx-labs.com",
  "type": "self_hosted",
  "session_duration": "24h"
}
```

Dashboard **Protect with Access** on tunnel ≈ origin validates `Cf-Access-Jwt-Assertion` (configure via tunnel/app linkage in Zero Trust UI or matching API fields).

---

## 3) Reusable Access policy (recommended)

**POST** policy (then reference `id` in app `policies[]`):

```http
POST https://api.cloudflare.com/client/v4/accounts/{CF_ACCOUNT_ID}/access/policies
```

```json
{
  "name": "Allow KpihX email",
  "decision": "allow",
  "precedence": 1,
  "include": [
    {
      "email": {
        "email": ["kapoivha@gmail.com"]
      }
    }
  ],
  "exclude": [],
  "require": []
}
```

**Service auth (machine-to-machine)** — separate policy:

```json
{
  "name": "Service token only",
  "decision": "non_identity",
  "precedence": 2,
  "include": [
    {
      "service_token": {
        "token_id": "<SERVICE_TOKEN_ID>"
      }
    }
  ]
}
```

**Precedence rules:** lower `precedence` runs first; first matching **allow** wins; default deny if no match.

**Policy actions (API):**

| Action | Method | Path |
|--------|--------|------|
| List reusable | GET | `/accounts/{id}/access/policies` |
| Create | POST | `/accounts/{id}/access/policies` |
| Update | PUT | `/accounts/{id}/access/policies/{policy_id}` |
| Delete | DELETE | `/accounts/{id}/access/policies/{policy_id}` |
| App-only policy | POST | `/accounts/{id}/access/apps/{app_id}/policies` |

Destructive policy/app changes → **HITL** in cf-proxy.

---

## 4) DNS (public hostname → tunnel)

```bash
flarectl dns create --zone kpihx-labs.com \
  --name vaultwarden --type CNAME \
  --content "{TUNNEL_UUID}.cfargotunnel.com" --proxy
```

Or API `POST /zones/{CF_ZONE_ID}/dns_records` with `"proxied": true`.

---

## 5) Gateway / private routes (optional — not tunnel ingress)

For **private IP/hostname** apps, **WARP**, or **order of Access vs Gateway**:

- Gateway network policies: `POST /accounts/{id}/gateway/rules` (selector e.g. Access Private App).
- Differs from **tunnel published routes** — see Zero Trust Traffic policies docs.

---

## Future `cf-proxy do` examples (ts-proxy parity)

```bash
cf-proxy admin status
cf-proxy do list-tunnel-routes '{}'
cf-proxy do get-access-app '{"app_id":"..."}'
cf-proxy do replace-tunnel-routes ./ingress.json   # HITL diff before PUT
cf-proxy do create-access-policy '{"name":"Allow KpihX",...}'  # HITL
```

**HITL:** PUT ingress, DELETE policy, DELETE DNS, PUT Access app — same dual-channel model as `ts-proxy` (web + TUI).

## QMD keywords

`cf-proxy`, `API request`, `Access policy precedence`, `originRequest`, `tunnel ingress PUT`, `CF_API_TOKEN`, `environment`, `service token`, `self_hosted app`

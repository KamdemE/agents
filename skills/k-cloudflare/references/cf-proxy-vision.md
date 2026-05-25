# cf-proxy vision (brainstorm — not implemented)

> **Status:** PLANNING · **Reference contract:** `$HOME/Work/KpihX-Labs/Fluid/ts_proxy/CONTRACT.md`

## Intent

**`cf-proxy`** — sovereign MCP/CLI proxy for Cloudflare, mirroring **`ts-proxy`** for Tailscale:

- Same operations via **CLI** (`do …`) and future **HTTP/MCP**
- **HITL** on destructive API calls (DNS delete, tunnel delete, Access policy change)
- **JSON-first** output for agents (`--json`, stable schemas)
- **0 hardcode** — account/zone IDs from config or env, secrets from **`k-bw`**

## Scope (target)

| Area | Examples |
|------|----------|
| DNS | list/create/update/delete records |
| Tunnels | list, token, route, status |
| Access | apps/policies read (write behind HITL) |
| Zones | list, settings read |

## Out of scope (stay on other tools)

| Area | Tool |
|------|------|
| Tunnel packet path | **`cloudflared`** daemon |
| Workers deploy | **IDE / wrangler** (not workstation) |
| Full API surface day one | incremental; `flarectl` + `curl` until proxy ships |

## Until cf-proxy exists

Use **`flarectl`** + **`cloudflared`** per `references/setup.md` and `k-cloudflare/SKILL.md`.

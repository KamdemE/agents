# Insights

## 2026-05-25 — [CURSOR]

- **Cloud hub SOT:** `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md` — all cloud/productivity skills should route through it; avoid duplicating full maps in each SKILL.md.

## Cloudflare — Cursor plugin MCP

- The Cursor **Cloudflare** MCP family (`cloudflare-bindings`, `cloudflare-builds`, `cloudflare-docs`, `cloudflare-observability`) exposes **account pickers**, **Workers scripts**, **Workers Builds**, **KV**, **D1**, **R2** (if enabled), **Hyperdrive**, **Workers Observability** queries, and **documentation search**. It does **not** expose tools to list or edit **DNS zones/records**, **Cloudflare Tunnel** configs, **Zero Trust / Access** applications or policies, **Gateway** rules, or **Pages** projects as live account state.
- **`search_cloudflare_documentation`** returns **public docs chunks**, not private account configuration. Do not treat doc search results as an inventory of the user’s Cloudflare setup.
- For full account inventory (tunnels, Access apps, DNS, etc.), use **Cloudflare API** / **dashboard** / **`flarectl`** / **`cloudflared`** with appropriately scoped credentials — outside this MCP surface unless Cloudflare extends the plugin.

## Tailscale

- Tagged devices do not behave like user-owned source identities in tailnet ACL evaluation. If a device has `tag:server`, a rule such as `src: ["group:admin"]` may still allow user-owned laptops to reach it, while the tagged device itself cannot initiate host-stack traffic back unless the ACL also allows `src: ["tag:server"]`.
- A strong diagnostic pattern is:
  - `tailscale ping` works
  - `tailscale ping --tsmp` works
  - OS `ping` and TCP to the peer's Tailscale IP timeout
  - local firewall looks open
  This strongly suggests tailnet policy mismatch, not a local host firewall issue.
- `ts-proxy` is a practical way to verify this quickly:
  - `admin status`
  - `do list-devices`
  - `do get-acl`
  Then compare device tags with ACL `src` selectors before touching local firewall rules.

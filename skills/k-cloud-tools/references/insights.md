# Insights

## 2026-05-25 — [CURSOR] token gate

- **`CF_API_TOKEN`** (and all Vault tokens): try CLI → tmux **`default`**/`remote`** → `Vaultwarden unlock && Vaultwarden get` + KπX password in chat. Never print values. See `references/token-gate.md`.

## 2026-05-25 — [CURSOR]

- **Cloudflare ops moved to `k-cloudflare`** — tunnel/DNS/setup/MCP limits live there; this hub keeps Tailscale + registry routing only.

## 2026-05-25 — [CURSOR] ops snapshot (Tailscale)

- **`ts-proxy`:** `ts-proxy admin status` → API 200, tailnet connected (5 devices). Use for ACL/device diagnostics before host firewall changes.

## 2026-05-25 — [CURSOR]

- **Cloud hub SOT:** `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md` — all cloud/productivity skills should route through it; avoid duplicating full maps in each SKILL.md.

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

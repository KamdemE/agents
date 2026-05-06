# Insights

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

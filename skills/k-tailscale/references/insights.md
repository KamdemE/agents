# k-tailscale — Insights

## 2026-07-24

- **Tailscale DNS + local network (eduroam):** When a local network pushes its own DNS (e.g. École Polytechnique `129.104.201.59`, `129.104.201.51`), do NOT override them blindly. Add them as Tailscale **Global Nameservers** instead, so Tailscale DNS can forward local-domain queries to them while still handling MagicDNS internally.
- The local network's search domain (e.g. `eleves.polytechnique.fr`) must also be configured in Tailscale when `accept-dns=true`, otherwise local hostname resolution fails.
- **Typical symptom:** `dig @100.100.100.100 domain timeout` — the Tailscale DNS resolver is not responding, usually because it cannot reach upstream resolvers or the local network DNS is missing from its configuration.
- Disabling `accept-dns` is a brute-force workaround that breaks MagicDNS and `.tail2527bd.ts.net` names — avoid except for debugging.

## 2026-07-21

- `tailscale serve` sans `--bg` = foreground, meurt au Ctrl+C et **perd la config**.
- Toujours utiliser `sudo tailscale serve --bg --yes --https <port> <target>` pour une config persistante.
- On peut chaîner avec `&&` pour configurer plusieurs ports en une ligne sudo.

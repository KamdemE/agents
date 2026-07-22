# k-tailscale — Insights

## 2026-07-21

- `tailscale serve` sans `--bg` = foreground, meurt au Ctrl+C et **perd la config**.
- Toujours utiliser `sudo tailscale serve --bg --yes --https <port> <target>` pour une config persistante.
- On peut chaîner avec `&&` pour configurer plusieurs ports en une ligne sudo.

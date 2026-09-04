# k-microsoft — insights

## 2026-05-25 — [CURSOR] m365 session

- **Cache v11:** `$HOME/.cli-m365-msal.json` + `~/.cli-m365-connection.json` — not `~/.config/m365` / `~/.local/share/m365`.
- **Refresh ~90d** (MSA deviceCode); access ~1h auto-refresh. Cannot extend via CLI config.
- **Persist:** `m365 cli config set` → `authType=deviceCode`, `tenantId=consumers`; never `rm` wrong dirs — use `m365 logout` only.
- **`connectedAs` empty** on `status` is normal; validate with `m365 request …/me` or inbox list **without** `--folderName Inbox` when Inbox count is 0.
- Hotmail account: `ivann.kamdem@hotmail.com` — sign in with that account at device code, not `kapoivha@gmail.com`.

## 2026-05-25 — [CURSOR] az off

- **`az` deactivated:** no Azure subscription — `azure-cli` purged from workstation; agents use **`m365` only** for Microsoft.
- **Do not** suggest `az login`, reinstall `azure-cli`, or read `$HOME/.azure/` unless KπX re-enables Azure.
- **Foundry:** `microsoft-foundry` skill is separate; not in scope until subscription exists.

## 2026-05-25 — [CURSOR] scripts

- **Pre-Fluid scripts:** `$HOME/.agents/skills/k-microsoft/scripts/` — run bundled inspect scripts; inventory in `scripts/README.md`.
- **Auth gate:** never `m365 login` / `logout` / `setup` from agents or scripts.

## 2026-05-25 — [CURSOR]

- **Uniform stack:** route via `k-clis/references/cloud-hub.md`; mail briefings stay in **`k-mail`**.
- **`m365` v11.7.0** at `$HOME/.npm-global/bin/m365` — sole Microsoft CLI on KπX.
- Poly mail: still **mail-mcp**, not `m365`.

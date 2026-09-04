# k-cloudflare — insights

## 2026-05-25 — [CURSOR] Inbound router (validated E2E)

- **Rollout:** `deploy-inbound-email-full.sh` = prime → sync → deploy; SOT `assets/kpihx-labs-inbound-router/inbound-routes.json`.
- **Prime rules:** `_prime-labs@`, `_prime-kapoivha@`, `_prime-hotmail@` — without native `forward`, Worker `message.forward()` fails with `destination address not verified` even when dashboard shows verified.
- **Anti-spam (2026-05-25):** `apply-inbound-antispam-filters.sh` — Gmail `to:<alias>` on **kapoivha + Labs** (all 3 aliases); Hotmail **inbox** `messageRules` via `m365 request -b @file --content-type application/json`. **junkemail/messageRules** → Graph **400** (manual Junk rule in Outlook if needed).
- **E2E send matrix:** Hotmail → `ivann@` / self-loop → **NDR/S3150**; kapoivha → alias → kapoivha → often **SENT only**; use external sender per `references/inbound-email-e2e.md`.
- **Proof tag:** `E2E-BILAN … ivann` (kapoivha → `ivann@` → Hotmail Inbox) closes `ivann@` route.
- **Outbound gws (2026-05-25):** All 3 aliases `accepted` on Gmail (Labs `contact@`, kapoivha `kpihx@`+`ivann@`). `From:` in raw MIME must match an `accepted` sendAs row or Gmail falls back to default `@gmail.com`. **m365** no `--from` on personal — alias send via kapoivha/Labs gws only.
- **DMARC (2026-05-25):** Record existed as `p=none` only; `dig` empty on some resolvers (timeout). **`rua`** added via CF API PUT — reports go to `kapoivha@gmail.com`. `flarectl dns update` display can lag; confirm with API GET or dashboard.
- **Verify script:** `scripts/verify-inbound-e2e.sh` — needs `command gws` or `$HOME/.npm-global/bin/gws`, `m365` in login shell; do not pipe `gws` output to `jq` without stripping `Using keyring` banner (`awk '/^\{/{p=1} p'`).
- **Gmail send API:** `gws gmail users messages send` — `--json '{"raw":…}'` with `--params '{"userId":"me"}'` (not `requestBody` inside `--params`).

## 2026-05-25 — [CURSOR] Email Routing API (`kpihx@`)

- **Enabled** via `POST …/zones/{CF_ZONE_ID}/email/routing/enable` → `status: ready`; MX + SPF + DKIM; tunnel CNAMEs untouched.
- **Token:** Rules + Addresses need **Edit**; **`GET/enable` need Zone Settings Edit** on zone `kpihx-labs.com`.
- **Multi-inbox:** one `forward` per standard rule → **Email Worker** for multiple `message.forward()` calls.
- **Ops style:** tmux step-by-step `curl` for provisioning; scripts for router rollout/E2E only.

## 2026-05-25 — [CURSOR] tunnel + workstation

- **Ingress routes:** API `GET/PUT …/configurations` — `flarectl` cannot edit routes (DNS only).
- **`cloudflared` quarantined on Ubuntu dev** — prod connector on homelab; laptop → `flarectl` only.
- **`flarectl`:** `CF_API_TOKEN` in Vault, not agent env — always run via `with-env` in tmux (confirmed 2026-09-04: `with-env flarectl zone list` works).

## 2026-05-25 — [CURSOR] skill bootstrap

- **`wrangler`:** general IDE Workers off; **exception** — inbound `deploy-inbound-email-worker.sh` only.
- **`cloudflared tunnel list`:** needs cert.pem for local-managed; remote-managed uses `tunnel run <token>` on server.
- **Future:** `cf-proxy` → `references/cf-proxy-vision.md`.

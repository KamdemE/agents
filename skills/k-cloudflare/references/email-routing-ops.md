# Email Routing — live ops runbook (`<github-user>.com`)

> **Validated 2026-05-25** · inbound **LIVE** (Worker + prime rules + Labs spam filters).  
> **Provision:** `flarectl` + `curl` + `jq` below · **E2E verify:** `references/inbound-email-e2e.md` + `scripts/verify-inbound-e2e.sh`.  
> **Outbound** `From: @<yourdomain.com>` → **`references/inbound-email-outbound-free.md`** (Gmail Send-as, SPF, optional Brevo).

## IDs (zone `<github-user>.com`)

| Var | Value |
|-----|--------|
| `CF_ZONE_ID` | `255f60d9f77924ac016c194300dbeb3c` |
| `CF_ACCOUNT_ID` | `5d0ff5e40bbc37baed99d3c7aacd0741` |
| Public alias | `mail@<yourdomain.com>` (rule id `332137f5445a4b368e0759a357cef0f9`) |
| Destinations (verify in CF account) | `<primary@gmail.com>` · `<personal@hotmail.com>` · `<labs@gmail.com>` |
| **Router** | `inbound-routes.json` + Worker `dfce70ed-…` — see **§ Evolutive inbound router** |
| **Prime rules** | `_prime-labs@`, `_prime-kapoivha@`, `_prime-hotmail@` — **mandatory** for Worker `forward()` |

## API token permissions (custom token)

| Scope | Permission | Enables |
|-------|------------|---------|
| Account | Email Routing Addresses **Edit** | `POST …/accounts/{id}/email/routing/addresses` |
| Zone `<github-user>.com` | Email Routing Rules **Edit** | `GET/POST …/zones/{id}/email/routing/rules` |
| Zone | Zone Settings **Edit** | `GET …/email/routing`, `POST …/enable` |
| Zone | DNS **Edit** | `flarectl dns list` |

**Edit token in dashboard** → same `CF_API_TOKEN` in Vault — **no** re-copy. Wait ~1–2 min, then ensure env is loaded if needed.

**Partial scope symptom:** Rules/addresses work but `GET …/email/routing` returns `Authentication error` until **Zone Settings Edit** is added.

## Preflight (read-only via `curls`)

```bash
export CF_ZONE_ID=255f60d9f77924ac016c194300dbeb3c
export CF_ACCOUNT_ID=5d0ff5e40bbc37baed99d3c7aacd0741

# Verify token & list email routing status / rules via curls
with-env curls -p cloudflare "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing"
with-env curls -p cloudflare "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing/rules"
with-env curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/email/routing/addresses"

flarectl zone list | rg <github-user>

curl -sS "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing" \
  -H "Authorization: Bearer $CF_API_TOKEN" | jq '{success,enabled:.result.enabled,status:.result.status}'

flarectl dns list --zone <github-user>.com | rg -i 'MX|mx\.cloudflare|spf|_domainkey' || true
```

## Enable routing (adds MX + SPF + DKIM)

```bash
curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing/enable" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" -d '{}' \
  | jq '{success,enabled:.result.enabled,status:.result.status}'
```

**Expect:** `success: true`, `status: "ready"`, `enabled: true`.

**Re-verify DNS:**

```bash
flarectl dns list --zone <github-user>.com | rg 'MX|mx\.cloudflare|spf|_domainkey'
```

Typical MX: `route1.mx.cloudflare.net` (prio 47), `route2` (25), `route3` (16).  
SPF apex: `v=spf1 include:_spf.mx.cloudflare.net ~all`.  
DKIM: `cf2024-1._domainkey.<github-user>.com`.

**Tunnel CNAMEs** (`sentinel`, apex, etc.) must stay unchanged — only mail DNS added.

## Destination address

```bash
curl -sS -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/email/routing/addresses" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data-raw '{"email":"<primary@gmail.com>"}' \
  | jq '{success,email:.result.email,verified:.result.verified}'
```

User must click **Verify** in Gmail if `verified` is null (first time).

List:

```bash
curl -sS "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/email/routing/addresses" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  | jq '.result[] | {email,verified}'
```

## Multi-destination (mandatory read)

Cloudflare **standard routing rules allow only one destination per custom address**. Linking several destinations to the same alias in the UI keeps **only the latest** ([CF docs](https://developers.cloudflare.com/email-routing/get-started/enable-email-routing/)).

| Need | Method |
|------|--------|
| **One** inbox per alias | Single `forward` rule (below) |
| **Several** inboxes (`kapoivha` + `kpihx.labs` + Hotmail) | **Email Worker** — `message.forward()` to each **verified** destination |

**Worker sketch** (deploy in Zero Trust → Email → Email Workers):

```javascript
export default {
  async email(message) {
    const dests = [
      "<primary@gmail.com>",
      "<labs@gmail.com>",
      "<personal@hotmail.com>",
    ];
    for (const addr of dests) {
      await message.forward(addr);
    }
  },
};
```

Then set the routing rule action `type: "worker"` (or dashboard: custom address → send to Worker). All `dests` must appear under **Destination addresses** and be **verified** first.

## Routing rule — single destination (`mail@`)

**Create** (already done — use POST only for new aliases):

```bash
curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing/rules" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data-raw '{"name":"kpihx public forward","enabled":true,"priority":1,"matchers":[{"type":"literal","field":"to","value":"mail@<yourdomain.com>"}],"actions":[{"type":"forward","value":["<primary@gmail.com>"]}]}' \
  | jq '{success,id:.result.id,enabled:.result.enabled}'
```

**Update** existing rule (e.g. switch sole dest to Hotmail — drops Gmail unless you use a Worker):

```bash
RULE_ID=332137f5445a4b368e0759a357cef0f9
curl -sS -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing/rules/$RULE_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data-raw '{"name":"kpihx public forward","enabled":true,"priority":1,"matchers":[{"type":"literal","field":"to","value":"mail@<yourdomain.com>"}],"actions":[{"type":"forward","value":["<personal@hotmail.com>"]}]}' \
  | jq '{success,actions:.result.actions}'
```

**Add Hotmail + keep Gmail:** do **not** only PUT one email — use **Worker** (above) or pick one inbox in the rule.

## Create a new `@<yourdomain.com>` alias

Example: `contact@<yourdomain.com>` → `<labs@gmail.com>` **and** `<primary@gmail.com>`.

1. **Verify destinations** (repeat per inbox):

```bash
curl -sS -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/email/routing/addresses" \
  -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type: application/json" \
  --data-raw '{"email":"<labs@gmail.com>"}' | jq '{email:.result.email,verified:.result.verified}'
# same for <primary@gmail.com> if not already verified
```

Click each verification link in the target mailbox.

2. **One destination only** — POST rule:

```bash
curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing/rules" \
  -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type: application/json" \
  --data-raw '{"name":"contact to labs","enabled":true,"priority":2,"matchers":[{"type":"literal","field":"to","value":"contact@<yourdomain.com>"}],"actions":[{"type":"forward","value":["<labs@gmail.com>"]}]}' \
  | jq '{success,id:.result.id}'
```

3. **Two+ destinations** — create Worker with `forwardList` for that alias, route matcher to Worker (dashboard or API `actions:[{"type":"worker","value":["<worker-name>"]}]` per CF API).

No hosted mailbox on Cloudflare — alias is receive-only forward.

List rules:

```bash
curl -sS "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/email/routing/rules" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  | jq '.result[] | {id,name,enabled,matchers,actions}'
```

**Note:** Default catch-all **drop** rule may exist (`type: all`, `enabled: false`) — leave disabled unless intended.

## E2E (inbound)

→ **`references/inbound-email-e2e.md`** (send matrix, tooling, traps, reference tags).

## `flarectl` limits

- **DNS list/create** — yes.
- **Email Routing rules/addresses/enable** — use **`curl`** (flarectl has no email-routing commands).
- **`flarectl zone list --json` + `jq`** may fail in zsh (xargs quote noise) — use table output + `rg` instead.

## Pitfalls

| Pitfall | Mitigation |
|---------|------------|
| PUT ingress replaces **entire** rule list | GET rules first; one change at a time |
| Multiple destinations per alias in UI | API: one forward per rule; multi-dest needs Worker |
| Enable without Zone Settings scope | Auth error on `…/enable` |
| Conflicting MX (Google Workspace + CF) | One inbound MX owner per zone |
| Reply still from `@gmail.com` | Configure outbound relay + Gmail Send-as (separate) |

## Evolutive inbound router (canonical layout)

| File | Role |
|------|------|
| `assets/<github-user>-inbound-router/inbound-routes.json` | **Source of truth** — aliases, priorities, `rule_id`, destination lists |
| `assets/<github-user>-inbound-router/src/routes.mjs` | Mirror for Worker bundle (edit JSON → sync copy → deploy) |
| `assets/<github-user>-inbound-router/src/index.mjs` | Generic sequential `message.forward()` + `console.log` / `console.error` |
| `scripts/ensure-destination-prime-rules.sh` | **Required** — native `forward` on `_prime-*@` aliases (Worker verification workaround) |
| `scripts/sync-inbound-email-routes.sh` | Upsert CF rules (`type: worker`) from JSON |
| `scripts/deploy-inbound-email-worker.sh` | `wrangler deploy` |
| `scripts/deploy-inbound-email-full.sh` | **One-shot:** prime → sync → deploy |
| `scripts/apply-inbound-antispam-filters.sh` | Gmail `to:<alias>` never spam + Outlook inbox rules |
| `scripts/verify-inbound-e2e.sh` | Read-only Gmail + Hotmail search by subject tag |
| `references/inbound-email-e2e.md` | E2E send matrix, anti-spam IDs, traps |

**Add or change an alias:**

1. Verify destinations in CF dashboard.
2. Edit `inbound-routes.json` + mirror `src/routes.mjs`.
3. Run **`deploy-inbound-email-full.sh`**.
4. E2E per **`inbound-email-e2e.md`** (use external senders; run verify script).

**Live route map (2026-05-25, validated):**

| Address | Destinations | CF rule |
|---------|----------------|---------|
| `mail@<yourdomain.com>` | Hotmail + kapoivha | worker |
| `contact@<yourdomain.com>` | Labs + kapoivha | worker |
| `personal@<yourdomain.com>` | Hotmail only | worker (`41bb5f76…`) |

**Prime rules (internal, do not publish):** `_prime-labs@`, `_prime-kapoivha@`, `_prime-hotmail@` → native forward to each destination. Without these, Worker `message.forward()` can fail with `destination address not verified` even when the dashboard shows verified.

## Deploy (live)

**Token:** Account → **Workers Scripts Edit** + Email Routing rules/addresses.

```bash
"$HOME/.agents/skills/k-cloudflare/scripts/deploy-inbound-email-full.sh"
"$HOME/.agents/skills/k-cloudflare/scripts/verify-inbound-e2e.sh" "E2E-BILAN"
```

**Post-deploy:** Worker tail `forward ok` per destination; inbox proof → **`inbound-email-e2e.md`**.

**Dashboard alternative:** Email → Email Workers → `<github-user>-inbound-router` → paste `assets/<github-user>-inbound-router/src/index.mjs`.

## QMD keywords

`email routing`, `mail@`, `contact@`, `personal@`, `enable`, `MX route1`, `prime rules`, `<github-user>-inbound-router`, `verify-inbound-e2e`, `inbound-email-e2e`

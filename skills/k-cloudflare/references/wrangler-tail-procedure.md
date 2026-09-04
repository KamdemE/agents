# Wrangler Tail — Worker Email Logs

**Version:** 1.0.0 · **Last updated:** 2026-09-04

## When to use

Use `wrangler tail` to read **live runtime logs** from the Cloudflare Email Worker. The Worker's `console.log()` and `console.error()` entries appear here in real time. This is the **only** way to see the exact forward/delivery outcome per destination.

## Prerequisites

- `CF_API_TOKEN` (or `CLOUDFLARE_API_TOKEN`) loaded via `with-env` (Vault / `~/.agents/.env`)
- `npx wrangler@3` available (used for email worker only — not general Workers)

## Procedure (tmux pane)

```bash
# In a tmux ops pane (k-tmux)
with-env npx --yes wrangler@3 tail kpihx-labs-inbound-router --format pretty
```

This creates a **long-running stream** (expires after ~6h). Send a test email while it's listening. The `console.log`/`console.error` entries from `src/index.mjs` appear immediately:

```
Email from:<sender> to:<alias> size:<bytes> @ <timestamp> - Ok
  (log) route <alias> -> <dest1>, <dest2>
  (log) forward ok: <dest1>
  (log) forward ok: <dest2>
```

If a destination fails:

```
  (error) forward failed <dest2>: <error message>
```

To stop: `Ctrl-C` in the pane.

## Key env vars

| Variable | Legacy | Notes |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | `CF_API_TOKEN` | Recommended |
| `CLOUDFLARE_ACCOUNT_ID` | `CF_ACCOUNT_ID` | Recommended |

Wrangler prints deprecation warnings for the old names — they still work but update recommended.

## Diagnostics workflow

1. Start `wrangler tail` in tmux pane (armed, TMUX_TIMEOUT=60+)
2. Send a test email via `mail-proxy do message-send` (another pane)
3. The tail captures the Worker's `route` + `forward ok`/`forward failed` per destination
4. Ctrl-C the tail when done
5. If all `forward ok` but mail missing → problem is **destination-side** (Gmail filters, spam, rejection)
6. If `forward failed` → problem is **CF-side** (destination not verified, prime rule missing)

## Pitfalls

- **`message.forward()` can only be called ONCE per email per Worker invocation** in practice — if the first forward throws, subsequent forwards are skipped. The `src/index.mjs` has try/catch per forward to log failures individually.
- **Destination must be verified** — even if the dashboard shows "verified", prime rules (`_prime-*@`) may be needed for Worker forwards. Re-send to `_prime-<dest>@kpihx-labs.com` to warm the verification.
- **Gmail filters can silently trash/strip forwarded mail** — always check destination inbox filters after verifying CF-side delivery.

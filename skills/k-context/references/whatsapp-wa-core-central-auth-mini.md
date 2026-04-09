# WhatsApp Central Auth Mini-Design (`wa-core`)

## Goal

Centralize Baileys auth/state on server side and let all WhatsApp services consume one canonical runtime.

## Current Reality

- `whats-mcp` uses Baileys auth files (`useMultiFileAuthState`) under `WHATSAPP_STATE_DIR`.
- Edge WhatsApp Web stores browser data (`IndexedDB`) but is not a stable drop-in auth backend for Baileys.
- Multiple independent clients can increase reconnect churn and operational drift.

## Target Architecture

### `wa-core` service (docker-host)

Single service owning:
- auth directory (credentials + keys)
- message store snapshot
- connection lifecycle/reconnect strategy

Persistent volume:
- `/data/state` (or equivalent), mounted once as source of truth.

### `whats-mcp-http`

- Front-end API on top of `wa-core`
- used by agents/tools over network (including Tailscale paths)

### `whats-mcp-stdio`

- local fallback client mode
- can target the same canonical state path when running on the host that owns state
- if not reachable, stays fallback-only with explicit degraded-mode notice

### `wa-bot` adjustment

- remove private `auth_info` ownership
- consume `wa-core` capability instead of separate independent session
- avoid dual session managers for same account

## Fallback Strategy

Edge remains fallback for manual recovery only:
- if `wa-core` auth is lost/corrupted, recover by re-linking and reseeding canonical Baileys state
- do not treat Edge storage as continuous primary auth backend

## Practical Next Steps

1. Create/rename dedicated `wa-core` compose service around current server runtime.
2. Bind all WhatsApp automations (`whats-mcp-http`, bots) to this core.
3. Add health + incident dashboard fields (state, reconnect attempts, last disconnect code).
4. Define runbook: reconnect, re-auth, rollback, and edge fallback procedure.

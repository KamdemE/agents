# Proxies Reflex

**KπX's proxies** (`tg-proxy`, `tick-proxy`, `mail-proxy`, `whats-proxy`, `ts-proxy`, `bw-proxy`, `browser-proxy`, …) are sovereign CLI daemons giving the agent access to external services with no native tool/MCP/API otherwise. Same family, same ADN: one binary, `do`/`admin` split, `{meta,data}` envelope, `--help` as the ONLY source of truth, HITL where a human must approve or answer.

**`browser-proxy` is the root of this family** (see `k-browser` skill) — when no dedicated proxy exists for a service, or a dedicated proxy doesn't yet cover a specific action, browser-proxy drives ANY web UI generically (virtually every service has a web version). It is the universal fallback underneath the whole family, not merely one proxy among equals.

## When to apply

- A headless/curl-based approach to any external service gets stuck, blocked, or requires a session no header/cookie trick can replicate
- KπX asks for a task on a service with **no dedicated proxy at all** → reach for `browser-proxy` directly
- A dedicated proxy exists (`tg-proxy`, `tick-proxy`, `mail-proxy`, `whats-proxy`, `ts-proxy`, `bw-proxy`) but the specific action needed isn't implemented there yet → `browser-proxy` covers the gap via the service's own web UI
- Any task genuinely requires seeing/clicking/reading a real rendered page — not just an API response

## What to do

1. Check whether a dedicated proxy already covers the task first (`k-tg`/`k-tick`/`k-mail`/`k-whats`/`k-clis` for `ts-proxy`/`k-bw` skills) — prefer its native action when one exists (faster, no browser overhead, no HITL needed for reads).
2. If none covers it, or the specific action is missing, load `k-browser` for the generic web-UI fallback.
3. **Never read ANY proxy's source code** to learn its usage. Always `<proxy> do --help` / `<proxy> do <action> --help` (or that proxy's own documented help convention) — docstrings ARE the contract, always in sync, and source code will not even be local post-beta for several of these.
4. For `browser-proxy` specifically: check `k-browser/references/sites/<domain>.md` before navigating blind, and check `k-browser/scripts/presets/` for an existing preset — never redo manually what a preset already automates. Also check `kpihx` + `kpihx-labs` skills for any non-secret personal field.
5. **Never** collect a password/secret through any proxy's ask/clarify mechanism (e.g. `browser-ask-user`) — notify KπX instead and let KπX enter it directly, out of the agent's data path.

## Exceptions

None — this reflex applies to every agent mode capable of driving proxy-mediated tasks (Colab primary; sub-agents inherit it when delegated such work).

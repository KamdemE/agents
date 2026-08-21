# Shared libs — single orientation point

The **libs-first reflex** (see `k-infras/SKILL.md` → Shared Libs Reflex, and
`AGENTS.md` → Libs-first reflex) says: before writing/editing any `.agents`
script that handles `.env`, JSONC configs, or notifications — **check `libs/`
first** and source the shared twin, never inline a private copy.

This file is the canonical index of the three shared libraries and the
guards/checks that consume them. When a concern is missing from `libs/`, add a
twin set there (per `libs/AGENTS.md`) and expose it via a check in `scripts/`.

Location: `$HOME/.agents/libs/`

| Subdir | Purpose | Twins |
|--------|---------|-------|
| `libs/env/` | `.env` / `.env.example` helpers (key names + presence, **never values**) | `env_lib.sh` / `env_lib.py` / `env_lib.js` |
| `libs/jsonc/` | JSONC strip/validate/load + infra helpers | `jsonc_lib.sh` / `jsonc_lib.py` / `jsonc_lib.js` |
| `libs/notif/` | Notifications (Telegram + system + mixed + homelab lock) | `notifier.sh` (sh only) |

---

## 1. `libs/env/env_lib.*` — `.env` helpers

Sourced by shell scripts via `source`; Python/JS twins imported from
`libs/env/`. **Security rule:** these helpers ONLY print key NAMES or
"present/empty" status. They NEVER print or read the VALUES.

| Function | Signature | Purpose |
|----------|-----------|---------|
| `env_keys` | `<file>` | Print non-commented KEY names (one per line). |
| `env_has_value` | `<file> <key>` | Return 0 if `<key>` has a non-empty value. |
| `env_validate_format` | `<file>` | Return 0 if every line is blank / comment / `KEY=...`. |
| `env_keys_not_in_example` | `<env> <example>` | Print KEYs present in `<env>` but absent from `<example>` (names only). |
| `env_load` | `<file>` | Source a `.env` safely (`set -a; source; set +a`), exports vars, never echoes. |
| `env_is_missing_key` | `<env> <example>` | Return 0 if a KEY of `<env>` has no (even empty) counterpart in `<example>`. |

Source of truth: `$HOME/.agents/libs/env/env_lib.sh`. Header block documents
each function's contract.

---

## 2. `libs/jsonc/jsonc_lib.*` — JSONC helpers

The KπX config standard is JSONC (JSON with `//` comments). These helpers parse
and match infra-scoped JSONC assets.

| Function | Signature | Purpose |
|----------|-----------|---------|
| `strip_jsonc` | (stdin → stdout) | Remove `//` and `/* */` comments, respecting string literals. |
| `jsonc_valid` | `<file>` | Strip comments then strict JSON parse (via `python3 -m json.tool`). |
| `load_jsonc` | `<file> <var>` | Eval to set `$var` to the JSON object string (or `'{}'` on failure). |
| `current_infra` | — | Resolve current infra name from `tailscale status --json` (fallback `hostname`). |
| `infra_matches` | `<current> <infras-json-or-*>` | True if infra applies (`*` or `["*"]` = ALL). |

Path constants exported: `AGENTS_DIR`, `ASSETS_DIR`, `INFRA_FILE`
(`assets/infras_skills.jsonc`), `SERVICES_FILE` (`assets/services.jsonc`),
`LINKS_FILE` (`assets/links.jsonc`).

Source of truth: `$HOME/.agents/libs/jsonc/jsonc_lib.sh`.

---

## 3. `libs/notif/notifier.sh` — notifications (sh only)

Single source for all notifications (desktop system notification, Telegram, or
mixed). Every skill that notifies (k-pve, k-ubuntu, k-dockerhost, k-phones, …)
sources THIS file. It depends on `libs/env/env_lib.sh` (`env_load`) to resolve
the token.

| Function | Signature | Purpose |
|----------|-----------|---------|
| `notify_tg_token` | — | Resolve the Telegram token: `$NOTIFY_TG_TOKEN` (explicit per-caller override — RECOMMENDED per skill), else first non-empty of `TELEGRAM_PVE_TOKEN`/`TELEGRAM_UBUNTU_TOKEN`/`TELEGRAM_DOCKERHOST_TOKEN`/`TELEGRAM_S25_TOKEN`/`TELEGRAM_TOKEN`. |
| `notify_emoji` | `<level>` | Print the emoji for a log level (OK/SUCCESS/ERROR/WARN/LOCK/CLEAN/INFO/…). |
| `notify_levels` | — | Print the supported level names. |
| `notify_telegram` | `<level> <message> <title>` | Send a Telegram message (only if token + `$TELEGRAM_CHAT_ID` set); always echo a local log line. |
| `notify_system` | `<level> <message> <title>` | Send a desktop notification (`notify-send`, best effort); echo local log line. |
| `notify_mixed` | `<level> <message> <title>` | Send BOTH system + Telegram. |
| `homelab_lock` | — | Create `/tmp/<basename>.lock` or exit if already running. |
| `homelab_unlock` | — | Remove the lock file. |

Usage from a skill script:

```bash
# shellcheck source=$HOME/.agents/libs/notif/notifier.sh
source "$HOME/.agents/libs/notif/notifier.sh"
NOTIFY_TG_TOKEN="${TELEGRAM_UBUNTU_TOKEN:-}"   # per-skill token (optional)
notify_mixed "OK" "Backup completed" "Backup Workstation"
```

Source of truth: `$HOME/.agents/libs/notif/notifier.sh`.

---

## Guards / checks that consume the libs

| Check | Path | Sources | Purpose |
|-------|------|---------|---------|
| `check-env` | `scripts/env/check_env.sh` | `libs/env/` (+ `scripts/env/lib.sh`) | Validate `.env` / `.env.example` key presence, format, missing keys. |
| `env_inspect` | `scripts/env/env_inspect.sh` | `libs/env/` | Inspect `.env` key names (never values). |
| `check-jsonc` | `scripts/jsonc/check_jsonc.sh` | `libs/jsonc/` | Validate every JSONC asset parses. |
| `check-services` | `scripts/services/check_services.sh` | `libs/jsonc/` (via `scripts/services/lib.sh`) | Orchestrator: asset guard + active guard + internal-paths guard per service. |
| `check-links` | `scripts/links/check_links.sh` | `libs/jsonc/` (via `scripts/links/lib.sh`) | Orchestrator: basic guard + crossref guard + completeness guard per link. |
| `check-tailscale` | `scripts/check_tailscale.sh` | — | Tailscale backbone check (up `--accept-dns --accept-routes`). |

Service/links guards (`scripts/services/service_*_guard.sh`,
`scripts/links/link_*_guard.sh`) source the thin `lib.sh` of their orchestrator,
which in turn sources `libs/jsonc/jsonc_lib.sh` — they never duplicate JSONC
logic.

---

## Adding a new shared concern

1. Create the twin set under `libs/<concern>/` (`env_lib.sh`/`.py`/`.js`, or a
   single `.sh` for pure-shell like notifier) per `libs/AGENTS.md`.
2. Add the inventory row in `libs/AGENTS.md`.
3. Expose it via a check in `scripts/` (thin wrapper that sources `libs/`).
4. Reference it here (this file) so agents discover it.

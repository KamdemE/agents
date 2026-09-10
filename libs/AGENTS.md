# libs/ — shared script libraries (single source of truth, no duplication)

This directory holds the **shared, cross-language libraries** that every
`.agents` script (and infra-skill script) imports instead of re-implementing
logic. There is exactly ONE implementation per concern, available as three
**twins** (shell / Python / JavaScript) that MUST stay identical, language
apart.

## Naming (MANDATORY)

Everything here is `source`d or `import`ed → **ALWAYS `snake_case` with `_`**
(`env_lib.py`, `jsonc_lib.sh`, `notifier.sh`). NEVER kebab-case: a `-` name is
invalid as a Python identifier (`import env-lib` = SyntaxError) and breaks the
twin-name parity across the `.sh`/`.py`/`.js` triplets. Full kernel-wide rule:
`rules/file-governance.md` → Naming Convention.

## Rules (MANDATORY)

1. **Three twins per library, always in sync.** Every library lives in its own
   subdirectory (`libs/env/`, `libs/jsonc/`, …) with the same base name in
   `.sh`, `.py`, and `.js`:
   - `libs/env/env_lib.sh` / `env_lib.py` / `env_lib.js`
   - `libs/jsonc/jsonc_lib.sh` / `jsonc_lib.py` / `jsonc_lib.js`
   - **Single-file exception (`libs/notif/`):** a pure-shell library (e.g.
     `notifier.sh`, Telegram/system notifications) does NOT need `.py`/`.js`
     twins — it is shell-only by design (sourced by shell scripts). Document it
     in the Inventory with the "sh only" flag.
2. **Identical behavior, language apart.** The `.py` and `.js` twins are the
   direct, faithful port of the `.sh` twin. Same function names (snake_case in
   sh/py, camelCase in JS), same return semantics, same edge-case handling.
   If you change behavior in ONE language, you MUST update the other two twins
   AND every caller that uses the library — in the same commit/change.
3. **No duplication, ever.** Any script that needs JSONC parsing uses
   `jsonc_lib.*`; any script that needs `.env` handling uses `env_lib.*`.
   Never inline a local copy of comment-stripping, infra-matching, or env
   loading. If a concern is missing here, ADD it here (new twin set) — do not
   create a private helper in a skill script.
4. **Secrets zero-touch (env_lib).** `env_lib.*` ONLY expose key NAMES and
   "value present / empty" booleans. They NEVER print, read, or return secret
   VALUES. Keep it that way — this is a hard security rule.
5. **Callers.** Shell scripts `source` the `.sh` twin. Python scripts insert
   `libs/` (and the specific subdir) into `sys.path` and `import`. JS/TS hooks
   `import` from the `file://.../libs/<subdir>/` path. See `scripts/AGENTS.md`
   for the uniform check structure that consumes these libs.

## Inventory

| Subdir | Purpose | Twins |
|--------|---------|-------|
| `libs/env/` | `.env` / `.env.example` helpers (keys + presence, never values) | `env_lib.sh` / `env_lib.py` / `env_lib.js` |
| `libs/jsonc/` | JSONC strip/validate/load + infra helpers | `jsonc_lib.sh` / `jsonc_lib.py` / `jsonc_lib.js` |
| `libs/humanize/` | PROSE dash humanization — 4 blocked patterns (---, —, -- , spaced –) + interval 2024–2025 exemption + code whitelist | `humanize_lib.sh` / `humanize_lib.py` / `humanize_lib.js` |
| `libs/notif/` | Notifications (Telegram token + emoji + levels + telegram/system/mixed + homelab lock) | `notifier.sh` (sh only) |

## Reflex

Before creating any helper, utility, or parsing logic inside `.agents`, **check
`libs/` first** — especially for infra-skill scripts dealing with `.env` or
JSONC configs. If a fitting library exists, USE it. If not, add a new twin set
here (per the rules above) and expose it via a check in `scripts/`.

Same reflex for notifications: **never write a private notification helper in a
skill script** — source `libs/notif/notifier.sh` (define `NOTIFY_TG_TOKEN` in
the skill's `.env` or inline fallback, then call `notify_telegram` /
`notify_system` / `notify_mixed`). See `skills/k-*` reference files for per-skill
usage examples.

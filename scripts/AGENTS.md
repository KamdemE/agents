# scripts/ — global utility scripts & uniform checks

This directory holds every global utility / validation script used by the
kernel (`make check`, `make link`, `make reload-services`, …). It follows the
**uniform check philosophy** — the same modular style used by `skills/`
(one entrypoint that only imports and launches, plus small focused guards).

## Structure & philosophy

- **One directory per domain**, each with its own `lib.sh` (thin wrapper that
  sources the shared `libs/` twin) and its checks:
  - `scripts/env/`      → `.env` governance: `check_env.sh` (main), `env_inspect.sh` (debug viewer)
  - `scripts/jsonc/`    → JSONC governance: `check_jsonc.sh` (main)
  - `scripts/services/` → systemd services: `check_services.sh`, `reload_services.sh`, `lib.sh`
  - `scripts/links/`    → symlink registry: `set_links.sh`, `check_links.sh`, `lib.sh`
  - `scripts/check_skills/` → skills audit (Python, modular guards)
  - `scripts/exec/`     → executability (`check_exec.sh`, `chmod.sh`)
  - `scripts/git/`      → git hooks install
  - top-level: `check_tailscale.sh` (backbone check)

- **Shared logic lives in `libs/`, NEVER re-implemented in a check.** JSONC →
  `libs/jsonc/`, `.env` → `libs/env/`. A check must be **thin**: it calls the
  libs and reports; it does not parse/validate itself.

- **Main check = orchestrator only.** The check that `make` calls
  (`check-env`, `check-jsonc`, `check-services`, `check-links`, …) has NO
  business logic. It imports/sources the libs and launches the focused guards,
  then aggregates failures and returns non-zero on any problem.

## Rules (MANDATORY)

1. **Split long/mixed checks.** If a check grows too long or mixes concerns,
   split it into focused sub-checks in the same directory and have the main
   check only `import`/`source` + launch them (exactly like `check_skills.py`
   aggregates its `*_guard.py` modules).
2. **No duplication.** Any parsing/validation/loading must come from the shared
   `libs/` twins (`jsonc_lib.*`, `env_lib.*`, …). Never inline a local copy.
3. **For the `.agents` kernel only**, always propose `make check` before
   commit/push; **never run the kernel check without KπX's explicit request or
   validation in the current conversation**. Once approved, it runs every
   check and MUST be 100% clean (see AGENTS.md → ABSOLUTE RULE — `make check`).
4. **Every script uses `set -uo pipefail`** unless there's a reason not to, and
   is written with `$HOME`/`$USER` (never hardcoded absolute paths).
5. **English** for all new files/comments. Existing files keep their language.
6. **Secrets zero-touch**: `env_lib.*` and any env-related script NEVER print or
   read values — only key names and "present/empty" status.
7. **Keep this doc up to date.** When you add/rename a script or split a check,
   update the structure above so it always mirrors reality.

## Adding a new check

1. Create `scripts/<domain>/check_<thing>.sh` (thin orchestrator) + the lib
   helpers it needs in `libs/` (or reuse existing twins).
2. Add the `make check-<thing>` target in `Makefile` and include it in the
   `check:` aggregate.
3. Document it here (structure) and in the owning `k-*` skill if relevant.
4. For a new kernel check, propose `make check`; run it and ensure it passes
   100% only after KπX's explicit approval.

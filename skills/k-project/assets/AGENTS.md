# AGENTS.md — <project-name>

> Project context for all AI agents working in this repository.
> Loaded automatically by all KπX agents when present at project root.

## KπX Mantras

**Exploration:** Problem First → Why before How → Visualization
**Architecture:** 0 Trust · 100% Control | 0 Magic · 100% Transparency | 0 Hardcoding · 100% Flexibility

## Reply Gate (run before every reply)

- [ ] ASCII diagram for the main idea?
- [ ] Table for comparisons/steps?
- [ ] Full sentences — fluent, connected prose (not telegraphic stubs)?
- [ ] Diagram → table → paragraphs (bullets only for checklists/steps)?

## Project Overview

| Field | Value |
|-------|-------|
| Purpose | <one-line purpose> |
| Stack | Python / TS / ... |
| Status | 🟡 In progress |

## Architecture Rules

- **Non-monolithic** — one package per concern; `src/<pkg>/` / `src/<pkg>/<pkg>` ... layout; no god modules
- **Flexibility** — no hardcoded values, no assumptions; everything configurable via `config.py`/`config.ts` constants or kwargs
- **Robustness** — explicit error handling at boundaries; fail loud, never silently swallow
- **Extensibility** — design for addition, not modification; new packages extend, not patch
- **Encapsulation** — public API explicit; internals prefixed `_`; no god objects
- **No hardcoding** — all runtime values live directly in `config.py`/`config.ts` (plain constants or a frozen dataclass/object) — no `config.yaml`, no loader, no `ConfigManager` singleton
- **Debug flag** — `debug: false` as a default in `config.py`/`config.ts`; override via kwargs or env; never `print()` / `console.log()` in prod

## Agent Output Before Validation

**Until KπX validates something in this project, whatever the agent produces stays in `./tmp/`** — nothing lands in the tracked tree (`src/`, `libs/`, `scripts/`, etc.) before that. This applies to code, scripts, docs, anything. `tmp/` is gitignored and exists in every project for exactly this reason, even a small one.

## scripts/ vs tmp/ Ownership

| Dir | Owner | Rule |
|-----|-------|------|
| `scripts/` | Human | Tracked, **meta** tooling unrelated to the project's own substance (sync scripts, one-off maintenance) — agents don't modify unless explicitly asked |
| `tmp/scripts/` | Agent | Scratch, gitignored — the agent's own working scripts, pending validation |
| Promotion | Human | Manual copy from `tmp/` → `scripts/`/`src/`/`libs/` only after KπX validates it; never auto-promoted |

## Delivery & Structure Pass (mandatory before calling work done)

`implement → tests green → smoke-test → structure pass → update docs`. The structure pass checks (adapt to the project): domain logic stays out of thin CLI/entry-point files; naming stays consistent with the rest of the codebase; no dead imports/branches left from exploration; config/dependency changes are reflected in `pyproject.toml`/`package.json`; docs below are refreshed.

## Docs Maintenance

| Doc | Commit? | Update when |
|-----|---------|-------------|
| `README.md` | Yes | User-facing behavior changes |
| `CHANGELOG.md` | Yes | Every release-worthy change (newest-first) |
| `TODO.md` | Yes | Item done (remove) or new item planned (add) |
| `AGENTS.md` (this file) | **No** — gitignored | Architecture/purpose/workflow drift |

## Evolution Rules

- New feature → update `TODO.md` first, propose before acting
- Any significant change → update `AGENTS.md` (architecture/purpose drift), `README.md` (user-facing), and any relevant `.md` docs (tutorials, API reference, guides)
- Breaking change → bump version in `pyproject.toml` / `package.json` + entry in `CHANGELOG.md`
- Destructive / architectural changes → **stop and confirm with KπX first**
- **Makefile is the standard task runner** — use `make push` (not raw `git push`), `make release`, etc.; check available targets with `make help` before running ad-hoc commands
- **Shell/systemd projects:** keep `scripts/install.sh` and `scripts/purge.sh` in sync with every new module, unit file, or directory the project introduces. These scripts are the contract for deploy and teardown — never let them drift from reality.
- **Git hygiene is enforced globally, not per-project** — `k-git`'s `core.hooksPath` passthrough already blocks commits when `make check` fails and strips AI-agent attribution trailers from every commit message, for every repo. Never set `core.hooksPath` locally in this project.

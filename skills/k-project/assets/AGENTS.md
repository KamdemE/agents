# AGENTS.md — <project-name>

> Project context for all AI agents working in this repository.
> Loaded automatically by all KπX agents when present at project root.

## KπX Mantras

**Exploration:** Problem First → Why before How → Visualization
**Architecture:** 0 Trust · 100% Control | 0 Magic · 100% Transparency | 0 Hardcoding · 100% Flexibility

## Project Overview

| Field | Value |
|-------|-------|
| Purpose | <one-line purpose> |
| Stack | Python / TS / ... |
| Status | 🟡 In progress |

## Architecture Rules

- **Non-monolithic** — one package per concern; `src/<pkg>/` / `src/<pkg>/<pkg>` ... layout; no god modules
- **Flexibility** — no hardcoded values, no assumptions; everything configurable via `config.yaml` / kwargs
- **Robustness** — explicit error handling at boundaries; fail loud, never silently swallow
- **Extensibility** — design for addition, not modification; new packages extend, not patch
- **Encapsulation** — public API explicit; internals prefixed `_`; no god objects
- **No hardcoding** — all values in `config.yaml`; `config.py`/`config.ts` loads them
- **Debug flag** — `debug: false` in config.yaml; override via kwargs or env; never `print()` / `console.log()` in prod

## Evolution Rules

- New feature → update `TODO.md` first, propose before acting
- Any significant change → update `AGENTS.md` (architecture/purpose drift), `README.md` (user-facing), and any relevant `.md` docs (tutorials, API reference, guides)
- Breaking change → bump version in `pyproject.toml` / `package.json` + entry in `CHANGELOG.md`
- Destructive / architectural changes → **stop and confirm with KπX first**
- **Makefile is the standard task runner** — use `make push` (not raw `git push`), `make build`, `make release`, etc.; check available targets with `make help` before running ad-hoc commands

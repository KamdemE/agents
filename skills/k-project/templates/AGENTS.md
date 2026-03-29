# AGENTS.md — <project-name>

> Project context for all AI agents working in this repository.
> Loaded automatically by all KπX agents when present at project root.

## KπX Mantras

**Exploration:** Problem First → Why before How → Visualization
**Architecture:** 0 Trust · 100% Control | 0 Magic · 100% Transparency | 0 Hardcoding · 100% Flexibility

**Engineering slogan:** Flexibilité · Robustesse · Extensibilité · Encapsulation · Non-monolithique

## Project Overview

| Field | Value |
|-------|-------|
| Name | `<project-name>` |
| Purpose | <one-line purpose> |
| Stack | Python / TS / ... |
| Status | 🟡 In progress |

## Architecture Rules

- **Non-monolithic** — one package per concern; `src/<pkg>/` layout; no god modules
- **No hardcoding** — all values in `config.yaml`; `config.py`/`config.ts` loads them
- **Secrets via `.env`** — loaded at runtime; `.env.example` committed, never `.env`
- **POO** — encapsulation; public API explicit; internals prefixed `_`
- **Debug flag** — `debug: false` in config.yaml; override via kwargs or env; never `print()` / `console.log()` in prod

## Evolution Rules

- New feature → update `TODO.md` first, propose before acting
- Breaking change → bump version in `pyproject.toml` / `package.json` + entry in `CHANGELOG.md`
- Destructive / architectural changes → **stop and confirm with KπX first**

---
name: k-project
description: >
  KπX project initialization — naming conventions, structure, config patterns,
  .agents/AGENTS.md template. Load when creating or initializing any project.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
allowed-tools: Bash(*), "*"
---

# KπX — Project Initialization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-git` (push, remotes, Makefiles — load for any git operation) · `k-docker` (load if project will be deployed on homelab)

## Naming Conventions

| Scope | Style | Example |
|-------|-------|---------|
| Project / repo / CLI binary | `kebab-case` | `my-tool`, `k-ai` |
| Module / folder / Python package | `snake_case` | `my_tool`, `k_ai` |
| PyPI / npm package name | `kebab-case` (same as repo) | `kpihx-ai` |

**Name conflict resolution** (PyPI / npm name taken):

1. `k-<name>` — first attempt
2. `k-<name>-x` — second attempt
3. `kpihx-<name>` — fallback

`pyproject.toml` decouples PyPI name from import name:
```toml
[tool.uv.build-backend]
module-name = "snake_name"   # import name ≠ PyPI name
```

## Project Init — Python

```bash
cd ~/Work/<category>/
uv init --package <project-name>
cd <project-name>
```

Initial structure:
```
<project-name>/
  src/<project_name>/
    __init__.py
  pyproject.toml
  README.md
```

Next steps:
1. Replace `pyproject.toml` → `templates/pyproject.toml` (adapt name + deps)
2. Add `src/<pkg>/config.py` → `templates/config.py` + a `config.yaml` defaults file alongside it
3. Add `.env.example` (keys only, no values) — `.env` goes in `.gitignore`

## Project Init — JS/TS

```bash
cd ~/Work/<category>/
mkdir <project-name> && cd <project-name>
bun init -y
```

- **TypeScript over JS** — always, no exceptions
- Add `src/config.ts` → `templates/config.ts` + `config.yaml` defaults

## Standard Files at Init

| File | Notes |
|------|-------|
| `.gitignore` | `.venv/`, `dist/`, `node_modules/`, `.env`, `.agents/` |
| `README.md` | Overview, install, usage |
| `CHANGELOG.md` | Newest-first, semver entries |
| `TODO.md` | Active development backlog |
| `.agents/AGENTS.md` | Project context for AI agents — from `templates/AGENTS.md` |

> **.agents/ is NEVER committed** — always in `.gitignore`.

## .agents/AGENTS.md

All AI agents auto-load `.agents/AGENTS.md` when present at a project root.
Content: KπX mantras · project purpose · architecture rules · evolution rules.
→ Template: `templates/AGENTS.md`

## Architecture Philosophy

- **Non-monolithic** — one package per concern; `src/<pkg>/` layout; no god modules
- **No hardcoding** — all values in `config.yaml`; secrets in `.env`
- **POO** — encapsulation; internals prefixed `_`; public API explicit
- **Config pattern** — `ConfigManager` per package (`templates/config.py` / `config.ts`):
  - 3-layer override: defaults (`config.yaml`) → override file → inline kwargs
  - `@lru_cache` on YAML loading (Python) / `Map` cache (TS)
  - `debug: false` default in config.yaml; never `print()` / `console.log()` in prod
- **Python CLI** — `typer` (interface) + `rich` (output)
- **TypeScript** — always over plain JS

## Local Install

```bash
# Python — editable install (picks up live source changes)
uv tool install . --editable

# JS/TS — bun link (preferred) or npm link
bun link
# then in consumer: bun link <project-name>
```

## Versioning & Release

1. Bump `version` in `pyproject.toml` / `package.json`
2. Add entry to `CHANGELOG.md`
3. Commit: `feat: vX.Y.Z — <summary>`
4. Tag: `git tag vX.Y.Z`
5. Run `make release` → see `k-git` Makefile templates for full pipeline

## References

- **Git workflow + Makefile templates** → `k-git`
- **Server deployment** → `k-docker` *(to be created)*

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v1.1.0 — added Related skills header (k-git, k-docker) |
| 2026-03-29 | [CLAUDE] | v1.0.0 — initial creation |

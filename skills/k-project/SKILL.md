---
name: k-project
description: >
  KπX project initialization — naming conventions (kebab/snake), Python (uv init --package)
  and TypeScript (bun init) setup, pyproject.toml + config.py + config.ts templates,
  .agents/AGENTS.md context file, architecture philosophy (non-monolithic, ConfigManager,
  no hardcoding). Load when creating or initializing any project, setting up pyproject.toml,
  config.py/config.ts, or applying the KπX project structure.
license: private
metadata:
  author: KpihX
  version: "1.9.2"
allowed-tools: Bash(*), "*"
---

# KπX — Project Initialization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-git` (push, remotes, Makefiles — load for any git operation) · `k-docker` (load if project will be deployed on homelab) · `k-git-pages` (load if project needs a Docsify docs site)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** check `~/Work/tutos_live/templates/` (pyproject.toml, config.py are symlinks here) — browse via `ls` or qmd.

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
  CHANGELOG.md
  TODO.md
  LICENSE
  .gitignore
  .agents/
    AGENTS.md
```

Next steps:
1. Replace `pyproject.toml` → `assets/pyproject.toml` (adapt name + deps)
2. Add `src/<pkg>/config.py` → `assets/config.py` + a `config.yaml` defaults file alongside it
3. Add `.env.example` (keys only, no values) — `.env` goes in `.gitignore`, also in `src/<pkg>/`
NB: we can have many `.env.example`, `.env`, `config.yaml`, `config.py`, since by default there are encapsulated in packages ; thus a very autonomous package sould have its own ones.

## Project Init — JS/TS

```bash
cd ~/Work/<category>/
mkdir <project-name> && cd <project-name>
bun init -y / npm init -y
```

- **TypeScript over JS** — always, no exceptions
- Add `src/config.ts` → `templates/config.ts` + `config.yaml` defaults

## Standard Files at Init

```
<project-name>/
├── src/<project_name>/
│   ├── __init__.py
│   ├── config.py          ← from assets/config.py
│   └── config.yaml
├── tests/
├── Makefile               ← from assets/Makefile.uv or Makefile.npm-bun
├── pyproject.toml         ← from assets/pyproject.toml
├── README.md
├── CHANGELOG.md
├── TODO.md
├── LICENSE
├── .gitignore
└── .agents/
    └── AGENTS.md          ← from assets/AGENTS.md (NEVER committed)
```

| File | Notes |
|------|-------|
| `.gitignore` | `.venv/`, `dist/`, `node_modules/`, `.env`, `.agents/` ... |
| `README.md` | Overview, install, usage |
| `CHANGELOG.md` | Newest-first, semver entries |
| `TODO.md` | Active development backlog |
| `.agents/AGENTS.md` | Project context for AI agents — from `assets/AGENTS.md` |
| `LICENSE` | Must be created at init. Default: MIT or GNU. |

> **.agents/ is NEVER committed & NEVER mentionned in repo** — always in `.gitignore`.

## .agents/AGENTS.md

All AI agents auto-load `.agents/AGENTS.md` when present at a project root.
Content: KπX mantras · project purpose · architecture rules · evolution rules.
→ Template: `assets/AGENTS.md`

## Architecture Philosophy

- **Non-monolithic** — one package per concern; `src/<pkg>/` layout; no god modules
- **No hardcoding** — all values in `config.yaml`; secrets in `.env`
- **P

## Changelog

- **v1.9.1 (2024-07-29):**
  - Add rule to create a LICENSE file at project init (default MIT/GNU).
- **v1.9.0 (2024-07-28):**
  - Add `uv init --package <name>` for Python projects.
  - Reorganize sections for clarity.OO** — encapsulation; internals prefixed `_`; public API explicit
- **Config pattern** — `ConfigManager` per package (`assets/config.py` / `config.ts`):
  - 3-layer override: defaults (`config.yaml`) → override file → inline kwargs
  - `@lru_cache` on YAML loading (Python) / `Map` cache (TS)
  - `debug: false` default in config.yaml; never `print()` / `console.log()` in prod
- **Python CLI** — `typer` (interface) + `rich` (output)
- **TypeScript** — always over plain JS

## Makefile — Standard Task Runner

**Always use `make` targets — never raw `git push`, `git tag`, `uv build`, etc.**
Check available targets first: `make help`.

| Common target | What it does |
|---------------|-------------|
| `make push` | Push to **all remotes** simultaneously (github + gitlab) |
| `make build` | Build the package |
| `make release` | Full release pipeline (bump + build + publish + push) |
| `make check` | Lint + type-check |

> Bypassing `make push` in favour of `git push origin` breaks the multi-remote invariant.

## Makefile Templates

Stored in `assets/` — copy to project root as `Makefile` and adapt:

| Template | Use case |
|----------|----------|
| `assets/Makefile.uv` | Python/uv — check, build, publish to PyPI, release pipeline |
| `assets/Makefile.npm-bun` | JS/TS/bun — test, build, publish to npm, release pipeline |

For scripts/shell/misc projects with no package manager → use `k-git/assets/Makefile.git` (baseline git workflow only).

**Publish secrets** (inject via bw-env before running):
- `Makefile.uv` → `UV_PUBLISH_TOKEN`
- `Makefile.npm-bun` → `NPM_TOKEN` (or `BUN_AUTH_TOKEN`)

## Local Install

```bash
# Python — editable install (picks up live source changes)
uv tool install . --editable

# JS/TS — bun link (preferred) or npm link
bun link / npm link <project-name>
# then in consumer: bun link <project-name>
```

## Versioning & Release

1. Bump `version` in `pyproject.toml` / `package.json`
2. Check `TODO.md` — remove completed items
3. Add entry to `CHANGELOG.md` (from TODO.md or general summary)
4. Update `README.md`
5. Commit: `feat: vX.Y.Z — <summary>`
6. Build & publish if the project is to be published (PyPI/npm)
7. Push: `make push` for all remotes
8. Tag: `git tag vX.Y.Z` (suggest when a stable version is reached)
9. Run `make release` → see `k-git` Makefile templates for full pipeline

## Documentation Site

To set up a Docsify GitHub Pages docs site for a project → **`references/docs-site.md`** (this skill dir).

Covers: `docs/` subdirectory pattern, Makefile `push-docs` target, GitHub Pages `main/docs` config.
Load `k-git-pages` for Docsify templates + link rules.

## Agent Proactivity

- **LICENSE file**: Proactively propose creating a `LICENSE` file (e.g., MIT, GNU) if a project does not have one.

## References

- **Git workflow + Makefile templates** → `k-git`
- **Server deployment** → `k-docker`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-31 | [CLAUDE] | v1.9.2 — templates/ → assets/, docs-site.md → references/docs-site.md (skill-creator standard) |
| 2024-07-29 | [GEMINI] | v1.9.1 — Add rule for proactive LICENSE file creation. |
| 2026-03-29 | [CLAUDE] | v1.9.0 — Makefile standard task runner section added (make push/build/release/check table + bypass warning); AGENTS template Makefile rule |
| 2026-03-29 | [CLAUDE] | v1.8.0 — config.ts rewritten to match config.py: resolveEnv() two-tier, SecretsUnavailableError, getSecret(), dotted-path get(), singleton loadConfig/updateConfig/getConfig, full HOW TO USE + PLACEHOLDERS header |
| 2026-03-29 | [CLAUDE] | v1.7.0 — Makefile Templates section added (Makefile.uv+npm-bun moved from k-git); project tree added to Standard Files |
| 2026-03-29 | [CLAUDE] | v1.6.0 — typos fixed (alson, numbering); docs-site.md trimmed to docs/ pattern only; Documentation Site blurb updated |
| 2026-03-29 | [GEMINI] | v1.5.0 — updated References: k-docker now exists |
| 2026-03-29 | [CLAUDE] | v1.4.0 — added Documentation Site section + docs-site.md reference |
| 2026-03-29 | [CLAUDE] | v1.3.0 — description enriched: explicit mentions of pyproject.toml, config.py/ts, uv/bun |
| 2026-03-29 | [CLAUDE] | v1.2.0 — config.py enriched (bw-env _resolve_env, SecretsUnavailableError, get_secret, dotted-path get); pyproject.toml enriched (authors, license, [tool.uv] package=true); concrete examples + k-git-pages cross-ref |
| 2026-03-29 | [CLAUDE] | v1.1.0 — added Related skills header (k-git, k-docker) |
| [SUMMARY] | — | v1.0.0 initial creation |

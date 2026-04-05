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
  version: "2.3.0"
allowed-tools: Bash(*), "*"
---

# KπX — Project Initialization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-git` (push, remotes, Makefiles — load for any git operation) · `k-docker` (load if project will be deployed on homelab) · `k-git-pages` (load if project needs a Docsify docs site)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** check `$HOME/Work/tutos_live/templates/` (pyproject.toml, config.py are symlinks here) — browse via `ls` or `k-qmd`.

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
cd $HOME/Work/<category>/
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
Autonomous packages may each own their own `.env.example`, `.env`, `config.yaml`, and `config.py` when the boundary is real and intentional.

## Project Init — JS/TS

```bash
cd $HOME/Work/<category>/
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
- **OO** — encapsulation; internals prefixed `_`; public API explicit
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
See also **Project Init — Bash/Shell** below.

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

## Project Init — Bash/Shell (no package manager)

For pure shell scripts, CLI wrappers, or systemd-managed tools with no `uv`/`npm`/`bun`:

```
<project-name>/
├── <scripts>.sh         # Main scripts at root or in a flat structure
├── systemd/             # Unit files (source of truth) — copied by install.sh
│   ├── *.service
│   └── *.timer
├── scripts/
│   ├── install.sh       # Install units, create dirs, enable timer/service
│   └── purge.sh         # Disable + remove units (idempotent)
├── .env.example         # Required env vars (keys only, no values)
├── README.md
├── CHANGELOG.md
└── .agents/
    └── AGENTS.md
```

**Mandatory scripts:**
- `scripts/install.sh` — installs the project (systemd units, directories, symlinks, etc.)
- `scripts/purge.sh` — fully removes the project (idempotent, no side effects)

Templates: `k-project/assets/install.sh` and `k-project/assets/purge.sh`.
Both must be kept in sync with the project as it evolves.
For simple projects (no `systemd/`), scripts can live at project root instead of `scripts/`.

**Makefile:** use `k-git/assets/Makefile.git` as base — includes `install`, `purge`, `log`, `status`, and `test-run` targets.

**`make status`** → `systemctl status <project>.service <project>.timer` (NOT git status — use `git-status` for that).
**`make test-run`** → `sudo bash <main-script>.sh` — run the service immediately for manual verification.
**`make install`** → call via `make install` (not `sudo make install`) — the Makefile calls sudo internally. Running `sudo make` runs make as root, which pollutes `.git/` via `git rev-parse` in Makefile variables.

**Machine-specific config** (excludes, paths) that varies per deployment must go in a gitignored conf file (e.g. `excludes.conf`) rather than being hardcoded in scripts. Ship an `.example` variant tracking the expected keys.

**Logging:** use `StandardOutput=journal` in systemd units — do **not** create a custom `logs/` directory or `tee` pipeline. Log access via `journalctl -u <project>`. Expose this in the Makefile as a `log` target:
```makefile
log:  ## Show recent logs (journald)
	@journalctl -u <project> -n 50 --no-pager
```
Document the `make log` / `journalctl` commands in the README — that is the only log admin needed.

## Git Submodules

When a project directory embeds another standalone git repo (submodule), declare it in `.gitmodules`:

```bash
# Add a submodule (run from the parent repo root)
git submodule add git@github.com:KpihX/<repo>.git <path>
# e.g.:
git submodule add git@github.com:KpihX/clean-sh.git clean
```

This creates/updates `.gitmodules`:
```ini
[submodule "clean"]
    path = clean
    url = git@github.com:KpihX/clean-sh.git
```

**Rules:**
- Always use **SSH remotes** in `.gitmodules` (never HTTPS)
- Parent repo tracks submodule at a specific commit — update with `git submodule update --remote <path>` then commit
- `.gitmodules` is committed and tracked by the parent repo
- `docs/` site repos (Docsify GitHub Pages) can also be submodules — see `references/docs-site.md`
- Clone with submodules: `git clone --recurse-submodules git@github.com:...`
- Init after plain clone: `git submodule update --init --recursive`

## Agent Proactivity

- **LICENSE file**: Proactively propose creating a `LICENSE` file (e.g., MIT, GNU) if a project does not have one.

## References

- **Git workflow + Makefile templates** → `k-git`
- **Server deployment** → `k-docker`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-05 | [CLAUDE] | v2.3.0 — Bash/Shell: make status→systemctl, test-run, make install ≠ sudo make install, excludes.conf pattern; k-git Makefile.git svc-status+test-run |
| 2026-04-05 | [CLAUDE] | v2.2.0 — Git Submodules section: .gitmodules format, SSH remotes, clone/update commands, docs-site pointer |
| [SUMMARY] | — | v2.1.0–v1.0.0: Bash/Shell case, install/purge templates, journald rule, docs-site refs, config/env per-package, architecture rewrite, assets/ migration, and earlier |

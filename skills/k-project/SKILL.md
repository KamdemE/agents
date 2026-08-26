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
  version: "2.13.0"
allowed-tools: Bash(*), "*"
---

# KπX — Project Initialization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-git` (push, remotes, Makefiles — load for any git operation) · `k-final` (**mandatory** when closing a project workstream — full checklist: tests, hygiene, docs, semver, push, CI, deploy logs, install, publish) · `k-docker` (load if project will be deployed on homelab) · `k-git-pages` (load if project needs a Docsify docs site) · `k-node` (Node/bun runtime versions, npm global tools, fnm management)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** `assets/pyproject.toml` + `assets/config.py` in this skill are the source of truth. External repos that referenced them via local symlinks (techskills/𝛱/TechSkills `templates/`) were **unplugged 2026-08-15** — they now reference the gitlab URL `https://gitlab.com/kpihx/agents/-/blob/main/skills/k-project/assets/<file>` instead. Browse via `ls` or `k-qmd`.

## Naming Conventions

| Scope | Style | Example |
|-------|-------|---------|
| Project / repo / CLI binary | `kebab-case` `-` | `my-tool`, `k-agent` |
| Module / folder / Python package | `snake_case` `_` | `my_tool`, `k_ai` |
| PyPI / npm package name | `kebab-case` (same as repo) | `kpihx-ai` |
| Script file — executable (shell) | `kebab-case` `-` | `scripts/install-hooks.sh` |
| Script file — sourced lib/guard (shell) | `snake_case` `_` | `link_basic_guard.sh` |
| Python module/package file (imported) | `snake_case` `_` — mandatory (`import foo-bar` = SyntaxError) | `config.py`, `check_skills/` |

> Kernel-wide file-naming rule (executable vs sourced vs imported): `rules/file-governance.md` → Naming Convention. In-repo canonical examples: `.agents/scripts/check-links.sh` / `.agents/scripts/link_basic_guard.sh`.

**Name conflict resolution** (PyPI / npm name taken — applies ONLY to KπX-owned projects):

1. `k-<name>` — first attempt
2. `k-<name>-x` — second attempt
3. `<name>-kpihx` — fallback

**Scope:** This naming convention applies **exclusively** to KπX's own publishable projects (skills published on registries, CLI tools, libraries on PyPI/npm). It does NOT apply to:
- Third-party tool wrappers (keep their native name, e.g. `hermes`, `gcloud`, `ollama`)
- Symlinks or aliases in `~/.local/bin/` (use the tool's original binary name)
- Configuration proxies or profile scripts for existing tools (e.g., `gws` profile aliases are internal to `k-google`, not published)

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
2. Add `src/<pkg>/config.py` → `assets/config.py` + a `config.yaml` runtime defaults file alongside it
3. Add `CONTRACT.md` from `references/contract-template.md` (mandatory; source-of-truth for external behavior)
4. Add `.env.example` (keys only, no values) — `.env` goes in `.gitignore`, also in `src/<pkg>/`
Autonomous packages may each own their own `.env.example`, `.env`, `config.yaml`, and `config.py` when the boundary is real and intentional.

## Project Init — JS/TS

```bash
cd $HOME/Work/<category>/
mkdir <project-name> && cd <project-name>
bun init -y / npm init -y
```

- **TypeScript over JS** — always, no exceptions
- Add `src/config.ts` → `templates/config.ts` + `config.yaml` defaults
- Add `CONTRACT.md` from `references/contract-template.md` (mandatory before transport/API implementation)

## Standard Files at Init

```
<project-name>/
├── src/<project_name>/
│   ├── __init__.py
│   ├── config.py          ← from assets/config.py
│   └── config.yaml
├── CONTRACT.md            ← from references/contract-template.md (mandatory)
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
| `Makefile` | Seeded from `assets/Makefile.uv` or `assets/Makefile.npm-bun`. **MUST have `SHELL := /bin/zsh`** at top — ensures `.zshenv` → `.kshrc` → `fnm` → Node v24 is available inside make recipes. Without it, `make` uses `/bin/sh` which lacks fnm/Node PATH. |
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
- **No hardcoding** — runtime values in `config.yaml`; secrets in `.env`
- **Config Standard (2026-08-14)** — KπX config-file standard is **JSONC** (JSON with `//` comments) for `.agents/` config assets and any non-code config (self-documenting, single source of truth). For **code projects**, prefer a plain `config.py` / `config.ts` (simpler — no import needed) over a config loader; secrets always in `.env` (never committed). JSONC is the standard for kernel/asset config (see `assets/*.jsonc` in `.agents`); `config.py`/`config.ts` for project code; `.env` for secrets.
- **No metadata in config** — package/app metadata (name, version, contract schema/version) lives in `pyproject.toml` or `package.json`, never in `config.yaml` / `config.ts` payloads to avoid desync.
- **Contract-first by default** — `CONTRACT.md` is mandatory at init; define operation surface/types/error model/transport mapping in English before scaling implementation.
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

**Publish secrets** (ensure environment is loaded):
- `Makefile.uv` → `UV_PUBLISH_TOKEN`
- `Makefile.npm-bun` → `NPM_TOKEN` (or `BUN_AUTH_TOKEN`)

## Local Install

Always prefer development linking to ensure the CLI uses the current codebase:

- **Python (uv)**: `make link` (user-level editable install)
- **JS/TS (bun)**: `make link` (runs `bun link`)
- Use `make unlink` to revert.

> **🛡️ Security Note**: For critical or sensitive projects (e.g. secret management, system tools), the development `link` is insufficient for production. In those cases, you MUST load **`k-final`** and follow the **Sovereign Security** workflow to perform a root-owned immutable install (`make install`) with AppArmor jailing.

## Versioning & Release

> **Closure:** Treat this section as the **content** of a release pass; the **process order** and gates (tests, CI, deploy logs, `dist/` wipe, tokens) live in **`k-final`** — load it whenever you finalize or "clean" the project so nothing is forgotten.

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
Covers: `docs/` subdirectory pattern, Makefile `push-docs` target, GitHub Pages `main/docs` config. Load `k-git-pages` for Docsify templates + link rules.

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
For simple projects (no `systemd/`), scripts can live at project root instead of `scripts/`.**Makefile:** use `k-git/assets/Makefile.git` as base — includes `install`, `purge`, `log`, `status`, and `run` targets.

**`make status`** → `systemctl status <project>.service <project>.timer` (NOT git status — use `git-status` for that).
**`make run`** → run `<main-script>.sh` via **shared tmux** if it needs elevation; otherwise normal shell.
**`make install`** → `make install` only — privilege stays in install targets; KπX approves `sudo` in tmux when needed (`k-tmux`). Never `sui` (deprecated). Running the whole Makefile as root pollutes `.git/` via `git rev-parse` in Makefile variables.

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
- **Contract template** → `references/contract-template.md`
- **Daemon-based CLI patterns** → `references/daemon-pattern.md` (O_EXCL lock, socket-first bind, readiness wait, idle-exit ping exclusion, env-scoped test isolation — verified in whats-proxy v0.2.0)

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-project/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-project/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [COLAB] | v2.13.0 — **File-level `_`/`-` naming rows added**: Naming Conventions table extended with executable shell script (`kebab -`), sourced lib/guard (`snake _`), imported Python module (`snake _`, mandatory) + cross-ref to `rules/file-governance.md` → Naming Convention (new kernel-wide rule created same day after the scripts/ guards `-` regression fix). |
| 2026-08-15 | [COLAB] | v2.12.0 — **Proxy relocation reference updated**: `references/daemon-pattern.md` path updated (`~/KpihX-Labs/whats_proxy/` → `~/KpihX-Labs/proxies/whats-proxy/`) after the `*_proxy` family moved into `proxies/` and aligned to kebab-case naming. |
| [SUMMARY] | — | v2.11.0 template→gitlab-URL unification (assets/pyproject.toml + config.py source of truth; techskills/𝛱 symlinks unplugged) · v2.10.0 Config Standard (JSONC) (→ `references/log.md`) · v2.9.0 daemon CLI patterns (→ `references/log.md`) · v2.8.0 zsh SHELL mandate; v2.7.x naming scope + dev install + sudo scoping — archived → `references/log.md` |

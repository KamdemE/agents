---
name: k-project
description: >
  KπX project initialization — naming conventions (kebab/snake), Python (uv init --package)
  and TypeScript (bun init) setup, pyproject.toml + config.py + config.ts templates,
  AGENTS.md (repo root) context file, architecture philosophy (non-monolithic, plain config.py/ts,
  no hardcoding), Service/Lib vs Pipeline R&D archetypes. Load when creating or initializing any project, setting up pyproject.toml,
  config.py/config.ts, or applying the KπX project structure.
license: private
metadata:
  author: KpihX
  version: "2.16.1"
allowed-tools: Bash(*), "*"
---

# KπX — Project Initialization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-git` (push, remotes, Makefiles — load for any git operation) · `k-final` (**mandatory** when closing a project workstream — full checklist: tests, hygiene, docs, semver, push, CI, deploy logs, install, publish) · `k-docker` (load if project will be deployed on homelab) · `k-git-pages` (load if project needs a Docsify docs site) · `k-node` (Node/bun runtime versions, npm global tools, fnm management)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** `assets/pyproject.toml` + `assets/config.py` in this skill are the source of truth. External repos that referenced them via local symlinks (techskills/𝛱/TechSkills `templates/`) were **unplugged 2026-08-15** — they now reference the gitlab URL `https://gitlab.com/kpihx/agents/-/blob/main/skills/k-project/assets/<file>` instead. Browse via `ls` or `k-qmd`.

## Project Archetypes

Two archetypes, same tooling backbone (`uv`, `Makefile`, `AGENTS.md`, `k-git` hooks) — pick one at init, don't blend:

| | **Service / Lib** (default, this file) | **Pipeline R&D** (→ `references/pipeline-archetype.md`) |
|---|---|---|
| Shape | One package, CLI or long-running service | `src/` = thin CLI shell · `libs/` = domain-grouped reusable code, zero business constants |
| Config | `config.py`/`config.ts`, plain constants/dataclass | Same, plus frozen dataclasses for run parameters |
| Non-code assets | None by default, or ad-hoc | `assets/{inputs,results,weights}/` — see reference |
| Multi-stage scripts | Not applicable | `step_NN_<name>` naming (module names can't start with a digit) |
| Scratch area | `tmp/` if needed, no fixed shape | `tmp/` with a fixed small root — see reference |
| Heavy asset sync (network drive, NVMe mirror, Windows↔Linux) | Not applicable | → `k-rclone` → `references/mnt-sync.md` |

Load `references/pipeline-archetype.md` when the project is an R&D/ML pipeline (multi-stage, uv workspace with CPU/GPU variants, heavy local data). Everything else in this file (naming, Makefile, config, git hooks) applies to **both** archetypes unchanged.

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
  AGENTS.md
```

Next steps:
1. Replace `pyproject.toml` → `assets/pyproject.toml` (adapt name + deps)
2. Add `src/<pkg>/config.py` → `assets/config.py` (plain constants/frozen dataclass — no `config.yaml`, no `ConfigManager`)
3. Add `CONTRACT.md` from `references/contract-template.md` (mandatory; source-of-truth for external behavior)
4. Add `.env.example` (keys only, no values) — `.env` goes in `.gitignore`, also in `src/<pkg>/`

> **🔴 No `config.yaml`, no `ConfigManager` (removed 2026-08-25):** `config.py`/`config.ts` hold plain constants or a frozen `dataclass`/object directly — no YAML loader, no layered-override singleton, no preload cost. Override at runtime only when actually needed (`dataclasses.replace()` in Python, a fresh object literal in TS) — never build a config-loading abstraction "just in case."
Autonomous packages may each own their own `.env.example`, `.env`, and `config.py` when the boundary is real and intentional.

## Project Init — JS/TS

```bash
cd $HOME/Work/<category>/
mkdir <project-name> && cd <project-name>
bun init -y / npm init -y
```

- **TypeScript over JS** — always, no exceptions
- Add `src/config.ts` → `assets/config.ts` (plain constants — no `config.yaml`)
- Add `CONTRACT.md` from `references/contract-template.md` (mandatory before transport/API implementation)

## Standard Files at Init

```
<project-name>/
├── src/<project_name>/
│   ├── __init__.py
│   └── config.py          ← from assets/config.py (plain constants/dataclass, no YAML)
├── CONTRACT.md            ← from references/contract-template.md (mandatory)
├── tests/
├── Makefile               ← from assets/Makefile.uv or Makefile.npm-bun
├── pyproject.toml         ← from assets/pyproject.toml
├── README.md
├── CHANGELOG.md
├── TODO.md
├── LICENSE
├── .gitignore
├── tmp/                   ← gitignored scratch — everything the agent produces before KπX validates it
└── AGENTS.md              ← from assets/AGENTS.md (NEVER committed)
```

| File | Notes |
|------|-------|
| `Makefile` | Seeded from `assets/Makefile.uv` or `assets/Makefile.npm-bun`. **MUST have `SHELL := /bin/zsh`** at top — ensures `.zshenv` → `.kshrc` → `fnm` → Node v24 is available inside make recipes. Without it, `make` uses `/bin/sh` which lacks fnm/Node PATH. |
| `.gitignore` | `.venv/`, `dist/`, `node_modules/`, `.env` — `AGENTS.md`/`.agents/` don't need a per-project entry, `k-git`'s global excludesFile already ignores them everywhere |
| `README.md` | Overview, install, usage |
| `CHANGELOG.md` | Newest-first, semver entries |
| `TODO.md` | Active development backlog |
| `AGENTS.md` (repo root) | Project context for AI agents — from `assets/AGENTS.md` |
| `LICENSE` | Must be created at init. Default: MIT or GNU. |
| `tmp/` | Gitignored scratch. Until KπX validates something, that's where the agent's output lives — nothing goes straight into `src/`/`scripts/` unvalidated. |

> **🔴 Standard is root `AGENTS.md`, not `.agents/AGENTS.md` (revised 2026-08-25).** One file, at the project root, gitignored by exact name (see `k-git`'s global excludesFile) — never committed, never mentioned in tracked files. No `.agents/` subdirectory for this.

## AGENTS.md

All AI agents auto-load `AGENTS.md` when present at a project root.
Content: KπX mantras · project purpose · architecture rules · evolution rules.
→ Template: `assets/AGENTS.md`

## Architecture Philosophy

- **Non-monolithic** — one package per concern; `src/<pkg>/` layout; no god modules
- **No hardcoding** — runtime values as plain constants or a frozen `dataclass`/object directly in `config.py`/`config.ts`; secrets in `.env`
- **Config Standard (2026-08-14, revised 2026-08-25)** — KπX config-file standard is **JSONC** (JSON with `//` comments) for `.agents/` config assets and any non-code config (self-documenting, single source of truth). For **code projects**: `config.py` / `config.ts` hold the values directly — no `config.yaml`, no loader, no `ConfigManager` singleton (removed kernel-wide 2026-08-25 — layered YAML merging added preload cost and indirection nothing in KπX projects actually needed); secrets always in `.env` (never committed).
- **No metadata in config** — package/app metadata (name, version, contract schema/version) lives in `pyproject.toml` or `package.json`, never in `config.py` / `config.ts` payloads to avoid desync.
- **Contract-first by default** — `CONTRACT.md` is mandatory at init; define operation surface/types/error model/transport mapping in English before scaling implementation.
- **OO** — encapsulation; internals prefixed `_`; public API explicit
- **Config pattern** — plain `config.py` / `config.ts` (`assets/config.py` / `config.ts`): constants or a frozen `dataclass` (Python) / plain object (TS) declared directly in the module. Override only when a real need appears (test isolation, CLI flag) via `dataclasses.replace()` (Python) or a fresh object literal (TS) — never a YAML file, never a cached layered-merge singleton.
- **Python CLI** — `typer` (interface) + `rich` (output)
- **TypeScript** — always over plain JS

## Makefile — Standard Task Runner

**Always use `make` targets — never raw `git push`, `git tag`, `uv build`, etc.**
Check available targets first: `make help`.

| Common target | What it does |
|---------------|-------------|
| `make push` | Push to **all remotes** simultaneously (github + gitlab) |
| `make uv-build` / `make bun-build` | Build the package |
| `make release` | Full release pipeline: `check → push → publish → push-tags` |
| `make check` | Lint + format-check + type-check + tests (also run by the global pre-commit gate, see `k-git`) |

> Bypassing `make push` in favour of `git push origin` breaks the multi-remote invariant.

## Makefile Templates

Stored in `assets/` — copy to project root as `Makefile` and adapt:

| Template | Use case |
|----------|----------|
| `assets/Makefile.uv` | Python/uv — check, build, publish to PyPI, release pipeline |
| `assets/Makefile.npm-bun` | JS/TS/bun — test, build, publish to npm, release pipeline |
| `assets/Makefile.pipeline` + `assets/pyproject.pipeline.toml` | Pipeline R&D archetype — uv workspace (`libs/` members), CPU/GPU dependency groups, `step_NN_` console-script legend; see `references/pipeline-archetype.md` |

For scripts/shell/misc projects with no package manager → use `k-git/assets/Makefile.git` (baseline git workflow only).
See also **Project Init — Bash/Shell** below.

**Publish secrets** (ensure environment is loaded):
- `Makefile.uv` → `UV_PUBLISH_TOKEN`
- `Makefile.npm-bun` → `NPM_TOKEN` (or `BUN_AUTH_TOKEN`)

## Local Install

Always prefer development linking to ensure the CLI uses the current codebase:

- **Python (uv)**: `make uv-link` (user-level editable install); `make uv-uninstall` to revert
- **JS/TS (bun)**: `make bun-link` (runs `bun install && bun link`); `make bun-unlink` to revert

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

For pure shell scripts, CLI wrappers, or systemd-managed tools with no `uv`/`npm`/`bun` → **`references/bash-shell-init.md`** (layout, mandatory `install.sh`/`purge.sh`, Makefile base, logging via journald).

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
- **Bash/Shell project init** → `references/bash-shell-init.md`
- **Daemon-based CLI patterns** → `references/daemon-pattern.md` (O_EXCL lock, socket-first bind, readiness wait, idle-exit ping exclusion, env-scoped test isolation — verified in whats-proxy v0.2.0)
- **Pipeline R&D archetype** → `references/pipeline-archetype.md` (src/libs split, assets convention, step_NN scripts, tmp/ scratch discipline, anti-patterns)
- **Heavy asset sync (network drive/NVMe mirror/Windows↔Linux)** → `k-rclone` → `references/mnt-sync.md`

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-project/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-project/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-05 | [LIVE] | v2.16.1 — **Root `AGENTS.md` standard enforced in references**: `references/docs-site.md` + `references/bash-shell-init.md` trees now show `AGENTS.md` at repo root (never `.agents/AGENTS.md`). |
| 2026-09-02 | [LIVE] | v2.16.0 — **Makefile.npm-bun publish pattern updated**: `bun-publish` now uses `npm config set` + `npm publish --access public` with `$(NPM_TOKEN)`. Agent calls `with-env make bun-publish`. |
| [SUMMARY] | — | v2.15.0 Root AGENTS.md + Makefile templates · v2.14.0 Pipeline R&D archetype + config.yaml purge · older → `references/log.md` |

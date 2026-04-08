---
name: k-final
description: >
  Post-work project closure workflow: tests, hygiene, config-as-docs, markdown
  sync, versioning, git (submodules order), CI/CD watch, deploy log check,
  local install, build/publish. Load when finishing a feature or release pass on
  any KπX project.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: project-lifecycle
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Project Finalization (`k-final`)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-project` (structure, Makefile, config pattern) · `k-git` (remotes, `make push`, CI hooks) · `k-docker` + `k-homelab` (deployed services, `docker logs`, docker-host SSH) · `k-git-pages` (Docsify `docs/` sub-repos) · `k-optim` (optional deep cleanup overlap — load if scope is large)
> **Resume token:** if execution stops on a blocker, KπX says **`continue`** → re-read this skill from the top and resume from the failed phase; do not skip earlier satisfied gates without re-verifying if context changed.

## Role

Mandatory **closing pass** after substantive work on a repo: every phase below is executed **as far as the project type allows**. Skip only what is **not applicable** (e.g. no `tests/` in a shell-only repo — still document why in `CHANGELOG` or `README` if relevant).

## Phase A — Tests

1. Extend `tests/` (or project test command) for **new behavior** not yet covered.
2. Run the full suite (`make test`, `make check`, `uv run pytest`, `bun test`, etc. — prefer **Makefile** targets).
3. Fix code until **all tests pass**. If a failure is ambiguous, **stop**, list hypotheses + options, wait for KπX validation before large rewrites.

## Phase B — Codebase hygiene

1. Remove orphan files, stale scratch artifacts, and unused imports / dead branches (no drive-by unrelated refactors).
2. Prefer **modular, extensible** layout; move magic values into **`config.yaml`** (or env + `.env.example`) — **de-hardcode**.
3. Comments: **sparing** in code; **rich** in **`config.yaml`** — every production-relevant key should be understandable **without** an external tutorial site (options, defaults, constraints, examples in YAML comments where the format allows).

## Phase C — Documentation (all tracked Markdown)

Refresh **every** present doc in scope:

| Artifact | Rule |
|----------|------|
| `README.md` | Install, usage, architecture pointers, current behavior |
| `CHANGELOG.md` | Newest-first; semver entry for this release pass |
| `TODO.md` | Remove **done** items; move substance to `CHANGELOG` (CHANGELOG may list work never in TODO) |
| `docs/` or docs submodule | All `.md` pages + sidebar/index if Docsify |
| `.agents/AGENTS.md` | Project agent context (local only — **never committed**; see `k-project`) |

## Phase D — Packaging & deploy artifacts

1. `.gitignore` / `.dockerignore` — align with actual tree (artifacts, secrets, `.agents/`).
2. `Dockerfile`*, `docker-compose*` — sync with app entrypoints, env, labels; load `k-docker` if homelab deploy.
3. CI config (`.gitlab-ci.yml`, GitHub Actions) — matches Makefile commands and deploy paths.

## Phase E — Version bump (semver)

Bump **`x.y.z`** in the owning metadata (`pyproject.toml`, `package.json`, Helm chart, etc.):

| Change type | Bump |
|-------------|------|
| Bugfix / internal-only fix | **PATCH** |
| New backward-compatible feature or notable doc/CI restructure | **MINOR** |
| Breaking API or incompatible config | **MAJOR** |

Keep a single coherent version across monorepo packages if the repo defines that rule.

## Phase F — Git commit order & push

1. **Docs submodule first** (if `docs/` is a separate repo): commit + `make push` **inside** `docs/`, then return to parent.
2. Parent repo: commit all applicable changes (never stage `.agents/` if gitignored).
3. **All remotes:** `make push` (never push a single remote alone) — `k-git`.
4. **SSH / Bitwarden:** if push fails with auth, **stop** — remind KπX to unlock **Bitwarden Desktop** + approve SSH; retry after `continue`.

## Phase G — CI/CD (deployed projects)

If `.gitlab-ci.yml` and/or GitHub Actions exists:

1. Watch pipelines to **green**: `glab pipeline list --repo <namespace>/<repo>`, `gh run watch` / `gh run list` as appropriate.
2. On failure: fix, recommit, `make push`, re-watch until **all** required jobs pass.

## Phase H — Runtime verification (after deploy)

For Docker / homelab / server workloads (load `k-docker`, `k-homelab`):

1. After CI deploy succeeds, inspect **service logs** (`docker logs`, `journalctl`, Portainer, Traefik — whatever the project uses) on **docker-host** or target environment.
2. Fix forward (config, image tag, compose) until logs are **healthy** (no recurring errors; startup clean).

## Phase I — Local install (after H when deploy applies)

**Order:** deploy healthy first when the project is deployed; otherwise run after Phase F.

Prefer, in order:

- Python: `uv tool install . --editable --force` or `make` target wrapping the same
- JS/TS: `bun link` / `npm link` per `k-project`
- Shell/systemd: `make install` → `scripts/install.sh` (propose `install.sh` + `purge.sh` from `k-project` templates if missing and no package manager)

## Phase J — Build & publish

1. **Remove old build output** before build: e.g. `rm -rf dist/` build dirs (or `make clean` if defined).
2. `make build` then publish via Makefile (`make publish` / `make release` — see project Makefile).
3. **Secrets:** `UV_PUBLISH_TOKEN`, `NPM_TOKEN` / `BUN_AUTH_TOKEN` via **bw-env** (`k-project`). If missing or invalid → **stop**; tell KπX to unlock **Vaultwarden / bw-env** and export tokens; say **`continue`** to retry.
4. On publish success, tag if the project uses release tags (`k-git` / `k-project` versioning section).

## Blocker protocol

- **Any** hard stop (tests flaky, permission denied, unclear product choice): present **issues + propositions**; wait for KπX validation.
- After resolution, KπX replies **`continue`** → agent **re-opens `k-final`** and resumes from the blocked phase.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v1.0.0 — initial skill: post-work test → hygiene → config-docs → markdown → ignores/docker → semver → git order → CI → runtime logs → local install → build/publish; resume token `continue`. |
| [SUMMARY] | — | initial baseline |

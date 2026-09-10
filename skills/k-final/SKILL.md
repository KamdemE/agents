---
name: k-final
description: >
  Post-work project closure workflow: tests, hygiene, config-as-docs, markdown
  sync, versioning, git (submodules order), CI/CD watch, deploy log check,
  local install, build/publish, then `.agents/` kernel sync (k-context, check,
  push). Every phase is obligatory when it applies - no silent skips. Load when
  finishing a feature or release pass on any  project.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: project-lifecycle
allowed-tools: Bash, Read, Write, Edit
---

#  — Project Finalization (`k-final`)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **Related skills:** `k-project` (structure, Makefile, config pattern, Pipeline R&D archetype → `references/pipeline-archetype.md`) · `k-git` (remotes, `make push`, global hook gates) · `k-docker` + `<github-user>` (deployed services) · `k-git-pages` (Docsify) · `k-context` (kernel updates in Phase K)
> **Static rules:** `rules/audit-commands.md` (make check, uv, make push, post-work checklist) · `rules/k-context-hygiene.md` (session log, active projects)
> **Resume token:** if execution stops on a blocker,  says **`continue`** → re-read this skill from the top and resume from the failed phase.

## Role

Mandatory **closing pass** after substantive work on a repo: you **must** execute **every phase A→K** whose preconditions are true for that repo. **None of these steps are facultative** — forgetting or hand-waving a gate (e.g. assuming CI is green, skipping `docker logs`, skipping `glab` job inspection) is a **process violation**.

### Obligation rule (non-negotiable)

1. Walk phases **in order**, respecting documented ordering (e.g. Phase **I** after **H** when the project is deployed).
2. **Skip** a phase only when a precondition is **objectively false** for that tree (example: no `tests/` and no test target in `Makefile` → state the skip in `CHANGELOG` or the session note). **Fatigue, time pressure, or “probably fine” are never valid skips.**
3. If you discover a missed gate after the fact, **go back**, run the missing steps, fix what they reveal, then update **`k-context`** (and project docs) in the same closure pass.

**Kernel contract:** `AGENTS.md`, `k-context`, `k-project`, and `k-git` all instruct agents to **load this file** when finalizing or "cleaning" a project — treat that as a hard gate, not a suggestion.

## Assets

- `assets/Makefile.security.uv`
- `assets/Makefile.security.bun`

## Phase A — Tests

1. Extend `tests/` (or project test command) for **new behavior** not yet covered.
2. Run `make check` (lint + format-check + type-check + `smoke` + tests — prefer this over ad-hoc `uv run pytest`/`bun test` so nothing is skipped).
3. Fix code until **all tests pass**. If a failure is ambiguous, **stop**, list hypotheses + options, wait for  validation before large rewrites.

## Phase B — Codebase hygiene

1. Remove orphan files, stale scratch artifacts, and unused imports / dead branches (no drive-by unrelated refactors).
2. Prefer **modular, extensible** layout; move magic values into **`config.py`/`config.ts`** constants (or `.env`/`.env.example` for secrets) — **de-hardcode**. No `config.yaml`, no `ConfigManager` (removed kernel-wide 2026-08-25 — see `k-project`).
3. Comments: **sparing** in code; explanatory comments belong **next to the `config.py`/`config.ts` constant they document** — every production-relevant value should be understandable without an external tutorial site (purpose, constraints, examples in a comment above the constant).
4. **Doc/Makefile drift check**: diff the Makefile targets documented in `README.md`/`AGENTS.md` against real `make help` output — a project's own docs can silently fall behind its Makefile (observed in a real project audit 2026-08-25); fix whichever side is stale.

## Phase C — Documentation (all tracked Markdown)

Refresh **every** present doc in scope:

| Artifact | Rule |
|----------|------|
| `README.md` | Install, usage, architecture pointers, current behavior |
| `CHANGELOG.md` | Newest-first; semver entry for this release pass |
| `TODO.md` | Remove **done** items; move substance to `CHANGELOG` (CHANGELOG may list work never in TODO) |
| `docs/` or docs submodule | All `.md` pages + sidebar/index if Docsify |
| `AGENTS.md` (repo root) | Project agent context (local only — **never committed**, gitignored by name via `k-git`'s global excludes; see `k-project`) |

## Phase D — Packaging & deploy artifacts

1. `.gitignore` / `.dockerignore` — align with actual tree (artifacts, secrets, `.agents/`).
2. `Dockerfile`*, `docker-compose*` — sync with app entrypoints, env, labels; load `k-docker` if homelab deploy.
3. CI config (GitHub Actions) — matches Makefile commands and deploy paths.

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
4. **Missing remote is not a stop condition:** if `origin` is absent, create it first (SSH only), then run `make push`.
   - GitHub bootstrap: create repo and wire `github` remote.
   - GitHub bootstrap: create repo (`gh repo create`) and wire `origin` remote.
   - Do not continue closure with only one remote configured.
4. **SSH / Bitwarden:** if push fails with auth, **stop** — remind  to unlock **Bitwarden Desktop** + approve SSH; retry after `continue`.

## Phase G — CI/CD (deployed projects)

**Obligatory** if `.gitlab-ci.yml` and/or GitHub Actions exists — until fully verified you do **not** call the project “done”.

1. **GitHub Actions:** `gh run list --repo <user>/<project>` for the branch you pushed, then `gh run view <run-id>` — confirm **each required job** is `success` (deploy stages included). `gh run list` alone is **insufficient** (it can hide failed jobs); always inspect jobs.
2. Workflows must be green before calling the project done.
3. On any failure: fix, recommit, `make push`, re-run this phase until **all** required jobs pass.

## Phase H — Runtime verification (after deploy)

**Obligatory** whenever Phase **G** included a **deploy** job or any Docker/Kubernetes rollout for that service (not optional “if you care”).

1. After deploy jobs are **success**, inspect **service logs** on the target host (`ssh docker-host` per `k-homelab`, then `docker logs <container> --tail …`, or the project’s `make log` target).
2. **HTTP health:** if the service exposes a public or internal health URL, **`curl -fsS`** it (e.g. `https://<public-host>/health`) and record failure modes.
3. Fix forward (image tag, compose, env) until the container is **healthy** and logs show no recurring errors.

## Phase I — Local install

**Order:** deploy healthy first when the project is deployed; otherwise run after Phase F.

### 🏠 Standard Projects (Developer Link)
Always prefer local linking for development to ensure the CLI uses the current codebase:
- **Python (uv)**: `make uv-link` (runs `uv tool install --editable .`); `make uv-uninstall` to clean up
- **JS/TS (bun)**: `make bun-link` (runs `bun install && bun link`); `make bun-unlink` to clean up
- **Other**: Use the project's standard link/dev-install command.

### 🛡️ Sovereign Security Projects (Critical/System)
For tools managing secrets (like `bw-proxy` — `bw-mcp`/`bw-admin` were purged 2026-08-14), system-level installs, or core homelab automation, enforce **Root-Protection** and **Confinement**:

1. **Root-Immutable Install**:
   - Use `make install` to deploy in `/opt/$(PKG_NAME)` with `root:root` ownership.
   - **Infrastructure Hardening**: Use `REAL_USER` and `REAL_HOME` detection in the `Makefile` so paths resolve correctly under elevation.
   - **Internal Hygiene**: Remove redundant `sudo` from Makefile targets;  runs privileged install steps via **shared tmux** (`k-tmux`) — **`sui` is deprecated** for agents.
   - Use the template from **`k-final/assets/Makefile.security.[uv|bun]`**.
   - **Requirement**: The agent MUST merge the security targets from `k-final` into the project's standard `Makefile` (from `k-project`).
2. **AppArmor Jailing**:
   - Critical apps MUST have an AppArmor profile.
   - `make install` should automatically generate and load the profile from the `apparmor-apply` target.
3. **Data & Binary Ownership**:
   - Persistent data/logs MUST live in `$(REAL_HOME)/.$(PKG_NAME)` with **700** permissions.
   - Root-created symlinks in `$(REAL_HOME)/.local/bin` MUST be fixed with `chown -h $(REAL_USER):$(REAL_USER)`.
   - The `install` target MUST recursively `chown` the data directory to `REAL_USER`.
4. **Audit & Verification**:
   - The `Makefile` MUST include an `audit` target (see templates) verifying root ownership, directory permissions (700 for data), and AppArmor enforcement.
    - Run `make check` after every install; success is mandatory.

## Phase J — Build & publish

1. `make uv-build` / `make bun-build` wipes `dist/` first (built into the target — no separate manual `rm -rf dist/` step needed).
2. `make uv-publish` / `make bun-publish` (each depends on its own `*-build` target, so `make release` alone runs the whole chain: `check → push → publish → push-tags` — see project Makefile).
   - **Requirement**: `UV_PUBLISH_TOKEN` / `NPM_TOKEN` must be in the environment before running `make`. The agent calls `with-env make bun-publish` (or `with-env make uv-publish`) from a tmux ops pane — `with-env` loads `$HOME/.agents/.env` and exports `NPM_TOKEN`/`UV_PUBLISH_TOKEN` into a subshell. The Makefile targets themselves reference `$(NPM_TOKEN)` / `$(UV_PUBLISH_TOKEN)` directly (2026-09-02: confirmed for whats-proxy — `npm config set //registry.npmjs.org/:_authToken "$(NPM_TOKEN)"` pattern).
   - If package name is unavailable on PyPI/npm, apply the fallback policy from `k-project` in order: `k-<name>` → `k-<name>-x` → `kpihx-<name>`.
3. **Secrets:** `UV_PUBLISH_TOKEN`, `NPM_TOKEN` / `BUN_AUTH_TOKEN` via env vars (loaded via `with-env` — see `AGENTS.md` kernel → Security — or `~/.agents/.env`). If missing or invalid → **stop**; tell  to export tokens; say **`continue`** to retry.
4. On publish success, tag if the project uses release tags (`k-git` / `k-project` versioning section).

## Contract coherence gate (before closure decision)

Before calling a repository "finalized", verify contract coherence explicitly:

1. If `CONTRACT.md` exists, documented operations/types/errors must match implementation (`dispatch`/public API) and tests.
2. Contract drift tests must pass (or equivalent automated checks).
3. Wrapper behavior (CLI/stdio/ws/mcp) must not contradict contract semantics or error codes.
4. If mismatch is found, fix code/docs/tests first, then continue A→K.

## Phase K — `$HOME/.agents/` kernel (always)

**Obligatory** after any project closure pass. See `rules/k-context-hygiene.md` and `rules/audit-commands.md` for the full contracts; this is the project-specific enforcement:

1. **k-context** (`skills/k-context/SKILL.md`): update `## Active Projects` (status, next step) and `## Session Log` (agent tag, version, folder path). Obey limits: max 10 rows → rotate overflow to `references/log.md`.
2. **<github-user>** or **k-context** only if new durable workspace facts were revealed.
3. **`make check`** from `$HOME/.agents/` → repeat until `ALL_OK`.
4. **Commit + `make push`** on all `.agents/` remotes.

## Blocker protocol

- **Any** hard stop (tests flaky, permission denied, unclear product choice): present **issues + propositions**; wait for  validation.
- After resolution,  replies **`continue`** → agent **re-opens `k-final`** and resumes from the blocked phase.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-final/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-final/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.


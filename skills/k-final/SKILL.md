---
name: k-final
description: >
  Post-work project closure workflow: tests, hygiene, config-as-docs, markdown
  sync, versioning, git (submodules order), CI/CD watch, deploy log check,
  local install, build/publish, then `.agents/` kernel sync (k-context, check,
  push). Every phase is obligatory when it applies - no silent skips. Load when
  finishing a feature or release pass on any KpihX project.
license: private
metadata:
  author: KpihX
  version: "1.6.3"
  scope: project-lifecycle
allowed-tools: Bash, Read, Write, Edit
---

# KpihX — Project Finalization (`k-final`)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-project` (structure, Makefile, config pattern) · `k-git` (remotes, `make push`, CI hooks) · `k-docker` + `kpihx-labs` (deployed services) · `k-git-pages` (Docsify) · `k-context` (kernel updates in Phase K)
> **Static rules:** `rules/audit-commands.md` (make check, uv, make push, post-work checklist) · `rules/k-context-hygiene.md` (session log, active projects)
> **Resume token:** if execution stops on a blocker, KπX says **`continue`** → re-read this skill from the top and resume from the failed phase.

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
4. **Missing remotes are not a stop condition:** if required remotes are absent, create them first (SSH only, standard names `github` and `gitlab`), then run `make push`.
   - GitHub bootstrap: create repo and wire `github` remote.
   - GitLab bootstrap: create repo and wire `gitlab` remote.
   - Do not continue closure with only one remote configured.
4. **SSH / Bitwarden:** if push fails with auth, **stop** — remind KπX to unlock **Bitwarden Desktop** + approve SSH; retry after `continue`.

## Phase G — CI/CD (deployed projects)

**Obligatory** if `.gitlab-ci.yml` and/or GitHub Actions exists — until fully verified you do **not** call the project “done”.

1. **GitLab (`glab`) — pipelines *and* jobs:** `glab pipeline list --repo <group>/<project>` is **insufficient by itself** (it often shows “No pipelines” while CI still ran). You **must**:
   - `glab ci status --repo <group>/<project>` (or resolve the latest pipeline for the pushed `ref` via API),
   - then **list every job** on that pipeline and confirm **each required job** is `success` (deploy stages included — e.g. `deploy_homelab`):
   ```bash
   glab ci status --repo <group>/<repo>
   glab api "projects/<group>%2F<repo>/pipelines/<PIPELINE_ID>/jobs"
   ```
   Parse job names + `status`; **do not skip** deploy jobs when they exist in `.gitlab-ci.yml`.
2. **GitHub Actions:** `gh run watch` / `gh run list` for the branch you pushed; every required workflow must be green.
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
- **Python (uv)**: `make link` (runs `uv tool install --editable .`)
- **JS/TS (bun)**: `make link` (runs `bun link`)
- **Other**: Use the project's standard link/dev-install command.
- Use `make unlink` to clean up.

### 🛡️ Sovereign Security Projects (Critical/System)
For tools managing secrets (like `bw-proxy` — `bw-mcp`/`bw-admin` were purged 2026-08-14), system-level installs, or core homelab automation, enforce **Root-Protection** and **Confinement**:

1. **Root-Immutable Install**:
   - Use `make install` to deploy in `/opt/$(PKG_NAME)` with `root:root` ownership.
   - **Infrastructure Hardening**: Use `REAL_USER` and `REAL_HOME` detection in the `Makefile` so paths resolve correctly under elevation.
   - **Internal Hygiene**: Remove redundant `sudo` from Makefile targets; KπX runs privileged install steps via **shared tmux** (`k-tmux`) — **`sui` is deprecated** for agents.
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

1. **Remove old build output** before build: e.g. `rm -rf dist/` build dirs (or `make clean` if defined).
2. `make build` then publish via Makefile (`make publish` / `make release` — see project Makefile).
   - **Requirement**: `make publish` MUST use `$(ZSH_LOGIN)` (e.g. `$(ZSH_LOGIN) "uv publish"`) to load the login environment.
   - If package name is unavailable on PyPI/npm, apply the fallback policy from `k-project` in order: `k-<name>` → `k-<name>-x` → `kpihx-<name>`.
3. **Secrets:** `UV_PUBLISH_TOKEN`, `NPM_TOKEN` / `BUN_AUTH_TOKEN` via env vars (loaded via `.kshrc` or `~/.agents/.env`). If missing or invalid → **stop**; tell KπX to export tokens; say **`continue`** to retry.
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
2. **kpihx-labs** or **k-context** only if new durable workspace facts were revealed.
3. **`make check`** from `$HOME/.agents/` → repeat until `ALL_OK`.
4. **Commit + `make push`** on all `.agents/` remotes.

## Blocker protocol

- **Any** hard stop (tests flaky, permission denied, unclear product choice): present **issues + propositions**; wait for KπX validation.
- After resolution, KπX replies **`continue`** → agent **re-opens `k-final`** and resumes from the blocked phase.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-final/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-final/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [COLAB] | v1.6.3 — Restored the mandatory project-finalization `make check` gates; the explicit approval rule applies only to standalone kernel work in `$HOME/.agents`. |
| 2026-07-26 | [OPENCODE] | v1.6.0 — **make check target**: Updated references from make audit to make check across the skill, in line with the new unified validation process. |
| [SUMMARY] | — | v1.6.2–v1.6.1 superseded approval-policy wording · v1.4.0–v1.5.0 Trimmed: Phase K simplified + k-workspace references replaced with k-context/kpihx-labs. v1.3.x MIE Ubisoft Case; v1.3.0 Hardened Sovereign workflow; v1.2.0–v1.1.0 audit pass and security templates; older → file history |

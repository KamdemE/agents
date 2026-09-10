---
name: k-docker
description: >
  Docker deployment — Dockerfile (multi-stage), docker-compose prod/override, CI
  (validate + deploy + sync), Traefik labels, Makefile.docker, repo creation. Load for ANY
  project that will be deployed on the homelab server.
license: private
metadata:
  author: 
  version: "1.0.0"
allowed-tools: Bash(*), "*"
---

#  — Docker Deployment

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **Related skills:** `k-git` (push, Makefiles, remotes) · `k-project` (init, naming, config)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** check `$HOME/Work/Homelab/presentation/techskills/assets/` (polytask, wa-bot docker-compose are symlinks to real projects) — browse via `k-qmd` or `ls`.

## When to Load

Load this skill for **any project that will run on the homelab server** — MCP servers, web apps, bots, background workers.

## Dockerfile — Multi-Stage

Never build a fat image. Always use multi-stage: **builder** (installs tools + deps) → **runner** (only what's needed at runtime).

Templates:
- `assets/Dockerfile.python` — uv-based multi-stage (builder compiles venv, runner copies it)
- `assets/Dockerfile.bun` — Bun production image

Key rules:
- `--no-install-recommends` on every `apt-get install`
- `rm -rf /var/lib/apt/lists/*` after every `apt-get`
- Copy `pyproject.toml`/`package.json` first (layer cache) — then source
- Add `.dockerignore` (template: `assets/.dockerignore`)
- `EXPOSE` the real app port
- `CMD` = runtime entrypoint only

## docker-compose.yml (production / server)

Template: `assets/docker-compose.yml`

Key rules:
- `name: <project-name>` at top — used as compose project name in CI (`-p <name>`)
- `env_file: .env` with `required: false` — CI generates `.env` from CI vars before deploy
- `networks: proxy: external: true` — joins Traefik's `proxy` network
- Named volume: `name: deploy_<project>_data` — survives `--remove-orphans`
- `healthcheck` mandatory — CI health-check loop relies on it
- Traefik labels: **two routers** — `-private` (public HTTPS + certresolver) + `-fallback` (`.homelab` internal TLS)
- Security middleware: `browserxssfilter`, `contenttypenosniff`, `framedeny`

## Database — Shared Server Postgres

The homelab server runs a **single shared `postgres` container** (`postgres:16-alpine`, name `postgres`, network `proxy`).

**Rule:** `docker-compose.yml` (prod) has **no `db` service**. The app joins the `proxy` network and connects directly to the `postgres` container by hostname.

Env vars to inject in CI `.env` for projects that need a DB:
```
DB_NAME=<project_db_name>    # project-specific (create the DB manually first)
DB_USER=admin                # fixed on the server
DB_PASS=$POSTGRES_PASSWORD   # <github-user> group var → maps to POSTGRES_PASSWORD
DB_HOST=postgres             # container name on the proxy network
DB_PORT=5432
```

> `POSTGRES_PASSWORD` is in the shared CI vars — never redefine it.

## docker-compose.override.yml (local dev)

Template: `assets/docker-compose.override.yml`

Key rules:
- Override `ports:` to expose on localhost (not needed on server — Traefik handles it)
- Override `networks: proxy: external: false` — create the network locally
- **DB service:** the override template includes a local `postgres:16-alpine` service — use it for projects that need a DB; remove the block entirely if not needed
- Override `environment: DB_HOST: db` to point to the local container (instead of server `postgres`)
- **NEVER commit a filled `.env`** — commit only `.env.example`

## CI/CD (GitHub Actions)

Templates (`assets/`):
- `.gitlab-ci.uv.yml` / `.gitlab-ci.bun.yml` — GitLab CI references (kept as examples)
- Prefer GitHub Actions workflows for new projects — verify with `gh run list`.


**Runner:** tag `homelab` (deploy job only — validate runs on shared runner with the appropriate language image)

**Shared CI vars** — set once per GitHub org/user, inherited by all projects.

> ⚠️ Always re-check before starting a new project — list may have changed.

| Key | Protected | Masked | Notes |
|-----|-----------|--------|-------|
| `GITHUB_TOKEN` | ✓ | ✓ | GitHub PAT — legacy CI sync fallback (prefer `gh` at init) |
| `WHATSAPP_CHAT_IDS` | ✓ | ✓ | Telegram/WA notification targets |
| `TELEGRAM_CHAT_IDS` | ✓ | ✓ | Telegram notification targets |
| `POSTGRES_PASSWORD` | ✓ | ✓ | Shared server postgres password |
| `TELEGRAM_PVE_TOKEN` | ✓ | ✓ | PVE Telegram bot token |
| `TELEGRAM_DOCKERHOST_TOKEN` | ✓ | ✓ | Docker host Telegram bot token |

**Project-specific vars** — create per project in GitHub **Settings → Secrets and variables → Actions** (or via CLI):

```bash
# Create a secret (replace values accordingly)
gh secret set TELEGRAM_PROJECT_TOKEN --body "<token>" --repo <user>/<project-name>

# Or for a project-specific API key
gh secret set TICKTICK_API_TOKEN --body "<token>" --repo <user>/<project-name>

# List all Actions variables for a project (verify after creation)
gh variable list --repo <user>/<project-name>
```

- Rule: **never hardcode** — always inject via CI vars → generated `.env`
- Pattern for Telegram bots: one token per project → `TELEGRAM_<PROJECT>_HOMELAB_TOKEN`

**Pipeline structure:**
```
validate (shared runner, Docker image)   → syntax check + unit tests
deploy   (homelab runner, tag=homelab)   → generate .env + docker compose up + healthcheck
sync     (shared runner, legacy)         → ⚠️ LEGACY — see Repo Creation below instead
```

**Sync stage — legacy, do not use for new projects.**
The CI sync approach (force-push via `GITHUB_TOKEN`) was used when `gh` org access wasn't available. The preferred approach is to create the GitHub mirror directly with `gh` at project init and push normally via `make push` (see k-git).

The `sync_github` block in the CI templates is kept commented out as a fallback only.

## Repo Creation

**Preferred — `gh` at project init:**

```bash
# New project (single remote)
gh repo create <user>/<name> --public

# Set remote (SSH — see k-git)
git remote add origin git@github.com:<user>/<name>.git

# Push
make push
```

> Once both remotes are set, `make push` keeps them in sync — no CI sync stage needed.

## Makefile.docker

Template: `assets/Makefile.docker`

Targets: `up`, `down`, `restart`, `build`, `logs`, `ps`, `deploy`, `prune`, `shell`, `exec`

> **Note in template:** merge with `k-git/assets/Makefile.{general,uv,npm-bun}` — copy relevant git targets (`push`, `push-tags`, `status`, `log`) into the project Makefile.

## Traefik URL Convention

| Context | Pattern |
|---------|---------|
| Public HTTPS | `<service>.<github-user>.com` |
| Internal VPN | `<service>.homelab` |
| Port | declared in `loadbalancer.server.port` |

## Post-Push Workflow: CI/CD Verification

After any `make push` to a project that has CI workflows, it is mandatory to monitor the pipeline's status to ensure the changes deploy successfully.

**Always check the pipeline status until it completes.**

Use the following `gh` command, replacing the repository path as needed:

```bash
# Check workflow runs for a project
gh run list --repo <user>/your-project-name
```

This ensures that a successful push translates to a successful deployment.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-docker/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-docker/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.


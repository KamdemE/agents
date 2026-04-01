---
name: k-docker
description: >
  KπX Docker deployment — Dockerfile (multi-stage), docker-compose prod/override, GitLab CI
  (validate + deploy + sync), Traefik labels, Makefile.docker, repo creation. Load for ANY
  project that will be deployed on the homelab server.
license: private
metadata:
  author: KpihX
  version: "1.4.1"
allowed-tools: Bash(*), "*"
---

# KπX — Docker Deployment

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-git` (push, Makefiles, remotes) · `k-project` (init, naming, config)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** check `~/Work/Homelab/presentation/tutos_live/assets/` (polytask, wa-bot docker-compose are symlinks to real projects) — browse via qmd or `ls`.

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
DB_PASS=$POSTGRES_PASSWORD   # kpihx-labs group var → maps to POSTGRES_PASSWORD
DB_HOST=postgres             # container name on the proxy network
DB_PORT=5432
```

> `POSTGRES_PASSWORD` is in the `kpihx-labs` GitLab group vars — never redefine it.

## docker-compose.override.yml (local dev)

Template: `assets/docker-compose.override.yml`

Key rules:
- Override `ports:` to expose on localhost (not needed on server — Traefik handles it)
- Override `networks: proxy: external: false` — create the network locally
- **DB service:** the override template includes a local `postgres:16-alpine` service — use it for projects that need a DB; remove the block entirely if not needed
- Override `environment: DB_HOST: db` to point to the local container (instead of server `postgres`)
- **NEVER commit a filled `.env`** — commit only `.env.example`

## GitLab CI/CD

Templates:
- `assets/.gitlab-ci.uv.yml` — Python/uv projects (validate with `ghcr.io/astral-sh/uv:python3.12-bookworm-slim`, pytest, health via `curl`)
- `assets/.gitlab-ci.bun.yml` — Bun/TS projects (validate with `oven/bun:1-slim`, `bun test`, health via `bun -e fetch`)

**Runner:** tag `homelab` (deploy job only — validate runs on shared runner with the appropriate language image)

**`kpihx-labs` GitLab group vars** — inherited by all group projects automatically.

> ⚠️ Always re-check before starting a new project — list may have changed:
> ```bash
> glab variable list -g kpihx-labs
> ```

| Key | Protected | Masked | Notes |
|-----|-----------|--------|-------|
| `GITHUB_TOKEN` | ✓ | ✓ | GitHub PAT — legacy CI sync fallback (prefer `gh` at init) |
| `WHATSAPP_CHAT_IDS` | ✓ | ✓ | Telegram/WA notification targets |
| `TELEGRAM_CHAT_IDS` | ✓ | ✓ | Telegram notification targets |
| `POSTGRES_PASSWORD` | ✓ | ✓ | Shared server postgres password |
| `TELEGRAM_HOMELAB_TOKEN` | ✓ | ✓ | Generic Telegram homelab bot token |

**Project-specific vars** — create per project in GitLab **Settings → CI/CD → Variables** (or via CLI):

```bash
# Create a masked+protected project var (replace values accordingly)
glab variable set TELEGRAM_PROJECT_HOMELAB_TOKEN --value "<token>" \
  --masked --protected --repo kpihx-labs/<project-name>

# Or for a project-specific API key
glab variable set TICKTICK_API_TOKEN --value "<token>" \
  --masked --protected --repo kpihx-labs/<project-name>

# List all vars for a project (verify after creation)
glab variable list --repo kpihx-labs/<project-name>
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

**Preferred — `gh` + `glab` at project init:**

```bash
# Homelab / CI-deploy projects (kpihx-labs org on both platforms)
gh repo create kpihx-labs/<name> --public
glab repo create kpihx-labs/<name> --public   # or: --group kpihx-labs

# Set remotes (SSH — see k-git)
git remote add github git@github.com:kpihx-labs/<name>.git
git remote add gitlab git@gitlab.com:kpihx-labs/<name>.git

# Push both
make push
```

```bash
# Personal namespace (tools/MCPs not tied to homelab infra)
gh repo create KpihX/<name> --public
glab repo create kpihx/<name> --public
git remote add github git@github.com:KpihX/<name>.git
git remote add gitlab git@gitlab.com:kpihx/<name>.git
```

> Once both remotes are set, `make push` keeps them in sync — no CI sync stage needed.

## Makefile.docker

Template: `assets/Makefile.docker`

Targets: `up`, `down`, `restart`, `build`, `logs`, `ps`, `deploy`, `prune`, `shell`, `exec`

> **Note in template:** merge with `k-git/assets/Makefile.{general,uv,npm-bun}` — copy relevant git targets (`push`, `push-tags`, `status`, `log`) into the project Makefile.

## Traefik URL Convention

| Context | Pattern |
|---------|---------|
| Public HTTPS | `<service>.kpihx-labs.com` |
| Internal VPN | `<service>.homelab` |
| Port | declared in `loadbalancer.server.port` |

## Post-Push Workflow: CI/CD Verification

After any `make push` to a project that has a `.gitlab-ci.yml`, it is mandatory to monitor the pipeline's status to ensure the changes deploy successfully.

**Always check the pipeline status until it completes.**

Use the following `glab` command, replacing the repository path as needed:

```bash
# Check pipeline status for a project in the 'kpihx-labs' group
glab pipeline list --repo kpihx-labs/your-project-name
```

This ensures that a successful push translates to a successful deployment.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-31 | [CLAUDE] | v1.4.1 — templates/ → assets/ (skill-creator standard) |
| 2026-03-29 | [CLAUDE] | v1.4.0 — sync stage marked legacy; Repo Creation prefers gh+glab at init + make push; GITHUB_TOKEN note updated; PROXY_URL removed |
| 2026-03-29 | [CLAUDE] | v1.3.0 — group vars table + glab check reminder + project var creation commands |
| 2026-03-29 | [CLAUDE] | v1.2.0 — DB section (shared postgres, no db in prod compose, override has local pg); 2 CI templates (.gitlab-ci.uv.yml + .gitlab-ci.bun.yml) |
| 2026-03-29 | [CLAUDE] | v1.1.0 — concrete examples pointer to presentation/tutos_live/assets/ |
| 2026-03-29 | [CLAUDE] | v1.0.0 — initial creation |

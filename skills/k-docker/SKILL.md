---
name: k-docker
description: >
  KπX Docker deployment — Dockerfile (multi-stage), docker-compose prod/override, GitLab CI
  (validate + deploy + sync), Traefik labels, Makefile.docker, repo creation. Load for ANY
  project that will be deployed on the homelab server.
license: private
metadata:
  author: KpihX
  version: "1.0.1"
allowed-tools: Bash(*), "*"
---

# KπX — Docker Deployment

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-git` (push, Makefiles, remotes) · `k-project` (init, naming, config)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.

## When to Load

Load this skill for **any project that will run on the homelab server** — MCP servers, web apps, bots, background workers.

## Dockerfile — Multi-Stage

Never build a fat image. Always use multi-stage: **builder** (installs tools + deps) → **runner** (only what's needed at runtime).

Templates:
- `templates/Dockerfile.python` — uv-based multi-stage (builder compiles venv, runner copies it)
- `templates/Dockerfile.bun` — Bun production image

Key rules:
- `--no-install-recommends` on every `apt-get install`
- `rm -rf /var/lib/apt/lists/*` after every `apt-get`
- Copy `pyproject.toml`/`package.json` first (layer cache) — then source
- Add `.dockerignore` (template: `templates/.dockerignore`)
- `EXPOSE` the real app port
- `CMD` = runtime entrypoint only

## docker-compose.yml (production / server)

Template: `templates/docker-compose.yml`

Key rules:
- `name: <project-name>` at top — used as compose project name in CI (`-p <name>`)
- `env_file: .env` with `required: false` — CI generates `.env` from CI vars before deploy
- `networks: proxy: external: true` — joins Traefik's `proxy` network
- Named volume: `name: deploy_<project>_data` — survives `--remove-orphans`
- `healthcheck` mandatory — CI health-check loop relies on it
- Traefik labels: **two routers** — `-private` (public HTTPS + certresolver) + `-fallback` (`.homelab` internal TLS)
- Security middleware: `browserxssfilter`, `contenttypenosniff`, `framedeny`

## docker-compose.override.yml (local dev)

Template: `templates/docker-compose.override.yml`

Key rules:
- Override `ports:` to expose on localhost (not needed on server — Traefik handles it)
- Override `networks: proxy: external: false` — create the network locally
- Add local DB service if needed (postgres/alpine)
- Override `environment:` for dev values
- **NEVER commit a filled `.env`** — commit only `.env.example`

## GitLab CI/CD

Template: `templates/.gitlab-ci.yml`

**Runner:** tag `homelab` (deploy job only — validate runs on shared runner with Docker image)

**Existing CI/CD vars in `kpihx-labs` GitLab group** (query: `glab variable list -g kpihx-labs | cut -d' ' -f1`):
```
PROXY_URL          GITHUB_TOKEN       WHATSAPP_CHAT_IDS
TELEGRAM_CHAT_IDS  POSTGRES_PASSWORD  TELEGRAM_HOMELAB_TOKEN
```

**Project-specific vars to create per project** (tell the user which ones to add in GitLab Settings → CI/CD → Variables):
- All project API tokens / secrets not in the group vars above
- Example: `TICKTICK_API_TOKEN`, `TELEGRAM_<PROJECT>_TOKEN`, etc.
- Rule: never hardcode — always inject via CI vars → generated `.env`

**Pipeline structure:**
```
validate (shared runner, Docker image)   → syntax check + unit tests
deploy   (homelab runner, tag=homelab)   → generate .env + docker compose up + healthcheck
sync     (shared runner, optional)       → push to GitHub mirror (kpihx-labs projects only)
```

**Sync stage** — kpihx-labs projects only:
- `GITHUB_TOKEN` already present in group vars
- Creates GitHub repo in `kpihx-labs` org if absent
- Force-pushes `$CI_COMMIT_SHA` → `refs/heads/main`

## Repo Creation

```bash
# Personal namespace (tools, MCPs not homelab-specific)
gh repo create KpihX/<name> --public
glab repo create kpihx/<name> --public

# Homelab / CI-deploy projects (kpihx-labs group)
gh repo create kpihx-labs/<name> --public
glab repo create kpihx-labs/<name> --public

# Set remotes (→ see k-git for SSH convention)
git remote add github git@github.com:kpihx-labs/<name>.git
git remote add gitlab git@gitlab.com:kpihx-labs/<name>.git
```

If creating manually is not possible (orgs/permissions), use sync via GITHUB_TOKEN in the CI (already set for kpihx-labs group).

## Makefile.docker

Template: `templates/Makefile.docker`

Targets: `up`, `down`, `restart`, `build`, `logs`, `ps`, `deploy`, `prune`, `shell`, `exec`

> **Note in template:** merge with `k-git/templates/Makefile.{general,uv,npm-bun}` — copy relevant git targets (`push`, `push-tags`, `status`, `log`) into the project Makefile.

## Traefik URL Convention

| Context | Pattern |
|---------|---------|
| Public HTTPS | `<service>.kpihx-labs.com` |
| Internal VPN | `<service>.homelab` |
| Port | declared in `loadbalancer.server.port` |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v1.0.0 — initial creation |

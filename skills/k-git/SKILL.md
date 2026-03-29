---
name: kpihx-git
description: KπX Git workflow — SSH protocol, remote naming convention, Makefile-driven push pattern, Vault/Tailscale SSH troubleshooting runbook, and new project init checklist. Load for any git or repo management task.
license: private
metadata:
  author: KpihX
  version: "2.2.0"
allowed-tools: Bash(git:*), Bash(make:*), Bash(gh:*), Bash(glab:*), Bash(ssh:*)
---

# KπX — Git Workflow

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Rules

- **Protocol:** SSH only. All remotes use `git@...` URLs — never HTTPS.
- **Remote names:** `github` → GitHub (`KpihX` namespace) · `gitlab` → GitLab (see namespace rule below)
- **GitLab namespace rule:**
  - Default → `kpihx` personal namespace
  - `kpihx-labs` group → homelab/server-related projects **or** projects deployed via GitLab CI (e.g. homelab infra, n8n workflows)
  - Personal tools (e.g. HTTP MCPs) → `kpihx` even if they run on the homelab
- **Push:** ALWAYS `make push` (all remotes simultaneously). Never push to one remote alone.
- **Commits:** Conventional Commits spec. Atomic. No `--no-verify`. No amending published commits.
- **Visibility:** Default public. Challenge and propose private for sensitive/early-stage projects.

## Makefile Patterns

### Header (every project)

```makefile
.DEFAULT_GOAL := help
ZSH_LOGIN     := zsh -lc         # wraps commands needing bw-env secrets (publish, deploy…)
BRANCH        := $(shell git rev-parse --abbrev-ref HEAD)

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
```

### Core targets (all projects)

```makefile
push:        ## Push current branch to ALL configured remotes
	@branch="$$(git branch --show-current)"; \
	for remote in $$(git remote); do \
		echo "==> pushing $$branch to $$remote"; \
		git push "$$remote" "$$branch"; \
	done

push-tags:   ## Push all tags to all remotes (triggers CI releases)
	@for remote in $$(git remote); do git push "$$remote" --tags; done

status:      ## Git status --short
	@git status --short

log:         ## Last 10 commits oneline
	@git log --oneline -10
```

### Linting / testing (scripts, Python, JS)

```makefile
check:       ## Syntax-check all .sh files
	@bash -n *.sh

lint:        ## Shellcheck on all .sh files
	@shellcheck --shell=bash *.sh

test:        ## Run pytest (Python projects)
	@uv run pytest -q

check-py:    ## py_compile + pytest
	@python3 -m py_compile $$(find src test -name '*.py' -print)
	@uv run pytest -q
```

### Python package (uv projects)

```makefile
build:       ## Build package (uv)
	@rm -rf dist && uv build

publish: build  ## Publish to PyPI — requires UV_PUBLISH_TOKEN via bw-env
	@$(ZSH_LOGIN) 'if ! env | grep -q "^UV_PUBLISH_TOKEN="; then \
		echo "UV_PUBLISH_TOKEN missing — run bw-env first"; exit 1; fi; \
	uv publish --check-url https://pypi.org/simple'

release: check-py build publish push  ## Full release: check → build → publish → push
```

### Install / teardown (projects with install scripts)

```makefile
install:     ## Run scripts/install.sh
	@./scripts/install.sh

purge:       ## Run scripts/purge.sh
	@./scripts/purge.sh
```

### Docs subdir (projects with `docs/` git sub-repo)

```makefile
push-docs:     ## Push docs/ repo to all remotes
	@$(MAKE) -C docs push

publish-docs:  ## Publish docs/ (e.g. GitHub Pages deploy)
	@$(MAKE) -C docs publish
```

## SSH Troubleshooting Runbook

`SSH_AUTH_SOCK` → Bitwarden Desktop socket (`~/.bitwarden-ssh-agent.sock`) loaded from `~/.kshrc`.
Vault (`vault.kpihx-labs.com`) is private — Tailscale must be up for SSH key validation.

1. `tailscale status` — confirm Tailscale routing is active
2. Disable conflicting VPNs (Windscribe overrides Tailscale routes)
3. Bitwarden Desktop: unlocked + connected to `vault.kpihx-labs.com`
4. `ssh -T git@github.com` → approve Bitwarden popup
5. `ssh -T git@gitlab.com` → approve Bitwarden popup
6. Retry `make push`

## New Project Init Checklist

1. `git init`
2. `.gitignore` — include `*.env`, `.venv/`, `node_modules/`, agent MD files if not repo root
3. `gh repo create KpihX/<name>` (GitHub) + `glab repo create` (GitLab) — default public, challenge if sensitive
4. `git remote add github git@github.com:KpihX/<name>.git`
5. GitLab remote — pick namespace:
   - **Personal / tools** (MCPs, personal scripts): `git remote add gitlab git@gitlab.com:kpihx/<name>.git`
   - **Homelab / CI-deploy** (infra, server workloads, GitLab CI pipelines): `git remote add gitlab git@gitlab.com:kpihx-labs/<name>.git`
6. Create `Makefile` with standard targets above (at minimum: `push`, `status`, `log`)
7. Initial commit + `make push`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v2.2.0 — Makefile: full patterns (header/core/lint/py/install/docs); GitLab namespace rule (kpihx default, kpihx-labs for homelab/CI) |
| [SUMMARY] | — | v2.1.0 init checklist simplified; v2.0.0 refonte; v1.0.0 initial |

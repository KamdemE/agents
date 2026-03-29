---
name: k-git
description: KπX Git workflow — SSH protocol, remote naming convention, Makefile-driven push pattern, Vault/Tailscale SSH troubleshooting runbook, and new project init checklist. Load for any git or repo management task.
license: private
metadata:
  author: KpihX
  version: "2.4.0"
allowed-tools: Bash(git:*), Bash(make:*), Bash(gh:*), Bash(glab:*), Bash(ssh:*)
---

# KπX — Git Workflow

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-project` (init, naming — load always alongside k-git) · `k-docker` (load if project will be deployed on homelab)

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

## Makefile Templates

Ready-to-use templates in `templates/` — copy to project root as `Makefile` and adapt:

| Template | Use case |
|----------|----------|
| `templates/Makefile.general` | Generic project (scripts, shell, misc) — push, status, log, lint |
| `templates/Makefile.uv` | Python package (uv) — check, build, publish to PyPI, release |
| `templates/Makefile.npm-bun` | JS/TS package (bun) — test, build, publish to npm, release |

All templates share: `.DEFAULT_GOAL := help`, auto-help via `grep -E`, `ZSH_LOGIN := zsh -lc` (bw-env secrets), dynamic `push` loop over `git remote`.

**Publish secrets required** (via bw-env before running):
- `Makefile.uv` → `UV_PUBLISH_TOKEN`
- `Makefile.npm-bun` → `NPM_TOKEN` (or `BUN_AUTH_TOKEN`)

**Optional add-ons** (not in templates — add as needed):

```makefile
push-docs:     ## Push docs/ sub-repo to all remotes
	@$(MAKE) -C docs push

publish-docs:  ## Publish docs/ (GitHub Pages deploy)
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
| 2026-03-29 | [CLAUDE] | v2.4.0 — added Related skills header (k-project always, k-docker if deployable) |
| 2026-03-29 | [CLAUDE] | v2.3.0 — Makefile section replaced by 3 templates in templates/ (general/uv/npm-bun) |
| [SUMMARY] | — | v2.2.0 full Makefile patterns + GitLab namespace rule; v2.1.0 init checklist; v2.0.0 refonte; v1.0.0 init |

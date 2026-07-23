---
name: k-git
description: KπX Git workflow — SSH protocol, remote naming convention, Makefile-driven push pattern, Vault/Tailscale SSH troubleshooting runbook, and new project init checklist. Load for any git or repo management task.
license: private
metadata:
  author: KpihX
  version: "2.6.5"
allowed-tools: Bash(git:*), Bash(make:*), Bash(gh:*), Bash(glab:*), Bash(ssh:*)
---

# KπX — Git Workflow

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-project` (init, naming — load always alongside k-git) · `k-final` (**mandatory** when finalizing a project — read fully; covers `make push`, CI watch, deploy verification, then install/publish order) · `k-docker` (load if project will be deployed on homelab or elsewhere)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** check `$HOME/Work/techskills/templates/` for Python/Makefile examples — browse via `ls` or `k-qmd`.

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

### `assets/Makefile.git` — baseline (this skill)

Generic git workflow — push, status, log, lint. Use for any project.
Copy to project root as `Makefile`, adapt as needed.

Shared conventions across all Makefiles: `.DEFAULT_GOAL := help`, auto-help via `grep -E`, `ZSH_LOGIN := zsh -lc` (login shell for secrets), dynamic `push` loop over `git remote`.

**Optional add-ons** (not in template — add as needed):

```makefile
push-docs:  ## Commit + push docs/ site
	@git add docs/ && git commit -m "docs: update site" || true; \
	branch="$$(git branch --show-current)"; \
	for remote in $$(git remote); do git push "$$remote" "$$branch"; done
```

### uv / bun projects → `k-project`

`Makefile.uv` (Python/uv — check, build, publish to PyPI, release) and `Makefile.npm-bun` (JS/TS/bun — test, build, publish to npm, release) live in **`k-project/assets/`** alongside pyproject.toml, config.py/ts.
Load `k-project` for project lifecycle philosophy + those templates.

## SSH Troubleshooting Runbook

`SSH_AUTH_SOCK` → Bitwarden Desktop socket (`$HOME/.bitwarden-ssh-agent.sock`) loaded from `$HOME/.kshrc`.
Vault (`vault.kpihx-labs.com`) is private — Tailscale must be up for SSH key validation.

1. `tailscale status` — confirm Tailscale routing is active
2. Disable conflicting VPNs (Windscribe overrides Tailscale routes)
3. Bitwarden Desktop: unlocked + connected to `vault.kpihx-labs.com`
4. `ssh -T git@github.com` → approve Bitwarden popup
5. `ssh -T git@gitlab.com` → approve Bitwarden popup
6. Retry `make push`

## New Project Init Checklist

1. `git init`
2. `.gitignore` — include `*.env`, `.venv/`, `node_modules/`, `lancedb/`, agent MD files if not repo root
3. `gh repo create KpihX/<name>` (GitHub) + `glab repo create` (GitLab) — default public, challenge if sensitive
4. `git remote add github git@github.com:KpihX/<name>.git`
5. GitLab remote — pick namespace:
   - **Personal / tools** (MCPs, personal scripts): `git remote add gitlab git@gitlab.com:kpihx/<name>.git`
   - **Homelab / CI-deploy** (infra, server workloads, GitLab CI pipelines): `git remote add gitlab git@gitlab.com:kpihx-labs/<name>.git`
6. Create `Makefile` from `assets/Makefile.git` (at minimum: `push`, `status`, `log`) — or from `k-project/assets/Makefile.uv` / `Makefile.npm-bun` for uv/bun projects
7. Initial commit + `make push`

## Post-Push Workflow: CI/CD Verification

During a **project finalization** pass, **`k-final`** owns the full sequence (tests and docs *before* push, then CI, then runtime logs, then local install/publish). This section remains the **git-focused** rule: after `make push`, watch pipelines until green.

After any `make push` to a project that has a `.gitlab-ci.yml`, it is mandatory to monitor the pipeline's status to ensure the changes deploy successfully.

**Always check the pipeline status until it completes.**

Use the following `glab` command, replacing the repository path as needed:

```bash
# Check pipeline status for a project in the 'kpihx-labs' group
glab pipeline list --repo kpihx-labs/your-project-name
```

This ensures that a successful push translates to a successful deployment.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-git/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-git/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-13 | [CODEX] | v2.6.5 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| 2026-04-09 | [CURSOR] | v2.6.4 — **`k-final`** cross-link: mandatory on project closure; CI section defers full finalization sequence to `k-final` |
| [SUMMARY] | — | +1 older changelog entries kept in file history; condensed for table limits |
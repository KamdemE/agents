---
name: kpihx-git
description: KπX Git workflow — SSH protocol, remote naming convention, Makefile-driven push pattern, Vault/Tailscale SSH troubleshooting runbook, and new project init checklist. Load for any git or repo management task.
license: private
metadata:
  author: KpihX
  version: "2.1.0"
allowed-tools: Bash(git:*), Bash(make:*), Bash(gh:*), Bash(glab:*), Bash(ssh:*)
---

# KπX — Git Workflow

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Rules

- **Protocol:** SSH only. All remotes use `git@...` URLs — never HTTPS.
- **Remote names:** `github` → GitHub personal namespace; `gitlab` → GitLab (`kpihx-labs` group for MCPs)
- **Push:** ALWAYS `make push` (both remotes simultaneously). Never push to one remote alone.
- **Commits:** Conventional Commits spec. Atomic. No `--no-verify`. No amending published commits.
- **Visibility:** Default public. Challenge and propose private for sensitive/early-stage projects.

## Standard Makefile Targets

```makefile
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

push:       ## Push to github AND gitlab simultaneously
	git push github $(BRANCH) && git push gitlab $(BRANCH)

push-tags:  ## Push all tags to all remotes (triggers CI releases)
	git push github --tags && git push gitlab --tags

check:      ## Bash syntax check on all .sh files
	bash -n *.sh

lint:       ## Shellcheck on all .sh files
	shellcheck --shell=bash *.sh

log:        ## Last 10 commits oneline
	git log --oneline -10

status:     ## Git status + diff stats
	git status && git diff --stat
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
3. `gh repo create` (GitHub) + `glab repo create` (GitLab) — default public, challenge if sensitive
4. `git remote add github git@github.com:KpihX/<name>.git`
5. `git remote add gitlab git@gitlab.com:kpihx-labs/<name>.git` (MCPs) or personal namespace
6. Create `Makefile` with standard targets above
7. Initial commit + `make push`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v2.1.0 — init checklist: removed stale context.md step, simplified |
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte: .agents/ refs, updated project init checklist |
| [SUMMARY] | — | v1.0.0 — initial creation in skills/kpihx-git/ |

---
name: k-git
description: KπX Git workflow — SSH protocol, remote naming convention, Makefile-driven push pattern, Vault/Tailscale SSH troubleshooting runbook, and new project init checklist. Load for any git or repo management task.
license: private
metadata:
  author: KpihX
  version: "2.11.0"
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
- **Kernel `.agents` repo contract:** EXACTLY two remotes — `github` → `git@github.com:kpihx-labs/agents.git` · `gitlab` → `git@gitlab.com:kpihx-labs/agents.git`. Never `origin`. Enforced by `make check-remotes` (first gate of `make check`, values in `scripts/remotes/lib.sh`), auto-fixed by `make set-remotes`.
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

### `assets/gitconfig` — canonical gitconfig

Centralized git configuration: email, name, SSH protocol, remote naming.
Symlinked to `~/.gitconfig` on every equipment.
Copy to project root as `Makefile`, adapt as needed.

Shared conventions across all Makefiles: `.DEFAULT_GOAL := help`, auto-help via `grep -E`, dynamic `push` loop over `git remote`.

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

### `assets/gitignore` — global excludesFile (XDG)

Canonical **global git excludesFile**: `$HOME/.agents/skills/k-git/assets/git-ignore-global`
symlinked to `$HOME/.config/git/ignore` (git's default XDG location — honored
automatically by ALL repos, no config needed).

Purpose: secrets & junk must NEVER appear as untracked files nor be indexed by
tools that honor git excludes (Loom indexes git repos via
`git ls-files --exclude-standard`). Contains: `.env`, `.env.*` (negations keep
`.env.example`/`.env.sample` indexable), keys/certs (`*.pem`, `*.key`,
`id_rsa*`, `id_ed25519*`, `*.p12`, `.pfx`), credential dotfiles (`.netrc`,
`.npmrc`, `.pypirc`) and generic stores (`secrets.json`, `credentials*.json`),
plus `**/.claude/settings.local.json`.

⚠️ Caveats: TRACKED files bypass ignores (`git ls-files -c` still lists them —
untrack at source). Non-git directories do NOT honor this file (they need a
tool-specific ignore, e.g. Loom `.loomignore` — see `k-loom`).

### `assets/git-hook-passthrough.sh` — global hook plumbing (owner)

**k-git owns ALL generic git hook plumbing.** One asset, N symlinks named after
each hook type (`pre-commit`, `commit-msg`, `prepare-commit-msg`, `pre-push`,
`pre-rebase`, `post-checkout`, `post-merge`, `post-rewrite`,
`pre-applypatch`) in `$HOME/.config/git/hooks/` (activated via
`core.hooksPath`). Each invocation re-chains the repo-local hook of the same
name (resolved via `$GIT_DIR`/`--absolute-git-dir` + `/hooks/<name>` — NOT
`rev-parse --git-path hooks`, which returns the GLOBAL dir once
`core.hooksPath` is set) with a recursion guard, preserving semantics and
exit codes. Zero added behavior — the ONLY hook that adds behavior is the
post-commit Loom dispatcher owned by `k-loom`.

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
| 2026-08-26 | [COLAB] | v2.11.0 — **pre-push gate: banner-proof remote SHA extraction**: `submodule_push_report()` fed `git ls-remote` stdout+stderr into `cut -f1`, so any multi-line server banner (GitLab `remote: INFO: Your SSH key expires soon`) polluted `remote_sha` → false-positive "not pushed" blocks on submodules that WERE pushed (3/4 blocked on deep-pc6, 2026-08-26), and connection errors were misreported as mismatches. Fix: extract only real ref lines (`awk -F'\t' '$1 ~ /^[0-9a-f]{40}$/'`), plus distinct report branches for UNREACHABLE vs branch-not-found vs true mismatch. |
| 2026-08-26 | [CLAUDE] | v2.10.1 — **Fixed `fatal: .git/index: index file open failed: Not a directory` from the submodule hook gates**: `submodule_dirty_report()`/`submodule_push_report()` in `assets/git-hook-passthrough.sh` ran `git -C <submodule>` without clearing the git-exported hook environment (`GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE`, ...) first — exactly the anti-pattern `git help githooks` warns about for invoking git in a foreign repository from inside a hook (a submodule's `.git` is a *file*, not a directory, so a leaked `GIT_DIR` can resolve `<leaked-dir>/index` onto it → `ENOTDIR`). Added `unset $(git rev-parse --local-env-vars)` at the top of both functions, the fix `git`'s own manual documents for this case. See `references/insights.md`. |
| [SUMMARY] | — | v2.10.0 remotes contract + check-remotes/set-remotes (scripts/remotes/, origin pruning) · v2.9.1 check-skills audit rotation (no log.md) · v2.9.0 hook plumbing ownership Prop A (`assets/git-hook-passthrough.sh` + 9 hook symlinks, k-git owns ALL git hook plumbing) · v2.8.0 global excludesFile · v2.7.0 global excludesFile (→ `references/log.md`) · v2.6.5 insights · v2.6.4 k-final (→ `references/log.md`) · v2.6.3 and older in history |
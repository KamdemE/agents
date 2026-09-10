---
name: k-git
description: " Git workflow — SSH protocol, remote naming convention, Makefile-driven push pattern, Vault/Tailscale SSH troubleshooting runbook, and new project init checklist. Load for any git or repo management task. ABSOLUTE: before handling any kernel merge, read references/merge-workflow.md in full."
license: private
metadata:
  author: 
  version: "1.0.0"
allowed-tools: Bash(git:*), Bash(make:*), Bash(gh:*), Bash(ssh:*)
---

#  — Git Workflow

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **Related skills:** `k-project` (init, naming — load always alongside k-git) · `k-final` (**mandatory** when finalizing a project — read fully; covers `make push`, CI watch, deploy verification, then install/publish order) · `k-docker` (load if project will be deployed on homelab or elsewhere)
> **ABSOLUTE merge companion:** `references/merge-workflow.md` — **must be read in full before handling any kernel branch merge** (PR/MR, rebase, conflict resolution, elegant presentation, coherent MD rewriting, version renumbering, `.gitattributes` binary handling). No shortcut.
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** check `$HOME/Work/techskills/templates/` for Python/Makefile examples — browse via `ls` or `k-qmd`.

## Rules

- **Protocol:** SSH only. All remotes use `git@...` URLs — never HTTPS.
- **Single remote:** exactly one remote named `origin` (owner's fork).
- **Kernel `.agents` repo contract (+ every submodule):** EXACTLY one required remote — `origin` → `git@github.com:KamdemE/agents.git` (a read-only `upstream` on submodules is tolerated, never pushed). Must be live-joinable (`git ls-remote`) with the current branch present. Enforced by `make check-remotes` (first gate of `make check`, values in `scripts/remotes/lib.sh`), auto-fixed by `make set-remotes` — both cover the kernel repo AND every declared submodule.
- **Push:** ALWAYS `make push` (→ `origin`).
- **PR:** ALWAYS `make pr` after `make push` — opens a GitHub PR (via `gh`) for the current branch against `master` (`make pr BASE=dev` to override). Title/body come from the last commit; slug parsed from the origin URL (`scripts/git/create-pr.sh`).
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

### `scripts/git-hook-passthrough.sh` — global hook plumbing (owner)

**k-git owns ALL generic git hook plumbing.** One asset, N symlinks named after
each hook type (`pre-commit`, `commit-msg`, `prepare-commit-msg`, `pre-push`,
`pre-rebase`, `post-checkout`, `post-merge`, `post-rewrite`,
`pre-applypatch`) in `$HOME/.config/git/hooks/` (activated via
`core.hooksPath`). Each invocation re-chains the repo-local hook of the same
name (resolved via `$GIT_DIR`/`--absolute-git-dir` + `/hooks/<name>` — NOT
`rev-parse --git-path hooks`, which returns the GLOBAL dir once
`core.hooksPath` is set) with a recursion guard, preserving semantics and
exit codes. Four gates add real behavior on top of every repo, in this order
(cheap → expensive, fail fast):

| Hook | Gate | Behavior |
|------|------|----------|
| `pre-commit` | 1 | Submodule hygiene (dirty/unpushed) — **no override** |
| `pre-commit` | 2 | `make check` (if `Makefile` has a `check:` target) blocks the commit on failure — **no override** |
| `commit-msg` | — | Strips `co-authored-by:`/`signed-off-by:`/`author:` lines (AI-attribution) before any repo-local hook sees the message — **no override** |
| `pre-push` | — | Every submodule must be pushed to all its remotes — **no override** |

> **🔴 NO BYPASS VARIABLES ( directive 2026-08-25, GRAVÉ).** There is deliberately NO env var to skip any gate (no `KPIHX_ALLOW_*`, no `KPIHX_SKIP_*`, no `KPIHX_KEEP_*`). If a gate blocks you, FIX THE UNDERLYING STATE — the checks ARE the code. Same rule in `scripts/git/push-submodules.sh` (`SUB_PUSH_REMOTES` purged — remotes are hardcoded `origin`) and `apply-inbound-email-worker-rules.sh` (IDs inlined).

The only OTHER hook that adds behavior is the post-commit Loom dispatcher owned by `k-loom`.

> **🔴 Repos NEVER set their own `core.hooksPath` (2026-08-25).** Setting it locally silently opts that repo OUT of every global gate above (submodule hygiene, `make check`, trailer strip, Loom sync) — `core.hooksPath` makes git ignore repo-local hooks of all types, that's exactly why this passthrough exists. If a project needs an *extra* project-specific hook, drop it at `.git/hooks/<name>` (untracked, machine-local) — the passthrough re-chains to it automatically. No installer script, no repo-local `core.hooksPath`, ever.

## SSH Troubleshooting Runbook

`SSH_AUTH_SOCK` → Bitwarden Desktop socket (`$HOME/.bitwarden-ssh-agent.sock`) loaded from `$HOME/.kshrc`.
Vault (`<vault-host>`) is private — Tailscale must be up for SSH key validation.

1. `tailscale status` — confirm Tailscale routing is active
2. Disable conflicting VPNs (Windscribe overrides Tailscale routes)
3. Bitwarden Desktop: unlocked + connected to `<vault-host>` (if used for SSH keys)
4. `ssh -T git@github.com` → approve agent popup if prompted
5. Retry `make push`

## New Project Init Checklist

1. `git init`
2. `.gitignore` — include `*.env`, `.venv/`, `node_modules/`, `lancedb/`, agent MD files if not repo root
3. `gh repo create <user>/<name>` (GitHub) — default public, challenge if sensitive
4. `git remote add origin git@github.com:<user>/<name>.git`
5. Create `Makefile` from `assets/Makefile.git` (at minimum: `push`, `status`, `log`) — or from `k-project/assets/Makefile.uv` / `Makefile.npm-bun` for uv/bun projects
6. Initial commit + `make push`

## Post-Push Workflow: CI/CD Verification

During a **project finalization** pass, **`k-final`** owns the full sequence (tests and docs *before* push, then CI, then runtime logs, then local install/publish). This section remains the **git-focused** rule: after `make push`, watch pipelines until green.

After any `make push` to a project that has CI (e.g. `.github/workflows/`), it is mandatory to monitor the run status to ensure the changes deploy successfully.

**Always check the pipeline status until it completes.**

```bash
gh run list --repo <user>/your-project-name
```

This ensures that a successful push translates to a successful deployment.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-git/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-git/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.


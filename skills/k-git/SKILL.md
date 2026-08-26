---
name: k-git
description: KπX Git workflow — SSH protocol, remote naming convention, Makefile-driven push pattern, Vault/Tailscale SSH troubleshooting runbook, and new project init checklist. Load for any git or repo management task. ABSOLUTE: before handling any kernel merge, read references/merge-workflow.md in full.
license: private
metadata:
  author: KpihX
  version: "2.15.0"
allowed-tools: Bash(git:*), Bash(make:*), Bash(gh:*), Bash(glab:*), Bash(ssh:*)
---

# KπX — Git Workflow

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-project` (init, naming — load always alongside k-git) · `k-final` (**mandatory** when finalizing a project — read fully; covers `make push`, CI watch, deploy verification, then install/publish order) · `k-docker` (load if project will be deployed on homelab or elsewhere)
> **ABSOLUTE merge companion:** `references/merge-workflow.md` — **must be read in full before handling any kernel branch merge** (PR/MR, rebase, conflict resolution, elegant presentation, coherent MD rewriting, version renumbering, `.gitattributes` binary handling). No shortcut.
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** check `$HOME/Work/techskills/templates/` for Python/Makefile examples — browse via `ls` or `k-qmd`.

## Rules

- **Protocol:** SSH only. All remotes use `git@...` URLs — never HTTPS.
- **Remote names:** `github` → GitHub (`KpihX` namespace) · `gitlab` → GitLab (see namespace rule below)
- **Kernel `.agents` repo contract (+ every submodule):** EXACTLY two required remotes — `github` → `git@github.com:kpihx-labs/agents.git` · `gitlab` → `git@gitlab.com:kpihx-labs/agents.git` (a read-only `upstream` on submodules is tolerated, never pushed). Never `origin`. Both must be live-joinable (`git ls-remote`) with the current branch present. Enforced by `make check-remotes` (first gate of `make check`, values in `scripts/remotes/lib.sh`), auto-fixed by `make set-remotes` — both cover the kernel repo AND every declared submodule.
- **GitLab namespace rule:**
  - Default → `kpihx` personal namespace
  - `kpihx-labs` group → homelab/server-related projects **or** projects deployed via GitLab CI (e.g. homelab infra, n8n workflows)
  - Personal tools (e.g. HTTP MCPs) → `kpihx` even if they run on the homelab
- **Push:** ALWAYS `make push` (all remotes simultaneously). Never push to one remote alone.
- **PR/MR:** ALWAYS `make pr` after `make push` — opens PR (github via `gh`) + MR (gitlab via `glab`) for the current branch against `master` (`make pr BASE=dev` to override). Title/body come from the last commit; slugs parsed from the remote URLs. 🚨 LOUD gate: if `glab` is missing or unauthenticated, the script prints the install/auth commands + the pre-filled web-UI fallback URL — never silent (`scripts/git/create-pr.sh`).
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

> **🔴 NO BYPASS VARIABLES (KπX directive 2026-08-25, GRAVÉ).** There is deliberately NO env var to skip any gate (no `KPIHX_ALLOW_*`, no `KPIHX_SKIP_*`, no `KPIHX_KEEP_*`). If a gate blocks you, FIX THE UNDERLYING STATE — the checks ARE the code. Same rule in `scripts/git/push-submodules.sh` (`SUB_PUSH_REMOTES` purged — remotes are hardcoded `github gitlab`) and `apply-inbound-email-worker-rules.sh` (IDs inlined).

The only OTHER hook that adds behavior is the post-commit Loom dispatcher owned by `k-loom`.

> **🔴 Repos NEVER set their own `core.hooksPath` (2026-08-25).** Setting it locally silently opts that repo OUT of every global gate above (submodule hygiene, `make check`, trailer strip, Loom sync) — `core.hooksPath` makes git ignore repo-local hooks of all types, that's exactly why this passthrough exists. If a project needs an *extra* project-specific hook, drop it at `.git/hooks/<name>` (untracked, machine-local) — the passthrough re-chains to it automatically. No installer script, no repo-local `core.hooksPath`, ever.

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
| 2026-08-26 | [COLAB] | v2.15.0 — **ABSOLUTE merge workflow reference created**: new `references/merge-workflow.md` — the operational companion to `rules/git-branch-per-infra.md`, documenting the full inspection → elegant presentation → arbitrage → coherent MD rewriting → version renumbering → binary handling → push/verify pipeline that was proven on the two-branch merge of PR #1 `deep-pc6` + PR #2 `blglaptop139-wsl` (46 + 146 files, 38 conflict zones, zero information loss). Every future kernel merge MUST load this file first. |
| 2026-08-26 | [COLAB] | v2.14.0 — **Passthrough relocated to skill scripts (KπX order)**: `assets/git-hook-passthrough.sh` → `skills/k-git/scripts/git-hook-passthrough.sh`; 9 global-hook symlinks (`~/.config/git/hooks/*`) retargeted, `assets/links.jsonc` entries updated, this SKILL.md section header + `k-loom` cross-reference adjusted, script's own Source-of-truth comment updated. Live E2E: subsequent commits/pushes run through the moved script. |
| 2026-08-26 | [COLAB] | v2.13.0 — **`make pr` (blglaptop139-wsl, KπX order)**: NEW `scripts/git/create-pr.sh` + Makefile target — opens PR (`gh`, github) + MR (`glab`, gitlab) for the current branch against master; title/body from last commit; slugs parsed from remote URLs (any repo). LOUD glab gate: missing/unauthenticated glab → install/auth commands + pre-filled web fallback URL, never silent. First live run created agents PR #2 + MR !1. `glab 1.53.0` installed on blglaptop139-wsl, OAuth-web login as kpihx. |
| [SUMMARY] | — | v2.12.0 NO BYPASS vars purge (`KPIHX_ALLOW_*`/`SKIP_*`/`KEEP_*` all removed from `git-hook-passthrough.sh` + `push-submodules.sh`; checks ARE the code) + remote-pair contract bonus checks (submodule coverage, live `ls-remote` joinability, branch presence) absorbed into `scripts/remotes/` · v2.11.0 pre-push gate banner-proof remote SHA extraction (fixed false-positive submodule blocks) · v2.10.1 GIT_DIR/etc cleared before per-submodule `git -C` calls (ENOTDIR fix) · v2.10.0 remotes contract + check-remotes/set-remotes (`scripts/remotes/`, origin pruning) · v2.9.1 check-skills audit rotation (no log.md) · v2.9.0 hook plumbing ownership Prop A (`assets/git-hook-passthrough.sh` + 9 hook symlinks, k-git owns ALL git hook plumbing) · v2.8.0 global excludesFile · v2.7.0 global excludesFile (→ `references/log.md`) · v2.6.5 insights · v2.6.4 k-final (→ `references/log.md`) · v2.6.3 and older in history |

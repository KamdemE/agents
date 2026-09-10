# Git Workflow — Single Machine, Work on `master`

> **Rule for this fork (single machine, single `origin` remote).**
> No per-infra branches. Work directly on `master`.
>
> **Before handling any merge:** load `skills/k-git/references/merge-workflow.md` in full — it is the operational companion to this rule (inspection, elegant presentation, arbitrage, coherent MD rewriting, versioning, push/verify).

## 1. Rule — `master`, One Remote

| Principle | Rule |
|-----------|------|
| **Single branch** | All work happens on `master`. No infra branches, no `feat/` branches for kernel work (use them only for experimental spikes you intend to PR). |
| **Single remote** | Exactly one remote, named `origin` (see `make check-remotes`). Push via `make push` (→ `origin`). |
| **Sync before push** | `git fetch origin` + rebase if `origin/master` moved. |

## 2. Setup — After Clone

```bash
# 1. Clone to the canonical location
mkdir -p ~/Labs
git clone git@github.com:KamdemE/agents.git ~/Labs/.agents   # real repo lives HERE
ln -sfn ~/Labs/.agents ~/.agents
cd ~/Labs/.agents

# 2. Wire the machine (symlinks, shell, editor)
make set-links && make check-links
```

## 3. Daily Workflow — Sync Before Push

```bash
git branch --show-current   # → master
# ... edit files ...
git add <files>
git commit -m "feat(scope): message"   # Conventional Commits
```

### Before every push — sync with `origin/master`

```bash
git fetch origin

# Is origin/master ahead?
git log --oneline HEAD..origin/master   # if output → new commits upstream

# Rebase on top (preferred — linear history)
git rebase origin/master
# If conflicts: fix, git add, git rebase --continue
```

### Push

```bash
make push   # pushes the CURRENT branch to origin
```

### Open a PR (only for experimental spikes)

```bash
gh pr create --base master --head <branch> --fill
```

After the PR is merged, update local `master`:
```bash
git fetch origin
git switch master && git pull --ff-only origin master
```

## 4. See Also

- `k-git/references/merge-workflow.md` — **ABSOLUTE** operational companion: inspection, elegant presentation, arbitrage, coherent rewriting, versioning, push/verify
- `k-infras` — single-machine setup template
- `k-git` — SSH-only, `make push` (→ `origin`), conventional commits
- `libs/jsonc/jsonc_lib.sh:current_infra` — programmatic machine-id detection (`$AGENTS_INFRA` override, else hostname)

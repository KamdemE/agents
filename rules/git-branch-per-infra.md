# Git Branch per Infra — Never Work on `main`

> **Absolute rule for the `.agents` kernel (and recommended for every KpihX project).**
> Each infrastructure works **exclusively** on its own branch named after the infra.
> `main`/`master` is **read-only** — it only moves via merged PRs.

## 1. Rule — One Branch per Infra, Never `main`

| Principle | Rule |
|-----------|------|
| **Branch name = infra short name** | Branch MUST be the infra's short name as listed in `assets/infras_skills.jsonc` and `k-infras` inventory: `kpihx-ubuntu`, `blglaptop139`, `deep-pc6`, `kpihx-pve`, `kpihx-pve-debian`, `kpihx-s25`, etc. No prefix, no `feat/` — the bare infra name. |
| **`main` is sacred** | Never commit directly on `main`/`master`. Never `git push origin main`. `main` is the integration branch — it only advances when a PR is merged. |
| **Agent confinement** | Any agent running on a given infra MUST `git branch --show-current` on entry and, if on `main`, immediately `git switch <infra>` (create if needed). Work on `main` = violation. |

## 2. Detecting the Current Infra

Resolve infra name in this order (first success wins):

```bash
# 1. Hostname (most reliable on servers without Tailscale)
hostname | tr '[:upper:]' '[:lower:]'   # deep-pc6 → deep-pc6

# 2. Kernel map — single source of truth
cat ~/.agents/assets/infras_skills.jsonc   # keys = infra names

# 3. Shared helper (preferred in scripts)
source ~/.agents/libs/jsonc/jsonc_lib.sh && current_infra
# → prints infra name by matching hostname / tailscale DNSName against infras_skills.jsonc

# 4. Live Tailscale state (when installed)
tailscale status --json | jq -r '.Self.DNSName'  # kpihx-ubuntu.kpihx-labs.ts.net → kpihx-ubuntu
tailscale status  # fallback text parse
```

If infra is unknown (new machine), add it to `assets/infras_skills.jsonc` + `k-infras` inventory BEFORE creating the branch.

## 3. Setup — After Clone, Immediately Switch to Infra Branch

Every new infra MUST do this as **Step 0** (see `k-infras` → New Infra Setup Checklist and `kpihx-labs` → Infrastructure Directory Standard):

```bash
# 1. Clone to the canonical location
mkdir -p ~/KpihX-Labs
git clone git@github.com:KpihX/agents.git ~/KpihX-Labs/.agents   # real repo lives HERE
ln -sfn ~/KpihX-Labs/.agents ~/.agents
cd ~/KpihX-Labs/.agents

# 2. Detect infra
INFRA=$(hostname | tr '[:upper:]' '[:lower:]')   # or: source libs/jsonc/jsonc_lib.sh && INFRA=$(current_infra)

# 3. Switch to infra branch — create if absent, track remote if present
if git show-ref --verify --quiet "refs/heads/$INFRA"; then
  git switch "$INFRA"
elif git ls-remote --heads origin "$INFRA" | grep -q "$INFRA"; then
  git fetch origin "$INFRA"
  git switch "$INFRA"   # auto-tracks origin/<infra>
else
  git switch -c "$INFRA"          # first time on this infra
  git push -u origin "$INFRA"     # publish and track
fi

# Verify
git branch --show-current   # must print $INFRA, never main
```

Single-branch clone variant (when you want ONLY your infra branch locally):
```bash
git clone --single-branch -b "$INFRA" git@github.com:KpihX/agents.git ~/KpihX-Labs/.agents
```

## 4. Daily Workflow — Work on Infra Branch, Sync Before Push, PR to `main`

### 4.1 You work ONLY on your infra branch
```bash
git branch --show-current   # → deep-pc6  (if not, switch now)
# ... edit files ...
git add <files>
git commit -m "feat(scope): message"   # Conventional Commits
```

### 4.2 Before every commit/push — sync with `main`

**Agents may work freely on their infra branch, but BEFORE each `commit`/`push`/`PR` they MUST check if `main` has moved** (other infras' PRs may have been merged). This is mandatory.

```bash
git fetch origin

# Is main ahead of your branch's base?
git log --oneline HEAD..origin/main   # if output → main has new commits

# Rebase your infra branch on top of the new main (preferred — linear history)
git rebase origin/main
# If conflicts: fix, git add, git rebase --continue
# Alternative if rebase is noisy: git merge origin/main (explicit merge commit)

# Re-run checks if needed
make check   # only with KπX approval for .agents kernel (see AGENTS.md gate)
```

> **Why rebase?** Keeps the PR diff clean and avoids criss-cross merges. Every push should be replayed on the latest `main`.

### 4.3 Push your infra branch, never `main`
```bash
# Standard kernel push (all remotes)
make push   # pushes current infra branch to github + gitlab

# Or raw (single remote)
git push origin deep-pc6
# First push needs upstream
git push -u origin deep-pc6
```

### 4.4 Open a PR → `main`
```bash
gh pr create --base main --head deep-pc6 --fill
# or via GitLab: glab mr create --target-branch main --source-branch deep-pc6
```

After the PR is merged, update your local `main` and rebase:
```bash
git fetch origin
git switch main && git pull --ff-only origin main
git switch deep-pc6
git rebase main
```

## 5. Periodic Guard — Don't Let Your Branch Drift

- **Before EVERY push:** `git fetch origin` + compare with `origin/main` (see 4.2).
- **At session start:** `git fetch origin && git log --oneline HEAD..origin/main` — if non-empty, rebase now.
- **Weekly / before large feature:** rebase even if no conflict is visible — catches silent drift.
- **After ANY PR merge (yours or another infra's):** treat `main` as changed until proven otherwise — fetch + rebase.

If you skipped the check and `main` moved under you, your PR may show conflicts or be rejected — rebase and force-push (`git push --force-with-lease`).

## 6. Protections (recommended)

- Enable branch protection on `main`/`master` (require PR, no direct push).
- CI must run on infra branches and on PRs to `main`.
- Local guard (optional): `git config --add branch.main.pushRemote no_push` or a `pre-push` hook that blocks `main`.

## 7. Quick Reference

| Situation | Command |
|-----------|---------|
| Which branch am I on? | `git branch --show-current` |
| Am I behind `main`? | `git fetch origin && git log --oneline HEAD..origin/main` |
| Sync with `main` | `git fetch origin && git rebase origin/main` |
| Push infra branch | `make push` or `git push -u origin $(git branch --show-current)` |
| Create PR | `gh pr create --base main --head <infra>` |
| After PR merged | `git fetch origin && git switch main && git pull && git switch <infra> && git rebase main` |

## 8. See Also

- `k-infras` — master infra map + New Infra Setup Checklist (Step 0 now includes branch switch)
- `k-git` — SSH-only, `make push`, conventional commits
- `kpihx-labs` — Infrastructure Directory Standard (clone + symlink + infra branch)
- `assets/infras_skills.jsonc` — infra → skill map (source of truth for branch names)
- `libs/jsonc/jsonc_lib.sh:current_infra` — programmatic infra detection

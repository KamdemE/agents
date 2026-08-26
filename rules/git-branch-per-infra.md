# Git Branch per Infra — Never Work on `master`

> **Absolute rule for the `.agents` kernel (and recommended for every KpihX project).**
> Each infrastructure works **exclusively** on its own branch named after the infra.
> `master` is **read-only** — it only advances via merged PRs — with ONE exception:
> **`kpihx-ubuntu` is the sole infra authorized to commit directly on `master`.**
>
> **Before handling any merge:** load `skills/k-git/references/merge-workflow.md` in full — it is the operational companion to this rule (inspection, elegant presentation, arbitrage, coherent MD rewriting, versioning, push/verify).

## 1. Rule — One Branch per Infra, Never `master` (Except Ubuntu)

| Principle | Rule |
|-----------|------|
| **Branch name = infra short name** | Branch MUST be the infra's short name as listed in `assets/infras_skills.jsonc` and `k-infras` inventory: `deep-pc6`, `blglaptop139`, `kpihx-pve`, `kpihx-pve-debian`, `kpihx-s25`, etc. No prefix, no `feat/` — the bare infra name. |
| **Windows/WSL suffix** | Exclusively for Windows machines working from WSL, the branch appends `-wsl` (e.g. `blglaptop139-wsl`) — keeping the door open for a future native-Windows clone, which would get its own naming decided at that time. |
| **Ubuntu = the `master` infra** | `kpihx-ubuntu` is the ONLY infra allowed to work on and commit to `master` directly — no infra branch, no PR for its own kernel work. Every other infra: `master` is forbidden territory. |
| **`master` advances via PRs** | For every non-ubuntu infra, `master` only moves when a PR is merged. Never `git push <remote> master` from another infra. |
| **Agent confinement** | Any agent running on a given infra MUST `git branch --show-current` on entry and, if on `master` while the infra is NOT `kpihx-ubuntu`, immediately `git switch <infra>` (create if needed). Working on `master` from any other infra = violation. |

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
git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents   # real repo lives HERE
ln -sfn ~/KpihX-Labs/.agents ~/.agents
cd ~/KpihX-Labs/.agents

# 2. Detect infra
INFRA=$(hostname | tr '[:upper:]' '[:lower:]')   # or: source libs/jsonc/jsonc_lib.sh && INFRA=$(current_infra)

# 3. Switch — ubuntu goes to master, everyone else to their own branch
if [ "$INFRA" = "kpihx-ubuntu" ]; then
  git switch master                # the sole infra working on master
elif git show-ref --verify --quiet "refs/heads/$INFRA"; then
  git switch "$INFRA"
elif git ls-remote --heads github "$INFRA" | grep -q "$INFRA"; then
  git fetch github "$INFRA"
  git switch "$INFRA"   # auto-tracks github/<infra>
else
  git switch -c "$INFRA"          # first time on this infra
  git push -u github "$INFRA"     # publish and track
fi

# Verify
git branch --show-current   # must print $INFRA — or `master` on kpihx-ubuntu, nothing else
```

Single-branch clone variant (when you want ONLY your infra branch locally):
```bash
git clone --single-branch -b "$INFRA" git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents
```

## 4. Daily Workflow — Work on Infra Branch, Sync Before Push, PR to `master`

### 4.1 You work ONLY on your infra branch (ubuntu: on `master`)
```bash
git branch --show-current   # → deep-pc6  (if not, switch now — unless you are kpihx-ubuntu)
# ... edit files ...
git add <files>
git commit -m "feat(scope): message"   # Conventional Commits
```

### 4.2 Before every commit/push — sync with `master`

**Agents may work freely on their infra branch, but BEFORE each `commit`/`push`/`PR` they MUST check if `master` has moved** (other infras' PRs may have been merged). This is mandatory.

```bash
git fetch github

# Is master ahead of your branch's base?
git log --oneline HEAD..github/master   # if output → master has new commits

# Rebase your infra branch on top of the new master (preferred — linear history)
git rebase github/master
# If conflicts: fix, git add, git rebase --continue
# Alternative if rebase is noisy: git merge github/master (explicit merge commit)

# Re-run checks if needed
make check   # only with KπX approval for .agents kernel (see AGENTS.md gate)
```

> **Why rebase?** Keeps the PR diff clean and avoids criss-cross merges. Every push should be replayed on the latest `master`.

### 4.3 Push your infra branch, never `master`
```bash
# Standard kernel push (all remotes)
make push   # pushes the CURRENT branch to github + gitlab

# Or raw (single remote)
git push github deep-pc6
# First push needs upstream
git push -u github deep-pc6
```

### 4.4 Open a PR → `master`
```bash
gh pr create --base master --head deep-pc6 --fill
# or via GitLab: glab mr create --target-branch master --source-branch deep-pc6
```

After the PR is merged, update your local `master` and rebase:
```bash
git fetch github
git switch master && git pull --ff-only github master
git switch deep-pc6
git rebase master
```

## 5. Periodic Guard — Don't Let Your Branch Drift

- **Before EVERY push:** `git fetch github` + compare with `github/master` (see 4.2).
- **At session start:** `git fetch github && git log --oneline HEAD..github/master` — if non-empty, rebase now.
- **Weekly / before large feature:** rebase even if no conflict is visible — catches silent drift.
- **After ANY PR merge (yours or another infra's):** treat `master` as changed until proven otherwise — fetch + rebase.

If you skipped the check and `master` moved under you, your PR may show conflicts or be rejected — rebase and force-push (`git push --force-with-lease`).

## 6. Protections (recommended)

- Enable branch protection on `master` (require PR, no direct push) configured so that `kpihx-ubuntu` retains direct-push rights (e.g. admin bypass) — it is the designated `master` infra.
- CI must run on infra branches and on PRs to `master`.
- Local guard (optional): a `pre-push` hook that blocks pushing `master` — with an explicit allow-list entry for `kpihx-ubuntu`.

## 7. Quick Reference

| Situation | Command |
|-----------|---------|
| Which branch am I on? | `git branch --show-current` |
| Am I behind `master`? | `git fetch github && git log --oneline HEAD..github/master` |
| Sync with `master` | `git fetch github && git rebase github/master` |
| Push infra branch | `make push` or `git push -u github $(git branch --show-current)` |
| Create PR | `gh pr create --base master --head <infra>` |
| After PR merged | `git fetch github && git switch master && git pull --ff-only github master && git switch <infra> && git rebase master` |
| Am I on kpihx-ubuntu? | Then working on `master` directly is allowed — no infra branch needed |

## 8. See Also

- `k-git/references/merge-workflow.md` — **ABSOLUTE** operational companion: inspection, elegant presentation, arbitrage, coherent rewriting, versioning, push/verify
- `k-infras` — master infra map + New Infra Setup Checklist (Step 0 now includes branch switch)
- `k-git` — SSH-only, `make push` (`github`+`gitlab`, NEVER `origin`), conventional commits
- `kpihx-labs` — Infrastructure Directory Standard (clone + symlink + infra branch)
- `assets/infras_skills.jsonc` — infra → skill map (source of truth for branch names)
- `libs/jsonc/jsonc_lib.sh:current_infra` — programmatic infra detection

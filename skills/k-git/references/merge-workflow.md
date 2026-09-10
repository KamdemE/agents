# k-git — Merge Workflow (ABSOLUTE — Read Before Handling Any Merge)

**Status:** ABSOLUTE reference for every merge of a kernel branch (`deep-pc6`, `blglaptop139-wsl`, or any future infra). **MUST be loaded and followed in full before touching a single file.** No shortcut, no mental summary.

> **Scope:** `.agents` kernel merges only (the `kpihx-labs/agents` repo, branch-per-infra workflow). Project repos follow `k-project`/`k-final` where applicable.
> **Companion rule:** `rules/git-branch-per-infra.md` (authoritative branch policy). This document is its **operational companion** — the step-by-step execution manual.

---

## 0. Mindset

- A merge is **never** a blind `git merge && push`. It is a **governance act**: every hunk is inspected, every conflict is resolved coherently, every version is renumbered, every doc is rewritten for fluidity.
- Two infras can implement the **same concept independently** (e.g. duplicate `check-remotes` contracts). Your job is to **absorb the surplus**, never delete it.
- `ubuntu` (`kpihx-ubuntu`) is the **sole infra allowed on `master`** — every other infra owns its named branch (`deep-pc6`, `blglaptop139-wsl` on WSL). This exception is GRAVÉ.
- `*.pdf`, `*.pptx`, `*.onnx`, `*.bin` are **binary** (`* binary` in `.gitattributes`) — never diffed as text.

---

## 1. Pre-Flight (Read-Only)

```bash
git status -sb | head -20                          # must be clean (or only k-context notes you will commit first)
git rev-parse master github/master gitlab/master    # refs aligned?
readlink ~/.agents                                  # → ~/KpihX-Labs/.agents (real repo), per Infrastructure Directory Standard
git fetch --all --prune
git branch -a | head -30
gh pr list -R kpihx-labs/agents --state all --limit 10
glab mr list --repo kpihx-labs/agents
```

- VPN-dependent services (`vpn-dxo`, `ollama6-tunnel`) — if `vpn-dxo` is `failed` for >1h, expect `make check` to block commits. Fix via tmux ops pane `ubuntu:0.2` (see `k-tmux` + `k-dxo`) **before** committing.

---

## 2. Full Read of the PR (Not a Summary)

```bash
base=$(git merge-base master github/<branch>)
git log --oneline --format='%h %ad %s' --date=short $base..github/<branch>
git diff --name-status $base..github/<branch>
git diff --stat $base..github/<branch> | sort -t'|' -k2 -rn | head -25
git diff $base..github/<branch> > /tmp/opencode/pr-full.diff; wc -l /tmp/opencode/pr-full.diff
```

- **Read the entire diff** — every file, line by line (`Read` tool in slices). For a 80k-line diff the PDF dominates; summarize it as binary, but read every other file.
- Cross-check overlaps:

```bash
git diff --name-only $base..master | sort > /tmp/a
git diff --name-only $base..github/<branch> | sort > /tmp/b
grep -Fx -f /tmp/a /tmp/b          # true conflict candidates vs current master
# also vs the other open PR if two are queued
```

- Check branch-base freshness: `git merge-base` must be recent. If `master` moved after the branch fork, a rebase-style conflict is guaranteed.

---

## 3. Elegant Presentation (So KπX Can Decide Without Re-Reading Code)

**Never modify before presenting.** Produce a single structured message in French (KπX's working language), with this exact skeleton — it is the one that lets him say "G1 je valide, G2 je valide, G8 option b…" in one pass:

```
# PR #N — <branch> · X commits · Y files (+A/−B)

Base = <sha> — <N> commits ahead of master? Master is M commits ahead?
Table: Commit | Date | Subject | Files

## CE QU'ELLE APPORTE — par groupe + proposition par élément

### G1 · Title (commit sha)
Content (what it brings), files, lines.
⚠️ Issues found (if any).
Ma proposition : ✅ VALIDER / PATCH / FUSIONNER / REJETER

### G2 · ...
...

## CONFLITS
| Fichier | côté master | côté PR | Résolution proposée |
...

## 💬 COMMENTS + ⚠️ REMARQUES + 🔭 INSIGHTS (territoire libre de l'agent — avis franc / alertes même hors demande et pré-existant / mode tuteur — sans limite de longueur, les 3 toujours recommandées, répétées tant que pertinentes si ignorées)
1. ...
2. ...

💡 SUGGESTIONS (≥3)
1. ...
```

**Grouping rule:** one `G` per coherent intent (often one commit, but a commit that touches 130 files like `blglaptop139-wsl: voice + k-windows + k-pptx` is split into thematic Gs: voice, k-windows, k-pptx, …). Keep `G` count ≤12, each with its own verdict.

**For every G provide:**
- What it brings (files + line counts + concrete behavior)
- Quality assessment (does it violate `_` vs `-`, does it duplicate another PR, does it contradict the branch-per-infra rule)
- A crisp proposal (`✅ VALIDER tel quel`, `✅ VALIDER + PATCH ...`, `🔀 FUSIONNER en absorbant ...`, `❌ REJETER / INVERSER`)

**Conflict tables:** two tables — vs current `master` (post-previous-merge) and vs the other queued PR. For each file: master side change, PR side change, proposed union.

**PDF / large binary note:** always flag `Mother_Mirror.pdf` style assets: `76376 insertions` but `Bin 0 → 19 MB` after `.gitattributes`. Propose option (b) binary.

**Example G lines from the two real merges (keep this tone):**

- `G1 NO BYPASS vars purge validated (… ) — checks ARE the code`
- `G2 scripts/remotes/{lib,check-remotes,set-remotes}.sh REWRITTEN to absorb 4 bonus features (submodule coverage, upstream tolerance, live ls-remote joinability, branch presence) while keeping thin-orchestrator + tracking-repoint; duplicates deleted`
- `G8 Mother_Mirror.pdf — option (b): .gitattributes forces *.pdf binary (was diffed as text, ~90% of raw diff)`

---

## 4. Await KπX Arbitrages (Question Tool)

After the presentation, **stop**. Use the `question` tool for every ambiguity:

- `k-pptx/references/log.md` deleted (12 lines) → Annuler vs Fondre dans [SUMMARY] ?
- 4 new `references/log.md` vs rule "rotation exclusive à k-context" → Garder comme archives gelées vs Replier ?
- `Mother_Mirror.pdf` → Sortir / Binary / Garder ?

Never assume. KπX's answers are recorded as `G1 je valide`, `G8 option b`, etc. — treat them as locked arbitrages for the merge pass.

---

## 5. Execution — One Merge at a Time

### 5.1 Commit pending k-context notes first (ubuntu may commit on master)

```bash
git add skills/k-context/SKILL.md && git commit -m "docs(k-context): ..."
# pre-commit hook runs the full `make check` — VPN must be green
```

If the hook fails on `check-services` (vpn-dxo down), restart via tmux ops pane `ubuntu:0.2` — see `k-tmux` Shared interactive gate.

### 5.2 Merge (no-ff, no-commit for control)

```bash
git merge github/<branch> --no-ff --no-commit
git diff --name-only --diff-filter=U   # list conflicts
for f in $(git diff --name-only --diff-filter=U); do echo "── $f ──"; grep -n '^<<<<<<< ' "$f"; done
```

### 5.3 Resolve Textually — MD Coherence First

> **KπX rule:** for `.md` files, **never just concatenate blocks** — rewrite the section for fluidity from start to finish.

- `AGENTS.md` version bump: `3.7.0 → 3.8.0` (or next minor), keep ubuntu exception + `-wsl` note + `github`/`gitlab` never `origin` + `kpihx-labs/agents.git` URLs.
- `rules/git-branch-per-infra.md` — rewrite **entirely** via `Write` (159 lines) to encode the locked arbitrages; do not patch line-by-line.
- `skills/k-*/SKILL.md` changelogs: if a skill would exceed **2 explicit rows before [SUMMARY]**, rotate the oldest row into `[SUMMARY]` (copy-then-condense, per kernel Zero-Deletion).
- `Makefile` duplicate targets: keep one `check-remotes` + `set-remotes` (the `scripts/remotes/` kebab version after absorption) + `pr` (from `create-pr.sh`).

### 5.4 Absorb Duplicate Contracts (Never Delete Surplus)

When two PRs implement the same contract (`scripts/remotes/` vs `scripts/git/`):

1. Keep `scripts/remotes/` (pattern coherent with `services/`, `links/`, `jsonc/`, `env/`).
2. Rename executables to `kebab-case` (`check-remotes.sh`, `set-remotes.sh`) per `rules/file-governance.md` — `lib.sh` stays `snake` (sourced).
3. Rewrite `lib.sh` + `check-remotes.sh` + `set-remotes.sh` to absorb the 4 bonuses: submodule loop, `upstream` tolerance, live `ls-remote` joinability, branch presence.
4. Delete the duplicate `scripts/git/{check,set}-remotes.sh` files.
5. Deduplicate Makefile targets.

Stage the deletions explicitly (`git rm -f`).

### 5.5 Verify Before Committing

```bash
grep -rln '^<<<<<<< ' --exclude-dir=.git . || echo 'AUCUN'
grep -rn 'github.com:KpihX/agents' --exclude-dir=.git . || echo 'AUCUNE mauvaise URL'
bash -n scripts/remotes/*.sh; zsh -n skills/k-*/assets/kshrc*
cat .gitattributes | grep -q '^\*\.pdf.*binary' && echo 'PDF binary ✓'
git status --short | head -40
```

### 5.6 Commit

```bash
git add -A
git commit -m "merge: PR #N <branch> — <one-line summary>

Integration per KπX arbitrages:
- G1: ...
- G2: scripts/remotes/ absorbed 4 bonuses, duplicates deleted
- ...
Version collisions resolved by renumbering (document inline):
AGENTS.md X.Y.Z, k-* A.B.C, ...
"
```

Pre-commit hook runs the **full** `make check` again — fix any `check-skills` max-2 violation before retrying.

### 5.7 k-context Session Log + Changelog

Update `skills/k-context/SKILL.md` (version bump, Session Log row on top, Changelog row, rotation if >2 rows → copy oldest to `references/log.md`). Commit as `docs(k-context): PR #N ... merged`.

---

## 6. Push & Verify Auto-Close

```bash
make push   # github + gitlab simultaneously
gh pr view N -R kpihx-labs/agents --json state,mergedAt
glab mr list --repo kpihx-labs/agents
```

Both the GH PR and the GitLab MR auto-close when `master` contains their commits.

---

## 7. Post-Merge Hygiene

- Notify the other infra(s) to rebase: `git fetch github && git rebase github/master`.
- If the merge introduced a new binary asset, confirm `git diff --cached --stat` shows `Bin 0 → N bytes` (not thousands of insertions).
- Update `k-context` Active TODOs (remove or mark the merged PR).

---

## 8. Presentation Template (Copy-Paste)

```markdown
# PR #N — <branch> · <n> commits · <f> fichiers (+A/−B)
Base = <sha> — master is M commits ahead

| Commit | Heure | Sujet |
|---|---|---|
| sha | HH:MM | subject |

## G1 · Title
Apporte : ...
Fichiers : ...
Proposition : ✅ ...

## CONFLITS vs master (K fichiers)
| Fichier | master | PR | Proposition |
|---|---|---|---|
| ... | ... | ... | Union → ... |

## 💬 COMMENTS + ⚠️ REMARQUES + 🔭 INSIGHTS (territoire libre — les 3 recommandées, sans limite, répétées si ignorées)
1. ...

💡 SUGGESTIONS
1. ...
```

Keep it scannable: tables for conflicts, bullet lists for files, bold for verdicts, `inline code` for paths/commands.

---

## 9. Anti-Patterns

- Reading only `git diff --stat` and guessing the rest.
- Merging two PRs at once — always one merge, one push, then the next PR rebased.
- `cat > file <<'EOF'` / `sed -i` — use `Read` + `Edit`/`Write` only.
- `make check 2>&1 | tail` — run `make check` exactly as two tokens, read everything.
- Deleting a `references/log.md` without first condensing its rows into the live `[SUMMARY]`.

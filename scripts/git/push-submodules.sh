#!/usr/bin/env bash
# ============================================================================
# push-submodules.sh — push ALL git submodules properly to ALL their remotes
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/scripts/git/push-submodules.sh
# Used by         : root Makefile target `push-sub`
#
# For EVERY submodule declared in .gitmodules:
#   1. If the worktree is dirty → stage everything and create a commit
#      (message: $1 or default "chore(sub): sync from kernel").
#   2. For EACH configured remote: fetch, rebase local on top if the remote
#      moved (fail loudly on conflict), then push the current branch.
#
# Transparency: every failure is printed and counted — the script exits 1 at
# the end if ANY submodule could not be fully pushed to all its remotes.
# No /dev/null silencing (rules/tool-discipline.md → /dev/null Redirection Policy).
# ============================================================================
set -u

MSG="${1:-chore(sub): sync from kernel}"
# Only PUSH to the owner fork: origin (fixed by convention).
# Other remotes (upstream pointing at third-party forks)
# are READ-ONLY upstreams — never push.
#
# 🔴 NO BYPASS VARIABLE (maintainer directive 2026-08-25) — GRAVÉ: the remote list
# is hardcoded here, no env override. The checks ARE the code.
PUSH_REMOTES="origin"
failures=0

mapfile -t SUBS < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | cut -d' ' -f2)
if [ "${#SUBS[@]}" -eq 0 ]; then
  echo "No submodules in .gitmodules — nothing to do."
  exit 0
fi

for sm in "${SUBS[@]}"; do
  [ -e "$sm/.git" ] || { echo "⚠️  $sm: not initialized (run 'make submodule-init')"; failures=$((failures+1)); continue; }
  echo "━━━ $sm ━━━"

  # Detached HEAD → cannot push a branch
  branch="$(git -C "$sm" rev-parse --abbrev-ref HEAD)"
  if [ "$branch" = "HEAD" ]; then
    echo "❌ $sm: detached HEAD — checkout a branch before pushing."
    failures=$((failures+1)); continue
  fi

  # 1) Commit dirty worktree
  if ! git -C "$sm" diff --quiet || ! git -C "$sm" diff --cached --quiet || [ -n "$(git -C "$sm" ls-files --others --exclude-standard)" ]; then
    git -C "$sm" add -A
    if git -C "$sm" commit -m "$MSG"; then
      echo "  ✅ committed: $MSG"
    else
      echo "❌ $sm: commit failed."
      failures=$((failures+1)); continue
    fi
  else
    echo "  • clean worktree"
  fi

  # 2) Push current branch to the -owned remotes only
  mapfile -t REMOTES < <(git -C "$sm" remote | while read -r r; do
    case " $PUSH_REMOTES " in *" $r "*) echo "$r";; *) echo "  (skip $r: upstream/read-only)" >&2;; esac
  done)
  if [ "${#REMOTES[@]}" -eq 0 ]; then
    echo "❌ $sm: none of the push remotes ($PUSH_REMOTES) configured."
    failures=$((failures+1)); continue
  fi
  rebase_failed=0
  for r in "${REMOTES[@]}"; do
    [ "$rebase_failed" = "1" ] && { failures=$((failures+1)); continue; }
    echo "  → $r/$branch"
    if ! git -C "$sm" fetch "$r" "$branch"; then
      echo "❌ $sm: fetch $r failed (unreachable?)."
      failures=$((failures+1)); continue
    fi
    behind=""
    if git -C "$sm" rev-parse --verify -q "$r/$branch" >/dev/null; then
      behind="$(git -C "$sm" rev-list --count "HEAD..$r/$branch")"
    else
      echo "    (no $r/$branch yet — first push)"
      behind=0
    fi
    if [ "${behind:-0}" != "0" ]; then
      echo "    remote ahead by $behind commit(s) — rebasing..."
      if ! git -C "$sm" pull --rebase "$r" "$branch"; then
        echo "❌ $sm: rebase onto $r/$branch has conflicts — aborting this submodule:"
        git -C "$sm" rebase --abort && echo "    (rebase aborted — local state restored)"
        echo "    resolve manually (merge/rebase), then re-run make push-sub"
        rebase_failed=1
        failures=$((failures+1))
        break
      fi
    fi
    if git -C "$sm" push "$r" "$branch"; then
      echo "    ✅ pushed"
    else
      echo "❌ $sm: push to $r failed (protected branch? force needed?)."
      failures=$((failures+1))
    fi
  done
done

if [ "$failures" -ne 0 ]; then
  echo "🔴 push-sub finished with $failures failure(s)."
  exit 1
fi
echo "✅ All submodules pushed to all their remotes."

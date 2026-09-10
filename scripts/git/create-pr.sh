#!/usr/bin/env bash
# ============================================================================
# create-pr.sh — open a GitHub PR for the CURRENT branch (single-remote flow)
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/scripts/git/create-pr.sh
# Used by         : root Makefile target `pr`
#
# Behavior:
#   • refuses to run on master/main (nothing to merge)
#   • base branch = $1 (default: master)
#   • title/body = last commit subject/body (single source of truth: the
#     commit itself — no retyping)
#   • slug parsed FROM THE ORIGIN URL (see check-remotes.sh contract), so
#     this works for ANY repo of the owner
#   • origin → `gh pr create`
#
# No /dev/null silencing (rules/tool-discipline.md).
# ============================================================================
set -u

failures=0

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
  echo "❌ On '$BRANCH' — checkout a feature branch first (nothing to merge)."
  exit 1
fi
BASE="${1:-master}"

TITLE="$(git log -1 --pretty=%s)"
BODY="$(git log -1 --pretty=%b)"

origin_url="$(git remote get-url origin 2>/dev/null || true)"
[ -n "$origin_url" ] || { echo "❌ remote 'origin' missing (run: make set-remotes)"; exit 1; }

slug="$(printf '%s' "$origin_url" | sed -E 's#.*github\.com[:/]##; s#\.git$##')"

echo "━━━ GitHub PR (${slug}) ━━━"
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ 'gh' CLI not installed — sudo apt install gh"
  failures=$((failures+1))
else
  out="$(gh pr create --repo "$slug" --base "$BASE" --head "$BRANCH" \
        --title "$TITLE" --body "$BODY" 2>&1)"
  rc=$?
  printf '%s\n' "$out"
  if [ $rc -eq 0 ]; then
    echo "✅ GitHub PR created."
  elif printf '%s' "$out" | grep -qi "already exists"; then
    echo "ℹ️  GitHub PR already exists — kept."
  else
    echo "❌ GitHub PR creation failed (rc=$rc)."
    failures=$((failures+1))
  fi
fi

if [ "$failures" -ne 0 ]; then
  echo "🔴 create-pr finished with $failures failure(s)."
  exit 1
fi
echo "✅ PR done for branch '$BRANCH' → '$BASE'."

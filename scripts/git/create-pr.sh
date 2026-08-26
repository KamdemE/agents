#!/usr/bin/env bash
# ============================================================================
# create-pr.sh — open a PR (github) + an MR (gitlab) for the CURRENT branch
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/scripts/git/create-pr.sh
# Used by         : root Makefile target `pr`
#
# Behavior:
#   • refuses to run on master/main (nothing to merge)
#   • base branch = $1 (default: master)
#   • title/body = last commit subject/body (single source of truth: the
#     commit itself — no retyping)
#   • slugs parsed FROM THE REMOTE URLS (github/gitlab pair — see
#     check-remotes.sh contract), so this works for ANY kpihx repo
#   • github → `gh pr create`; gitlab → `glab mr create`
#
# 🔴 LOUD glab gate (KπX directive): if glab is MISSING or NOT AUTHENTICATED,
# this script FLAGS IT EXPLICITLY (install/config instructions printed) and
# still gives the pre-filled web-UI fallback URL. Never silent.
#
# 🔴 NO BYPASS VARIABLE (KπX directive 2026-08-25) — GRAVÉ. No env override.
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

gh_url="$(git remote get-url github 2>/dev/null || true)"
gl_url="$(git remote get-url gitlab 2>/dev/null || true)"
[ -n "$gh_url" ] || { echo "❌ remote 'github' missing (run: make set-remotes)"; exit 1; }
[ -n "$gl_url" ] || { echo "❌ remote 'gitlab' missing (run: make set-remotes)"; exit 1; }

gh_slug="$(printf '%s' "$gh_url" | sed -E 's#.*github\.com[:/]##; s#\.git$##')"
gl_slug="$(printf '%s' "$gl_url" | sed -E 's#.*gitlab\.com[:/]##; s#\.git$##')"

mr_web_url="https://gitlab.com/${gl_slug}/-/merge_requests/new?merge_request%5Bsource_branch%5D=${BRANCH}&merge_request%5Btarget_branch%5D=${BASE}"

echo "━━━ github PR (${gh_slug}) ━━━"
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ 'gh' CLI not installed — sudo apt install gh"
  failures=$((failures+1))
else
  out="$(gh pr create --repo "$gh_slug" --base "$BASE" --head "$BRANCH" \
        --title "$TITLE" --body "$BODY" 2>&1)"
  rc=$?
  printf '%s\n' "$out"
  if [ $rc -eq 0 ]; then
    echo "✅ github PR created."
  elif printf '%s' "$out" | grep -qi "already exists"; then
    echo "ℹ️  github PR already exists — kept."
  else
    echo "❌ github PR creation failed (rc=$rc)."
    failures=$((failures+1))
  fi
fi

echo "━━━ gitlab MR (${gl_slug}) ━━━"
if ! command -v glab >/dev/null 2>&1; then
  echo "🚨 GLAB NOT INSTALLED — install it, then re-run:"
  echo "   sudo apt install glab          # (or the official glab install script)"
  echo "👉 Web fallback (pre-filled MR form):"
  echo "   $mr_web_url"
  failures=$((failures+1))
elif ! glab auth status --hostname gitlab.com >/dev/null 2>&1; then
  echo "🚨 GLAB NOT CONFIGURED — authenticate, then re-run:"
  echo "   glab auth login --hostname gitlab.com   # paste your GitLab PAT"
  echo "👉 Web fallback (pre-filled MR form):"
  echo "   $mr_web_url"
  failures=$((failures+1))
else
  out="$(glab mr create --repo "$gl_slug" --source-branch "$BRANCH" --target-branch "$BASE" \
        --title "$TITLE" --description "$BODY" 2>&1)"
  rc=$?
  printf '%s\n' "$out"
  if [ $rc -eq 0 ]; then
    echo "✅ gitlab MR created."
  elif printf '%s' "$out" | grep -qi "already exists"; then
    echo "ℹ️  gitlab MR already exists — kept."
  else
    echo "❌ gitlab MR creation failed (rc=$rc)."
    echo "👉 Web fallback (pre-filled MR form): $mr_web_url"
    failures=$((failures+1))
  fi
fi

if [ "$failures" -ne 0 ]; then
  echo "🔴 create-pr finished with $failures failure(s)."
  exit 1
fi
echo "✅ PR/MR done for branch '$BRANCH' → '$BASE'."

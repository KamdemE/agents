#!/usr/bin/env bash
# ============================================================================
# set-remotes.sh — FORCE the kpihx remote pair (github+gitlab) on THIS repo AND
# every declared submodule. Idempotent: deletes whatever remotes exist, then
# sets EXACTLY github + gitlab with the convention URLs.
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/scripts/git/set-remotes.sh
# Used by         : root Makefile target `set-remotes`
#
# Scope (KπX directive 2026-08-25): parent repo first, then every submodule.
# For EACH, regardless of what was there before (origin, wrong URL, stale…):
#   • github → git@github.com:kpihx-labs/<name>.git   (parent repo name mapped:
#     directory `.agents` = repo `agents`)
#   • gitlab → git@gitlab.com:kpihx-labs/<name>.git
# Any other remote (origin, upstream…) is removed — exactly these 2 remain.
#
# This script ONLY configures remotes — it never pushes (`make push` /
# `make push-sub`) and never creates the repos themselves (create them on
# github.com / gitlab.com, or via gh/glab).
#
# 🔴 NO BYPASS VARIABLE (KπX directive 2026-08-25) — GRAVÉ. The convention IS
# the code: github+gitlab, kpihx-labs namespace, no env overrides.
# No /dev/null silencing (rules/tool-discipline.md).
# ============================================================================
set -u

failures=0

set_repo() {
  local dir="$1" label="$2" name="$3"
  echo "━━━ $label ━━━"
  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ $label: not a git repository"; failures=$((failures+1)); return
  fi

  local gh_expected="git@github.com:kpihx-labs/${name}.git"
  local gl_expected="git@gitlab.com:kpihx-labs/${name}.git"

  # Purge ALL existing remotes — the pair is set from scratch, every time.
  local r
  for r in $(git -C "$dir" remote); do
    if git -C "$dir" remote remove "$r"; then
      echo "  − removed '$r'"
    else
      echo "❌ $label: failed removing remote '$r'"; failures=$((failures+1))
    fi
  done

  if git -C "$dir" remote add github "$gh_expected" \
     && git -C "$dir" remote add gitlab "$gl_expected"; then
    echo "  ✓ github → $gh_expected"
    echo "  ✓ gitlab → $gl_expected"
  else
    echo "❌ $label: failed setting the kpihx remote pair"; failures=$((failures+1))
  fi
}

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Not inside a git repo"; exit 1; }

# Parent repo: directory `.agents` hosts the repo `agents` (kpihx-labs org).
root_name="$(basename "$ROOT")"
[ "$root_name" = ".agents" ] && root_name="agents"
set_repo "$ROOT" "$(basename "$ROOT")" "$root_name"

mapfile -t SUBS < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | cut -d' ' -f2)
for sm in "${SUBS[@]:-}"; do
  [ -n "$sm" ] || continue
  [ -e "$sm/.git" ] || { echo "━━━ $sm ━━━"; echo "❌ $sm: not initialized (run 'make submodule-init')"; failures=$((failures+1)); continue; }
  set_repo "$sm" "$sm" "$(basename "$sm")"
done

if [ "$failures" -ne 0 ]; then
  echo "🔴 set-remotes finished with $failures failure(s)."
  exit 1
fi
echo "✅ Parent repo and all submodules have EXACTLY the kpihx remote pair."
echo "Next: verify with 'make check-remotes', push with 'make push'."

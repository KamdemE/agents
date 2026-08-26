#!/usr/bin/env bash
# ============================================================================
# check-remotes.sh — verify THIS repo AND every submodule have EXACTLY the
# kpihx remote pair (github + gitlab), with the exact URLs, both reachable.
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/scripts/git/check-remotes.sh
# Used by         : root Makefile target `check-remotes`
#
# Scope (KπX directive 2026-08-25): the PARENT repo (e.g. ~/.agents) AND all
# its submodules. For EACH of them verify:
#   1. exactly TWO kpihx remotes exist: `github` and `gitlab` — nothing else is
#      allowed except a read-only `upstream` (explicitly tolerated, never pushed)
#   2. URLs are the EXACT convention:
#        github → git@github.com:kpihx-labs/<name>.git  (or KpihX/<name> personal)
#        gitlab → git@gitlab.com:kpihx-labs/<name>.git  (or kpihx/<name> personal)
#   3. both are JOINABLE: live `git ls-remote` succeeds (SSH auth + repo exists)
#
# 🔴 NO BYPASS VARIABLE (KπX directive 2026-08-25) — GRAVÉ: the checks ARE the
# code. If this fails, FIX with `make set-remotes`, never silence it.
# No /dev/null silencing (rules/tool-discipline.md).
# ============================================================================
set -u

failures=0

check_repo() {
  local dir="$1" label="$2"
  echo "━━━ $label ━━━"

  # Collect remotes
  local remotes gh_url gl_url extra r url out name branch
  remotes="$(git -C "$dir" remote)"
  gh_url="$(git -C "$dir" remote get-url github 2>/dev/null || true)"
  gl_url="$(git -C "$dir" remote get-url gitlab 2>/dev/null || true)"

  # 0) repo must be a git repo
  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ $label: not a git repository"
    failures=$((failures+1))
    return
  fi

  name="$(basename "$dir")"
  [ "$label" = "." ] && name="$(basename "$(git -C "$dir" rev-parse --show-toplevel)")"
  # Directory `.agents` hosts the repo `agents` (kpihx-labs org).
  [ "$name" = ".agents" ] && name="agents"

  # 1) exactly the kpihx pair (+ optional read-only upstream)
  for r in $remotes; do
    case "$r" in
      github|gitlab|upstream) ;;                       # allowed
      *)
        echo "❌ $label: unexpected remote '$r' ($(git -C "$dir" remote get-url "$r")) — only github/gitlab (+upstream read-only) allowed"
        failures=$((failures+1)) ;;
    esac
  done

  # 2) presence + exact URL
  if [ -z "$gh_url" ]; then
    echo "❌ $label: remote 'github' MISSING → make set-remotes"
    failures=$((failures+1))
  else
    case "$gh_url" in
      git@github.com:kpihx-labs/"$name".git|git@github.com:KpihX/"$name".git)
        echo "  ✓ github = $gh_url" ;;
      *)
        echo "❌ $label: github URL wrong: $gh_url (expected git@github.com:kpihx-labs/$name.git or KpihX/$name.git)"
        failures=$((failures+1)) ;;
    esac
  fi

  if [ -z "$gl_url" ]; then
    echo "❌ $label: remote 'gitlab' MISSING → make set-remotes"
    failures=$((failures+1))
  else
    case "$gl_url" in
      git@gitlab.com:kpihx-labs/"$name".git|git@gitlab.com:kpihx/"$name".git)
        echo "  ✓ gitlab = $gl_url" ;;
      *)
        echo "❌ $label: gitlab URL wrong: $gl_url (expected git@gitlab.com:kpihx-labs/$name.git or kpihx/$name.git)"
        failures=$((failures+1)) ;;
    esac
  fi

  # 3) joinable (live SSH check)
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
  for r in github gitlab; do
    url="$(git -C "$dir" remote get-url "$r" 2>/dev/null || true)"
    [ -n "$url" ] || continue
    out="$(git -C "$dir" ls-remote --heads "$r" 2>&1)"
    if [ $? -ne 0 ]; then
      echo "❌ $label: ls-remote $r FAILED:"
      printf '%s\n' "$out" | sed 's/^/      /'
      failures=$((failures+1))
    elif ! printf '%s\n' "$out" | grep -q "refs/heads/$branch"; then
      echo "❌ $label: branch '$branch' does NOT exist on '$r' (push needed) → make push"
      failures=$((failures+1))
    else
      echo "  ✓ $r reachable, branch '$branch' present"
    fi
  done
}

# --- Parent repo first ---
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Not inside a git repo"; exit 1; }
check_repo "$ROOT" "$(basename "$ROOT")"

# --- Then every declared submodule ---
mapfile -t SUBS < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | cut -d' ' -f2)
for sm in "${SUBS[@]:-}"; do
  [ -n "$sm" ] || continue
  [ -e "$sm/.git" ] || { echo "━━━ $sm ━━━"; echo "❌ $sm: not initialized (run 'make submodule-init')"; failures=$((failures+1)); continue; }
  check_repo "$sm" "$sm"
done

if [ "$failures" -ne 0 ]; then
  echo "🔴 check-remotes finished with $failures failure(s)."
  exit 1
fi
echo "✅ Parent repo and all submodules have working github+gitlab remotes."

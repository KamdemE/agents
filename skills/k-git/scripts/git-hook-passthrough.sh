#!/bin/sh
# ============================================================================
# KπX global git hook pass-through — GENERIC (any hook type via $0)
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/skills/k-git/scripts/git-hook-passthrough.sh
# Deployed as     : symlinks named after each hook type in
#                   $HOME/.config/git/hooks/ (commit-msg, pre-push, ...)
# Activated by    : git config --global core.hooksPath "$HOME/.config/git/hooks"
#
# WHY: `core.hooksPath` makes git ignore repo-local hooks of ALL types. This
# pass-through guarantees repo-local hooks still run — nothing regresses.
#
# The script reads its OWN name ($0) to know which repo-local hook to chain:
# one asset, N symlinks.
#
# ⚠️ RESOLUTION NOTE (fixed 2026-08-24): `git rev-parse --git-path hooks`
# CANNOT be used here — once `core.hooksPath` is set it returns the GLOBAL
# hooks dir (= $0 itself), so the recursion guard would skip every repo-local
# hook. We resolve the repo's own .git dir instead (`$GIT_DIR`, exported by
# git when running hooks, else `rev-parse --absolute-git-dir`) and append
# `/hooks/<name>`.
#
# ORDERING (KπX directive 2026-08-24): the GLOBAL gates run BEFORE the
# repo-local hooks (fail fast — never burn an expensive local `make check`
# on a commit that must be blocked anyway).
#
# ADDED BEHAVIOR (2026-08-24, KπX directive):
#   • pre-commit — Submodule hygiene gate: blocks if ANY submodule has
#     uncommitted changes OR unpushed commits.
#   • pre-push — Submodule push gate: blocks if ANY submodule HEAD is not
#     present on EVERY of its remotes (live `git ls-remote` check, no stale
#     tracking refs).
#
# ADDED BEHAVIOR (2026-08-25, KπX directive — generalized from a per-project
# pattern found in a mature pipeline project; repos NEVER set their own
# `core.hooksPath` anymore, these two gates now apply to every repo globally):
#   • pre-commit — `make check` gate: if the repo has a Makefile with a
#     `check:` target, runs it and blocks the commit on failure. Runs AFTER
#     the (cheap) submodule gate, BEFORE any repo-local hook (fail fast).
#   • commit-msg — AI-attribution trailer strip: removes any commit message
#     line starting with `co-authored-by:`, `signed-off-by:`, or `author:`
#     (case-insensitive) before the repo-local hook (if any) sees it.
#
# 🔴🔴🔴 NO BYPASS, NO OVERRIDE VARIABLES (KπX directive 2026-08-25) — GRAVÉ
# There is deliberately NO environment variable to skip ANY gate here
# (no KPIHX_ALLOW_* / KPIHX_SKIP_* / KPIHX_KEEP_*). If a gate blocks you,
# FIX THE UNDERLYING STATE — never bypass the check. The checks ARE the code.
# ============================================================================
hook="$(basename "$0")"
gd="${GIT_DIR:-$(git rev-parse --absolute-git-dir 2>/dev/null)}"
[ -n "$gd" ] || exit 0
case "$gd" in /*) ;; *) gd="$(pwd)/$gd" ;; esac
repo_hook="$gd/hooks/$hook"

is_local_hook() {
  [ -n "$repo_hook" ] && [ -x "$repo_hook" ] \
    && [ "$(readlink -f "$repo_hook" 2>/dev/null)" != "$(readlink -f "$0" 2>/dev/null)" ]
}

sm_paths() {
  git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | cut -d' ' -f2
}

# --- GLOBAL GATE 1: pre-commit submodule hygiene ----------------------------
# Unpushed is measured against the KPIX-owned PUSH remotes (github/gitlab) —
# NOT @{upstream}, which points at read-only upstreams (Flickwire/IgorWarzocha).
submodule_dirty_report() {
  report=""
  for p in $(sm_paths); do
    [ -e "$p/.git" ] || continue
    st="$(git -C "$p" status --porcelain | sed 's/^/      /')"
    branch="$(git -C "$p" rev-parse --abbrev-ref HEAD)"
    sha="$(git -C "$p" rev-parse HEAD)"
    on_a_remote=0
    for r in github gitlab; do
      git -C "$p" rev-parse --verify -q "$r/$branch" >/dev/null || continue
      if git -C "$p" merge-base --is-ancestor "$sha" "$r/$branch"; then
        on_a_remote=1
        break
      fi
    done
    if [ -n "$st" ] || [ "$on_a_remote" != "1" ]; then
      report="$report
  🔴 $p (committed work present on no kpihx mirror: $sha)"
      [ -n "$st" ] && report="$report
$st"
    fi
  done
}

# --- GLOBAL GATE 2: pre-push — every submodule pushed to ALL its PUSH remotes
# (KPIX-owned mirrors only — NOT read-only upstreams like Flickwire/IgorWarzocha)
submodule_push_report() {
  report=""
  for p in $(sm_paths); do
    [ -e "$p/.git" ] || continue
    branch="$(git -C "$p" rev-parse --abbrev-ref HEAD)"
    sha="$(git -C "$p" rev-parse HEAD)"
    [ -n "$branch" ] && [ -n "$sha" ] || { report="$report
  🔴 $p (cannot resolve HEAD/branch)"; continue; }
    remotes=""
    for r in github gitlab; do
      git -C "$p" remote get-url "$r" >/dev/null 2>&1 && remotes="$remotes $r"
    done
    if [ -z "$remotes" ]; then
      report="$report
  🔴 $p (none of the kpihx push remotes github/gitlab configured)"
      continue
    fi
    for r in $remotes; do
      remote_out="$(git -C "$p" ls-remote "$r" "refs/heads/$branch" 2>&1)"
      remote_sha="$(printf '%s' "$remote_out" | cut -f1)"
      if [ -z "$remote_sha" ]; then
        report="$report
  🔴 $p — branch '$branch' NOT found or unreachable on '$r'
        cause: $(printf '%s' "$remote_out" | head -2 | tr '\n' ' ')"
      elif [ "$remote_sha" != "$sha" ]; then
        report="$report
  🔴 $p — HEAD $sha not on '$r/$branch' (remote has $remote_sha) → push/reconcile"
      fi
    done
  done
}

# --- GLOBAL GATE 3: pre-commit — `make check` (generalized 2026-08-25) -----
# Returns 0 (nothing to block on) when there's no Makefile / no check target;
# otherwise runs it live (no output capture) and returns its exit status.
run_make_check() {
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 0
  mk="$root/Makefile"
  [ -f "$mk" ] || return 0
  grep -qE '^check:' "$mk" || return 0
  echo "🔍 Running 'make check' (global pre-commit gate)..." >&2
  make -C "$root" check
}

case "$hook" in
  pre-commit)
    # GLOBAL FIRST (KπX): block before running any local hook.
    if [ -f .gitmodules ]; then
      submodule_dirty_report
      if [ -n "$report" ]; then
        echo "🔴 COMMIT BLOCKED — dirty/unpushed submodules detected:$report" >&2
        echo "   Fix each one first: cd <submodule> && git add -A && git commit && make push-sub" >&2
        exit 1
      fi
    fi
    if ! run_make_check; then
      echo "🔴 COMMIT BLOCKED — 'make check' failed. Fix the issues above." >&2
      exit 1
    fi
    ;;
  commit-msg)
    # GLOBAL FIRST (KπX): strip AI-agent attribution trailers before the
    # repo-local hook (if any) sees the message. $1 = path to the message file.
    if [ -n "${1:-}" ] && [ -f "$1" ]; then
      tmp="$(mktemp)"
      grep -viE '^(co-authored-by|signed-off-by|author):' "$1" > "$tmp" && mv "$tmp" "$1"
    fi
    ;;
  pre-push)
    # GLOBAL FIRST (KπX): every submodule must be on ALL its remotes.
    if [ -f .gitmodules ]; then
      submodule_push_report
      if [ -n "$report" ]; then
        echo "🔴 PUSH BLOCKED — submodule(s) not pushed to all their remotes:$report" >&2
        echo "   Fix: make push-sub" >&2
        exit 1
      fi
    fi
    ;;
esac

# Repo-local hook ALWAYS runs after the global gate passes.
if is_local_hook; then
  exec "$repo_hook" "$@"
fi

exit 0

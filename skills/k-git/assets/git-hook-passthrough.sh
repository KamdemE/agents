#!/bin/sh
# ============================================================================
# KπX global git hook pass-through — GENERIC (any hook type via $0)
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/skills/k-git/assets/git-hook-passthrough.sh
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
#     uncommitted changes OR unpushed commits. Override (déconseillé):
#     KPIHX_ALLOW_DIRTY_SUBMODULES=1.
#   • pre-push — Submodule push gate: blocks if ANY submodule HEAD is not
#     present on EVERY of its remotes (live `git ls-remote` check, no stale
#     tracking refs). Override (déconseillé): KPIHX_ALLOW_UNPUSHED_SUBMODULES=1.
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
  # githooks(5): a hook that runs git in a foreign repo (here: each submodule)
  # must clear the GIT_DIR/GIT_WORK_TREE/... git exports for hook processes,
  # or `git -C <submodule>` inherits them and can hit
  # "fatal: .git/index: index file open failed: Not a directory" (the
  # submodule's own .git is a FILE, not a dir — see k-git/references/insights.md).
  # shellcheck disable=SC2046 # word-splitting is the point: unset each var name
  unset $(git rev-parse --local-env-vars) 2>/dev/null
  for p in $(sm_paths); do
    [ -e "$p/.git" ] || continue
    st="$(git -C "$p" status --porcelain | sed 's/^/      /')"
    branch="$(git -C "$p" rev-parse --abbrev-ref HEAD)"
    sha="$(git -C "$p" rev-parse HEAD)"
    on_a_remote=0
    for r in ${KPIHX_SUB_PUSH_REMOTES:-github gitlab}; do
      git -C "$p" rev-parse --verify -q "$r/$branch" >/dev/null || continue
      if git -C "$p" merge-base --is-ancestor "$sha" "$r/$branch"; then
        on_a_remote=1
        break
      fi
    done
    if [ -n "$st" ] || [ "$on_a_remote" != "1" ]; then
      report="$report
  🔴 $p (committed work present on no kpix mirror: $sha)"
      [ -n "$st" ] && report="$report
$st"
    fi
  done
}

# --- GLOBAL GATE 2: pre-push — every submodule pushed to ALL its PUSH remotes
# (KPIX-owned mirrors only — NOT read-only upstreams like Flickwire/IgorWarzocha)
submodule_push_report() {
  report=""
  # githooks(5): clear the git-exported env before running git in a foreign
  # repo (each submodule) — see the matching comment in submodule_dirty_report.
  # shellcheck disable=SC2046 # word-splitting is the point: unset each var name
  unset $(git rev-parse --local-env-vars) 2>/dev/null
  for p in $(sm_paths); do
    [ -e "$p/.git" ] || continue
    branch="$(git -C "$p" rev-parse --abbrev-ref HEAD)"
    sha="$(git -C "$p" rev-parse HEAD)"
    [ -n "$branch" ] && [ -n "$sha" ] || { report="$report
  🔴 $p (cannot resolve HEAD/branch)"; continue; }
    remotes=""
    for r in ${KPIHX_SUB_PUSH_REMOTES:-github gitlab}; do
      git -C "$p" remote get-url "$r" >/dev/null 2>&1 && remotes="$remotes $r"
    done
    if [ -z "$remotes" ]; then
      report="$report
  🔴 $p (none of the kpix push remotes configured)"
      continue
    fi
    for r in $remotes; do
      remote_out="$(git -C "$p" ls-remote "$r" "refs/heads/$branch" 2>&1)" && ls_rc=0 || ls_rc=$?
      # stderr (server banners like GitLab's "INFO: Your SSH key expires soon")
      # is merged into remote_out on purpose for diagnostics — so extract ONLY
      # real ref lines (<40-hex><TAB><ref>) for comparison; raw cut -f1 turned
      # multi-line banners into bogus SHAs → false-positive mismatches
      # (2026-08-26: 3 submodules blocked despite being pushed).
      remote_sha="$(printf '%s\n' "$remote_out" | awk -F'\t' 'length($1)==40 && $1 !~ /[^0-9a-f]/ { print $1; exit }')"
      if [ "$ls_rc" != "0" ] && [ -z "$remote_sha" ]; then
        report="$report
  🔴 $p — '$r' UNREACHABLE (ls-remote failed)
        cause: $(printf '%s\n' "$remote_out" | head -2 | tr '\n' ' ')"
      elif [ -z "$remote_sha" ]; then
        report="$report
  🔴 $p — branch '$branch' NOT found on '$r' → push it"
      elif [ "$remote_sha" != "$sha" ]; then
        report="$report
  🔴 $p — HEAD $sha not on '$r/$branch' (remote has $remote_sha) → push/reconcile"
      fi
    done
  done
}

case "$hook" in
  pre-commit)
    # GLOBAL FIRST (KπX): block before running any local hook.
    if [ "${KPIHX_ALLOW_DIRTY_SUBMODULES:-0}" != "1" ] && [ -f .gitmodules ]; then
      submodule_dirty_report
      if [ -n "$report" ]; then
        echo "🔴 COMMIT BLOCKED — dirty/unpushed submodules detected:$report" >&2
        echo "   Fix each one first: cd <submodule> && git add -A && git commit && git push" >&2
        echo "   Override (déconseillé): KPIHX_ALLOW_DIRTY_SUBMODULES=1 git commit ..." >&2
        exit 1
      fi
    fi
    ;;
  pre-push)
    # GLOBAL FIRST (KπX): every submodule must be on ALL its remotes.
    if [ "${KPIHX_ALLOW_UNPUSHED_SUBMODULES:-0}" != "1" ] && [ -f .gitmodules ]; then
      submodule_push_report
      if [ -n "$report" ]; then
        echo "🔴 PUSH BLOCKED — submodule(s) not pushed to all their remotes:$report" >&2
        echo "   Fix (if this repo has the target): make push-sub" >&2
        echo "   Else, manually: cd <submodule> && git push <remote> <branch> (for EACH listed remote)" >&2
        echo "   Override (déconseillé): KPIHX_ALLOW_UNPUSHED_SUBMODULES=1 git push ..." >&2
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

#!/bin/sh
# ============================================================================
# KπX global git hook pass-through — GENERIC (any hook type via $0)
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/skills/k-loom/assets/git-hook-passthrough.sh
# Deployed as     : symlinks named after each hook type in
#                   $HOME/.config/git/hooks/ (commit-msg, pre-push, ...)
# Activated by    : git config --global core.hooksPath "$HOME/.config/git/hooks"
#
# WHY: `core.hooksPath` makes git ignore repo-local hooks of ALL types. The
# KπX global layer only ADDS behavior on post-commit (Loom sync). For every
# OTHER hook type this pass-through re-chains the repo-local hook so nothing
# regresses — zero added behavior, semantics fully preserved (including exit
# codes and arguments).
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
# ============================================================================
hook="$(basename "$0")"
gd="${GIT_DIR:-$(git rev-parse --absolute-git-dir 2>/dev/null)}"
[ -n "$gd" ] || exit 0
case "$gd" in /*) ;; *) gd="$(pwd)/$gd" ;; esac
repo_hook="$gd/hooks/$hook"

if [ -n "$repo_hook" ] && [ -x "$repo_hook" ] \
   && [ "$(readlink -f "$repo_hook" 2>/dev/null)" != "$(readlink -f "$0" 2>/dev/null)" ]; then
  exec "$repo_hook" "$@"
fi

exit 0

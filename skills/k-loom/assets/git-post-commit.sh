#!/bin/sh
# ============================================================================
# KπX global git post-commit dispatcher
# ----------------------------------------------------------------------------
# Source of truth : $HOME/.agents/skills/k-loom/assets/git-post-commit.sh
# Deployed as     : $HOME/.config/git/hooks/post-commit (symlink)
# Activated by    : git config --global core.hooksPath "$HOME/.config/git/hooks"
#
# WHY A DISPATCHER (and not a plain hook): `core.hooksPath` makes git IGNORE
# repo-local hooks entirely. Many KπX repos carry their own post-commit hooks
# (.agents kernel repo, k-qmd collections repos, loom-installed repos). This
# dispatcher re-chains them so NOTHING regresses, then adds the global Loom
# layer on top of every commit.
#
# Chain:
#   1. Run the repo-local post-commit hook if one exists and is executable
#      (skipped if it resolves to THIS file — recursion guard).
#   2. `loom sync` in background if a Loom index exists for this project
#      (~/.loom/projects/<dirname>.db) — incremental, ~2-5s.
#   3. OPTIONAL: auto-index brand-new repos with `loom analyze .` — SLOW
#      (10-60s), armed ONLY by exporting LOOM_AUTO_ANALYZE=1 in the
#      environment. Off by default.
#
# All diagnostics are silent (hooks must never spam commit output); failures
# never block a commit (exit 0 always).
#
# ⚠️ RESOLUTION NOTE (fixed 2026-08-24): `git rev-parse --git-path hooks`
# CANNOT be used here — once `core.hooksPath` is set it returns the GLOBAL
# hooks dir (= $0 itself), so the recursion guard would skip every repo-local
# hook. We resolve the repo's own .git dir instead (`$GIT_DIR`, exported by
# git when running hooks, else `rev-parse --absolute-git-dir`) and append
# `/hooks/post-commit`.
# ============================================================================
hook_name="post-commit"
gd="${GIT_DIR:-$(git rev-parse --absolute-git-dir 2>/dev/null)}"
repo_hook=""
if [ -n "$gd" ]; then
  case "$gd" in /*) ;; *) gd="$(pwd)/$gd" ;; esac
  repo_hook="$gd/hooks/$hook_name"
fi

# 1. Repo-local post-commit chain-in (recursion guard via readlink -f)
if [ -n "$repo_hook" ] && [ -x "$repo_hook" ] \
   && [ "$(readlink -f "$repo_hook" 2>/dev/null)" != "$(readlink -f "$0" 2>/dev/null)" ]; then
  "$repo_hook" "$@" >/dev/null 2>&1 || true
fi

command -v loom >/dev/null 2>&1 || exit 0

db="$HOME/.loom/projects/$(basename "$(pwd)").db"
if [ -f "$db" ]; then
  # 2. Index exists → cheap incremental sync (backgrounded, never blocks)
  (cd "$(pwd)" && loom sync >/dev/null 2>&1 &) &
elif [ "${LOOM_AUTO_ANALYZE:-0}" = "1" ]; then
  # 3. Opt-in full index of an unindexed repo (slow — armed explicitly)
  (cd "$(pwd)" && loom analyze . >/dev/null 2>&1 &) &
fi

exit 0

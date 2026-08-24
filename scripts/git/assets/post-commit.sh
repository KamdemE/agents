#!/bin/sh
# KπX post-commit hook — tracked source of truth.
# Symlink target for .git/hooks/post-commit.
# Install: scripts/git/install-hooks.sh.

UPDATER="$HOME/.agents/skills/k-qmd/scripts/update_collections.sh"

if [ ! -f "$UPDATER" ]; then
  echo "--- [QMD Hook] Updater script not found: $UPDATER"
  exit 1
fi

if ! bash "$UPDATER" "agents" "*"; then
  echo "--- [QMD Hook] Collection update failed."
  exit 1
fi

exit 0

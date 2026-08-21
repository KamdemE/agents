#!/bin/sh
# KπX post-commit hook — tracked source of truth.
# Symlink target for .git/hooks/post-commit.
# Install: scripts/git/install-hooks.sh

UPDATER="$HOME/.agents/skills/k-qmd/scripts/update_collections.sh"

if [ -f "$UPDATER" ]; then
    bash "$UPDATER" "agents" "*"
else
    echo "--- [QMD Hook] Updater script not found: $UPDATER"
fi

exit 0

#!/bin/bash
# KπX git hooks installer for the .agents repo.
# Symlinks all hooks from scripts/git/assets/ into .git/hooks/.
#
# Usage:
#   scripts/git/install-hooks.sh              # install all hooks
#   scripts/git/install-hooks.sh --check      # check which hooks would change
#   scripts/git/install-hooks.sh --force      # overwrite existing non-symlink hooks

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ASSETS_DIR="$REPO_ROOT/scripts/git/assets"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
MODE="${1:-install}"  # install | check | force

if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ No .git/hooks directory found at $HOOKS_DIR"
    echo "   Are you running from inside a git repo?"
    exit 1
fi

if [ ! -d "$ASSETS_DIR" ]; then
    echo "❌ No asset hooks found at $ASSETS_DIR"
    exit 1
fi

installed=0
skipped=0
failed=0

for asset in "$ASSETS_DIR"/*.sh; do
    hook_name="$(basename "$asset")"
    hook_name="${hook_name%.sh}"  # post-commit.sh → post-commit
    target="$HOOKS_DIR/$hook_name"

    if [ -L "$target" ]; then
        current="$(readlink "$target")"
        if [ "$current" = "$asset" ]; then
            echo "  ✓ $hook_name already linked correctly"
            skipped=$((skipped + 1))
            continue
        else
            echo "  ~ $hook_name relinking: $current → $asset"
            ln -sfn "$asset" "$target"
            installed=$((installed + 1))
        fi
    elif [ -f "$target" ] && [ ! -L "$target" ]; then
        if [ "$MODE" = "check" ]; then
            echo "  ⚠ $hook_name exists as regular file (would overwrite)"
            skipped=$((skipped + 1))
            continue
        elif [ "$MODE" = "force" ]; then
            echo "  ! $hook_name backing up and replacing"
            cp "$target" "${target}.bak"
            ln -sfn "$asset" "$target"
            installed=$((installed + 1))
        else
            echo "  ⚠ $hook_name exists as regular file (use --force to overwrite)"
            skipped=$((skipped + 1))
            continue
        fi
    else
        echo "  + $hook_name installing"
        ln -sfn "$asset" "$target"
        installed=$((installed + 1))
    fi
done

echo ""
echo "--- Summary: $installed installed, $skipped skipped, $failed failed ---"

if [ "$MODE" = "check" ]; then
    echo ""
    echo "Assets available:"
    for asset in "$ASSETS_DIR"/*.sh; do
        echo "  - $(basename "$asset")"
    done
fi

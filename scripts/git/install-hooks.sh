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
case "${1:-install}" in
    install) MODE="install" ;;
    --check|check) MODE="check" ;;
    --force|force) MODE="force" ;;
    *) echo "❌ Usage: $0 [--check|--force]"; exit 2 ;;
esac

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
would_change=0

link_hook() {
    local asset="$1" target="$2" hook_name="$3"
    if ln -sfn "$asset" "$target"; then
        installed=$((installed + 1))
    else
        echo "  ✗ $hook_name could not be linked"
        failed=$((failed + 1))
    fi
}

for asset in "$ASSETS_DIR"/*.sh; do
    hook_name="$(basename "$asset")"
    hook_name="${hook_name%.sh}"  # post-commit.sh → post-commit
    target="$HOOKS_DIR/$hook_name"

    asset_resolved="$(readlink -f "$asset")"
    if [ "$MODE" = "check" ]; then
        if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$asset_resolved" ]; then
            echo "  ✓ $hook_name already linked correctly"
        elif [ -e "$target" ] || [ -L "$target" ]; then
            echo "  ~ $hook_name would be replaced with $asset"
            would_change=$((would_change + 1))
        else
            echo "  + $hook_name would be installed"
            would_change=$((would_change + 1))
        fi
        continue
    fi

    if [ -L "$target" ]; then
        current="$(readlink "$target")"
        if [ "$(readlink -f "$target")" = "$asset_resolved" ]; then
            echo "  ✓ $hook_name already linked correctly"
            skipped=$((skipped + 1))
            continue
        else
            echo "  ~ $hook_name relinking: $current → $asset"
            link_hook "$asset" "$target" "$hook_name"
        fi
    elif [ -f "$target" ] && [ ! -L "$target" ]; then
        if [ "$MODE" = "force" ]; then
            backup="$(mktemp "/tmp/${hook_name}.XXXXXX.bak")"
            echo "  ! $hook_name backing up to $backup and replacing"
            if ! cp "$target" "$backup"; then
                echo "  ✗ $hook_name backup failed"
                failed=$((failed + 1))
                continue
            fi
            link_hook "$asset" "$target" "$hook_name"
        else
            echo "  ⚠ $hook_name exists as regular file (use --force to overwrite)"
            skipped=$((skipped + 1))
            continue
        fi
    else
        echo "  + $hook_name installing"
        link_hook "$asset" "$target" "$hook_name"
    fi
done

echo ""
echo "--- Summary: $installed installed, $skipped skipped, $would_change would change, $failed failed ---"

if [ "$MODE" = "check" ]; then
    echo ""
    echo "Assets available:"
    for asset in "$ASSETS_DIR"/*.sh; do
        echo "  - $(basename "$asset")"
    done
fi

[ "$failed" -eq 0 ]

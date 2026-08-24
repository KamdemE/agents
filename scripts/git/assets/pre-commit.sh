#!/bin/bash
# KπX pre-commit hook — tracked source of truth.
# Runs make check before every commit.
# Install: scripts/git/install-hooks.sh

echo "🔍 Running pre-commit check..."
REPO_ROOT="$(git rev-parse --show-toplevel)" || {
    echo "❌ Cannot resolve the Git repository root."
    exit 1
}
if ! make -C "$REPO_ROOT" check; then
    echo "❌ Validation failed. Please fix issues before committing."
    exit 1
fi
echo "✅ Validation passed. Proceeding with commit."
exit 0

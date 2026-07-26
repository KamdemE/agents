#!/bin/bash
# KπX pre-commit hook — tracked source of truth.
# Runs make check before every commit.
# Install: scripts/git/install-hooks.sh

echo "🔍 Running pre-commit check..."
make -C "$(dirname "$0")/../../.." check 2>/dev/null || make -C "$HOME/.agents" check
STATUS=$?
if [ $STATUS -ne 0 ]; then
    echo "❌ Validation failed. Please fix issues before committing."
    exit $STATUS
fi
echo "✅ Validation passed. Proceeding with commit."
exit 0

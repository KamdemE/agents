#!/bin/bash
# KπX pre-commit hook — tracked source of truth.
# Runs make audit before every commit.
# Install: scripts/git/install-hooks.sh

echo "🔍 Running pre-commit audit..."
make -C "$(dirname "$0")/../../.." audit 2>/dev/null || make -C "$HOME/.agents" audit
STATUS=$?
if [ $STATUS -ne 0 ]; then
    echo "❌ Audit failed. Please fix governance drift before committing."
    exit $STATUS
fi
echo "✅ Audit passed. Proceeding with commit."
exit 0

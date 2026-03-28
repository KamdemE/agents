#!/bin/sh
# QMD post-commit hook template
# ─────────────────────────────────────────────────────────────────────────────
# Usage: copy to <repo>/.git/hooks/post-commit and set COLLECTION + PATTERN.
#
# Install:
#   cp ~/.agents/skills/qmd/references/post-commit-hook.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
# ─────────────────────────────────────────────────────────────────────────────

# ── Configure these for each repo ────────────────────────────────────────────
COLLECTION="agents"                  # qmd collection name for this repo
PATTERN="\.(md|yml|yaml|json|sh)$"  # file extensions that trigger re-embed
QMD="${QMD:-$HOME/.npm-global/bin/qmd}"  # full path (bun version may be broken)
# ─────────────────────────────────────────────────────────────────────────────

echo "--- [QMD Hook] Running post-commit checks ---"

# 1. Skip silently if qmd is not installed
if ! command -v "$QMD" > /dev/null 2>&1 && ! command -v qmd > /dev/null 2>&1; then
    echo "--- [QMD Hook] 'qmd' not found. Skipping update."
    exit 0
fi

# Prefer explicit path, fallback to PATH
QMD_BIN="$QMD"
if ! command -v "$QMD_BIN" > /dev/null 2>&1; then
    QMD_BIN="qmd"
fi

# 2. Check if relevant files were modified in this commit
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE "$PATTERN"; then
    echo "--- [QMD Hook] Relevant files modified. Updating QMD index..."
    "$QMD_BIN" update "$COLLECTION" && "$QMD_BIN" embed "$COLLECTION"
    echo "--- [QMD Hook] QMD index update complete."
else
    echo "--- [QMD Hook] No relevant files modified. Skipping."
fi

exit 0

#!/bin/sh
# QMD post-commit hook template
# ─────────────────────────────────────────────────────────────────────────────
# Usage: copy to <repo>/.git/hooks/post-commit and set COLLECTION + PATTERN.
#
# Install:
#   cp $HOME/.agents/skills/k-qmd/references/post-commit-hook.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
# ─────────────────────────────────────────────────────────────────────────────

# ── Configure these for each repo ────────────────────────────────────────────
COLLECTION="agents"                  # qmd collection name for this repo
PATTERN="\.(md|yml|yaml|json|sh)$"  # file extensions that trigger refresh
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
EMBED_LOG="${TMPDIR:-/tmp}/qmd-embed-${COLLECTION}.log"

# 2. Check if relevant files were modified in this commit
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE "$PATTERN"; then
    echo "--- [QMD Hook] Relevant files modified. Updating QMD index..."
    if "$QMD_BIN" update "$COLLECTION"; then
        if pgrep -af "qmd(.js)? embed ${COLLECTION}" > /dev/null 2>&1; then
            echo "--- [QMD Hook] Embed already running. Skipping duplicate background embed."
        else
            nohup "$QMD_BIN" embed "$COLLECTION" > "$EMBED_LOG" 2>&1 &
            echo "--- [QMD Hook] Background embed started. Log: $EMBED_LOG"
        fi
        echo "--- [QMD Hook] QMD index update complete."
    fi
else
    echo "--- [QMD Hook] No relevant files modified. Skipping."
fi

exit 0

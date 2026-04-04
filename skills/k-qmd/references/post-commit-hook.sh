#!/bin/sh
# QMD post-commit hook template
# ─────────────────────────────────────────────────────────────────────────────
# Usage: symlink or copy to <repo>/.git/hooks/post-commit.
# If COLLECTION is unset, the hook derives it from the git repo root name.
#
# Install:
#   cp $HOME/.agents/skills/k-qmd/references/post-commit-hook.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
# ─────────────────────────────────────────────────────────────────────────────

# ── Configure these for each repo ────────────────────────────────────────────
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"
COLLECTION="${COLLECTION:-$REPO_NAME}"    # qmd collection name for this repo
PATTERN="${PATTERN:-\.(md|yml|yaml|toml)$}" # file extensions that trigger refresh
QMD="${QMD:-$HOME/.npm-global/bin/qmd}"   # full path (bun version may be broken)
EMBED_MODE="${EMBED_MODE:-update-only}"   # update-only | debounced
EMBED_DEBOUNCE_SECONDS="${EMBED_DEBOUNCE_SECONDS:-1800}"
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
STAMP_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/qmd-hooks"
STAMP_FILE="${STAMP_DIR}/${COLLECTION}.embed.stamp"

# 1b. Skip safely when this repo does not map to an active QMD collection
if ! "$QMD_BIN" collection show "$COLLECTION" > /dev/null 2>&1; then
    echo "--- [QMD Hook] Collection '$COLLECTION' not found. Skipping."
    exit 0
fi

# 2. Check if relevant files were modified in this commit
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE "$PATTERN"; then
    echo "--- [QMD Hook] Relevant files modified. Updating QMD index..."
    if "$QMD_BIN" update "$COLLECTION"; then
        case "$EMBED_MODE" in
            update-only)
                echo "--- [QMD Hook] Update-only mode. Skipping embed."
                ;;
            debounced)
                mkdir -p "$STAMP_DIR"
                now="$(date +%s)"
                last_run="0"
                if [ -f "$STAMP_FILE" ]; then
                    last_run="$(cat "$STAMP_FILE" 2>/dev/null || echo 0)"
                fi
                age="$((now - last_run))"
                if pgrep -af "qmd(.js)? embed ${COLLECTION}" > /dev/null 2>&1; then
                    echo "--- [QMD Hook] Embed already running. Skipping duplicate background embed."
                elif [ "$age" -lt "$EMBED_DEBOUNCE_SECONDS" ]; then
                    echo "--- [QMD Hook] Embed debounce active (${age}s < ${EMBED_DEBOUNCE_SECONDS}s). Skipping."
                else
                    echo "$now" > "$STAMP_FILE"
                    nohup "$QMD_BIN" embed "$COLLECTION" > "$EMBED_LOG" 2>&1 &
                    echo "--- [QMD Hook] Background embed started. Log: $EMBED_LOG"
                fi
                ;;
            *)
                echo "--- [QMD Hook] Unknown EMBED_MODE='$EMBED_MODE'. Expected update-only or debounced."
                exit 1
                ;;
        esac
        echo "--- [QMD Hook] QMD index update complete."
    fi
else
    echo "--- [QMD Hook] No relevant files modified. Skipping."
fi

exit 0

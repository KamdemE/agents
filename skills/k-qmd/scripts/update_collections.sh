#!/usr/bin/env bash
# update_collections.sh — simplified QMD updater for git post-commit hook.
#
# Usage:
#   update_collections.sh [collections] [extensions]
#
# Examples:
#   update_collections.sh "agents,presentation" "md,yml"
#   update_collections.sh "*" "*"

set -euo pipefail

# 1. Locate QMD
QMD_BIN="${QMD_BIN:-$HOME/.npm-global/bin/qmd}"
if ! command -v "$QMD_BIN" >/dev/null 2>&1; then
    QMD_BIN="$(command -v qmd 2>/dev/null || true)"
fi

if [[ -z "${QMD_BIN:-}" ]] || ! command -v "$QMD_BIN" >/dev/null 2>&1; then
    exit 0 # QMD not installed, skip silently
fi

# 2. Parse arguments
COLLECTIONS_INPUT="${1:-*}"
EXTENSIONS_INPUT="${2:-*}"
INDEX_YML="${QMD_INDEX_YML:-$HOME/.config/qmd/index.yml}"

# Default extensions pattern if '*' or empty
if [[ "$EXTENSIONS_INPUT" == "*" || -z "$EXTENSIONS_INPUT" ]]; then
    PATTERN="\.(md|yml|yaml|json|sh)$"
else
    # Convert comma-separated extensions (e.g. "md,yml") to regex (e.g. "\.(md|yml)$")
    regex_parts="${EXTENSIONS_INPUT//,/|}"
    PATTERN="\.(${regex_parts})$"
fi

# Resolve target collections
declare -a TARGET_COLLECTIONS=()

if [[ "$COLLECTIONS_INPUT" == "*" || "$COLLECTIONS_INPUT" == "[*]" ]]; then
    if [[ -f "$INDEX_YML" ]]; then
        in_collections=0
        while IFS= read -r line; do
            if [[ "$line" =~ ^collections:[[:space:]]*$ ]]; then
                in_collections=1
                continue
            elif [[ "$line" =~ ^[a-zA-Z0-9_-]+:[[:space:]]*$ ]]; then
                in_collections=0
            fi
            
            if [[ "$in_collections" -eq 1 ]]; then
                if [[ "$line" =~ ^[[:space:]]{2}([a-zA-Z0-9_-]+):[[:space:]]*$ ]]; then
                    TARGET_COLLECTIONS+=("${BASH_REMATCH[1]}")
                fi
            fi
        done < "$INDEX_YML"
    fi
else
    IFS=',' read -r -a TARGET_COLLECTIONS <<< "${COLLECTIONS_INPUT// /}"
fi

if [[ ${#TARGET_COLLECTIONS[@]} -eq 0 ]]; then
    exit 0
fi

# 3. Check modified files in the last commit
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

MODIFIED_FILES="$(git diff --name-only HEAD~1 HEAD 2>/dev/null || true)"
if [[ -z "$MODIFIED_FILES" ]]; then
    exit 0
fi

MATCHING_FILES="$(echo "$MODIFIED_FILES" | grep -E "$PATTERN" || true)"
if [[ -z "$MATCHING_FILES" ]]; then
    exit 0
fi

# 4. Run update and background embed
for col in "${TARGET_COLLECTIONS[@]}"; do
    echo "Updating QMD collection: $col..."
    if "$QMD_BIN" update "$col"; then
        EMBED_LOG="${TMPDIR:-/tmp}/qmd-embed-${col}.log"
        if pgrep -af "qmd(.js)? embed ${col}" > /dev/null 2>&1; then
            echo "--- Embed already running for '$col'. Skipping. ---"
        else
            nohup "$QMD_BIN" embed "$col" > "$EMBED_LOG" 2>&1 &
            echo "--- Background embed started for '$col'. ---"
        fi
    fi
done

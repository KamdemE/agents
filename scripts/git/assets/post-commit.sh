#!/bin/sh
# KπX post-commit hook — tracked source of truth.
# Symlink target for .git/hooks/post-commit.
# Install: scripts/git/install-hooks.sh

COLLECTION="agents"
PATTERN="\.(md|yml|yaml|json|sh)$"
QMD="${QMD:-$HOME/.npm-global/bin/qmd}"

echo "--- [QMD Hook] Running post-commit checks ---"

if ! command -v "$QMD" > /dev/null 2>&1 && ! command -v qmd > /dev/null 2>&1; then
    echo "--- [QMD Hook] 'qmd' not found. Skipping update."
else
    QMD_BIN="$QMD"
    if ! command -v "$QMD_BIN" > /dev/null 2>&1; then QMD_BIN="qmd"; fi
    EMBED_LOG="${TMPDIR:-/tmp}/qmd-embed-${COLLECTION}.log"

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
fi

# --- [OpenCode Auto-Deploy] Restart on config/service/hook change ---
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -q "skills/k-opencode/assets/opencode-web.service"; then
    echo "--- [OpenCode Auto-Deploy] Service file changed: daemon-reload + restart ---"
    systemctl --user daemon-reload 2>/dev/null && systemctl --user try-restart opencode-web 2>/dev/null && \
        echo "--- [OpenCode Auto-Deploy] Done ---" || echo "--- [OpenCode Auto-Deploy] Skipped (not systemd or service not active) ---"
elif git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -q "skills/k-opencode/assets/opencode.jsonc"; then
    echo "--- [OpenCode Auto-Deploy] Config changed: restart opencode-web ---"
    systemctl --user try-restart opencode-web 2>/dev/null && \
        echo "--- [OpenCode Auto-Deploy] Done ---" || echo "--- [OpenCode Auto-Deploy] Skipped (not systemd or service not active) ---"
elif git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -q "skills/k-opencode/scripts/hooks/.*\.js"; then
    echo "--- [OpenCode Auto-Deploy] Plugin hooks changed: restart opencode-web ---"
    systemctl --user try-restart opencode-web 2>/dev/null && \
        echo "--- [OpenCode Auto-Deploy] Done ---" || echo "--- [OpenCode Auto-Deploy] Skipped (not systemd or service not active) ---"
fi

# --- [Skills Sync] Auto-link/copy new skills to agent runtimes ---
SYNC_TARGETS="
$HOME/.codex/skills
"
COPY_TARGETS="
$HOME/.openclaw/workspace/skills
"
echo "--- [Skills Sync] Syncing ~/.agents/skills/ → per-agent dirs ---"
for d in "$HOME/.agents/skills/"/*/; do
    name=$(basename "$d")
    for target_dir in $SYNC_TARGETS; do
        [ -n "$target_dir" ] && [ -d "$target_dir" ] && [ ! -e "$target_dir/$name" ] && \
            ln -sf "$d" "$target_dir/$name" && echo "  +$name (link) → $target_dir"
    done
    for target_dir in $COPY_TARGETS; do
        [ -n "$target_dir" ] && [ -d "$target_dir" ] && \
            rsync -a --delete "$d" "$target_dir/$name/" 2>/dev/null && echo "  ~$name (copy) → $target_dir"
    done
done
echo "--- [Skills Sync] Done. ---"

exit 0

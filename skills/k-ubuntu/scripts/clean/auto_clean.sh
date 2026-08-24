#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
# systemd services do NOT export $HOME by default → under `set -u` a bare
# `$HOME` reference below would abort, and as root $HOME=/root would miss the
# kernel. Set it explicitly to the agent user home (where .agents lives) before
# sourcing notifier.sh. ${HOME:-default} is safe under `set -u`.
export HOME="${HOME:-/home/kpihx}"
# systemd services with explicit `User=root` preset $HOME=/root, which misses
# the kernel (/root/.agents does not exist) — force the agent user home whenever
# .agents is not reachable from the current value.
[ -d "$HOME/.agents" ] || export HOME="/home/kpihx"
# shellcheck source=/home/kpihx/.agents/libs/notif/notifier.sh
source "$HOME/.agents/libs/notif/notifier.sh"
NOTIFY_TG_TOKEN="${TELEGRAM_UBUNTU_TOKEN:-}"
# auto_clean.sh — Automated weekly cleanup: run all modules, analyze, notify via Telegram.
# Runs as root via systemd (clean.service).
# Machine config hardcoded below. Secrets sourced from ~/.agents/.env.

set -euo pipefail

# ── Machine config (edit per machine) ─────────────────────────────────────────
USER_BACKUP="kpihx"
PC_NAME="KpihX-Ubuntu"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="/var/log/clean"
USER_HOME="/home/$USER_BACKUP"
export HOME="$USER_HOME" # Export for child scripts
mkdir -p "$LOG_DIR"

# du -x = one filesystem only — automatically skips mount points (rclone, bind mounts).
# EXCLUDE_DIRS catches large local dirs on the same fs that would distort the report.
EXCLUDE_DIRS=(".ollama" ".ollama-ipex")

_build_excludes() {
    local base="$USER_HOME"; local args=()
    for d in "${EXCLUDE_DIRS[@]:-}"; do args+=(--exclude="$base/$d"); done
    echo "${args[@]:-}"
}

echo "🚀 [$(date)] Starting Automated Weekly Cleanup (as Root) — HOME=$HOME"

# ── 1. Baseline measurements ──────────────────────────────────────────────────
INITIAL_SPACE_ROOT=$(df / | tail -1 | awk '{print $3}')
INITIAL_SPACE_HOME=$(du -s -x "$USER_HOME" "$(_build_excludes)" 2>/dev/null | awk '{print $1}' || echo 0)

# ── 2. Run Workspace Scan ────────────────────────────────────────────────
echo "--- Running workspace_scan.sh ---"
# Run as user (git commands require user context); stream verbose to stdout AND log
WORKSPACE_SCAN_LOG="$LOG_DIR/workspace_scan.log"
su - "$USER_BACKUP" -c "$SCRIPT_DIR/workspace_scan.sh -s" 2>&1 | tee "$WORKSPACE_SCAN_LOG" || true
WORKSPACE_SCAN_OUTPUT=$(awk '/Summary/{y=1} y' "$WORKSPACE_SCAN_LOG" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
if [ -z "$WORKSPACE_SCAN_OUTPUT" ]; then
    WORKSPACE_SCAN_OUTPUT=$(tail -n 10 "$WORKSPACE_SCAN_LOG" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
fi

# ── 3. Run all cleanup modules ────────────────────────────────────────────────
echo "--- Running clean_all.sh ---"
"$SCRIPT_DIR/clean_all.sh" -s --system -y

# ── 3b. Reporting tail is best-effort ──────────────────────────────────────────
# The cleanup modules above are the REAL work and must fail the oneshot service
# if they fail (set -e active above). From here on everything is REPORTING
# (governance audit, QMD check, df/du analysis, Telegram notification) — a
# non-zero from any of these (e.g. `grep -v` returning 1 on an empty log, or a
# df/du pipeline) must NOT mark the service as failed. So we disable errexit
# now, before the audit.
set +e

# ── 4. Governance Audit ────────────────────────────────────────────────────────
echo "--- Running .agents governance audit ---"
AUDIT_STATUS="✅ OK"
AUDIT_DETAILS=""
if ! su - "$USER_BACKUP" -c "make -C $USER_HOME/.agents check-skills" > "$LOG_DIR/audit.log" 2>&1; then
    AUDIT_STATUS="❌ FAILED"
    AUDIT_DETAILS=$(cat "$LOG_DIR/audit.log" | grep -v "make: ")
fi

# ── 4b. QMD collection health ───────────────────────────────────────────────────
echo "--- Running QMD collection health check ---"
QMD_STATUS="✅ OK"
QMD_DETAILS=""
QMD_LOG="$LOG_DIR/qmd_check.log"
if ! su - "$USER_BACKUP" -c "$USER_HOME/.agents/skills/k-qmd/scripts/check_collections.sh" > "$QMD_LOG" 2>&1; then
    QMD_STATUS="❌ ISSUES"
    QMD_DETAILS=$(cat "$QMD_LOG")
fi

# ── 5. Post-cleanup analysis ──────────────────────────────────────────────────
# The cleanup modules above already ran and succeeded (set -e would have aborted
# on a real failure). From here on it is best-effort REPORTING only — a failed
# df/du pipeline must not mark the whole oneshot service as `failed`. So we
# disable errexit for the reporting tail.
set +e
echo "--- Post-Cleanup Analysis ---"
FINAL_SPACE_ROOT=$(df / | tail -1 | awk '{print $3}')
FINAL_SPACE_HOME=$(du -s -x "$USER_HOME" "$(_build_excludes)" 2>/dev/null | awk '{print $1}' || echo 0)

DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}')
DISK_FREE=$(df -h / | tail -1 | awk '{print $4}')

TOP_HOME=$(du -h -x --max-depth=1 "$USER_HOME" "$(_build_excludes)" 2>/dev/null | sort -hr | head -n 6 | tail -n 5)

# Target known large dirs only — avoids full / scan and the RAM spike it causes
TOP_ROOT=$(du -xh -d 1 /var /usr /home /opt 2>/dev/null | sort -hr | head -n 6 | tail -n 5)

SAVED_KB=$(( (INITIAL_SPACE_ROOT - FINAL_SPACE_ROOT) + (INITIAL_SPACE_HOME - FINAL_SPACE_HOME) ))
SAVED_MB=$(( SAVED_KB / 1024 ))

# ── 6. Telegram notification (best-effort — skipped if token not available) ───
if [[ -n "${TELEGRAM_UBUNTU_TOKEN:-}" ]] && [[ -n "${TELEGRAM_CHAT_ID:-}" ]]; then
    
    # Audit block (only show details on failure)
    _AUDIT_MSG="⚖️ *Governance:* ${AUDIT_STATUS}"
    if [[ "$AUDIT_STATUS" != "✅ OK" ]]; then
        _AUDIT_MSG="${_AUDIT_MSG}
⚠️ *Governance Drift Detected!*
\`\`\`
${AUDIT_DETAILS}
\`\`\`"
    fi

    _QMD_MSG="🧠 *QMD:* ${QMD_STATUS}"
    if [[ "$QMD_STATUS" != "✅ OK" ]]; then
        _QMD_MSG="${_QMD_MSG}
⚠️ *QMD collection drift — re-index or fix paths*
\`\`\`
${QMD_DETAILS}
\`\`\`"
    fi

    MESSAGE="🧹 *${PC_NAME} Weekly Cleanup Report* 🚀

✅ *Status:* System Optimized!
${_AUDIT_MSG}
${_QMD_MSG}

💾 *Root Usage:* ${DISK_USAGE} (${DISK_FREE} Free)
🧹 *Space Reclaimed:* ${SAVED_MB} MB

🔥 *Top 5 Home Folders:*
\`\`\`
${TOP_HOME}
\`\`\`

📂 *Top 5 System Folders:*
\`\`\`
${TOP_ROOT}
\`\`\`

🔍 *Workspace Scan:*
\`\`\`
${WORKSPACE_SCAN_OUTPUT}
\`\`\`"

    notify_telegram "CLEAN" "$MESSAGE" "NETTOYAGE"
    echo "✅ [$(date)] Cleanup & Audit Finished and Notification Sent."
fi

# ── 7. Explicit success exit ───────────────────────────────────────────────────
# The cleanup did its job; the oneshot service must report SUCCESS even if the
# best-effort reporting/notification tail was skipped or hit a non-fatal error.
exit 0

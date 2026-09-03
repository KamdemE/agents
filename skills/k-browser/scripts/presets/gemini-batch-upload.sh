#!/bin/bash
# gemini-batch-upload.sh — Upload multiple images to Gemini via browser-proxy.
#
# Usage:
#   ./gemini-batch-upload.sh <TARGET_ID> <IMAGE1> [IMAGE2] [IMAGE3] ...
#
# For each image: opens Importer menu → clicks Importer des fichiers → waits for
# file inputs → calls gemini-upload.py → waits for next.
#
# Requires: browser-proxy running, Python 3, TARGET_ID from tab-list.
set -e

TARGET_ID="${1:?Usage: $0 <TARGET_ID> <IMAGE1> [IMAGE2] ...}"
shift

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for img in "$@"; do
    if [ ! -f "$img" ]; then
        echo "⚠️ File not found: $img — skipping"
        continue
    fi
    fname=$(basename "$img")
    echo ""
    echo "━━━ Uploading: $fname ━━━"

    # Step 1: Click Importation button
    echo "  [1/4] Clicking Importation..."
    browser-proxy do page-click "{\"profile\":\"default\",\"target_id\":\"$TARGET_ID\",\"selector\":\"button[aria-label*=\\\"Importation\\\"]\"}" > /dev/null
    sleep 2

    # Step 2: Click Importer des fichiers (menuitem 0)
    echo "  [2/4] Clicking Importer des fichiers..."
    browser-proxy do page-evaluate "{\"profile\":\"default\",\"target_id\":\"$TARGET_ID\",\"expression\":\"var items = document.querySelectorAll('[role=menuitem]'); if(items.length > 0) { items[0].click(); 'clicked' } else { 'no menu' }\"}" > /dev/null
    sleep 3

    # Step 3: Check file inputs
    INPUTS=$(browser-proxy do page-evaluate "{\"profile\":\"default\",\"target_id\":\"$TARGET_ID\",\"expression\":\"document.querySelectorAll('input[type=file]').length\"}" 2>/dev/null | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['data']['result'])" 2>/dev/null || echo "0")
    if [ "$INPUTS" = "0" ]; then
        echo "  ⚠️ No file inputs found — retrying..."
        sleep 2
        INPUTS=$(browser-proxy do page-evaluate "{\"profile\":\"default\",\"target_id\":\"$TARGET_ID\",\"expression\":\"document.querySelectorAll('input[type=file]').length\"}" 2>/dev/null | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['data']['result'])" 2>/dev/null || echo "0")
    fi
    echo "  [3/4] File inputs: $INPUTS"

    if [ "$INPUTS" = "0" ]; then
        echo "  ❌ Still no file inputs — skipping $fname"
        continue
    fi

    # Step 4: Upload via gemini-upload.py
    echo "  [4/4] Uploading..."
    python3 "$SCRIPT_DIR/gemini-upload.py" "$TARGET_ID" "$img" "$fname"
    sleep 2
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All uploads complete"

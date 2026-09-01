#!/usr/bin/env bash
# add-to-playlist.sh — Add the currently playing song to a named YouTube Music playlist
# Usage: add-to-playlist.sh <playlist_name> [target_id]
# Requires: browser-proxy (running, default profile), ytmusic-add-to-playlist-renderer DOM
#
# Flow:
#   1. Click the three-dot menu in the player bar
#   2. Click "Enregistrer dans une playlist"
#   3. Find the named playlist in the dialog and click its inner <button>
#   4. Verify via toast (success or "already in playlist")

set -euo pipefail

PLAYLIST="${1:?Usage: add-to-playlist.sh <playlist_name> [target_id]}"
TARGET_ID="${2:-}"

if [[ -z "$TARGET_ID" ]]; then
  # Get the first attached page tab
  TARGET_ID=$(browser-proxy do tab-list '{}' 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for t in data['data']['tabs']:
    if t['type'] == 'page' and t.get('attached'):
        print(t['targetId'])
        break
" 2>/dev/null || true)

  if [[ -z "$TARGET_ID" ]]; then
    echo "❌ No attached page tab found. Start Edge first." >&2
    exit 1
  fi
fi

echo "📋 Adding to playlist: $PLAYLIST (target: $TARGET_ID)"

# Step 1: Click the three-dot menu in the player bar
echo "  → Opening player menu..."
browser-proxy do page-evaluate "{\"target_id\": \"$TARGET_ID\", \"expression\": \"(() => { const bar = document.querySelector('ytmusic-player-bar'); const btns = bar.querySelectorAll('button'); const menuBtn = Array.from(btns).find(b => { const label = b.getAttribute('aria-label'); return label && label.includes('Menu'); }); if (menuBtn) { menuBtn.click(); return 'ok'; } return 'no menu'; })()\"}" >/dev/null

sleep 1

# Step 2: Click "Enregistrer dans une playlist"
echo "  → Clicking 'Enregistrer dans une playlist'..."
browser-proxy do page-evaluate "{\"target_id\": \"$TARGET_ID\", \"expression\": \"(() => { const items = document.querySelectorAll('tp-yt-paper-listbox ytmusic-menu-navigation-item-renderer'); for (const item of items) { const label = item.querySelector('yt-formatted-string'); if (label && label.textContent.includes('Enregistrer')) { item.click(); return 'ok'; } } return 'not found'; })()\"}" >/dev/null

sleep 1

# Step 3: Find and click the named playlist
echo "  → Selecting playlist '$PLAYLIST'..."
RESULT=$(browser-proxy do page-evaluate "{\"target_id\": \"$TARGET_ID\", \"expression\": \"(() => { const dialog = document.querySelector('ytmusic-add-to-playlist-renderer'); if (!dialog) return 'no dialog'; const scroller = dialog.querySelector('.scroller'); if (!scroller) return 'no scroller'; const items = scroller.querySelectorAll('ytmusic-playlist-add-to-option-renderer'); for (let i = 0; i < items.length; i++) { const name = items[i].querySelector('yt-formatted-string'); if (name && name.textContent.trim() === '$PLAYLIST') { const btn = items[i].querySelector('button'); if (btn) { btn.click(); return 'clicked'; } } } return 'not found'; })()\"}" 2>/dev/null)

if echo "$RESULT" | grep -q '"clicked"'; then
  echo "  ✅ Clicked '$PLAYLIST'"
else
  echo "  ❌ Playlist '$PLAYLIST' not found in dialog" >&2
  # Close the dialog
  browser-proxy do page-evaluate "{\"target_id\": \"$TARGET_ID\", \"expression\": \"(() => { const d = document.querySelector('ytmusic-add-to-playlist-renderer'); if (d) { const c = d.querySelector('.close-icon button'); if (c) c.click(); } })()\"}" >/dev/null 2>&1
  exit 1
fi

sleep 1

# Step 4: Check toast for result
TOAST=$(browser-proxy do page-evaluate "{\"target_id\": \"$TARGET_ID\", \"expression\": \"(() => { const toast = document.querySelector('tp-yt-paper-toast'); if (toast) return toast.textContent.trim(); return ''; })()\"}" 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('data', {}).get('result', ''))
" 2>/dev/null || true)

if echo "$TOAST" | grep -q "déjà dans la playlist"; then
  echo "  ℹ️  Song already in playlist '$PLAYLIST'"
elif echo "$TOAST" | grep -q "Enregistrée dans\|Ajouté à"; then
  echo "  ✅ Song added to playlist '$PLAYLIST'"
else
  echo "  ⚠️  Unknown result: $TOAST"
fi

# Close the dialog
browser-proxy do page-evaluate "{\"target_id\": \"$TARGET_ID\", \"expression\": \"(() => { const d = document.querySelector('ytmusic-add-to-playlist-renderer'); if (d) { const c = d.querySelector('.close-icon button'); if (c) c.click(); } })()\"}" >/dev/null 2>&1

echo "  🎵 Done."

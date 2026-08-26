#!/usr/bin/env bash
# KpihX mnt-sync — push LOCAL_ROOT ⟶ REMOTE_ROOT (Linux, one-way, mirrors
# exactly via --delete — orphans on the remote side ARE removed).
# Generic mount-to-mount sync — REMOTE_ROOT/LOCAL_ROOT are any two mounted
# disks/paths, not necessarily a project's assets/ (that's just the default).
# Copy next to your project's dirs.txt, set the two paths below (or export
# them before calling), then wire a `make sync-push` target to this script.
set -euo pipefail

REMOTE_ROOT="${MNT_SYNC_REMOTE_ROOT:-/mnt/REPLACE_ME}"
LOCAL_ROOT="${MNT_SYNC_LOCAL_ROOT:-$(dirname "$0")/../../assets}"

source "$(dirname "$0")/load_dirs.sh"

echo "Pushing: $LOCAL_ROOT ⟶ $REMOTE_ROOT (mirror, --delete)"

for d in "${SYNC_DIRS[@]}"; do
  src="$LOCAL_ROOT/$d"
  dst="$REMOTE_ROOT/$d"
  if [ ! -d "$src" ]; then
    echo "  ⚠ skip $d — not found at $src"
    continue
  fi
  mkdir -p "$dst"
  echo "  → $d"
  rsync -au --delete --info=progress2 "$src/" "$dst/"
done

echo "✅ Push complete."

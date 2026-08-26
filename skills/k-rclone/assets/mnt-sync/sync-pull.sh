#!/usr/bin/env bash
# KpihX mnt-sync — pull REMOTE_ROOT ⟶ LOCAL_ROOT (Linux, one-way, no --delete).
# Generic mount-to-mount sync — REMOTE_ROOT/LOCAL_ROOT are any two mounted
# disks/paths, not necessarily a project's assets/ (that's just the default).
# Copy next to your project's dirs.txt, set the two paths below (or export
# them before calling), then wire a `make sync-pull` target to this script.
set -euo pipefail

REMOTE_ROOT="${MNT_SYNC_REMOTE_ROOT:-/mnt/REPLACE_ME}"   # e.g. a CIFS/NFS mount, or a mounted network drive
LOCAL_ROOT="${MNT_SYNC_LOCAL_ROOT:-$(dirname "$0")/../../assets}"

source "$(dirname "$0")/load_dirs.sh"

echo "Pulling: $REMOTE_ROOT ⟶ $LOCAL_ROOT"
mkdir -p "$LOCAL_ROOT"

for d in "${SYNC_DIRS[@]}"; do
  src="$REMOTE_ROOT/$d"
  dst="$LOCAL_ROOT/$d"
  if [ ! -d "$src" ]; then
    echo "  ⚠ skip $d — not found at $src"
    continue
  fi
  mkdir -p "$dst"
  echo "  → $d"
  rsync -au --info=progress2 "$src/" "$dst/"
done

echo "✅ Pull complete."

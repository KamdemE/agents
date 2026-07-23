#!/usr/bin/env bash
# Fix Cursor tunnel 404 (BlobNotFound) for missing remote-releases commit on Azure.
# Maps a published Cursor REH build onto the commit hash requested by the tunnel client.
set -euo pipefail

COMMIT_WANT="${1:-f6cfa2ea2403534de03f069bdf160d06451ed282}"
COMMIT_HAVE="${2:-$(/usr/bin/cursor --version 2>/dev/null | sed -n '2p')}"
if [[ -z "${COMMIT_HAVE}" ]]; then
  echo "Could not detect local Cursor commit. Pass it as second argument." >&2
  exit 1
fi

SERVERS_DIR="${HOME}/.cursor/cli/servers"
DEST="${SERVERS_DIR}/Stable-${COMMIT_WANT}"
STAGING="${DEST}.staging"
CACHE_TAR="/tmp/cursor-reh-${COMMIT_HAVE}.tar.gz"
BLOB_URL="https://cursor.blob.core.windows.net/remote-releases/${COMMIT_HAVE}/vscode-reh-linux-x64.tar.gz"

echo "[1/6] Stop tunnel (ignore errors if not running)"
cursor tunnel kill 2>/dev/null || true
sleep 1

echo "[2/6] Download published REH tarball for commit ${COMMIT_HAVE}"
if [[ ! -f "${CACHE_TAR}" ]]; then
  curl -fL --retry 3 -o "${CACHE_TAR}" "${BLOB_URL}"
fi

echo "[3/6] Install server into ${DEST}"
rm -rf "${DEST}" "${STAGING}"
mkdir -p "${DEST}"
tar -xzf "${CACHE_TAR}" -C "${DEST}" --strip-components=1

echo "[4/6] Patch commit in product.json only (never sed binaries)"
if [[ -f "${DEST}/product.json" ]]; then
  sed -i "s/${COMMIT_HAVE}/${COMMIT_WANT}/g" "${DEST}/product.json"
  sed -i "s/aac81804b986d739acab348ed96b8bea6e83cc57/${COMMIT_WANT}/g" "${DEST}/product.json"
fi

echo "[5/6] Mark server in LRU (avoid prune removing it)"
printf '%s\n' "[\"Stable-${COMMIT_WANT}\"]" > "${SERVERS_DIR}/lru.json"

echo "[6/6] Verify entrypoint (install must exist before tunnel start)"
test -x "${DEST}/bin/cursor-server"
"${DEST}/bin/cursor-server" --version | head -3
ls -la "${DEST}/bin/cursor-server"

echo
echo "Install OK at: ${DEST}"
echo "Next (manual): cursor tunnel --accept-server-license-terms"
echo "Then in Cursor: quit app fully, reopen, connect to tunnel machine."
echo "Do NOT run: cursor tunnel prune  (it can delete this install)."

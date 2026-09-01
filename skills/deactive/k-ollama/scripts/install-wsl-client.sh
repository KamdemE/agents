#!/usr/bin/env bash
# install-wsl-client.sh — Ollama CLIENT ONLY for WSL, talking to a
# Windows-hosted Ollama server via .wslconfig's networkingMode=mirrored.
#
# Does NOT install a server, does NOT touch systemd, does NOT enable any
# service. See k-ollama/references/windows.md -> "Ollama in WSL" -> Option B
# for why (a WSL-side server would race the Windows one for :11434).
#
# Why this script exists instead of `curl https://ollama.com/install.sh | sh`:
# that installer bundles the full server + multi-GB CUDA/ROCm backend libs
# (useless for a pure client) and unconditionally runs `systemctl enable
# ollama` when systemd is present (true on any KπX WSL distro, wsl.conf sets
# systemd=true) -- exactly the two things we don't want here.
#
# Requires: curl, tar, uv (for the zstd decompression step -- see below).
# Idempotent: skips the download if the installed version already matches
# the latest release.
#
# Usage: bash install-wsl-client.sh

set -euo pipefail

INSTALL_PATH="${OLLAMA_CLIENT_PATH:-$HOME/.local/bin/ollama}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Resolving latest ollama release tag..."
# Capture into a variable first, then grep it -- piping curl straight into
# `grep -m1` can make curl fail with "(23) Failure writing output" because
# grep -m1 closes its stdin the instant it finds a match, killing the pipe
# out from under curl before it's done writing the rest of the response.
RELEASE_JSON="$(curl -fsSL https://api.github.com/repos/ollama/ollama/releases/latest)"
LATEST_TAG="$(printf '%s' "$RELEASE_JSON" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
[ -n "$LATEST_TAG" ] || { echo "❌ Could not resolve the latest ollama release tag." >&2; exit 1; }
echo "    latest = $LATEST_TAG"

# Check the target install path directly, not just $PATH -- a non-login/
# non-interactive shell (cron, CI, this script itself run standalone) may
# not have ~/.local/bin on PATH even though it's there on disk.
EXISTING_BIN=""
if [ -x "$INSTALL_PATH" ]; then
  EXISTING_BIN="$INSTALL_PATH"
elif command -v ollama >/dev/null 2>&1; then
  EXISTING_BIN="$(command -v ollama)"
fi

if [ -n "$EXISTING_BIN" ]; then
  CURRENT_VER="$("$EXISTING_BIN" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ "v$CURRENT_VER" = "$LATEST_TAG" ]; then
    echo "✅ ollama client already at $LATEST_TAG ($EXISTING_BIN) — nothing to do."
    exit 0
  fi
  echo "    installed = v${CURRENT_VER:-none} ($EXISTING_BIN), updating to $LATEST_TAG"
fi

# Recent releases only ship .tar.zst (no .tgz anymore -- the older `curl
# .../ollama-linux-amd64.tgz` URL 404s). Decompressing needs the external
# `zstd` binary; GNU tar's own `--zstd` flag just shells out to it too, and
# it isn't installed by default (only the libzstd1 *library* usually is,
# which is not the same thing). Installing `zstd` via apt would need sudo,
# so we use a throwaway `uv run --with zstandard` env instead -- no sudo, no
# system package touched.
ARCHIVE="$TMP_DIR/ollama.tar.zst"
echo "==> Downloading ollama-linux-amd64.tar.zst ($LATEST_TAG)..."
curl -fsSL -A "Mozilla/5.0" -o "$ARCHIVE" \
  "https://github.com/ollama/ollama/releases/download/$LATEST_TAG/ollama-linux-amd64.tar.zst"

echo "==> Decompressing (uv-managed zstandard, no sudo)..."
UV_BIN="$(command -v uv || echo "$HOME/.local/bin/uv")"
"$UV_BIN" run --with zstandard python3 -c "
import zstandard as zstd
with open('$ARCHIVE', 'rb') as i, open('$TMP_DIR/ollama.tar', 'wb') as o:
    zstd.ZstdDecompressor().copy_stream(i, o)
"

echo "==> Extracting bin/ollama only (skipping multi-GB lib/ollama/{cuda_v12,cuda_v13,rocm} -- a client never needs them)..."
tar -xf "$TMP_DIR/ollama.tar" -C "$TMP_DIR" bin/ollama

mkdir -p "$(dirname "$INSTALL_PATH")"
install -m755 "$TMP_DIR/bin/ollama" "$INSTALL_PATH"
echo "✅ Installed ollama client at $INSTALL_PATH ($LATEST_TAG)"

echo "==> Sanity checks..."
if systemctl status ollama >/dev/null 2>&1; then
  echo "⚠️  An ollama.service exists and is active -- this script never creates one." >&2
  echo "    If you didn't enable it yourself, investigate before relying on the Windows server." >&2
else
  echo "✅ No ollama.service on this WSL distro (expected -- client-only)."
fi
echo "✅ OLLAMA_HOST=${OLLAMA_HOST:-<unset -- check .kshrc, should default to http://localhost:11434>}"

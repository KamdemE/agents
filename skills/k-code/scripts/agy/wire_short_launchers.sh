#!/usr/bin/env bash
# ==============================================================================
#  short launchers (pattern A): agy-ide, agy-hub → Google binaries.
# Keeps antigravity-ide / antigravity-hub as compatibility symlinks.
# ==============================================================================
set -euo pipefail

LOCAL_BIN="${HOME}/.local/bin"
HUB_DIR="${HOME}/.local/share/antigravity-hub"
IDE_DIR="${HOME}/.local/share/antigravity-ide"

hub_bin="${HUB_DIR}/antigravity"
ide_bin="${IDE_DIR}/antigravity-ide"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hub_wrapper="${script_dir}/agy-hub.sh"

if [[ ! -x "${hub_bin}" ]]; then
  echo "ERROR: missing Hub binary ${hub_bin} (run install_agy_components.sh first)" >&2
  exit 1
fi
if [[ ! -x "${ide_bin}" ]]; then
  echo "ERROR: missing IDE binary ${ide_bin} (run install_agy_components.sh first)" >&2
  exit 1
fi
if [[ ! -f "${hub_wrapper}" ]]; then
  echo "ERROR: missing ${hub_wrapper}" >&2
  exit 1
fi

mkdir -p "${LOCAL_BIN}"
chmod +x "${hub_wrapper}"
ln -sf "${hub_wrapper}" "${LOCAL_BIN}/agy-hub"
ln -sf "${hub_bin}" "${LOCAL_BIN}/antigravity-hub"
ln -sf "${ide_bin}" "${LOCAL_BIN}/agy-ide"
ln -sf "${ide_bin}" "${LOCAL_BIN}/antigravity-ide"

echo "Short launchers:"
echo "  agy-hub          -> ${hub_wrapper} (--no-sandbox; x11 on Wayland)"
echo "  agy-ide          -> ${ide_bin}"
echo "Compat aliases:"
echo "  antigravity-hub  -> ${hub_bin}"
echo "  antigravity-ide  -> ${ide_bin}"

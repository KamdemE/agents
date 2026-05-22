#!/usr/bin/env bash
# ==============================================================================
# Install Google Antigravity ecosystem (Hub 2.0, IDE, CLI, SDK) from KπX paths.
# Usage: install_agy_components.sh [--skip-apt-remove] [--skip-cli] [--skip-sdk]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOADS="${HOME}/Downloads"
HUB_ARCHIVE="${DOWNLOADS}/Antigravity.tar.gz"
IDE_ARCHIVE="${DOWNLOADS}/Antigravity IDE.tar.gz"
HUB_DIR="${HOME}/.local/share/antigravity-hub"
IDE_DIR="${HOME}/.local/share/antigravity-ide"
LOCAL_BIN="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"

SKIP_APT_REMOVE=false
SKIP_CLI=false
SKIP_SDK=false

usage() {
  cat <<'EOF'
Usage: install_agy_components.sh [OPTIONS]

  (default)     Extract Hub + IDE from ~/Downloads, install CLI + SDK, wire launchers.
  --skip-apt-remove  Keep apt package `antigravity` if present.
  --skip-cli    Do not run official curl CLI installer.
  --skip-sdk    Do not install google-antigravity via uv tool.
  --help        Show this text.

After install, fix chrome-sandbox (requires sudo once per tree):
  sudo chown root:root ~/.local/share/antigravity-ide/chrome-sandbox
  sudo chmod 4755 ~/.local/share/antigravity-ide/chrome-sandbox
  (repeat for antigravity-hub if GUI fails)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-apt-remove) SKIP_APT_REMOVE=true ;;
    --skip-cli) SKIP_CLI=true ;;
    --skip-sdk) SKIP_SDK=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

require_archive() {
  local f="$1"
  if [[ ! -f "${f}" ]]; then
    echo "ERROR: missing archive ${f}" >&2
    exit 1
  fi
}

install_hub() {
  require_archive "${HUB_ARCHIVE}"
  echo ">>> Installing Antigravity Hub (2.0 desktop) -> ${HUB_DIR}"
  rm -rf "${HUB_DIR}"
  mkdir -p "${HUB_DIR}"
  tar -xzf "${HUB_ARCHIVE}" -C "${HUB_DIR}" --strip-components=1
  chmod +x "${HUB_DIR}/antigravity" 2>/dev/null || true
  mkdir -p "${LOCAL_BIN}"
  ln -sf "${HUB_DIR}/antigravity" "${LOCAL_BIN}/agy-hub"
  ln -sf "${LOCAL_BIN}/agy-hub" "${LOCAL_BIN}/antigravity-hub"
  echo "    launchers: agy-hub, antigravity-hub (compat)"
}

install_ide() {
  require_archive "${IDE_ARCHIVE}"
  echo ">>> Installing Antigravity IDE -> ${IDE_DIR}"
  rm -rf "${IDE_DIR}"
  local staging="${HOME}/.cache/antigravity/staging/ide-$$"
  mkdir -p "${staging}"
  tar -xzf "${IDE_ARCHIVE}" -C "${staging}"
  if [[ -d "${staging}/Antigravity IDE" ]]; then
    mv "${staging}/Antigravity IDE" "${IDE_DIR}"
  else
    echo "ERROR: unexpected IDE tarball layout under ${staging}" >&2
    ls -la "${staging}" >&2
    exit 1
  fi
  rm -rf "${staging}"
  chmod +x "${IDE_DIR}/antigravity-ide" "${IDE_DIR}/bin/antigravity-ide" 2>/dev/null || true
  mkdir -p "${LOCAL_BIN}"
  ln -sf "${IDE_DIR}/antigravity-ide" "${LOCAL_BIN}/agy-ide"
  ln -sf "${LOCAL_BIN}/agy-ide" "${LOCAL_BIN}/antigravity-ide"
  echo "    launchers: agy-ide, antigravity-ide (compat)"
}

install_cli() {
  echo ">>> Installing Antigravity CLI (official curl installer)"
  curl -fsSL https://antigravity.google/cli/install.sh | bash
  if command -v agy >/dev/null 2>&1; then
    echo "    agy: $(command -v agy) ($(agy --version 2>/dev/null || echo version-unknown))"
  else
    echo "WARN: agy not on PATH after install" >&2
  fi
}

install_sdk() {
  echo ">>> Installing google-antigravity SDK (Python library)"
  # Package ships importable modules only (no CLI entrypoints) — not suitable for `uv tool install`.
  if pip3 install --user google-antigravity; then
    python3 -c "import google.antigravity" && echo "    import google.antigravity: OK"
  else
    echo "ERROR: pip3 install google-antigravity failed" >&2
    exit 1
  fi
}

write_desktops() {
  chmod +x "${SCRIPT_DIR}/launch_agy_hub.sh" "${SCRIPT_DIR}/launch_agy_ide.sh" 2>/dev/null || true
  bash "${SCRIPT_DIR}/refresh_agy_menu.sh"
}

remove_apt_overlap() {
  if [[ "${SKIP_APT_REMOVE}" == true ]]; then
    return 0
  fi
  if dpkg -s antigravity >/dev/null 2>&1; then
    echo ">>> Removing apt package antigravity (tar installs are canonical)"
    if command -v sudo >/dev/null 2>&1; then
      sudo apt-get remove -y antigravity || true
    else
      echo "WARN: sudo not available; skip apt remove" >&2
    fi
  fi
}

main() {
  install_hub
  install_ide
  [[ "${SKIP_CLI}" == false ]] && install_cli
  [[ "${SKIP_SDK}" == false ]] && install_sdk
  "${SCRIPT_DIR}/install_agy_icons.sh"
  write_desktops
  chmod +x "${SCRIPT_DIR}/launch_agy_hub.sh" "${SCRIPT_DIR}/launch_agy_ide.sh" "${SCRIPT_DIR}/refresh_agy_menu.sh"
  "${SCRIPT_DIR}/sync_agy.sh"
  "${SCRIPT_DIR}/wire_short_launchers.sh"
  "${SCRIPT_DIR}/fix_agy_sandbox.sh" || true
  remove_apt_overlap
  echo ""
  echo "=== KπX launchers: agy (CLI) · agy-ide · agy-hub ==="
  echo "=== If GUI still fails, run: ${SCRIPT_DIR}/fix_agy_sandbox.sh (sudo once) ==="
}

main "$@"

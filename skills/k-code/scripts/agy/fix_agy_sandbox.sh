#!/usr/bin/env bash
# ==============================================================================
# Fix chrome-sandbox for tar-installed Antigravity Hub + IDE (requires sudo once).
# Without this, GUI launchers exit immediately with no window.
# ==============================================================================
set -euo pipefail

HUB_SB="${HOME}/.local/share/antigravity-hub/chrome-sandbox"
IDE_SB="${HOME}/.local/share/antigravity-ide/chrome-sandbox"
fixed=0

fix_one() {
  local sb="$1"
  if [[ ! -f "${sb}" ]]; then
    echo "SKIP: missing ${sb}"
    return 0
  fi
  if [[ "$(id -u)" -eq 0 ]]; then
    chown root:root "${sb}"
    chmod 4755 "${sb}"
    echo "OK: ${sb}"
    fixed=$((fixed + 1))
    return 0
  fi
  if sudo -n true 2>/dev/null; then
    sudo chown root:root "${sb}"
    sudo chmod 4755 "${sb}"
    echo "OK (sudo): ${sb}"
    fixed=$((fixed + 1))
    return 0
  fi
  echo "NEED_SUDO: sudo chown root:root ${sb} && sudo chmod 4755 ${sb}"
  return 1
}

need=0
fix_one "${HUB_SB}" || need=1
fix_one "${IDE_SB}" || need=1

if [[ "${need}" -eq 1 ]]; then
  echo ""
  echo "Run in tmux (password required), then retry your menu icons:"
  echo "  tmux attach -t default"
  echo "  sudo chown root:root ${HUB_SB} ${IDE_SB}"
  echo "  sudo chmod 4755 ${HUB_SB} ${IDE_SB}"
  exit 1
fi

echo "Sandbox fixed (${fixed} binaries). Test: agy-hub --version && agy-ide --version"
exit 0

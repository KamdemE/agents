#!/usr/bin/env bash
# ==============================================================================
# BOOTSTRAP: Google Antigravity ("Open Cloud") + Continue (Mistral BYOK)
# - Keeps Antigravity wired to VS Code user dir (sync_agy.sh)
# - Ensures ~/.continue/global rules symlink to the sovereign AGENTS kernel
# - Optional: install ~/.local desktop entry that launches Antigravity with shell env
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_SYNC_AGY="${SCRIPT_DIR}/sync_agy.sh"
WIRE_LAUNCHERS="${SCRIPT_DIR}/wire_short_launchers.sh"

usage() {
  cat <<'EOF'
Usage: bootstrap_open_cloud.sh [--launch [args...]] [--install-desktop] [--help]

  (default)        Run sync + continue rule symlinks only.
  --launch         After setup, exec agy-ide (passes remaining args).
  --install-desktop  Write ~/.local/share/applications/kpihx-antigravity-open-cloud.desktop
  --help           Show this text.

Secrets: set MISTRAL_API_KEY in ~/.continue/.env (recommended) or export via ~/.kshrc / Vaultwarden
         before --launch so Continue can resolve ${{ secrets.MISTRAL_API_KEY }}.
EOF
}

install_desktop() {
  echo "Desktop: use agy-ide.desktop (bootstrap is wired in install_agy_components.sh)."
  echo "Legacy kpihx-antigravity-open-cloud.desktop is kept hidden (NoDisplay=true) if present."
  bash "${SCRIPT_DIR}/install_agy_icons.sh" 2>/dev/null || true
  if [[ -f "${SCRIPT_DIR}/install_agy_components.sh" ]]; then
    bash "${SCRIPT_DIR}/install_agy_components.sh" --skip-cli --skip-sdk --skip-apt-remove 2>/dev/null || true
  fi
}

setup_continue_rules() {
  local rules agents link_target
  rules="${HOME}/.continue/rules"
  agents="${HOME}/.agents/AGENTS.md"
  mkdir -p "${rules}"
  if [[ ! -f "${agents}" ]]; then
    echo "ERROR: missing ${agents}" >&2
    exit 1
  fi
  link_target="../../.agents/AGENTS.md"
  ln -sf "${link_target}" "${rules}/00-kpihx-AGENTS.md"
  echo "Symlink OK: ${rules}/00-kpihx-AGENTS.md -> ${link_target}"
}

ensure_env_template() {
  local envf
  envf="${HOME}/.continue/.env"
  if [[ -f "${envf}" ]]; then
    return 0
  fi
  cat >"${envf}" <<'EOF'
# Continue resolves ${{ secrets.MISTRAL_API_KEY }} from this file (global).
# Map Bitwarden custom field "MISTRAL API Key" to MISTRAL_API_KEY via Vaultwarden, or paste for local-only IDE launches.
MISTRAL_API_KEY=
EOF
  chmod 0600 "${envf}"
  echo "Created template ${envf} — set MISTRAL_API_KEY (or use Vaultwarden + login shell)."
}

main() {
  if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    usage
    exit 0
  fi

  local do_launch=0
  local do_desktop=0
  local -a ag_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --launch)
        do_launch=1
        shift
        break
        ;;
      --install-desktop)
        do_desktop=1
        shift
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
  done

  if [[ "${do_launch}" -eq 1 ]]; then
    ag_args=("$@")
  fi

  if [[ ! -f "${REPO_SYNC_AGY}" ]]; then
    echo "ERROR: sync_agy.sh not found at ${REPO_SYNC_AGY}" >&2
    exit 1
  fi
  bash "${REPO_SYNC_AGY}"
  if [[ -x "${WIRE_LAUNCHERS}" ]]; then
    bash "${WIRE_LAUNCHERS}" 2>/dev/null || true
  fi
  setup_continue_rules
  ensure_env_template

  if [[ "${do_desktop}" -eq 1 ]]; then
    install_desktop
  fi

  if [[ "${do_launch}" -eq 1 ]]; then
    # Desktop/menu launch uses launch_agy_ide.sh (avoids set -u + secrets traps from .kshrc).
    # Terminal bootstrap may still load full shell when  runs this script interactively.
    if [[ -t 0 ]] && [[ -f "${HOME}/.kshrc" ]]; then
      set +u
      set +e
      # shellcheck disable=SC1090
      source "${HOME}/.kshrc"
      set -e
      set -u
    fi
    if [[ -f "${HOME}/.continue/.env" ]]; then
      set -a
      set +u
      # shellcheck disable=SC1090
      source "${HOME}/.continue/.env"
      set +a
    fi
    exec "$(command -v agy-ide || command -v antigravity-ide)" --no-sandbox "${ag_args[@]}"
  fi

  echo "Open Cloud bootstrap done. Tip: run with --launch from desktop or terminal after secrets load."
}

main "$@"

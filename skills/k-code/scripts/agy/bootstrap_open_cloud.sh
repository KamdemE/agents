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

usage() {
  cat <<'EOF'
Usage: bootstrap_open_cloud.sh [--launch [args...]] [--install-desktop] [--help]

  (default)        Run sync + continue rule symlinks only.
  --launch         After setup, exec /usr/bin/antigravity (passes remaining args).
  --install-desktop  Write ~/.local/share/applications/kpihx-antigravity-open-cloud.desktop
  --help           Show this text.

Secrets: set MISTRAL_API_KEY in ~/.continue/.env (recommended) or export via ~/.kshrc / bw-env
         before --launch so Continue can resolve ${{ secrets.MISTRAL_API_KEY }}.
EOF
}

install_desktop() {
  local desk dir ag
  dir="${HOME}/.local/share/applications"
  desk="${dir}/kpihx-antigravity-open-cloud.desktop"
  ag="$(command -v antigravity)"
  mkdir -p "${dir}"
  cat >"${desk}" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=Antigravity (KpihX Open Cloud)
Comment=Antigravity + Continue Mistral; loads shell env then starts IDE
Exec=${SCRIPT_DIR}/bootstrap_open_cloud.sh --launch %F
Terminal=false
Categories=Development;IDE;
StartupWMClass=antigravity
EOF
  chmod 0644 "${desk}"
  echo "Installed desktop entry: ${desk} (antigravity binary: ${ag})"
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
# Map Bitwarden custom field "MISTRAL API Key" to MISTRAL_API_KEY via bw-env, or paste for local-only IDE launches.
MISTRAL_API_KEY=
EOF
  chmod 0600 "${envf}"
  echo "Created template ${envf} — set MISTRAL_API_KEY (or use bw-env + login shell)."
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
  setup_continue_rules
  ensure_env_template

  if [[ "${do_desktop}" -eq 1 ]]; then
    install_desktop
  fi

  if [[ "${do_launch}" -eq 1 ]]; then
    if [[ -f "${HOME}/.continue/.env" ]]; then
      set -a
      # shellcheck disable=SC1090
      source "${HOME}/.continue/.env"
      set +a
    fi
    if [[ -f "${HOME}/.kshrc" ]]; then
      # shellcheck disable=SC1090
      source "${HOME}/.kshrc"
    fi
    exec /usr/bin/antigravity "${ag_args[@]}"
  fi

  echo "Open Cloud bootstrap done. Tip: run with --launch from desktop or terminal after secrets load."
}

main "$@"

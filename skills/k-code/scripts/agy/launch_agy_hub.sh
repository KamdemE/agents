#!/usr/bin/env bash
# Launch Antigravity Hub from app menu (delegates to agy-hub.sh — no login-shell side effects).
set -euo pipefail

WRAPPER="${HOME}/.agents/skills/k-code/scripts/agy/agy-hub.sh"
LOG="${HOME}/.cache/antigravity/launch-hub.log"
mkdir -p "${HOME}/.cache/antigravity"

if [[ ! -x "${WRAPPER}" ]]; then
  echo "$(date -Iseconds) missing ${WRAPPER}" >>"${LOG}"
  exit 1
fi

exec "${WRAPPER}" "$@"

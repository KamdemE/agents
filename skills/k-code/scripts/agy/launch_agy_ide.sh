#!/usr/bin/env bash
# Launch Antigravity IDE from app menu (Continue .env only — avoids kshrc set -u traps).
IDE="$(command -v agy-ide || command -v antigravity-ide)"
LOG="${HOME}/.cache/antigravity/launch-ide.log"
mkdir -p "${HOME}/.cache/antigravity"
if [[ ! -x "${IDE}" ]]; then
  echo "$(date -Iseconds) missing agy-ide" >>"${LOG}"
  exit 1
fi
if [[ -f "${HOME}/.continue/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${HOME}/.continue/.env"
  set +a
fi

ide_flags=(--no-sandbox)
if [[ "${XDG_SESSION_TYPE:-}" == wayland ]]; then
  ide_flags+=(--ozone-platform=x11)
fi
exec "${IDE}" "${ide_flags[@]}" "$@"

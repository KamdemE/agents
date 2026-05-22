#!/usr/bin/env bash
# KπX shell launcher for Antigravity Hub (always safe flags for tar install + Wayland).
set -euo pipefail

HUB="${HOME}/.local/share/antigravity-hub/antigravity"
LOG="${HOME}/.cache/antigravity/launch-hub.log"

mkdir -p "${HOME}/.cache/antigravity"

if [[ ! -x "${HUB}" ]]; then
  echo "$(date -Iseconds) missing ${HUB}" >>"${LOG}"
  echo "agy-hub: install Hub first (install_agy_components.sh)" >&2
  exit 1
fi

hub_flags=(--no-sandbox)

# Wayland + Vulkan often yields a blank/invisible Hub window on Ubuntu 26.04.
if [[ "${XDG_SESSION_TYPE:-}" == wayland ]]; then
  hub_flags+=(--ozone-platform=x11)
fi

if pgrep -f "${HUB} " >/dev/null 2>&1 || pgrep -f "${HUB} --" >/dev/null 2>&1; then
  echo "agy-hub: Hub already running — check the system tray or the Antigravity window." >&2
  echo "agy-hub: launching again to focus the existing instance…" >&2
fi

echo "$(date -Iseconds) exec ${HUB} ${hub_flags[*]} $*" >>"${LOG}"
exec "${HUB}" "${hub_flags[@]}" "$@"

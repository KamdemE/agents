#!/usr/bin/env bash
# ==============================================================================
# Menu icons: Hub = light full-color (app.asar /icon.png), IDE = dark square
# (jetski-logo-white.svg on #202124 — matches IDE dark brand assets).
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ASSETS="${SCRIPT_DIR}/../../assets/agy"
ICON_DIR="${HOME}/.local/share/icons/kpihx"
HUB_ASAR="${HOME}/.local/share/antigravity-hub/resources/app.asar"
IDE_SVG_DARK="${HOME}/.local/share/antigravity-ide/resources/app/out/media/jetski-logo-white.svg"
CACHE_EXTRACT="${HOME}/.cache/antigravity/hub-icon-extract/asar"

mkdir -p "${ICON_DIR}"

install_hub_light_icon() {
  local out="${ICON_DIR}/agy-hub.png"
  if [[ -f "${HUB_ASAR}" ]] && command -v npx >/dev/null 2>&1; then
    mkdir -p "${CACHE_EXTRACT}"
    rm -rf "${CACHE_EXTRACT}"
    mkdir -p "${CACHE_EXTRACT}"
    if npx --yes @electron/asar extract "${HUB_ASAR}" "${CACHE_EXTRACT}" 2>/dev/null \
      && [[ -f "${CACHE_EXTRACT}/icon.png" ]]; then
      cp "${CACHE_EXTRACT}/icon.png" "${out}"
      echo "    agy-hub.png (light / full-color from Hub asar)"
      return 0
    fi
  fi
  if [[ -f "${SKILL_ASSETS}/agy-hub.png" ]]; then
    cp "${SKILL_ASSETS}/agy-hub.png" "${out}"
    echo "    agy-hub.png from skill assets (fallback)"
    return 0
  fi
  echo "WARN: Hub icon missing" >&2
  return 1
}

install_ide_dark_icon() {
  local out="${ICON_DIR}/agy-ide.png"
  if [[ -f "${IDE_SVG_DARK}" ]] && command -v magick >/dev/null 2>&1; then
    magick -density 384 -background '#202124' "${IDE_SVG_DARK}" \
      -resize 400x400 -gravity center -extent 512x512 "${out}"
    echo "    agy-ide.png (dark: white logo on #202124)"
    return 0
  fi
  if [[ -f "${SKILL_ASSETS}/agy-ide.png" ]]; then
    cp "${SKILL_ASSETS}/agy-ide.png" "${out}"
    echo "    agy-ide.png from skill assets (fallback)"
    return 0
  fi
  echo "WARN: IDE dark icon missing (need magick + jetski-logo-white.svg)" >&2
  return 1
}

install_hicolor_theme() {
  local icon name size
  for name in agy-hub agy-ide; do
    icon="${ICON_DIR}/${name}.png"
    [[ -f "${icon}" ]] || continue
    for size in 512 256 128 64; do
      mkdir -p "${HOME}/.local/share/icons/hicolor/${size}x${size}/apps"
      cp "${icon}" "${HOME}/.local/share/icons/hicolor/${size}x${size}/apps/${name}.png"
    done
  done
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
  fi
}

main() {
  echo ">>> Installing AGY menu icons -> ${ICON_DIR}"
  install_hub_light_icon || true
  install_ide_dark_icon || true
  install_hicolor_theme
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${HOME}/.local/share/applications" 2>/dev/null || true
  fi
  cp -f "${ICON_DIR}/agy-hub.png" "${SKILL_ASSETS}/agy-hub.png" 2>/dev/null || true
  cp -f "${ICON_DIR}/agy-ide.png" "${SKILL_ASSETS}/agy-ide.png" 2>/dev/null || true
  echo ">>> Done: light=Hub, dark=IDE"
}

main "$@"

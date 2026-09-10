#!/usr/bin/env bash
# Refresh AGY .desktop entries + icon theme + GNOME app cache.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons/kpihx"

chmod +x "${SCRIPT_DIR}/launch_agy_hub.sh" "${SCRIPT_DIR}/launch_agy_ide.sh"
bash "${SCRIPT_DIR}/install_agy_icons.sh"
bash "${SCRIPT_DIR}/wire_short_launchers.sh" 2>/dev/null || true

# Remove legacy duplicate (gear icon in grid when cached).
rm -f "${DESKTOP_DIR}/kpihx-antigravity-open-cloud.desktop"
rm -f "${DESKTOP_DIR}/antigravity-hub.desktop" "${DESKTOP_DIR}/antigravity-ide.desktop"

icon_hub="${ICON_DIR}/agy-hub.png"
icon_ide="${ICON_DIR}/agy-ide.png"

cat >"${DESKTOP_DIR}/agy-hub.desktop" <<EOF
[Desktop Entry]
Type=Application
Version=1.2
Name=Antigravity Hub
GenericName=Antigravity 2.0
Comment=Agent-first desktop orchestrator
Exec=${SCRIPT_DIR}/launch_agy_hub.sh %F
Icon=agy-hub
StartupNotify=true
Terminal=false
Categories=Development;
StartupWMClass=antigravity
EOF

cat >"${DESKTOP_DIR}/agy-ide.desktop" <<EOF
[Desktop Entry]
Type=Application
Version=1.2
Name=Antigravity IDE
GenericName=Antigravity IDE
Comment=Pair-programmer IDE ( Continue)
Exec=${SCRIPT_DIR}/launch_agy_ide.sh %F
Icon=agy-ide
StartupNotify=true
Terminal=false
Categories=Development;IDE;
StartupWMClass=antigravity-ide
EOF

chmod 0644 "${DESKTOP_DIR}/agy-hub.desktop" "${DESKTOP_DIR}/agy-ide.desktop"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "${DESKTOP_DIR}" 2>/dev/null || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
fi

echo ">>> Refreshed: agy-hub.desktop, agy-ide.desktop"
echo ">>> Icons: ${icon_hub} (light), ${icon_ide} (dark)"
echo ""
echo "If the app grid still shows old gear icons:"
echo "  1. Remove old Antigravity tiles from the dash (right-click → Remove)."
echo "  2. Log out and log back in (or Alt+F2 → r → Enter on X11)."
echo "  3. Re-add from Search: 'Antigravity Hub' / 'Antigravity IDE'."
echo ""
echo "Test launch:"
echo "  ${SCRIPT_DIR}/launch_agy_hub.sh"
echo "  ${SCRIPT_DIR}/launch_agy_ide.sh"

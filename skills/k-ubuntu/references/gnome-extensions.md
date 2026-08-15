# GNOME Shell Extensions Reference

This reference documents the GNOME Shell extensions installed on the workstation (`kpihx-ubuntu`) and provides the procedure to automate their installation and management using `uv`.

---

## Extension Inventory

There are 16 extensions managed on the workstation: 9 user-installed (via extensions.gnome.org) and 7 system-installed.

### User Extensions (local to `~/.local/share/gnome-shell/extensions/`)

| Extension Name | UUID / Identifier | Version | Purpose & Workstation Role |
| :--- | :--- | :---: | :--- |
| **Tiling Shell** | `tilingshell@ferrarodomenico.com` | 17.3 | **ASUS VE228 Stretch Fix**: Creates a custom 1920x880 snap zone, leaving 200px of black space at the bottom to prevent vertical stretching. Implements Win11-style Snap Assist and Fancy Zones. |
| **GSConnect** | `gsconnect@andyholmes.github.io` | 72 | **KDE Connect Integration**: Syncs your phone (`kpihx-s25`) to GNOME to securely share notifications, files, SMS messages, clipboards, and remote controls. |
| **System Monitor** | `System_Monitor@bghome.gmail.com` | 43 | **Resource Monitoring**: Displays CPU, Memory, Swap, Network, and thermal sensors in real-time on your top status bar. |
| **Clipboard History** | `clipboard-history@alexsaveau.dev` | 48 | **Clipboard Management**: Saves everything copied to the clipboard into a searchable history panel in the panel. |
| **Alphabetical App Grid** | `AlphabeticalAppGrid@stuarthayhurst` | 44 | **App List Ordering**: Automatically orders apps and folders in the GNOME app grid alphabetically. |
| **Keep awake!** | `KeepAwake@jepfa.de` | 21 | **Sleep Prevention**: Toggles system sleep, screensaver, and hibernate prevention (lock icon persists across reboots). |
| **Text Extractor** | `text-extractor@aditya190803` | 10 | **OCR Extraction**: Runs OCR on a selected screen region using Tesseract OCR, copying the text to the clipboard. **Setup on this workstation:** OCR helper `text-extractor-ocr` installed to `~/.local/bin` (uv venv `text-extractor-ocr-venv` with pytesseract + pillow); `tesseract-ocr-fra` installed; `ocr-language=fra`. |
| **Advanced Weather Companion**| `advanced-weather@sanjai.com` | 30 | **Weather Indicator**: Integrated weather forecasts featuring dynamic geolocation and multi-provider queries. |
| **Power Off Options** | `power-off-options@axelitama.github.io` | 8 | **Enhanced Power Menu**: Enriches the default power menu with hibernate, suspend, switch user, and UEFI/BIOS reboot options. |

### System Extensions (global to `/usr/share/gnome-shell/extensions/`)

| Extension Name | UUID / Identifier | Purpose |
| :--- | :--- | :--- |
| **Ubuntu Dock** | `ubuntu-dock@ubuntu.com` | Standard lateral dock (modified version of Dash to Dock maintained by Canonical). |
| **Ubuntu Tiling Assistant** | `tiling-assistant@ubuntu.com` | Standard Ubuntu utility adding window-snap popups. *(Note: Functionally overlaps with the user-installed Tiling Shell)*. |
| **Desktop Icons NG (DING)** | `ding@rastersoft.com` | Restores desktop icons and shortcuts support on the desktop screen. |
| **Ubuntu AppIndicators** | `ubuntu-appindicators@ubuntu.com` | Restores standard system tray icons (systray AppIndicators support) for apps like Discord or Tailscale. |
| **SNAPD Permission Prompting** | `snapd-prompting@canonical.com` | Gext handles Snap security prompt popups natively. |
| **Snapd Search Provider** | `snapd-search-provider@canonical.com` | Integrates Snap package search in global overview. |
| **Web Search Provider** | `web-search-provider@ubuntu.com` | Integrates web search in overview. |

---

## CLI Installation Automation (100% `uv`)

To automate online installation and updates of GNOME Shell extensions from extensions.gnome.org (EGO), the workstation uses **`gnome-extensions-cli`** (`gext`) managed via **`uv`**.

### 1. Installation of management tool

Run the following command to install the extensions manager CLI in an isolated, uv-managed tool environment:
```bash
uv tool install gnome-extensions-cli
```

### 2. Automation Script Pattern

Below is the shell pattern to install and enable extensions programmatically:

```bash
# Array of desired user extensions UUIDs
desired_extensions=(
  "AlphabeticalAppGrid@stuarthayhurst"
  "System_Monitor@bghome.gmail.com"
  "advanced-weather@sanjai.com"
  "gsconnect@andyholmes.github.io"
  "clipboard-history@alexsaveau.dev"
  "KeepAwake@jepfa.de"
  "power-off-options@axelitama.github.io"
  "text-extractor@aditya190803"
  "tilingshell@ferrarodomenico.com"
)

# Loop to verify, install, and enable
for uuid in "${desired_extensions[@]}"; do
  # Check if installed
  if ! gnome-extensions list | grep -q "$uuid"; then
    echo "Installing $uuid..."
    gext install "$uuid"
  fi
  # Enable extension
  gnome-extensions enable "$uuid"
done
```

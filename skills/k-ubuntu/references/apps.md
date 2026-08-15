# KpihX-Ubuntu — Desktop Applications Registry

> **Scope:** complete inventory of the GUI/desktop applications installed on the KpihX-Ubuntu workstation (Intel Core Ultra 7 155H, Ubuntu 26.04 LTS). Source: `/usr/share/applications/*.desktop` (system), `~/.local/share/applications/*.desktop` (user), `/opt/*` (proprietary heavy clients), `snap list` (GUI snaps).
>
> **Maintenance rule:** update this file whenever a desktop app is installed, removed, or purged. Log the change in `k-ubuntu/references/log.md`.
>
> **Last verified:** 2026-08-14 (post-purging of Signal, Zoom, Wine — no longer listed).

---

## A. Daily-Driver & User Applications

### Browsers
| App | Desktop file | Notes |
|-----|--------------|-------|
| Google Chrome | `com.google.Chrome.desktop` / `google-chrome.desktop` | `/usr/bin/google-chrome-stable` (apt) |
| Microsoft Edge | `com.microsoft.Edge.desktop` / `microsoft-edge.desktop` | `/usr/bin/microsoft-edge-stable` (apt) |

### Editors & Development
| App | Desktop file | Notes |
|-----|--------------|-------|
| Visual Studio Code | `code.desktop` / `code-url-handler.desktop` | `/usr/share/code/code` (apt) |
| Cursor | `cursor.desktop` / `cursor-url-handler.desktop` | `/usr/share/cursor/cursor` (IDE, apt) |
| OpenCode | `@opencode-aidesktop.desktop` | `/opt/OpenCode/@opencode-aidesktop` — AI agent desktop |
| Neovim | `nvim.desktop` | `$EDITOR`, LSP/plugins (k-nvim) |
| Vim | `vim.desktop` | classic editor |
| Micro | `micro.desktop` | lightweight TUI editor |
| OpenJDK Java 21 Runtime | `openjdk-21-java.desktop` | `cautious-launcher` |
| OpenJDK Java 25 Runtime | `openjdk-25-java.desktop` | `cautious-launcher` |

### Communication & Remote Access
| App | Desktop file | Notes |
|-----|--------------|-------|
| Telegram Desktop | snap `telegram-desktop` | v7.0.9 (snap) |
| Remmina | `org.remmina.Remmina.desktop` | RDP/VNC — DxO VPN (BLGLAPTOP139, deep-pc6) |
| RustDesk | `rustdesk.desktop` / `rustdesk-link.desktop` | remote desktop |
| GSConnect | `org.gnome.Shell.Extensions.GSConnect.desktop` (+ Preferences) | Android (S25) integration — user-level |
| Bluetooth Transfer | `bluetooth-sendto.desktop` | send files over Bluetooth |

### Productivity & Tasks
| App | Desktop file | Notes |
|-----|--------------|-------|
| TickTick | `ticktick.desktop` | `/opt/TickTick/ticktick` (tasks) |
| Bitwarden | `bitwarden.desktop` | `/opt/Bitwarden/bitwarden` (passwords) |
| LibreOffice | `libreoffice-startcenter.desktop` | full suite |
| LibreOffice Writer | `libreoffice-writer.desktop` | word processor |
| LibreOffice Calc | `libreoffice-calc.desktop` | spreadsheet |
| LibreOffice Impress | `libreoffice-impress.desktop` | presentations |
| LibreOffice Draw | `libreoffice-draw.desktop` | vector drawing |
| LibreOffice Math | `libreoffice-math.desktop` | formulas |
| FreeFileSync | `FreeFileSync.desktop` | file sync |
| RealTimeSync | `RealTimeSync.desktop` | real-time sync monitor |

### Media & Graphics
| App | Desktop file | Notes |
|-----|--------------|-------|
| mpv Media Player | `mpv.desktop` | `--player-operation-mode=pseudo-gui` |
| F3D | `f3d.desktop` (+ `f3d-plugin-*`) | fast 3D viewer |
| ImageMagick (display) | `display-im7.q16.desktop` | image manipulation |
| Shotwell | `org.gnome.Shotwell.desktop` | photo manager |
| GNOME Image Viewer (Loupe) | `org.gnome.Loupe.desktop` | images |
| GNOME Video Player (Showtime) | `org.gnome.Showtime.desktop` | videos |
| GNOME Camera (Snapshot) | `org.gnome.Snapshot.desktop` | webcam |
| Document Scanner | `simple-scan.desktop` | scanning |
| Document Viewer (Papers) | `org.gnome.Papers.desktop` (+ `-previewer`) | PDF/Documents |
| Evince | `org.gnome.Evince.desktop` (+ `-previewer`) | PDF/Documents |

### VPN & Networking
| App | Desktop file | Notes |
|-----|--------------|-------|
| Windscribe | `windscribe.desktop` | `/opt/windscribe/Windscribe` (VPN) |
| GP Connect (GlobalProtect) | `gpgui.desktop` | `gpclient launch-gui` — DxO VPN |
| Advanced Network Config | `nm-connection-editor.desktop` | network connections |
| nm-tray | `nm-tray.desktop` | network manager tray |
| GNOME Network Displays | `org.gnome.NetworkDisplays.desktop` | Miracast/casting |

### System & Utilities
| App | Desktop file | Notes |
|-----|--------------|-------|
| GParted | `gparted.desktop` | partition editor |
| Extension Manager | `com.mattjakeman.ExtensionManager.desktop` | GNOME extensions GUI |
| GNOME Tweaks | `org.gnome.tweaks.desktop` | GNOME appearance/behavior |
| Disk Usage Analyzer | `org.gnome.baobab.desktop` | storage usage |
| Disks | `org.gnome.DiskUtility.desktop` | disk/partition utility |
| Disk Image Mounter | `gnome-disk-image-mounter.desktop` | mount ISO/img |
| Disk Image Writer | `gnome-disk-image-writer.desktop` | restore images |
| Resources | `net.nokyan.Resources.desktop` | system monitor |
| Passwords and Keys | `org.gnome.seahorse.Application.desktop` | keyring/certs |
| Software Updater | `update-manager.desktop` | apt updates |
| Startup Disk Creator | `usb-creator-gtk.desktop` | bootable USB |
| Backups (DejaDup) | `org.gnome.DejaDup.desktop` | system backups |
| Rygel | `rygel.desktop` | DLNA/UPnP media sharing |
| Tecla | `org.gnome.Tecla.desktop` | accessibility |

### GNOME Native Applications
| App | Desktop file | Notes |
|-----|--------------|-------|
| Files (Nautilus) | `org.gnome.Nautilus.desktop` | file manager |
| Terminal (Ptyxis) | `org.gnome.Ptyxis.desktop` | default terminal |
| Terminal (GNOME) | `org.gnome.Terminal.desktop` (+ Preferences) | classic terminal |
| Settings | `org.gnome.Settings.desktop` | GNOME settings (covers all `gnome-*-panel.desktop` sub-pages) |
| Calculator | `org.gnome.Calculator.desktop` | calculator |
| Calendar | `org.gnome.Calendar.desktop` | calendar |
| Characters | `org.gnome.Characters.desktop` | Unicode characters |
| Clocks | `org.gnome.clocks.desktop` | world clock/alarms |
| Text Editor | `org.gnome.TextEditor.desktop` | text editor |
| Logs | `org.gnome.Logs.desktop` | system logs |
| Fonts | `org.gnome.font-viewer.desktop` | font viewer |
| Help | `org.gnome.Yelp.desktop` | help/documentation |
| Screenshot | `org.gnome.Screenshot.desktop` | screen capture |
| Sysprof | `org.gnome.Sysprof.desktop` | profiling |
| File Roller | `org.gnome.FileRoller.desktop` | archive manager |
| Orca | `orca.desktop` | screen reader |
| Input Method (IBus) | `ibus-setup-table.desktop`, `org.freedesktop.IBus.*` | input methods (Cangjie, pinyin, Emoji) |

### User-Level Desktop Apps (`~/.local/share/applications/`)
| App | Desktop file | Notes |
|-----|--------------|-------|
| Claude Code URL Handler | `claude-code-url-handler.desktop` | `~/.local/bin/claude --handle-uri` — extension-auth (k-claude, deactivated) |
| GSConnect | `org.gnome.Shell.Extensions.GSConnect.desktop` | Android integration |
| GSConnect Preferences | `org.gnome.Shell.Extensions.GSConnect.Preferences.desktop` | GSConnect settings |

---

## B. Proprietary / Heavy Clients in `/opt`

| Directory | App | Purpose |
|-----------|-----|---------|
| `/opt/OpenCode/` | OpenCode desktop | AI agent desktop environment |
| `/opt/Bitwarden/` | Bitwarden Desktop | password manager |
| `/opt/TickTick/` | TickTick Desktop | tasks/productivity |
| `/opt/windscribe/` | Windscribe | VPN client |
| `/opt/google/` | Google Chrome + Google Cloud CLI | browser + GCP |
| `/opt/microsoft/` | Microsoft Edge | browser |
| `/opt/dell/` | Dell Command Configure (CCTK) | Dell BIOS/battery management |
| `/opt/intel/` | Intel NPU/GPU software + compilers | hardware acceleration |
| `/opt/containerd/` | containerd runtime | Docker container runtime |

---

## C. GUI Snaps

| Snap | Version | Notes |
|------|---------|-------|
| `telegram-desktop` | 7.0.9 | Telegram desktop client |
| `snap-store` | — | Ubuntu Software Center |

---

## D. Recently Purged (no longer installed — 2026-08-14)

For the record (GRAVÉ — never deleted from history):

| App | Removal |
|-----|---------|
| Signal Desktop (`signal-desktop` 8.10.0) | apt purge + `/opt/Signal` + configs + apparmor + sources |
| Zoom (`zoom` 6.7.2.6498) | apt purge + `/opt/zoom` + desktop + apparmor |
| Wine (`wine`, `wine64`, `wine-common`, `libwine`) + Winetricks | apt purge + `wine-extension-*` desktop files + `wine` dirs + `desktop-directories/wine-*` |
| asciinema (uv tool v2.4.0) | `uv tool uninstall asciinema` + `~/.config/asciinema` |
| Config debris (apps no longer installed) | cleaned 2026-08-14: `~/.config/{asciinema,BraveSoftware,Slack,Termius,Wave,Windsurf,browseruse,chromium,devin,github.com.thewh1teagle.vibe,kaggle,obs-studio,onedrive,opera,vivaldi,vivaldi-snapshot,viperx,xarchiver,jupyterlab-desktop,google-chrome-beta,google-chrome-unstable,google-chrome-for-testing,microsoft-edge-beta,microsoft-edge-dev,eog,gogcli,ggs,vercel-plugin,zoom.conf,zoomus.conf}` + `~/.local/share/{devin,qalculate,totem,vlc,hyprland,opentui,rhythmbox,meld,tirith,nemo,nemo-python,onedriver}` |
| `k-desktop-mcp.py` | `~/.local/bin/k-desktop-mcp.py` removed (no longer used) |
| `bw-admin` / `bw-mcp` | `~/.local/bin/bw-admin`, `~/.local/bin/bw-mcp` broken symlinks removed (`/opt/bw-mcp` no longer exists); references archived in `k-bw/references/purged.md` |

---

## Appendix — How to Rebuild This List

```bash
# System desktop apps
for f in /usr/share/applications/*.desktop; do grep -m1 '^Name=' "$f"; done | sort
# User desktop apps
for f in ~/.local/share/applications/*.desktop; do grep -m1 '^Name=' "$f"; done | sort
# GUI snaps
snap list
# /opt heavy clients
ls /opt/
```

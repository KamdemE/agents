---
name: k-dxo
description: DxO internship infrastructure — VPN, RDP, accounts, and remote access procedures.
metadata:
  author: KpihX
  version: "1.6.0"
  scope: infrastructure
---

# KπX — DxO Internship Infrastructure

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (workstation) · `k-blglaptop139` (Windows workstation at DxO) · `k-deep-pc6` (DxO Linux server) · `k-clis` (CLI registry)

## Accounts

| Service | Username | Domain | Notes |
|---------|----------|--------|-------|
| Windows / VPN / Atlassian on-prem | `ikamdem` | `corp.dxo.com` | Initial password: `chanGE*me951` (change on first login with Ctrl+Alt+Del) |
| Mail / Jira / Confluence Cloud | `ikamdem@dxo.com` | — | Same password as Windows. Outlook pre-configured on BLGLAPTOP139. Webmail: https://webmail.dxo.com |
| Microsoft Authenticator MFA | `ikamdem@dxo.com` | — | Set up via https://myapplications.microsoft.com |
| Slack | `ikamdem@dxo.com` | — | Invitation sent by email |
| Adobe CC Photography | — | — | Invitation sent by email |

## CLI Tools

| CLI | Path | Purpose |
|-----|------|---------|
| `tmux6` | `k-dxo/assets/tmux6` (symlink → `~/.local/bin/`) | SSH + tmux to deep-pc6 server (issue guidance: echoes what to do if VPN/SSH fails) |
| `ollama6` | `k-dxo/scripts/ollama6` (symlink → `~/.local/bin/`) | Ollama CLI proxy to deep-pc6 (core only: on issue, tells you to start VPN/tunnel services) |

## VPN (GlobalProtect)

### Ubuntu workstation (this machine)

**Management:** native systemd — the `vpn-dxo` CLI wrapper was removed (2026-08-03). Control the unit directly with `systemctl` / `journalctl`.

**Dependencies:**
- `openconnect` (apt package) — the underlying VPN client
- `systemd` — runs VPN as a root service for clean lifecycle
- `gpclient` wrapper (handles GlobalProtect cookie auth)

**How it works:** The root systemd unit `vpn-dxo.service` (source of truth stored in `k-dxo/assets/vpn-dxo.service`, symlinked to `/etc/systemd/system/vpn-dxo.service`) launches `gpclient --ignore-tls-errors --fix-openssl connect vpn-ext.dxo.com`. Because `gpclient` requires access to the user's SAML cookie stored in the GNOME keyring (`libsecret`), the unit explicitly sets `SUDO_USER=kpihx`, `SUDO_UID=1000`, and `SUDO_GID=1000` to correctly route the keyring request without spawning `gpauth` interactively as root.

```bash
sudo systemctl start vpn-dxo        # start VPN (prompts for sudo password)
sudo systemctl stop vpn-dxo         # graceful disconnect
systemctl status vpn-dxo            # service state + last journal lines
systemctl is-active vpn-dxo         # quick check: active / inactive
journalctl -u vpn-dxo -n 50         # last 50 log lines
journalctl -u vpn-dxo -f            # follow live journal
systemctl show vpn-dxo              # full unit properties (ExecStart, Environment, Restart policy)
```

After connecting, the tunnel stays active in the background. The service is **not enabled at boot** (on-demand), so it occupies **zero RAM** when stopped. At session expiry (30 days), the service will exit cleanly; manual restart interactively may be required to trigger the WebKit MFA popup.

### Windows (BLGLAPTOP139)

Simpler — native GlobalProtect client from DxO:
1. Go to https://vpn-ext.dxo.com (connect with DxO mail + password, approve with Microsoft Authenticator)
2. Download Windows 64-bit version, install with defaults
3. Connect to portal `vpn-ext.dxo.com` (no https) using the same credentials
4. A GlobalProtect icon appears in the system tray

## Remote Desktop (RDP)

### Windows → BLGLAPTOP139 (native)

Built-in Remote Desktop Connection (mstsc.exe):
- **Computer:** `BLGLAPTOP139`
- **Username:** `corp.dxo.com\ikamdem`
- **Password:** Windows password (same as above)

### Ubuntu → BLGLAPTOP139 (Remmina)

Remmina profile (saved):
- **Server:** `BLGLAPTOP139.corp.dxo.com`
- **Username:** `ikamdem` (domain: `corp.dxo.com`)
- **Resolution:** Use client resolution
- **Multi-monitor:** Span screen over multiple monitors (optional)
- **Audio:** `sound=local`, `microphone=local`

RDP is only accessible when the DxO VPN is connected.

## Ollama via deep-pc6 (`ollama6`)

**CLI:** `ollama6` (script in `k-dxo/scripts/ollama6`, symlinked to `~/.local/bin/`)

**Purpose:** Run the standard `ollama` CLI against deep-pc6's Ollama server (127.0.0.1:11434 on deep-pc6 — localhost only, 2× RTX 3090) through the local tunnel endpoint on port **11436**. Core function only — no merged responsibility: `ollama6` does NOT manage the VPN or the tunnel; on issue it tells you what to do.

**Architecture (v1.5.0):** the tunnel is a **systemd USER service** `ollama6-tunnel.service` (source: `k-dxo/assets/ollama6-tunnel.service`, symlinked to `~/.config/systemd/user/`). No tmux. Its `ssh -N -v` runs verbose so `journalctl --user` shows the live tunnel logs. The VPN is `vpn-dxo.service` (system). Both are on-demand (not enabled at boot).

**How it works:**
1. Checks whether `http://127.0.0.1:11436` answers (the tunnel endpoint). If yes, runs `ollama` directly with `OLLAMA_HOST` set to that endpoint (ollama 0.9.3 has NO `--host` flag — `OLLAMA_HOST` is the supported mechanism, verified).
2. If the port does NOT answer, prints what to do: start the VPN (`sudo systemctl start vpn-dxo`) and/or the tunnel (`systemctl --user start ollama6-tunnel.service`), and how to check logs. Exits 1 — it never starts services itself.

```bash
ollama6 list                          # list deep-pc6's models (tunnel must be up)
ollama6 run ministral-3:8b "say OK"   # stream an answer from deep-pc6
# Tunnel service (manage it yourself):
systemctl --user start ollama6-tunnel.service        # start the tunnel
systemctl --user status ollama6-tunnel.service       # tunnel state
journalctl --user -u ollama6-tunnel.service -f       # follow live tunnel logs
systemctl --user stop ollama6-tunnel.service         # stop the tunnel
```

**Notes:**
- `ollama6` passes ALL arguments through to ollama (no reserved subcommands) — it is a pure proxy.
- The tunnel service is independent: `Restart=on-failure` (auto-recovers on VPN drop), idempotent re-start.

## Important notes

- **Do NOT turn off the computer at DxO** — it must remain on for remote access
- Always work on the DxO PC over RDP — do not access internal DxO resources from the personal computer directly
- The VPN only allows internet access on the `DxO-Public` Wi-Fi; internal resources require the GlobalProtect VPN
- The `vpn-dxo.service` unit on Ubuntu uses `gpclient` (openconnect-based), which may open a WebKit popup for MFA — follow the prompts

## Assets

| File | Purpose |
|------|---------|
| `assets/tmux6` | SSH+tmux launcher for deep-pc6 (symlinked to `~/.local/bin/`, issue guidance on VPN/SSH failure) |
| `assets/vpn-dxo.service` | systemd system service for DxO VPN (symlinked to `/etc/systemd/system/`) |
| `assets/ollama6-tunnel.service` | systemd USER service for the deep-pc6 Ollama tunnel (symlinked to `~/.config/systemd/user/`) |
| `assets/rclone-deep-pc6.service` | systemd user service for rclone mount of DxO PC6 remote |
| `scripts/ollama6` | Ollama CLI proxy to deep-pc6 (core only — on issue tells you to start VPN/tunnel services) |
| `scripts/opencode-ollama6.sh` | Ollama6 wrapper + OpenCode model sync (sourced from `.kshrc`). |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-08 | [OPENCODE] | v1.6.0 — **`opencode-ollama6.sh` script integrated** : integrated the OpenCode Ollama6 wrapper into `k-dxo/scripts/opencode-ollama6.sh` (moved from `k-opencode`) and updated the assets documentation. |
| 2026-08-03 | [OPENCODE] | v1.5.0 — `ollama6` redone: tunnel is now a systemd USER service (`assets/ollama6-tunnel.service` → `~/.config/systemd/user/`), NO tmux; `ollama6` is core-only (pure ollama proxy to deep-pc6, no reserved subcommands) and on issue tells the user to start `vpn-dxo.service` / `ollama6-tunnel.service`. `tmux6` gained issue guidance (echoes what to do when VPN/SSH fails). |
| [SUMMARY] | — | Older changelog entries were copied to `references/log.md`; the live table keeps only the two newest entries. |

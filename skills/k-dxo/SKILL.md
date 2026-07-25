---
name: k-dxo
description: DxO internship infrastructure — VPN, RDP, accounts, and remote access procedures.
metadata:
  author: KpihX
  version: "1.1.0"
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
| `vpn-dxo` | `k-dxo/scripts/vpn-dxo` (symlink → `~/.local/bin/`) | GlobalProtect VPN connection via tmux |
| `tmux6` | `k-dxo/assets/tmux6` (symlink → `~/.local/bin/`) | SSH + tmux to deep-pc6 server |

## VPN (GlobalProtect)

### Ubuntu workstation (this machine)

**CLI:** `vpn-dxo` (script in `k-dxo/scripts/vpn-dxo`, symlinked to `~/.local/bin/`)

**Dependencies:**
- `openconnect` (apt package) — the underlying VPN client
- `tmux` — runs VPN in persistent session
- `gpclient` wrapper (handles GlobalProtect cookie auth)

**How it works:** The script launches `sudo gpclient --ignore-tls-errors --fix-openssl connect vpn-ext.dxo.com` inside a tmux session named `vpn-dxo`. The `--ignore-tls-errors` and `--fix-openssl` flags are needed because DxO uses a self-signed certificate and OpenSSL 3+ requires legacy renegotiation.

```bash
vpn-dxo            # start VPN (or attach if already running)
vpn-dxo stop       # kill VPN session
vpn-dxo status     # check if VPN is connected
```

After connecting, a WebKit popup appears for Microsoft auth (email + MFA via Authenticator). The tunnel stays active in the tmux session in the background.

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

## Important notes

- **Do NOT turn off the computer at DxO** — it must remain on for remote access
- Always work on the DxO PC over RDP — do not access internal DxO resources from the personal computer directly
- The VPN only allows internet access on the `DxO-Public` Wi-Fi; internal resources require the GlobalProtect VPN
- `vpn-dxo` on Ubuntu uses `gpclient` (openconnect-based), which may open a WebKit popup for MFA — follow the prompts

## Assets

| File | Purpose |
|------|---------|
| `assets/tmux6` | SSH+tmux launcher for deep-pc6 (symlinked to `~/.local/bin/`) |
| `assets/rclone-deep-pc6.service` | systemd user service for rclone mount of DxO PC6 remote |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-25 | [OPENCODE] | v1.1.0 — Added tmux6 CLI and rclone-deep-pc6.service in assets/. |
| 2026-07-24 | [OPENCODE] | v1.0.0 — Created k-dxo: moved vpn-dxo from k-ubuntu, added accounts, VPN, RDP, setup procedures. |
| [SUMMARY] | — | — |

---
name: k-dxo
description: DxO internship infrastructure — VPN, RDP, accounts, and remote access procedures.
metadata:
  author: KpihX
  version: "1.7.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KπX — DxO Internship Infrastructure

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (workstation) · `k-blglaptop139` (Windows workstation at DxO) · `k-deep-pc6` (DxO Linux server) · `k-windows` (generic Windows/MSYS2 mechanics — the `.cmd` launchers referenced below live there, since they carry no DxO-specific values themselves) · `k-clis` (CLI registry)
>
> **🔴 Scope discipline (why this skill exists as its own thing):** everything in this skill is DxO-internship-internal by design — accounts, VPN, RDP targets, deep-pc6 access. The goal is that **deleting this one skill at internship end leaves zero DxO-internal residue anywhere else** in the kernel. Never let a DxO-specific value (an internal hostname, IP, domain-qualified username, VPN portal) leak into a generic skill (`k-windows`, `k-blglaptop139`, `k-ollama`, …) — if it's DxO-specific, it belongs here, even if the *mechanism* around it is generic and documented elsewhere.

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

> This is a specific instance of the generic **corporate SSL-VPN + RDP remote-access pattern** — see `k-windows/references/remote-desktop.md` for that pattern written up company-agnostically (and its native-RDP/Chrome-Remote-Desktop mechanism reference). Nothing DxO-specific belongs there; nothing generic belongs here.

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

## Access to deep-pc6 from Windows (BLGLAPTOP139) — mounted as `Z:`

Mounted so deep-pc6's filesystem appears in Explorer like a local drive (same idea as WSL's `\\wsl.localhost\Ubuntu`).

**Software:** WinFSP 2.1.25156, rclone 1.74.3 (chosen over SSHFS-Win — bypassed due to the `\` in the domain-qualified username breaking it), nssm 2.24 (Windows service wrapper).

```powershell
winget install --id WinFsp.WinFsp -e
winget install --id Rclone.Rclone -e
```

**SSH config** (`%USERPROFILE%\.ssh\config`) — full block: `assets/ssh_config`.
```
Host deep-pc6
    HostName 172.16.150.163
    User corp\ikamdem
    PreferredAuthentications publickey,password
    IdentityFile ~/.ssh/id_ed25519_deep_pc6
```
Public key on file: `assets/id_ed25519_deep_pc6.pub` (comment `IKamdem`) — private key never stored in the kernel, lives only on disk on this laptop.

**rclone config** (`%APPDATA%\rclone\rclone.conf`):
```
[deep-pc6]
type = sftp
host = 172.16.150.163
user = corp\ikamdem
key_file = C:\Users\ikamdem\.ssh\id_ed25519_deep_pc6
key_use_agent = false
```

**Manual mount/unmount:**
```powershell
rclone mount deep-pc6: Z: --network-mode --volname "deep-pc6 (deep-pc6)" --vfs-cache-mode writes --dir-cache-time 10m
net use Z: /delete
taskkill /f /im rclone.exe
```

**Autostart** — nssm service `rclone-deep-pc6` (`LocalSystem`, `AppNoConsole=1`, auto-restart on crash, depends on `LanmanWorkstation`). Before 2026-07-16 this ran as a scheduled task + PowerShell wrapper, but the Windows Job Object killed rclone when the task closed — switched to a real nssm service. Scripts: `assets/mount-deep-pc6.bat` / `assets/unmount-deep-pc6.bat` — these are the DxO-specific fill-in of the **generic** rclone/WinFsp/nssm SSH-mount pattern documented in `k-windows/references/ssh-mount.md` (template: `k-windows/assets/ssh-mount/`).

```powershell
nssm install "rclone-deep-pc6" "<path-to-rclone.exe>" mount deep-pc6: Z: --network-mode ...
nssm set "rclone-deep-pc6" AppNoConsole 1
Start-Service -Name "rclone-deep-pc6"
Get-Service -Name "rclone-deep-pc6"
```

**Troubleshooting:**
- "No host key validation is being performed" → normal warning, no action.
- Mount fails at boot → network not ready yet; the `.bat` script waits 15s + retries 3× (5s apart).
- "Access denied" → test with `ssh deep-pc6 "echo OK"`.
- "Connection reset by peer" → SFTP subsystem missing on deep-pc6; check `grep Subsystem /etc/ssh/sshd_config` there — must contain `Subsystem sftp /usr/lib/openssh/sftp-server`.

**`tmux6`/`ollama6` on Windows** — same purpose as the Ubuntu `assets/tmux6` / `scripts/ollama6` below, implemented as `.cmd` launchers for MSYS2/cmd.exe. The launchers themselves live in **`k-windows/assets/msys2/tmux6.cmd`** and **`k-windows/assets/msys2/ollama6.cmd`** — they carry no DxO-specific values (the `deep-pc6` name only resolves via the SSH config Host block above), so the generic mechanism stays in `k-windows`; this skill just documents that it's the same DxO-internal target.

## `framework-internship-culling` project

Private DxO GitHub repo (`git@github.com:dxo-labs-rd/framework-internship-culling.git`) — the internship's ML codebase. Data syncs from DxO's internal network drive (`O:`, `\\00-dxo.corp.dxo.com\800-IMAGESDB`, domain `corp`). **Not migrated here** — it's DxO's code/data, stays in that repo, never copied into this personal kernel. The project has its own `.agents/skills/k-pptx` (deck-generation skill, more advanced than this kernel's current `k-pptx`) — a separate migration candidate, tracked outside this skill.

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
| `assets/ssh_config` | Windows-side `~/.ssh/config` `Host deep-pc6` block (IP, domain user, key path) |
| `assets/id_ed25519_deep_pc6.pub` | Public key for deep-pc6 SSH/rclone auth (comment `IKamdem`) — private key never stored here |
| `assets/mount-deep-pc6.bat` | Windows autostart mount script (retry/log logic) for the `Z:` rclone mount |
| `assets/unmount-deep-pc6.bat` | Windows unmount script for the `Z:` rclone mount |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-dxo/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-dxo/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-25 | [CLAUDE] | v1.7.0 — Added `allowed-tools` frontmatter (was missing, unlike `k-deep-pc6`/`k-blglaptop139`). Merged in the Windows-side (BLGLAPTOP139) half of deep-pc6 access, migrated from an unversioned Windows-side `.agents` at real risk of loss: `Z:` rclone/nssm mount (SSH config, rclone config, mount/unmount, nssm service, troubleshooting — new assets `ssh_config`, `id_ed25519_deep_pc6.pub`, `mount-deep-pc6.bat`, `unmount-deep-pc6.bat`), plus a pointer section to `framework-internship-culling` (DxO's private repo — code/data never migrated, only acknowledged). The Windows `tmux6.cmd`/`ollama6.cmd` launchers themselves went to the new `k-windows` skill instead (no DxO-specific values inside them) — this skill just documents they're the same DxO-internal target. Added Insights Discipline + `references/insights.md` (were missing). Follow-up re-audit the same day (`k-blglaptop139` will also be abandoned at internship end since the laptop itself belongs to DxO, not just this skill) cross-referenced the VPN/RDP section to `k-windows/references/remote-desktop.md`'s new generic corporate-VPN+RDP pattern note. |
| 2026-08-08 | [OPENCODE] | v1.6.0 — **`opencode-ollama6.sh` script integrated** : integrated the OpenCode Ollama6 wrapper into `k-dxo/scripts/opencode-ollama6.sh` (moved from `k-opencode`) and updated the assets documentation. |
| [SUMMARY] | — | v1.5.0 `ollama6` redone as systemd USER service, no tmux, core-only proxy; `tmux6` gained issue guidance (→ `references/log.md`) · older rows in `references/log.md`. |

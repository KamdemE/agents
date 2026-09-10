# k-tailscale — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-laptop` (laptop)

---

## Native Windows Tailscale

Tailscale runs natively on Windows. Install:

```powershell
winget install Tailscale.Tailscale
```

Or download from https://tailscale.com/download.

The Windows app provides:
- System tray icon for status and settings
- GUI for managing serve/funnel (limited — CLI preferred for advanced ops)
- Tailscale SSH daemon (optional)
- Automatic connectivity

## Tailscale in WSL

When Tailscale is installed on Windows, WSL2 automatically routes through the Windows Tailscale instance. No additional Tailscale installation needed inside WSL.

### Key Details

- WSL2 forwards `localhost` to Windows — Tailscale MagicDNS works inside WSL
- `tailscale status` from WSL shows the **Windows host's** Tailscale identity (not a separate WSL identity)
- The WSL instance shares the Windows Tailscale IP
- For a separate WSL identity, install Tailscale **inside WSL** (needed whenever the WSL distro must be its own SSH/tmux/CLI-agent target — e.g. `laptop-wsl`, see naming convention below)

### Separate Tailscale in WSL (if needed)

```bash
# Inside WSL
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --hostname=<host>-wsl
```

This registers WSL as a **separate node with its own IP**, distinct from the Windows host's native Tailscale node.

### ⚠️ Naming convention — dual Windows/WSL identity

When a machine runs Tailscale **both** natively on Windows AND inside WSL, the two are separate nodes in the tailnet and MUST be named to disambiguate:

| Node | Hostname pattern | Example |
|------|-------------------|---------|
| Native Windows | `<host>` | `laptop` |
| WSL (separate install) | `<host>-wsl` | `laptop-wsl` |

- Set the WSL node's hostname explicitly at `tailscale up` time (`--hostname=<host>-wsl`), or rename after the fact with `sudo tailscale set --hostname=<host>-wsl`.
- Without this, `tailscale status` is ambiguous about which OS/tmux-session/SSH-target a given tailnet entry actually reaches — the `-wsl` suffix makes the OS column (`linux` vs `windows`) redundant-but-confirmed at a glance.
- Document both identities in the infra skill's `## Host Identity` table (see `k-laptop`).

## CLI Access

From PowerShell:
```powershell
& "C:\Program Files\Tailscale\tailscale.exe" status
```

From WSL:
```bash
tailscale status   # if using Windows Tailscale routing
```

## Serve on Windows

Tailscale Serve works on Windows identically to Linux. The `--bg` flag ensures the proxy survives terminal closure.

```powershell
tailscale serve --https 1443 http://127.0.0.1:4097
```

Note: On Windows, `tailscale serve` runs as a Windows service, not a systemd unit.

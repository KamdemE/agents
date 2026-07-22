# k-tailscale — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-blglaptop139` (blglaptop139)

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
- For a separate WSL identity, install Tailscale **inside WSL** (rarely needed)

### Separate Tailscale in WSL (if needed)

```bash
# Inside WSL
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

This registers WSL as a separate node with its own IP.

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

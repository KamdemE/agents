# k-tmux — Windows / WSL

> **OS reference:** Windows (with WSL subsystem)  
> **Applies to:** `k-blglaptop139` (blglaptop139) and any Windows machine running WSL

---

## WSL tmux Access

tmux is a Linux-native tool. On Windows, it runs inside WSL (Windows Subsystem for Linux). It is NOT available natively on Windows — there is no native Windows tmux.

### Prerequisites

- WSL2 with a Linux distribution installed (Ubuntu recommended)
- tmux installed in WSL: `sudo apt install tmux`

### SSH Access to WSL

To connect to the WSL environment from outside (e.g., from the Ubuntu workstation), WSL must run an SSH server:

```bash
# Inside WSL
sudo apt install openssh-server
sudo service ssh start
```

Then from Ubuntu: `ssh kapoivha@blglaptop139` (Tailscale SSH).

### Alias Pattern

On Windows, typical workflows either:
1. Open a WSL terminal (Ubuntu tab in Windows Terminal) — tmux works natively inside
2. SSH into WSL from another machine — tmux works natively on the remote session

No special alias needed when already inside WSL. If accessing a Windows-native shell (PowerShell, cmd), use:
```powershell
wsl tmux   # Launch tmux inside WSL from PowerShell
```

### Limitations

- Copy-mode paste from Windows clipboard requires `tmux set-option -g default-command ""` workaround in some WSL configurations
- Systemd integration in WSL2 is optional — if `systemd` is not enabled, tmux sessions are tied to the WSL instance lifecycle
- No native tmux on Windows — do NOT attempt to install via `winget` or `choco`

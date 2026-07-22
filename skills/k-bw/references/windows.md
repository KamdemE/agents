# k-bw — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-blglaptop139` (blglaptop139)

---

## bw-env (WSL-only)

`bw-env` is Linux-specific (`/dev/shm`, shell injection via `.kshrc`). On Windows, it runs **exclusively inside WSL**.

**Prerequisites:**
1. WSL2 with Ubuntu installed
2. The `.agents/` kernel cloned in WSL
3. `.kshrc` sourced in WSL shell

`bw-env` commands work identically inside WSL:
```bash
bw-env unlock   # prompts for master password
bw-env sync     # syncs vault
```

## bw-proxy (Cross-platform)

`bw-proxy` uses a browser-based approval UI and works from Windows natively or via WSL. Access the approval page at `http://localhost:1138`.

## bw CLI

Install inside WSL:
```bash
sudo apt install bitwarden-cli
```

Or natively on Windows:
```powershell
winget install Bitwarden.CLI
```

## Vault Access

The vault URL `https://vault.kpihx-labs.com` is Tailscale-only. The Windows machine must have Tailscale connected to access it — same as any other machine.

## Bitwarden Desktop SSH Agent — WSL Bridge

The Bitwarden desktop app runs on Windows and uses a **named pipe** (`\\.\pipe\openssh-ssh-agent`) instead of a Unix socket. To use it from WSL, you need `npiperelay` + `socat` to bridge the pipe into a Unix socket.

### Activation (Windows desktop app)

1. **Open Bitwarden desktop app**, unlock your vault.
2. **Settings → SSH Agent → Enable SSH agent ON**
3. **Set authorization to "Remember until vault is locked"**
4. **Create an SSH key**: `+` → `SSH key` → save

### Disable Windows OpenSSH service (PowerShell admin)

```powershell
Stop-Service ssh-agent -Force
Set-Service -Name ssh-agent -StartupType Disabled
```

### Install npiperelay (Windows)

```powershell
winget install --id=albertony.npiperelay -e
```

### Install socat + create bridge (WSL)

```bash
sudo apt-get update && sudo apt-get install -y socat

# Create bridge script
mkdir -p ~/scripts
cat > ~/scripts/agent-bridge.sh << 'EOF'
#!/bin/bash
USERNAME=$(/mnt/c/WINDOWS/system32/cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d "\r\n")
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
ss -a | grep -q "$SSH_AUTH_SOCK"
if [ $? -ne 0 ]; then
  rm -f "$SSH_AUTH_SOCK"
  (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork \
     EXEC:"/mnt/c/Users/$USERNAME/AppData/Local/Microsoft/WinGet/Packages/albertony.npiperelay_Microsoft.Winget.Source_8wekyb3d8bbwe/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi
EOF
chmod +x ~/scripts/agent-bridge.sh

# Source in .zshrc
echo "source ~/scripts/agent-bridge.sh" >> ~/.zshrc
```

### Alternative — IdentityAgent in SSH config

Add to `~/.ssh/config` in WSL:

```
Host *
  IdentityAgent //./pipe/openssh-ssh-agent
```

### Troubleshooting

- **Pipe blocks after ~1h** → restart Bitwarden desktop app (known upstream issue)
- **`ssh-add -L` fails** → Bitwarden running? Vault unlocked? SSH Agent enabled in Settings?
- **Socket not found** → `ls -la ~/.ssh/agent.sock`; toggle SSH Agent off/on
- **Alternative stable setup** → use Linux desktop Bitwarden via WSLg (drops Windows pipe entirely, uses `SSH_AUTH_SOCK` directly)

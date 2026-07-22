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

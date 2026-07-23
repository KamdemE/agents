# k-bw — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (kpihx-ubuntu workstation)

---

## Vaultwarden (Linux-specific)

`Vaultwarden` uses `/dev/shm` (RAM-only tmpfs) for secret injection — this is a Linux-specific feature. It requires:

- Linux kernel with `/dev/shm` mounted (default on Ubuntu)
- Shell via `.kshrc` sourcing (Vaultwarden injects into shell environment)
- GPG for cold-start backup encryption

**Location:** `$HOME/.agents/skills/k-ubuntu/scripts/secrets/`

## bw-proxy (Cross-platform)

`bw-proxy` uses a browser-based approval UI (Web HITL on `localhost:1138`) and works on any OS with a browser. No OS-specific setup required.

## bw CLI

The Bitwarden CLI (`bw`) is installed via:
```bash
sudo apt install bitwarden-cli
# Or via npm:
npm install -g @bitwarden/cli
```

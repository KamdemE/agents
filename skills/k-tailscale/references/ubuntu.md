# k-tailscale — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (kpihx-ubuntu workstation)

---

## Installation

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

## Systemd Service Paths

| File | Path | Purpose |
|------|------|---------|
| System service file | `/lib/systemd/system/tailscaled.service` | Default unit (from package) |
| Override | `/etc/systemd/system/tailscaled.service` | Local override (symlink to skill asset) |
| Config | `/etc/default/tailscaled` | Daemon flags (symlink to skill asset) |
| State | `/var/lib/tailscale/tailscaled.state` | Persistent state |
| Socket | `/run/tailscale/tailscaled.sock` | Local API socket |

## Service Management

```bash
sudo systemctl status tailscaled
sudo systemctl restart tailscaled
sudo journalctl -u tailscaled -f
```

## Up

```bash
sudo tailscale up --accept-routes=true --accept-dns=true --operator=kpihx
```

This enables:
- `--accept-routes=true`: Accept subnet routes from peers (e.g., `10.10.10.0/24` from kpihx-pve)
- `--accept-dns=true`: Use Tailscale DNS (MagicDNS)
- `--operator=kpihx`: Allow `tailscale` CLI without sudo for the kpihx user

## Assets

The canonical service override and config live in the skill's `assets/` directory:
- `assets/tailscaled.service` → `/etc/systemd/system/tailscaled.service`
- `assets/tailscaled-config` → `/etc/default/tailscaled`

Edit the assets, then:
```bash
sudo systemctl daemon-reload
sudo systemctl restart tailscaled
```

## Firewall

Tailscale WireGuard port `41641/udp` must be allowed through nftables. See `k-nftables` for the current ruleset.

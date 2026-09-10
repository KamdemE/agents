# k-tailscale — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (workstation workstation)

---

## Installation

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

## Systemd Service Paths

| File | Path | Purpose |
|------|------|---------|
| System service file | `/lib/systemd/system/tailscaled.service` | Default unit (from package) |
| Override | `/etc/systemd/system/tailscaled.service` | Local override — REAL FILE since 2026-08-24 (stock Tailscale-managed, de-linked from skill per maintainer decision) |
| Config | `/etc/default/tailscaled` | Daemon flags — REAL FILE since 2026-08-24 (de-linked from skill per maintainer decision) |
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

NONE in `.agents` since 2026-08-24 (de-link per maintainer decision): `tailscaled.service` and `/etc/default/tailscaled` are stock Tailscale-managed files with zero  customization — they live directly in `/etc` as real files and Tailscale governs them. To customize, edit the `/etc` files directly, then:
```bash
sudo systemctl daemon-reload
sudo systemctl restart tailscaled
```

## Firewall

Tailscale WireGuard port `41641/udp` must be allowed through nftables. See `k-nftables` for the current ruleset.

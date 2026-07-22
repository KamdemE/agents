# k-nftables — Insights

## 2026-07-21 — Initial creation

- Priority `-10` is critical: nftables must run BEFORE iptables-nft chains (Docker, Tailscale) which default to `priority 0`.
- `flags interval` is mandatory for CIDR elements in sets; without it, CIDR notation `100.64.0.0/10` is a syntax error.
- Docker Swarm ports 4789/8472/10442 must ALL be open for overlay networks to work across hosts.
- `policy drop` on INPUT without a catch-all allow for established/related traffic WILL lock you out — rule #2 (`ct state established,related accept`) is essential.
- The tailscale_nets set (100.64.0.0/10) covers all Tailscale IPs. Individual Tailscale IPs are allocated from this CGNAT range.
- nftables.conf is maintained in `$HOME/.config/opencode/skills/k-nftables/assets/` and symlinked from `/etc/`. Always edit the asset and let the symlink propagate.
- systemd `ProtectHome=true` in nftables.service blocks symlink resolution into `/home/`. Fixed via drop-in `/etc/systemd/system/nftables.service.d/protect-home.conf` setting `ProtectHome=read-only`.
- Use `sudo nft -f /etc/nftables.conf` for live reload (no service restart needed).
- After editing the asset with the Write tool, the inode changes but the symlink still resolves correctly since it points to the path, not the inode.

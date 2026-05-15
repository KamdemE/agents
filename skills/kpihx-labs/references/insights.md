# k-homelab Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- `homelab` denies direct access to `/var/run/docker.sock` for user `kpihx`; operational container inventory must use `sudo docker ...` or an equivalent privileged path.
- Live stack discovery on `homelab` is more reliable through Docker labels (`com.docker.compose.project` / `service`) than through compose-file search alone, because several active stacks no longer have an obvious compose file under `/root`.
- On `kpihx-pve`, the working DNS pattern for the `homelab` CT (`100`) is explicit Proxmox-managed resolvers in CT config (`nameserver:`) that materialize into a static `/etc/resolv.conf`; for Debian cloud VMs, masking `systemd-resolved` without replacing the `/etc/resolv.conf` symlink leaves the guest with `No DNS servers known` even when `qm config` has a nameserver set.

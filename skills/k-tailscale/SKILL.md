---
name: k-tailscale
description: >
  KπX Tailscale — generic installation, status, peers, routes, serve, funnel,
  DERP, ACL management, and troubleshooting. This skill covers Tailscale
  patterns that work on any OS. Machine-specific identity (hostname, IPs,
  DNS, serve config) lives in the relevant infra skill (e.g., k-ubuntu).
  Load before any tailscale serve, funnel, accept-routes, peer, or port
  management task.
metadata:
  version: 2.2.0
  author: KpihX
  scope: network
---

# KπX — Tailscale Generic Operations

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **OS references:** `references/ubuntu.md` (systemd service paths, apt install) · `references/windows.md` (WSL setup, native Windows Tailscale)
> **Machine identity:** See `k-ubuntu` (this workstation) or the relevant infra skill for hostname, IPs, DNS, serve config, and peer state.
> **Canonical assets:** NONE in `.agents` since 2026-08-24 — `tailscaled.service` + `/etc/default/tailscaled` are stock Tailscale-managed files with zero KπX customization: they live directly in `/etc` (real files, no symlinks) and Tailscale governs them (de-link per KπX order).

---

## Installation

### Linux (Ubuntu/Debian)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

### Windows

Download from https://tailscale.com/download or:
```powershell
winget install Tailscale.Tailscale
```

### Verification

```bash
tailscale version
tailscale status
```

---

## Essential Commands

```bash
# Status
tailscale status
tailscale status --json

# Serve (proxy HTTPS tailnet)
tailscale serve status
tailscale serve status --json
sudo tailscale serve --bg --yes --https <port_ts> http://127.0.0.1:<local_port>
sudo tailscale serve --https <port_ts> off

# Funnel (expose to internet)
tailscale funnel status

# Network check
tailscale netcheck

# Ping a peer
tailscale ping --c 3 --verbose <IP>

# Peer info
tailscale whois <IP>

# Debug
tailscale bugreport

# Configuration up
# ⚠️ Launch via tmux ops pane (k-tmux SUDO GATE) — never raw sudo in agent shell
sudo tailscale up --accept-routes=true --accept-dns=true --operator=<user>
```

---

## Serve — Adding a New Service

1. Start the local service on a free port >1024
2. Add the proxy:
   ```bash
   sudo tailscale serve --bg --yes --https <port_ts> http://127.0.0.1:<local_port>
   ```
3. Verify: `tailscale serve status`
4. Port convention: sequential series 1xxx, 2xxx, 3xxx (1443, 2443, 3443...)

**Flags:**
- `--bg` = background — **required** for persistence (without it, config is lost on Ctrl+C)
- `--yes` = skip interactive confirmation
- `sudo` needed for first call (sudo timestamp allows subsequent calls)

---

## Funnel (Internet Exposure)

Funnel exposes tailnet services to the public internet. Use with caution — prefer tailnet-only Serve when possible.

```bash
# Enable funnel on a port
sudo tailscale funnel --bg --yes --https <port> http://127.0.0.1:<local_port>

# Disable
sudo tailscale funnel --https <port> off

# Status
tailscale funnel status
```

---

## DERP (Relay Servers)

Tailscale uses DERP relays when direct connections are unavailable. List global DERP servers:

```bash
tailscale netcheck
```

Key regions: `par` (Paris), `lhr` (London), `ams` (Amsterdam), `fra` (Frankfurt), `nyc` (New York), `sfo` (San Francisco), `sin` (Singapore), `syd` (Sydney), `hkg` (Hong Kong), `tyo` (Tokyo), plus 16+ others worldwide.

---

## Routes & Subnets

### Accept Routes

Enable subnet routes from peers:
```bash
sudo tailscale up --accept-routes=true --accept-dns=true --operator=<user>
```

### Advertise a Subnet (on the machine hosting it)

```bash
sudo tailscale up --advertise-routes=<subnet/cidr>
```

### Check Advertised Routes

```bash
tailscale status --json | jq '.Peer[] | select(.HostName == "<peer>") | .AllowedIPs'
```

---

## ACL (Access Control)

Tailscale ACLs are managed via the Tailscale admin console or API. Key patterns:
- Tagged devices (e.g., `tag:server`) are managed independently of user accounts
- ACL rules define which tags/users can access which resources
- Default: all users can access all their own devices; tagged devices follow ACL rules

---

## Troubleshooting

```bash
# Check local service is listening
ss -tlnp | grep <port>

# "No serve config" after configuring
# → you forgot --bg

# Peer unreachable
tailscale ping --c 3 --verbose <IP>
# → if DERP only, no direct → check firewall port 41641/udp

# Slow connection
tailscale netcheck
# → check nearest DERP and latency

# Logs
journalctl -u tailscaled -f  # Linux (systemd)
```

---

## Reserved Ports

| Port | Usage |
|------|-------|
| `41641/udp` | WireGuard mesh between all peers |
| Variable (e.g., `59210`) | Source ephemeral DERP (changes on tailscaled restart) |

---

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.
- Keep insights autonomous and evolutionary.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [COLAB] | v2.2.0 — De-linked `tailscaled.service` + `/etc/default/tailscaled` from `.agents` per KπX order: stock Tailscale-managed files with zero KπX customization now live directly in `/etc` as real root-owned files (Tailscale governs them); skill assets purged from `assets/`; registry entries removed from `links.jsonc` + `services.jsonc` (explanatory comments kept); `references/ubuntu.md` service-paths table + Assets section rewritten to document the de-link; "Canonical assets" header note replaced by de-link notice. Backups of the exact live content preserved at `/tmp/opencode/tailscaled*.bak`. Service verified active after daemon-reload. |
| 2026-07-22 | [OPENCODE] | v2.1.0 — Added SUDO GATE warning to `tailscale up`: must be launched via tmux ops pane. |
| [SUMMARY] | — | v2.0.0 generic core (→ `references/log.md`) · v1.2.0 assets symlinks · v1.1.0 full rewrite · v1.0.0 creation |

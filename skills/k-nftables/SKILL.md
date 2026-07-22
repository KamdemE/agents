---
name: k-nftables
description: >
  KpihX nftables firewall — ruleset reference, interface inventory, service
  management, and troubleshooting. Load before any nftables, firewall, or
  network security task on the Ubuntu workstation.
metadata:
  version: 1.1.0
  author: KpihX
  scope: system-firewall
---

# KpiX — nftables

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Canonical ruleset:** `assets/nftables.conf` — system `/etc/nftables.conf` is a symlink to it.

---

## Architecture

### File Layout

```
/etc/nftables.conf                          # symlink → skill asset
  └─> $HOME/.config/opencode/skills/k-nftables/assets/nftables.conf  # SINGLE SOURCE OF TRUTH

/etc/systemd/system/nftables.service.d/
  └─ protect-home.conf                      # systemd drop-in override
```

### Why a Symlink?

The canonical ruleset lives in the skill asset so the skill is self-contained (versioned, portable, editable via OpenCode). The system `/etc/nftables.conf` is a **symlink** to `assets/nftables.conf` — single source of truth, no sync needed.

### Why a systemd Drop-in?

nftables.service ships with `ProtectHome=true` (its ExecStart cannot read any file under `/home/`). A symlink under `/etc/` that resolves into `/home/` is blocked. The drop-in `/etc/systemd/system/nftables.service.d/protect-home.conf` overrides `ProtectHome=read-only` so systemd can follow the symlink.

### Edit Workflow

```bash
# 1. Edit the asset directly
#    (path is inside $HOME/.config/opencode/skills/k-nftables/assets/nftables.conf)

# 2. Test syntax
sudo nft -c -f /etc/nftables.conf           # resolves through symlink

# 3. Apply
sudo nft -f /etc/nftables.conf              # live reload (no systemctl restart needed)
# OR
sudo systemctl restart nftables             # full service restart
```

**Never edit `/etc/nftables.conf` directly** — it will be overwritten if the symlink is recreated. Always edit `assets/nftables.conf`.

---

## Interface Map

| Interface | Role | Scope |
|-----------|------|-------|
| `tailscale0` | Tailscale mesh VPN | All remote access: SSH, RDP, Docker Swarm, VXLAN |
| `lo` | Loopback | Local inter-process communication |
| `docker0` / `br-*` | Docker bridges | Container networking (local only) |
| `wlp0s20f3` | WiFi (local LAN) | Blocked for all inbound except ICMP/mDNS/DHCP |

---

## Table: `inet filter`

**Priority:** `-10` (executes BEFORE iptables-nft chains from Docker/Tailscale)

### Chain INPUT — `policy drop`

| # | Rule | Port/Proto | Source Restriction | Purpose |
|---|------|-----------|-------------------|---------|
| 1 | `iifname "lo" accept` | all | loopback only | Local IPC |
| 2 | `ct state established,related accept` | all | — | Ongoing connections |
| 3 | `ct state invalid drop` | all | — | Drop broken packets |
| 4 | ICMP (v4+v6) rate-limited | icmp/icmpv6 | 5/sec | Ping, errors, NDP |
| 5 | DHCP | udp 67-68 | — | IP assignment |
| 6 | mDNS | udp 5353 | `224.0.0.251` | .local discovery |
| 7 | **SSH** | tcp 22 | `tailscale0` only | Remote shell |
| 8 | **RDP** | tcp 3389 | `tailscale0` only | Remote desktop |
| 9 | **Ollama** | tcp+udp 11434 | `172.16.0.0/12` (Docker) | LLM API — containers only |
| 10 | Docker Swarm mgmt | tcp 2377 | `tailscale0` only | Cluster management |
| 11 | Docker Swarm gossip | tcp+udp 7946 | `tailscale0` only | Node sync |
| 12 | Docker VXLAN overlay | udp 4789,8472,10442 | `tailscale0` only | Cross-host container networking |
| 14 | Tailscale catch-all | all | `@tailscale_nets` on `tailscale0` | Any tailnet traffic |
| 15 | **Log + Drop** | all | — | Blocked traffic log (5/min) |

### Chain OUTPUT — `policy accept`
All outbound traffic permitted.

### Chain FORWARD — `policy accept`
All forwarding permitted (Docker/Tailscale handle their own filtering via `ip filter`).

---

## Key Sets

```nft
set tailscale_nets {
    type ipv4_addr
    flags interval
    elements = { 100.64.0.0/10 }
}

set tailscale_nets6 {
    type ipv6_addr
    flags interval
    elements = { fd7a:115c:a1e0::/48 }
}
```

---

## Essential Commands

### Status & Inspection

```bash
# Ruleset complet
sudo nft list ruleset

# Statistiques (paquets matchés par règle)
sudo nft list ruleset | grep -A3 'counter'

# Vérifier que nftables est actif
sudo systemctl status nftables

# Voir les sets et leurs éléments
sudo nft list set inet filter tailscale_nets
```

### Management

```bash
# Appliquer / recharger la config
sudo nft -f /etc/nftables.conf

# Tester la syntaxe sans appliquer
sudo nft -c -f /etc/nftables.conf

# Start / Stop / Restart
sudo systemctl start nftables
sudo systemctl stop nftables
sudo systemctl restart nftables

# Activer au boot / désactiver
sudo systemctl enable nftables
sudo systemctl disable nftables
```

### Logs & Debug

```bash
# Voir les paquets bloqués
sudo journalctl -k -g "NFT DROP"

# En temps réel
sudo journalctl -k -f -g "NFT DROP"

# Logs du service nftables
journalctl -u nftables

# dmesg
dmesg | grep NFT
```

### Test Rules

```bash
# Vérifier que SSH est bloqué sur WiFi mais pas sur Tailscale
# → depuis WiFi : ssh user@192.168.1.X (doit timeout/refused)
# → depuis Tailscale : ssh user@100.X.X.X (doit marcher)

# Moniteur de blocages (laisser tourner dans un terminal)
sudo journalctl -k -f -g "NFT DROP"
```

---

## Background

- Migrated from UFW (backup at `/etc/ufw.bak.20260721/`)
- UFW removed: `sudo ufw disable && sudo systemctl disable ufw`
- nftables runs at priority `-10` to execute BEFORE Docker/Tailscale iptables-nft chains
- Old nftables backup: `/etc/nftables.conf.bak.20260721` (original nftables.conf)
- Local backup before symlink: `/etc/nftables.conf.bak.20260721.local` (pre-symlink nftables.conf)
- All remote-admin ports (SSH, RDP, Docker Swarm) restricted to Tailscale only
- Ollama accessible only from Docker containers (`172.16.0.0/12`)
- Outbound and forwarding unrestricted (Docker/Tailscale manage their own)

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-nftables/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-nftables/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-21 | [OPENCODE] | v1.1.0 — Added Architecture section (symlink + systemd drop-in), edit workflow, systemd drop-in documentation. Updated insights. |
| 2026-07-21 | [OPENCODE] | v1.0.0 — Created skill: ruleset reference, interface map, commands, background. Asset `assets/nftables.conf` is canonical; `/etc/nftables.conf` symlinked to it. |
| [SUMMARY] | — | All entries listed above |

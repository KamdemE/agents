# network — PVE Network Management (Grimoire)

Network watchdog, boot notification, interface switching, and eduroam setup for Proxmox VE.

**Philosophy:** PVE is critical infrastructure. All deployments use `cp` (copy), never `ln` (symlinks). The source of truth lives in `.agents/`. If you modify anything here, you must `cp` it to the PVE target path — no auto-sync.

---

## Part 1 — Network Interface Configuration (one-time per location)

These configs define how the PVE connects to the internet. Two modes: WIRED (Polytechnique 802.1X) and WIFI (eduroam).

### Assets

| Asset | Target (on PVE) | Role |
|-------|-----------------|------|
| `assets/network/interfaces.wired` | `/etc/network/interfaces` (after `network_switch.sh wired`) | Bridge config: vmbr0 (WAN) + vmbr1 (NAT for CT 100) |
| `assets/network/interfaces.wifi` | `/etc/network/interfaces` (after `network_switch.sh wifi`) | wlo1 DHCP + vmbr1 NAT |
| `assets/network/network.conf.d/eduroam.conf` | `/etc/wpa_supplicant/eduroam.conf` | WPA supplicant for eduroam (WPA-EAP) |
| `assets/network/network.conf.d/polytechnique.conf` | `/etc/wpa_supplicant/polytechnique.conf` | WPA supplicant for Polytechnique wired (802.1X) |

### Phase 1-A: First-time eduroam setup (run once at École Polytechnique)

```bash
# 1. Copy the Python installer from assets
cp ~/.agents/skills/k-pve/assets/network/eduroam-linux-Ecole_Polytechnique-Ecole_polytechnique.py .

# 2. Run setup (generates eduroam.conf + installs certificates)
sudo bash ~/.agents/skills/k-pve/scripts/network/setup_eduroam.sh \
    ./eduroam-linux-Ecole_Polytechnique-Ecole_polytechnique.py \
    "ivann.kamdem-pouokam.2024@polytechnique.org" \
    "your_password"

# 3. That's it. The eduroam.conf is already at /etc/wpa_supplicant/eduroam.conf
```

### Phase 1-B: Switch between WIRED and WIFI

```bash
# Switch to WIRED (Polytechnique 802.1X) — default for homelab
sudo bash ~/.agents/skills/k-pve/scripts/network/network_switch.sh wired

# Switch to WIFI (eduroam) — when at École Polytechnique
sudo bash ~/.agents/skills/k-pve/scripts/network/network_switch.sh wifi
```

**What `network_switch.sh` does (wired example):**
1. Backups current `/etc/network/interfaces` → `/etc/network/interfaces.bak`
2. Copies `assets/network/interfaces.wired` → `/etc/network/interfaces`
3. Kills old wpa_supplicant + dhclient processes
4. AppArmor fix for dhclient (if needed)
5. Restarts `networking.service`
6. Waits for internet (10 retries, 2s apart)
7. Sends Telegram notification with new IP

---

## Part 2 — Automatic Network Services (watchdog + boot notify)

Two systemd services run autonomously. They monitor and repair the PVE network.

### Assets

| Asset | Target (on PVE) | Role |
|-------|-----------------|------|
| `assets/network/watchdog.service` | `/etc/systemd/system/watchdog.service` | Oneshot: runs `network_watchdog.sh` |
| `assets/network/watchdog.timer` | `/etc/systemd/system/watchdog.timer` | Every 5 min: `OnCalendar=*:0/5` |
| `assets/network/boot-notify.service` | `/etc/systemd/system/boot-notify.service` | Oneshot: runs `boot_notify.sh` at boot |

### Phase 2-A: Deploy the service files (one-time)

```bash
# Copy unit files from .agents/ (not symlinks — PVE critical)
sudo cp ~/.agents/skills/k-pve/assets/network/watchdog.service  /etc/systemd/system/
sudo cp ~/.agents/skills/k-pve/assets/network/watchdog.timer   /etc/systemd/system/
sudo cp ~/.agents/skills/k-pve/assets/network/boot-notify.service /etc/systemd/system/

# Make scripts executable
sudo chmod +x ~/.agents/skills/k-pve/scripts/network/*.sh
sudo chmod +x ~/.agents/skills/k-pve/scripts/notifier.sh

# Enable services
sudo systemctl daemon-reload
sudo systemctl enable --now watchdog.timer boot-notify.service
```

> **Important:** If you modify any `.service` or `.timer` file in `.agents/`, you must `sudo cp` it again to `/etc/systemd/system/` and `sudo systemctl daemon-reload`. The source of truth is `.agents/` — the system copy is a deployment artefact.

### Phase 2-B: Verify the services

```bash
# Check timer status
systemctl status watchdog.timer
# → loaded active running; next: Fri 2026-07-25 XX:XX:XX

# Test watchdog manually
sudo bash ~/.agents/skills/k-pve/scripts/network/network_watchdog.sh
# → should log ping result + Telegram notification

# Test boot notification manually
sudo bash ~/.agents/skills/k-pve/scripts/network/boot_notify.sh
# → waits for internet, sends "🚀 SERVEUR EN LIGNE" to Telegram
```

---

## Part 3 — Runtime: What happens automatically

### Every 5 minutes: Network Watchdog (`watchdog.timer`)

```
watchdog.timer (every 5 min)
  → watchdog.service
    → network_watchdog.sh
      │
      ├─ Auto-detect WIRED or WIFI (reads /etc/network/interfaces)
      │
      ├─ Ping 8.8.8.8 (5s timeout)
      │   ├─ OK → check LXC 100 (docker host)
      │   │   ├─ running? → exit
      │   │   └─ stopped? → pct start 100
      │   └─ FAIL → 3-step repair protocol:
      │       ├─ Action 0 (Soft): cycle IFACE down/up + wait 5s
      │       │   ├─ ping OK? → Telegram SUCCESS, exit
      │       │   └─ fail →
      │       ├─ Action 1 (Hard): restart wpa_supplicant + dhclient
      │       │   ├─ ping OK? → Telegram SUCCESS, exit
      │       │   └─ fail →
      │       └─ Action 2 (Nuclear): systemctl restart networking
      │           ├─ ping OK? → Telegram WARN, exit
      │           └─ fail → log ERROR, exit 1
      │
      ├─ IP change detection
      │   └─ new IP ≠ last IP? → Telegram INFO with new IP
      │
      └─ Container check (if host OK but CT KO)
          ├─ pct stop + pct start 100
          └─ Telegram SUCCESS or ERROR
```

### On every boot: Boot Notification (`boot-notify.service`)

```
System boot
  → boot-notify.service (After=network.target)
    → boot_notify.sh
      │
      ├─ Wait for network (max 5 min, ping google.com every 5s)
      │   ├─ OK → send "🚀 SERVEUR EN LIGNE" Telegram
      │   └─ Timeout → log error, exit 1
      └─ Done
```

### Manual: Interface Switch (`network_switch.sh`)

When the PVE moves between locations (dorm ↔ École), run the appropriate command:

```bash
sudo bash ~/.agents/skills/k-pve/scripts/network/network_switch.sh wired
# or
sudo bash ~/.agents/skills/k-pve/scripts/network/network_switch.sh wifi
```

---

## Part 4 — Logs Reference

| Log file | Source | Content |
|----------|--------|---------|
| `/var/log/network_watchdog.log` | `network_watchdog.sh` | All ping attempts, repair actions, IP changes |
| `/var/log/cron_watchdog_debug.log` | systemd stderr | Service-level errors from the watchdog |
| `/var/log/boot_notify.log` | `boot_notify.sh` | Network wait status and send result |
| `/var/log/boot_notify_debug.log` | systemd stderr | Service-level errors from boot notify |
| `/var/log/net_switch.log` | `network_switch.sh` | Interface switch operations |

---

## Part 5 — Files Inventory

| File in `.agents/` | Type | Deploy via | Frequency |
|--------------------|------|------------|-----------|
| `scripts/network/network_watchdog.sh` | Script | `cp` (auto via watchdog.service) | Once |
| `scripts/network/boot_notify.sh` | Script | `cp` (auto via boot-notify.service) | Once |
| `scripts/network/network_switch.sh` | Script | Manual use | Per location change |
| `scripts/network/setup_eduroam.sh` | Script | Manual use | Once per location |
| `scripts/notifier.sh` | Lib | — (loaded by scripts via `source`) | Once |
| `assets/network/watchdog.service` | Systemd unit | `sudo cp → /etc/systemd/system/` | Once |
| `assets/network/watchdog.timer` | Systemd timer | `sudo cp → /etc/systemd/system/` | Once |
| `assets/network/boot-notify.service` | Systemd unit | `sudo cp → /etc/systemd/system/` | Once |
| `assets/network/interfaces.wired` | Config | `cp` via `network_switch.sh wired` | Per switch |
| `assets/network/interfaces.wifi` | Config | `cp` via `network_switch.sh wifi` | Per switch |
| `assets/network/network.conf.d/` | Configs | `sudo cp` to `/etc/wpa_supplicant/` | Once |

## Secrets

`TELEGRAM_PVE_TOKEN` + `TELEGRAM_CHAT_ID` from `/root/.agents/.env` (on PVE). Created via `cp ~/.agents/.env.example ~/.agents/.env` then edit.

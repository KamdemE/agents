---
name: k-pve-debian
description: >
  KpihX-PVE-Debian — Debian VM running on the kpihx-pve Proxmox hypervisor.
  Primary Docker deployment host: runs Traefik, Portainer, Vaultwarden, and
  all Docker Compose stacks. Also hosts GitLab CI pipelines and the Homelab
  project stack. Sub-infra of k-pve.
  Load for Debian VM tasks, Docker stack management, Traefik config,
  GitLab CI operations, or Vaultwarden maintenance.
license: private
metadata:
  author: KpihX
  version: "1.2.1"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KpihX-PVE-Debian — Debian VM

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-pve` (hypervisor — parent infra) · `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-docker` (generic Docker patterns) · `k-tailscale` (mesh VPN) · `k-optim` (maintenance/cleanup)
> **Source:** Content migrated from `kpihx-labs` v1.x (Docker/deployment sections) and `k-docker` (Ubuntu-specific deployment notes)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Setup (once per machine)

> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to understand the setup rule: everything lives in `.agents/` (single source of truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own `assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized).

```bash
# 1. Clone .agents repo (canonical location; ~/.agents is only a symlink)
mkdir -p ~/KpihX-Labs
[ -d ~/KpihX-Labs/.agents ] || git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents
[ -e ~/.agents ] || ln -sfn ~/KpihX-Labs/.agents ~/.agents
# 1b. Branch per infra: cd ~/KpihX-Labs/.agents && git switch <infra>  (ubuntu stays on master)

# 2. kshrc — symlink ($HOME item), source of truth is k-pve-debian/assets/kshrc
ln -sf ~/.agents/skills/k-pve-debian/assets/kshrc ~/.kshrc

# 3. SSH config — Include canonical
echo "Include ~/.agents/skills/k-ssh/assets/ssh.conf" > ~/.ssh/config

# 4. Secrets
cp ~/.agents/.env.example ~/.agents/.env
```

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | Debian VM on kpihx-pve |
| Short name (tmux) | `pve-debian` |
| Tailscale | `kpihx-pve-debian` (`100.117.171.4`) |
| LAN IP | `10.10.10.101` (vmbr1) |
| SSH OS | Linux (Debian) |
| Role | Docker deployment host, GitLab CI runner, service hosting |

---

## SSH Access

| Alias | Target | Route | Key | Notes |
|-------|--------|-------|-----|-------|
| `pve-debian` | `10.10.10.101` via `pve` | LAN jump | `id_ed25519_pve` | Local (campus network) via PVE |
| `kpihx-pve-debian` | `10.10.10.101` via `kpihx-pve` | Tailscale jump | `id_ed25519_pve` | Remote via Tailscale |

---

## Docker Deployment

This VM runs Docker containers. For generic Docker patterns (multi-stage builds, docker-compose, Traefik labels, best practices), load **`k-docker`**.

### Host Access

The Docker host is accessed via `homelab` / `kpihx-cloud` SSH aliases (CT 100 at `10.10.10.10` — the main Docker host).

| Alias | Target | Route | Key |
|-------|--------|-------|-----|
| `homelab` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `id_ed25519_homelab` |
| `kpihx-cloud` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `id_ed25519_homelab` |

> **Note:** `homelab` (CT 100) denies direct access to `/var/run/docker.sock` for user `kpihx`. Operational container inventory must use `sudo docker ...` or an equivalent privileged path.
> Live stack discovery is more reliable through Docker labels (`com.docker.compose.project` / `service`) than through compose-file search alone, because several active stacks no longer have an obvious compose file under `/root`.

---

## Services Running

| Service | Access | Notes |
|---------|--------|-------|
| Traefik | `traefik.kpihx-labs.com` (or via port forward) | Reverse proxy, ingress for all HTTP/S services |
| Portainer | `localhost:9443` (via tunnel from kpihx-pve-ui) | Container management UI |
| Vaultwarden | `vault.kpihx-labs.com` | Password manager, Tailscale-only |
| (Other stacks) | Via Traefik routes | See Homelab project registry in `kpihx-labs` |

---

## GitLab CI

GitLab CI pipelines deploy containers and manage infrastructure. Related configuration:
- All MCPs in kpihx-labs GitLab group namespace
- CI pipeline templates: `$HOME/Work/KpihX-Labs/Homelab/presentation/techskills/templates/`

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-pve-debian/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-pve-debian/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [COLAB] | v1.2.1 — **`kr()` reload helper propagated (KπX audit finding)**: mirrored from `k-ubuntu`'s already-fixed version — saves `$PWD` before re-sourcing `.kshrc`, `cd`s back after (was missing here, violating the k-zsh SYNC RULE). |
| 2026-08-26 | [CLAUDE] | v1.2.0 — Persistent SSH agent (gpg-agent ssh-emulation, socket-activated) added to `assets/kshrc` Section 1 — verify `systemctl --user status gpg-agent-ssh.socket` on this VM before relying on it. See `k-zsh` v2.5.0 for the mechanism; mirrored here per the SYNC RULE. |
| [SUMMARY] | — | v1.1.0 setup rule added (kshrc symlink from kshrc.base, registered in assets/links.jsonc) · v1.0.0 created k-pve-debian from kpihx-labs Docker/deployment content |

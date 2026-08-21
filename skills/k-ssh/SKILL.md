---
name: k-ssh
description: >
  KpihX centralized SSH configuration management — canonical Host fragment,
  standardized key naming, SSH agent strategy (gcr vs Bitwarden), key generation,
  and passphrase management for all equipment across all infrastructures.
license: private
metadata:
  author: KpihX
  version: "1.2.2"
  scope: cross-infra
allowed-tools: Bash(ssh:*), Bash(ssh-keygen:*), Bash(scp:*), Bash(Include:*)
---

# KpihX — SSH Centralized Management

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Cross-infra skill:** applies to all KpihX equipment running OpenSSH
> (Ubuntu workstation, PVE Debian, WSL, Termux Android).
> **OS references:** OS-specific SSH setup (socket paths) in
> `k-bw/references/ubuntu.md` and `k-bw/references/windows.md`.

## Philosophy

SSH configuration is centralized into a **single canonical fragment**
(`assets/ssh.conf`) that every machine includes via OpenSSH `Include`
directive. All Host blocks live in this one file — never duplicated across
machines, never edited inline in local `~/.ssh/config`.

Each machine's `~/.ssh/config` becomes a one-liner:
```bash
Include ~/.agents/skills/k-ssh/assets/ssh.conf
```

## Canonical Fragment

`assets/ssh.conf` — the single source of truth.

| Section | Hosts | Equipment |
|---------|-------|-----------|
| **Git** | github.com, gitlab.com | Git hosting |
| **PVE** | pve, kpihx-pve, pve-ui, kpihx-pve-ui | Proxmox hypervisor (kpihx-pve) |
| **PVE Dockerhost LXC** | dockerhost, kpihx-dockerhost, homelab, kpihx-cloud | Docker LXC (10.10.10.10) |
| **PVE Debian VM** | pve-debian, kpihx-pve-debian | Debian VM (10.10.10.101) |
| **Android** | kpihx-s25, s25 | Samsung Galaxy S25 over Tailscale |
| **Ubuntu (from phone)** | ubuntu, kpihx-ubuntu | Workstation reachable from phone |
| **DxO Internship** | deep-pc6 | DxO office server |

### Distribution

| Machine | Method |
|---------|--------|
| **Ubuntu workstation** | `Include ~/.agents/skills/k-ssh/assets/ssh.conf` (direct, `.agents` is local) |
| **PVE Debian** | Same Include if `.agents` is cloned; otherwise copy file to `~/.ssh/ssh.conf` |
| **WSL (blglaptop139)** | Same Include (`.agents` is shared via Windows filesystem mount) |
| **Phone (Termux)** | `scp ~/.agents/skills/k-ssh/assets/ssh.conf s25:~/storage/shared/kpihx-ssh/ssh.conf` then Include from there |

## Key Naming Convention

### Pattern

```
Filename:    id_ed25519_<target-infra>
Comment:     <source-machine-name>
```

The **filename suffix** indicates where the key authenticates **TO** (the target service or device).
The **comment** indicates where the key was generated **ON** (the source machine).
This makes `authorized_keys` entries instantly recognizable: you see which machine
originated the key and can identify it at a glance.

### Current key inventory

All keys in `~/.ssh/`:

| Key file | Suffix (target) | Comment (source) | Purpose |
|----------|-----------------|-------------------|---------|
| `id_ed25519_github` | `github` | `KpihX-Ubuntu` | GitHub authentication |
| `id_ed25519_gitlab` | `gitlab` | `KpihX-Ubuntu` | GitLab authentication |
| `id_ed25519_pve` | `pve` | `KpihX-Ubuntu` | Proxmox host + Debian VM access |
| `id_ed25519_homelab` | `homelab` | `KpihX-Ubuntu` | Dockerhost LXC (legacy naming) |
| `id_ed25519_s25` | `s25` | `KpihX-Ubuntu` | Samsung S25 phone (Termux sshd) |
| `id_ed25519_deep_pc6` | `deep_pc6` | `IKamdem Ubuntu` | DxO internship server |
| `id_ed25519_x` | `x` | `ivann.kamdem-pouokam.@polytechnique.edu` | (unknown service — polytechnique email) |

### Examples of key generation

```bash
# Generate a new key for a target service/infrastructure
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<target> -C "KpihX-Ubuntu"

# Real examples from history:
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_deep_pc6 -C "IKamdem Ubuntu"
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_docker_host -C "Ubuntu"
```

### Deploying public keys

The public key (`id_ed25519_<target>.pub`) must be added to the target's
`~/.ssh/authorized_keys` (or the service's SSH key settings, like GitHub/GitLab
web UI). The comment helps identify where the key came from.

## SSH Agent Strategy

### Linux — gcr-ssh-agent (GNOME Keyring) [PREFERRED]

Default GNOME agent at `/run/user/$(id -u)/gcr/ssh`. Load keys once per session:

```bash
ssh-add ~/.ssh/id_ed25519_<target>
```

Passphrase asked once, then instant. No conflicts.

**⚠️ Avoid dual-agent:** The Bitwarden desktop GUI has its own SSH agent. If both
are active (`SSH_AUTH_SOCK` pointing to Bitwarden while gcr runs), SSH gets
"agent refused operation" and falls back to slow key decryption (+1-3s delay).

**Fix:** Bitwarden → Settings → SSH Agent → **Disable** on all platforms.
Passphrase + native agent (gcr/ssh-agent) is better than Bitwarden SSH agent
everywhere — Linux, WSL, even Windows via OpenSSH agent.

## Passphrase Management

### Adding or changing a passphrase on an existing key

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519_<target>
# You will be prompted for:
#   1. Old passphrase (leave empty if none)
#   2. New passphrase
#   3. Confirm new passphrase
```

### Removing a passphrase from an existing key

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519_<target>
# Enter old passphrase
# Enter new passphrase (leave empty to remove)
# Confirm new passphrase (leave empty)
```

### When to use passphrases

- **Every key should have a passphrase** — it protects the private key file
  if stolen. The native agent (gcr/ssh-agent) caches the unlocked key after
  one prompt, so you only type it once per session.
- **Automation keys** (GitHub/GitLab CI/CD): no passphrase (non-interactive).
  Store in Bitwarden vault for backup, served via deploy keys or CI secrets.

## kshrc Setup (cross-reference)

When a new infra is added, `~/.kshrc` (shell hub) follows the same centralization pattern as SSH:

- **Source of truth:** `assets/kshrc` in the infra skill (e.g. `k-ubuntu/assets/kshrc`, `k-phones/assets/kshrc`)
- **`~/.kshrc`** is a **symlink** to that file
- If the infra skill does not exist, create it following `k-ai` (AI hub + runtime registry) before proceeding

See `k-infras` → New Infra Setup Checklist → step 1b.

## Key Distribution Workflow

When a new infrastructure is added:

1. Generate the key: `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<target> -C "KpihX-Ubuntu"`
2. Add to `assets/ssh.conf`: create a new `Host` block with `IdentityFile`
3. Copy to target's `authorized_keys`: `ssh-copy-id -i ~/.ssh/id_ed25519_<target>.pub user@host`
4. Store in Bitwarden vault as SSH key item
5. Update this skill if the new infrastructure is permanent

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-ssh/references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## References

- `assets/ssh.conf` — canonical SSH Host fragment (the actual config)
- `references/insights.md` — durable runtime lessons
- `k-bw` — Bitwarden desktop SSH agent setup + WSL bridge
- `k-phones` — phone-specific SSH details (Termux sshd, autostart)
- `k-git` — Git authentication via SSH

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-20 | [COLAB] | v1.2.2 — Corrected the generic phone shell source path to `k-phones/assets/kshrc`. |
| 2026-08-20 | [COLAB] | v1.2.1 — Updated the Android cross-references for the `k-phones` rename and S25-specific shell asset. |
| [SUMMARY] | — | v1.1.0 SSH agent strategy refactor; v1.0.0 created k-ssh |

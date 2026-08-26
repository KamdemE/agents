---
name: k-ssh
description: >
  KpihX centralized SSH configuration management — canonical Host fragment,
  standardized key naming, SSH agent strategy (gcr vs Bitwarden), key generation,
  and passphrase management for all equipment across all infrastructures.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
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

### Linux, GUI session — gcr-ssh-agent (GNOME Keyring) [PREFERRED]

Default GNOME agent at `/run/user/$(id -u)/gcr/ssh`. Load keys once per session:

```bash
ssh-add ~/.ssh/id_ed25519_<target>
```

Passphrase asked once, then instant. No conflicts.

**Gotcha (found 2026-08-26, deep-pc6):** `gcr-ssh-agent.service` is gated behind
`graphical-session-pre.target`, which is only reached under an actual GNOME
session. On a tty-only / headless box (`XDG_SESSION_TYPE=tty` — SSH+tmux, no
desktop), that target never fires, the agent never starts, and every git-over-ssh
op decrypts the key fresh with no caching. Confirm with `ssh-add --help` — if it
prints "Could not open a connection to your authentication agent", this is why.
Use the tty/headless strategy below on that class of machine instead.

### Linux, tty/headless (no GUI session) — gpg-agent ssh-emulation [PREFERRED]

`gpg-agent`'s SSH-agent emulation is socket-activated independently of any
graphical target — confirmed running continuously for 54+ days across tmux
reconnects on `deep-pc6` with zero manual intervention:

```bash
systemctl --user status gpg-agent-ssh.socket   # Active (listening), enabled
```

Wired automatically via `k-zsh/assets/kshrc.base` (mirrored into every
per-infra kshrc — see `references/insights.md` if you need to re-verify one):

```sh
_gpg_ssh_sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gnupg/S.gpg-agent.ssh"
[ -S "$_gpg_ssh_sock" ] && export SSH_AUTH_SOCK="$_gpg_ssh_sock"
```

Load keys once per boot (not per session — the socket survives reconnects):

```bash
ssh-add ~/.ssh/id_ed25519_<target>
```

**Cache behaviour, verified via `gpgconf --list-options gpg-agent`** (not assumed):
a passphrase-protected key stays cached for `default-cache-ttl-ssh` seconds after
*last use* (compiled-in default **1800s / 30 min**, sliding — resets on every use,
same shape as `sudo`'s timestamp cache), up to a hard ceiling of
`max-cache-ttl-ssh` (default **7200s / 2h**) regardless of activity. To change
either, create `~/.gnupg/gpg-agent.conf` with `default-cache-ttl-ssh <N>` /
`max-cache-ttl-ssh <N>`, then `gpg-connect-agent reloadagent /bye`.

**Canonical config asset:** `~/.gnupg/gpg-agent.conf` is a **symlink** to
`k-ssh/assets/gpg-agent.conf` (registered `gpg-agent-conf` in
`assets/links.jsonc`). It sets `default-cache-ttl-ssh`/`max-cache-ttl-ssh`
explicitly and `min-passphrase-len 0` — **found 2026-08-26 (deep-pc6):**
GnuPG's compiled-in default `min-passphrase-len 8` makes gpg-agent's ssh
import REJECT an empty internal protection passphrase, even for a source
`~/.ssh/id_ed25519_*` key file that is itself completely unencrypted
(`cipher: none, kdf: none` — verify with
`ssh-keygen -y -f <key> -P ""` succeeding instantly). This manifests as
`agent refused operation` on every subsequent `ssh`/git operation for that
key, with no indication the real cause is a *policy minimum*, not a
forgotten passphrase. See `references/insights.md` for the full incident
and the companion zombie-`pinentry` pattern.

**Not universal:** `systemctl --user status gpg-agent-ssh.socket` must be checked
per machine before relying on it — containers/LXCs (`k-dockerhost`) and some VMs
may lack a full `systemd --user` instance; WSL only runs systemd if enabled in
`/etc/wsl.conf`; Termux has no systemd at all. The kshrc wiring is a guarded
no-op (`[ -S "$_gpg_ssh_sock" ]`) everywhere it doesn't apply, so it's safe to
keep in every kshrc regardless.

### Dual-agent conflicts (applies to both strategies above)

**⚠️ Avoid dual-agent:** The Bitwarden desktop GUI has its own SSH agent. If both
are active (`SSH_AUTH_SOCK` pointing to Bitwarden while gcr or gpg-agent runs),
SSH gets "agent refused operation" and falls back to slow key decryption
(+1-3s delay), or the wrong agent wins the race for `SSH_AUTH_SOCK`.

**Fix:** Bitwarden → Settings → SSH Agent → **Disable** on all platforms.
Passphrase + a native agent (gcr / gpg-agent / Windows OpenSSH agent) is better
than Bitwarden SSH agent everywhere — Linux, WSL, even Windows.

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
- `references/log.md` — append-only historical operation log
- `k-bw` — Bitwarden desktop SSH agent setup + WSL bridge
- `k-phones` — phone-specific SSH details (Termux sshd, autostart)
- `k-git` — Git authentication via SSH

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [COLAB] | v1.4.0 — **Canonical `gpg-agent.conf` asset created** (`assets/gpg-agent.conf`, symlinked at `~/.gnupg/gpg-agent.conf`, registered in `assets/links.jsonc` as `gpg-agent-conf`): sets `min-passphrase-len 0` after diagnosing a real incident on `deep-pc6` — `ssh-add` of the unencrypted `id_ed25519_github` key was silently rejected (`Bad Passphrase`) by GnuPG's compiled-in `min-passphrase-len 8` policy when the internal protection passphrase was left empty, producing a confusing downstream `agent refused operation` on every git push. Also made `default-cache-ttl-ssh`/`max-cache-ttl-ssh` explicit (previously only documented, not enforced by a real file). Companion **zombie-`pinentry` pattern** documented in `references/insights.md`: a freshly spawned `pinentry` process can spin at 70-95% CPU holding the agent's pinentry lock (`failed to acquire the pinentry lock: Timeout` in `journalctl --user -u gpg-agent`) instead of rendering its curses dialog — `kill -9 <pid>` immediately unblocks a clean, correctly rendering dialog on the next attempt. |
| 2026-08-26 | [CLAUDE] | v1.3.0 — **tty/headless SSH agent strategy added**: `gcr-ssh-agent` is gated behind `graphical-session-pre.target` and never starts on a tty-only box (confirmed on `deep-pc6`, `ssh-add --help` → "Could not open a connection to your authentication agent") — every submodule-gate check in a git hook was decrypting the key fresh, prompting once per submodule per push. Documented `gpg-agent` ssh-emulation (`gpg-agent-ssh.socket`, socket-activated, no GUI needed) as the PREFERRED strategy for that class of machine, with its verified cache TTLs (`default-cache-ttl-ssh` 1800s sliding / `max-cache-ttl-ssh` 7200s hard ceiling, sudo-shaped). Wired in `k-zsh` v2.5.0 + mirrored across all 7 per-infra kshrc. |
| 2026-08-20 | [COLAB] | v1.2.2 — Corrected the generic phone shell source path to `k-phones/assets/kshrc`. |
| [SUMMARY] | — | v1.2.1 Android cross-references for `k-phones` rename + S25-specific shell asset · v1.1.0 SSH agent strategy refactor; v1.0.0 created k-ssh |

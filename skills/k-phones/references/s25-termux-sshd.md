# S25 — Termux `sshd` (persistent SSH)

## What Ubuntu actually loads (not this `.md` file)

| Layer | Read by OpenSSH? | Role |
|-------|------------------|------|
| `$HOME/.ssh/config` | **Yes** | Main config on **PC**; `Include` → phone fragment |
| `k-ssh/assets/ssh.conf` | **Yes** (via Include) | `Host kpihx-s25 s25` → IP `100.125.54.1`, port `8022`, key `id_ed25519_s25` |
| `references/s25-termux-sshd.md` | **No** | Runbook for **you** and **agents** — steps to run on the phone |
| Termux `~/.ssh/config` | **Yes** (on phone) | `Host ubuntu` → PC; unrelated to `ssh s25` |

**Ubuntu never “imports” Markdown.** Agents follow `k-phones` and execute the commands here; only files under `~/.ssh/` affect `ssh` on the workstation.

## One-time (already done on device)

```bash
pkg update && pkg install openssh
passwd   # Termux password (for keyboard/session unlock — SSH uses keys)
ssh-keygen -A   # host keys if prompted
```

Ensure **`$HOME/.ssh/authorized_keys`** on the phone contains **`id_ed25519_s25.pub`** from the workstation (PC → phone direction).

## Why `ssh s25` fails after reopening Termux

`Connection refused` on port **8022** = **no process listening** — Termux does not keep `sshd` running when:

- the Termux app was swiped away or killed;
- the phone rebooted;
- Android battery optimization stopped background work.

Fix = **start `sshd` again** or automate it (below).

## Persistence — two complementary hooks

| When | Mechanism | Source |
|------|-----------|--------|
| **Every Termux shell** (app reopen) | `k-phones/scripts/k_phones_sshd_autostart.sh` sourced via `kshrc` | See setup in SKILL.md |
| **Android boot** | Termux:Boot | `assets/termux-boot-sshd` → `~/.termux/boot/sshd` |

### A — Autostart on shell open (simplified)

Setup in one command (run on S25):

```bash
ln -sf ~/.agents/skills/k-phones/assets/kshrc ~/.kshrc
```

The shell asset sources `~/.agents/skills/k-phones/scripts/k_phones_sshd_autostart.sh` directly, which contains the sshd autostart function. No deploy scripts, no zshrc hooks, no manual file creation.

**Test:** close Termux completely → reopen → one shell opens → from PC: `ssh s25` (no manual `sshd`).

### B — Autostart on Android boot (optional)

Follow `references/termux-boot.md` for the complete literal procedure: F-Droid
or raw-ADB installation, the kernel-owned boot payload copy, permissions, and
reboot verification. Boot scripts run only after boot; they do **not** replace
(A) when you only reopen Termux without rebooting.

## Manual start (debug)

```bash
sshd
ss -ltn | grep 8022
```

From **kpihx-ubuntu** (PC config must show Tailscale IP — check with `ssh -G s25 | grep hostname`):

```bash
ssh s25
```

## If connection refused

1. Open **Termux** on the phone.
2. Run `sshd` and confirm `:8022` LISTEN.
3. **Tailscale** connected on the phone.
4. PC: `ssh -G s25` → `hostname 100.125.54.1` (not MagicDNS if DNS is flaky).
5. PC: `ssh s25`.

**Note:** ADB wireless debugging and Termux SSH are **independent**.

## Android battery / OEM

If `sshd` still dies in background: disable battery optimization for **Termux** (and **Termux:Boot** if installed) in Samsung device care.

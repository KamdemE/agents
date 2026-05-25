# S25 — Termux `sshd` (persistent SSH)

## What Ubuntu actually loads (not this `.md` file)

| Layer | Read by OpenSSH? | Role |
|-------|------------------|------|
| `$HOME/.ssh/config` | **Yes** | Main config on **PC**; `Include` → phone fragment |
| `k-phones/assets/ssh-kpihx-phones.conf` | **Yes** (via Include) | `Host s25` → IP `100.125.54.1`, port `8022`, key `id_ed25519_s25` |
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

| When | Mechanism | Path on phone |
|------|-----------|---------------|
| **Every Termux shell** (app reopen) | Source autostart in zsh | `~/.kphones-remote.zsh` ← `termux-sshd-autostart.sh` |
| **Android boot** | Termux:Boot | `~/.termux/boot/sshd` ← `termux-boot-sshd` |

### A — Autostart on shell open (recommended first)

Add to Termux (manual or deploy script):

```bash
# In ~/.kphones-remote.zsh (or paste termux-sshd-autostart.sh from k-phones/assets/)
_kphones_sshd_autostart() {
  command -v sshd >/dev/null 2>&1 || return 0
  if ss -ltn 2>/dev/null | grep -q ':8022 '; then
    return 0
  fi
  sshd 2>/dev/null || true
}
_kphones_sshd_autostart
```

Hook `~/.zshrc`:

```bash
[[ -f ~/.kphones-remote.zsh ]] && . ~/.kphones-remote.zsh
```

**Test:** close Termux completely → reopen → one shell opens → from PC: `ssh s25` (no manual `sshd`).

### B — Autostart on Android boot (optional)

**Termux:Boot** is a separate **F-Droid app** (`com.termux.boot`) — not an `apt` package. Install it, **open the app once**, then:

```bash
mkdir -p ~/.termux/boot
```

`~/.termux/boot/sshd`:

```bash
#!/data/data/com.termux/files/usr/bin/sh
sshd
```

```bash
chmod +x ~/.termux/boot/sshd
```

**Android:** Settings → Apps → **Termux:Boot** → allow **Run at startup** (wording varies by OEM).

Boot scripts run only after boot; they do **not** replace (A) when you only reopen Termux without rebooting.

## Install Termux:Boot (F-Droid plugin)

| Method | Command |
|--------|---------|
| **Automated (ADB up)** | `adb-s25 <PORT>` then `zsh "$HOME/.agents/skills/k-phones/scripts/termux-install-boot.sh"` |
| **SSH + one tap** | Script stages APK → opens installer → tap **Install** on phone → re-run script |
| **Manual** | F-Droid → Termux:Boot → open once |

APK staged by script: `/sdcard/Download/termux-boot.apk` (F-Droid `com.termux.boot` v0.8.1).

## Deploy from Ubuntu (when `ssh s25` works once)

```bash
zsh "$HOME/.agents/skills/k-phones/scripts/termux-deploy-sshd.sh"
```

Pushes autostart + boot script + starts `sshd` immediately.

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

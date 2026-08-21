# Termux SSHD and Termux:Boot Manual Setup

This is the literal, adaptable procedure for any KπX Android phone. Replace
`<PHONE_ALIAS>` and `<PHONE_TAILSCALE_IP>` with the device being configured.

## 1. Prepare Termux

On the phone, in Termux:

```bash
pkg update
pkg install openssh tmux termux-api
passwd
sshd
ss -ltn | grep 8022
```

`openssh` supplies `sshd`; the listener check confirms that Termux is serving
SSH on port 8022. Configure the workstation public key in
`$HOME/.ssh/authorized_keys` on the phone before relying on key-based SSH.

## 2. Start SSHD whenever Termux opens

On the phone, link the phone shell source of truth:

```bash
ln -sf ~/.agents/skills/k-phones/assets/kshrc ~/.kshrc
```

Open a fresh Termux shell. Its interactive shell startup sources
`scripts/k_phones_sshd_autostart.sh`, which starts `sshd` only when it is not
already running.

Test from the workstation:

```bash
ssh <PHONE_ALIAS>
```

## 3. Enable SSHD after Android boots

Termux:Boot is a separate Android application. Pick one installation path.

### A. Install directly on the phone

Install **Termux:Boot** from F-Droid, then open it once. Android requires this
first launch before it can deliver the boot event.

### B. Install from a connected workstation with raw ADB

First establish raw wireless ADB as documented in `adb.md`, then run:

```bash
adb install -r ~/.agents/skills/k-phones/assets/termux-boot.apk
adb shell monkey -p com.termux.boot -c android.intent.category.LAUNCHER 1
```

If Samsung rejects the ADB install with verification failure, explicitly choose
whether to relax that verification for this installation:

```bash
adb shell settings put global verifier_verify_adb_installs 0
adb install -r ~/.agents/skills/k-phones/assets/termux-boot.apk
```

## 4. Install the boot payload

On the phone, copy the kernel-owned payload into Termux:Boot's required path:

```bash
mkdir -p ~/.termux/boot
cp ~/.agents/skills/k-phones/assets/termux-boot-sshd ~/.termux/boot/sshd
chmod +x ~/.termux/boot/sshd
```

The payload acquires a Termux wake lock when available, then runs `sshd`.

## 5. Verify

1. Reboot the phone.
2. Wait for Tailscale to reconnect.
3. From the workstation:

   ```bash
   tailscale status
   ssh <PHONE_ALIAS>
   ```

If SSH is refused, open Termux once and run `sshd`; then check Android battery
optimization for both Termux and Termux:Boot.

## Scope boundary

Termux SSH and wireless ADB are independent. Use `ssh <PHONE_ALIAS>` for the
Termux/Linux environment; use raw `adb` for Android shell, packages, files,
and screen control.

# S25 — Termux `sshd` (persistent SSH)

## One-time (already done on device)

```bash
pkg update && pkg install openssh
passwd   # Termux password (for keyboard/session unlock — SSH uses keys)
ssh-keygen -A   # host keys if prompted
```

Ensure **`$HOME/.ssh/authorized_keys`** contains **`id_ed25519_s25.pub`** from the workstation.

## Start sshd (every boot until automated)

```bash
sshd
# verify listening:
ss -ltn | grep 8022
```

From **kpihx-ubuntu**:

```bash
ssh kpihx-s25    # or: ssh s25
```

## Optional — auto-start on boot (Termux)

```bash
pkg install termux-boot
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

Grant **Termux:Boot** permission in Android settings.

## If connection refused

`ssh: connect to host kpihx-s25.tail2527bd.ts.net port 8022: Connection refused` means **nothing is listening on 8022** — almost always **`sshd` not started** in Termux (not an SSH config bug on the PC).

1. Open **Termux** on the phone (app must be running).
2. Run:

```bash
sshd
ss -ltn | grep 8022   # should show LISTEN on :8022
```

3. Confirm **Tailscale** connected on the phone (key icon in status bar).
4. From PC: `tailscale ping kpihx-s25` then `ssh s25` (or `ssh kpihx-s25`).

**Note:** ADB wireless debugging and Termux SSH are **independent** — ADB pair can succeed while SSH still refuses until `sshd` runs.

# k-windows — Mounting a remote SSH/SFTP host as a Windows drive

> Generalized from a concrete DxO-internship case (mounting `server` as `Z:` — see `k-dxo` for that exact instance, account, and IP). This doc is the generic mechanism; templates → `assets/remote-server/` (part of the wider "remote server access" template family documented in `references/remote-server-access.md` — VPN, tunnel, tmux launcher, CLI proxy, and this mount pattern together).

## Why rclone (not SSHFS-Win)

Two tools can do this: **SSHFS-Win** and **rclone** (SFTP remote type). SSHFS-Win breaks when the remote username is domain-qualified with a backslash (`DOMAIN\user`) — a common shape for corporate SSH targets. **rclone is the one that actually works** in that case and is the recommended default.

## 1. Software

```powershell
winget install --id WinFsp.WinFsp -e
winget install --id Rclone.Rclone -e
```
(`nssm` — a Windows service wrapper — is also needed for autostart; see step 5.)

## 2. SSH config (`%USERPROFILE%\.ssh\config`)

```
Host <alias>
    HostName <ip-or-hostname>
    User <username>
    PreferredAuthentications publickey,password
    IdentityFile ~/.ssh/id_ed25519_<alias>
```

## 3. rclone config (`%APPDATA%\rclone\rclone.conf`)

```
[<alias>]
type = sftp
host = <ip-or-hostname>
user = <username>
key_file = C:\Users\<user>\.ssh\id_ed25519_<alias>
key_use_agent = false
```

## 4. Manual mount / unmount

```powershell
rclone mount <alias>: <DriveLetter>: --network-mode --volname "<alias> (<alias>)" --vfs-cache-mode writes --dir-cache-time 10m
net use <DriveLetter>: /delete
taskkill /f /im rclone.exe
```

`--vfs-cache-mode full` (rather than `writes`) is needed if Explorer copy/paste onto the mount should work smoothly — trades some disk cache space for that.

## 5. Autostart (nssm service, not a scheduled task)

**Don't use a scheduled task + PowerShell wrapper** — the Windows Job Object that owns a scheduled task kills the wrapped process when the task's own session closes, which kills the mount. A real Windows **service** (via `nssm`) doesn't have that problem.

```powershell
nssm install "<alias>-mount" "<path-to-rclone.exe>" mount <alias>: <DriveLetter>: --network-mode --config "C:\ProgramData\rclone\rclone.conf" --vfs-cache-mode full --dir-cache-time 10m
nssm set "<alias>-mount" AppNoConsole 1
Start-Service -Name "<alias>-mount"
```

- Run as `LocalSystem` (needs SSH-key read rights — copy the key/rclone.conf somewhere `LocalSystem` can read, e.g. `C:\ProgramData\rclone\`).
- `AppNoConsole = 1` — no visible console window.
- Depends on `LanmanWorkstation` (needs the network stack up).
- Auto-restart on rclone crash.

Templates implementing steps 4-5's retry/logging logic → `assets/remote-server/mount-server.bat` + `assets/remote-server/unmount-server.bat` (personalize `REMOTE_NAME`/`DRIVE_LETTER` per target — see `k-dxo/assets/mount-server.bat` for a filled-in example).

## 6. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| "No host key validation is being performed" | Normal warning for this setup, no action needed. |
| Mount fails right after boot | Network wasn't ready yet — the template waits 15s and retries 3× (5s apart); check the `.log` file. |
| "Access denied" | Test raw SSH first: `ssh <alias> "echo OK"`. |
| "Connection reset by peer" | The remote's SFTP subsystem is missing — check `grep Subsystem /etc/ssh/sshd_config` on the remote, must contain `Subsystem sftp /usr/lib/openssh/sftp-server`. |

## Going further

- Mount a subfolder only: `rclone mount <alias>:<subpath> <DriveLetter>: ...`
- `rclone mount --help` for the full flag reference.


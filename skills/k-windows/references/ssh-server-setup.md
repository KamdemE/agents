# k-windows — OpenSSH Server (Windows side) + Ubuntu client pairing

> Generalized from live diagnosis on a specific machine (`k-laptop`) — pure Windows/OpenSSH mechanism below, zero company-specific content (no hostname, no domain, no account name). The company-specific *target* (which machine, which domain, which account) belongs in that company's own skill (e.g. `k-dxo`).

## 1. Check what's actually installed — don't trust one signal alone

**🔴 Insight verified live (2026-08-26):** `Get-Service sshd` can report `Running`/`Automatic` while `Get-WindowsCapability -Online -Name OpenSSH.Server*` reports **`NotPresent`** on the very same machine. These are two different tracking systems:

- `Get-Service sshd` — Service Control Manager truth: is the service registered and running, regardless of *how* the binaries got there.
- `Get-WindowsCapability` — DISM/CBS Feature-on-Demand (FOD) truth: was it installed through Windows' own on-demand component mechanism.

Corporate-imaged machines frequently deploy OpenSSH via SCCM/Intune/a golden image bake (dropping `sshd.exe`/`ssh.exe` directly, or via an MSI) **outside** the FOD path — the service works perfectly, but the Capability query lies about it being absent. **Always check `Get-Service sshd` first as the functional ground truth**; only fall back to `Add-WindowsCapability` if the service genuinely doesn't exist.

```powershell
Get-Service sshd                                          # ground truth: is it actually running?
Get-WindowsCapability -Online -Name OpenSSH.Server*        # secondary signal only — can show NotPresent even when Running
# Install ONLY if Get-Service found nothing at all:
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
```

## 2. Firewall — verify by the real rule name, not a guess

The install (Capability or corporate MSI) usually creates a rule whose **display name is `OpenSSH Server (sshd)`** (sometimes an older `OpenSSH SSH Server Preview (sshd)` rule also lingers, disabled, from a prior Windows build — harmless). Searching by an assumed short name (`name=sshd`) can return **zero rules found** even when the real rule exists under its full display name — false negative, not proof of absence:

```powershell
# Wrong way to check (can false-negative):
Get-NetFirewallRule -Name sshd

# Reliable way — search all rules for anything SSH-related:
netsh advfirewall firewall show rule name=all | findstr /i ssh
# or:
Get-NetFirewallRule | Where-Object { $_.DisplayName -match 'ssh' } | Select-Object DisplayName, Enabled, Direction

# Only create if truly missing:
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

## 3. `authorized_keys` location depends on the account's group

OpenSSH on Windows special-cases members of the local **Administrators** group:

| Account type | `AuthorizedKeysFile` actually read |
|---|---|
| Standard user | `C:\Users\<user>\.ssh\authorized_keys` |
| Member of `Administrators` (local or domain) | **`C:\ProgramData\ssh\administrators_authorized_keys`** — the user's own `~\.ssh\authorized_keys` is silently **ignored** |

This is driven by a `Match Group administrators` block in `C:\ProgramData\ssh\sshd_config`. If you land in the wrong file, auth silently falls back to password (or fails outright) with no explicit "wrong location" error — check `net localgroup Administrators` first to know which file actually matters.

```powershell
$key = Get-Content "C:\Users\<user>\.ssh\authorized_keys" -Raw
Set-Content -Path "C:\ProgramData\ssh\administrators_authorized_keys" -Value $key -Encoding ASCII
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /grant "SYSTEM:F" "Administrators:F"
Restart-Service sshd
```

## 4. Default shell — `cmd.exe` unless told otherwise

Without an explicit registry value, every SSH session (interactive **and** one-shot `ssh host "command"`) lands in `cmd.exe` — no `ls`/`cat`/native PowerShell aliases. This is a **server-wide** setting (`HKLM`, applies to every user of that sshd instance), not a per-user `.zshrc`-style file — there is no per-user equivalent that's safe for automation (see the `AutoRun` footgun below).

```powershell
Test-Path 'HKLM:\SOFTWARE\OpenSSH'
# New-Item -Path 'HKLM:\SOFTWARE' -Name OpenSSH -Force   # if the key itself doesn't exist yet

Set-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Force
Restart-Service sshd
```

**🔴 Gotcha verified live: use `powershell.exe` (Windows PowerShell 5.1), not `pwsh.exe` (PowerShell 7) if the machine is corporate-managed.** On a corporate-hardened machine, launching `pwsh.exe` from an SSH session can fail with **`Access is denied`** even though the SSH session's own token is **High Mandatory Level** (i.e. not a UAC/elevation problem) and `powershell.exe` launches perfectly fine in the exact same session. This is the signature of an **AppLocker/WDAC rule specifically targeting the third-party `pwsh.exe` binary** (typically installed under `Program Files\PowerShell\7\`) while leaving the built-in, more heavily audited (AMSI/Script Block Logging) `powershell.exe` untouched — a deliberate, common corporate security posture, not a misconfiguration. Confirm via Event Viewer → `Applications and Services Logs\Microsoft\Windows\AppLocker\EXE and DLL`, Event ID `8004`, if you need definitive proof. **Don't fight this policy — use `powershell.exe` as `DefaultShell`, it's fully capable.**

**⚠️ Considered and rejected: `HKCU:\Software\Microsoft\Command Processor\AutoRun`.** This *is* the actual per-user `.zshrc`-equivalent for `cmd.exe` — but it also fires for **non-interactive** `cmd /c "<command>"` sessions (confirmed: only the `/D` flag suppresses it, and OpenSSH's Windows server does not pass `/D` when spawning the shell). If the `AutoRun` command itself launches an interactive nested shell, every scripted one-off `ssh host "command"` call hangs waiting on stdin instead of ever running the intended command — a real automation footgun. Use `DefaultShell` instead; it correctly handles both interactive sessions and one-shot exec without this trap.

## 5. Ubuntu-side client — key + config

Follow `k-ssh` for the key naming convention (`id_ed25519_<target>`) and the canonical `assets/ssh.conf` fragment (never edit local `~/.ssh/config` directly). The `Host * !github.com !gitlab.com` global block already there (`ControlMaster`/`ControlPersist`/`RemoteForward`) applies automatically to any new Windows host added — no per-host repetition needed for those directives.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<target> -C "<source-machine>"
# paste the .pub into the right authorized_keys file per step 3 above
ssh -i ~/.ssh/id_ed25519_<target> <user>@<hostname>
```


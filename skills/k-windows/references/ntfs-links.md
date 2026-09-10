# k-windows — NTFS Links (symlink / hardlink / junction)

> **OS reference:** Windows 11 (any  Windows machine). General mechanics only — an *instance-specific* table of "which real file lives where, which path is a link to it" belongs to the skill that owns that file (e.g. a machine's own infra skill), not here.

## The three link types

| Type | Command | Privilege needed | Files or dirs | Same volume only | Retargetable |
|------|---------|-------------------|----------------|-------------------|--------------|
| Symbolic link | `New-Item -ItemType SymbolicLink` | Yes — `SeCreateSymbolicLinkPrivilege` (admin shell OR Developer Mode) | Both | No | Yes (delete + recreate) |
| Hard link | `New-Item -ItemType HardLink` | No | Files only | Yes | No (same file, not a pointer) |
| Junction | `New-Item -ItemType Junction` | No | Directories only | No — junctions *can* cross volumes on the same machine, unlike hard links | Yes (delete + recreate) |

**Rule of thumb:** prefer a real symlink first; fall back to a hard link (file) or junction (directory) only when elevation isn't available.

## The Developer Mode incident (why this matters)

First attempt at linking a file back to its canonical copy failed with:
```
New-Item: Administrator privilege required for this operation.
```
Cause: `SeCreateSymbolicLinkPrivilege` is granted by default only to **Administrators** and (since Windows 10) accounts with **Developer Mode** on — neither applied to that shell session.

Fallback used at the time: **hard links** for individual files, a **junction** for the one directory case (`C:\Users\<user>\.agents` → `Labs\.agents`).

**Fix:** enable Developer Mode via `Settings → Privacy & security → For developers → Developer Mode`. The privilege becomes available immediately in **new** shell sessions — no reboot required. After enabling, every existing hard link/junction can be upgraded to a true symlink.

**Policy note:** toggling Developer Mode on/off is a security-relevant Windows setting — this is something a **human operator** changes from Settings, never something an agent session should flip automatically. If a session hits "Administrator privilege required" and Developer Mode is off, fall back to a hard link/junction rather than trying to enable Developer Mode itself.

## Probe: does this session have symlink rights?

```powershell
$probe = "$env:TEMP\symlink-probe-$PID"
try {
    New-Item -ItemType SymbolicLink -Path $probe -Target $env:USERPROFILE -ErrorAction Stop | Out-Null
    Remove-Item $probe -Force
    "symlinks OK"
} catch { "still needs elevation or Developer Mode: $($_.Exception.Message)" }
```

## Upgrade an existing hard link/junction to a true symlink

```powershell
Remove-Item $linkPath -Force          # removes only that path, not the real file elsewhere
New-Item -ItemType SymbolicLink -Path $linkPath -Target $realPath | Out-Null
```

## Checking what a path actually is

```powershell
Get-Item $path -Force | Format-List Name, LinkType, Target, Attributes
```
- `LinkType` is empty for a normal file/dir; otherwise `SymbolicLink`, `HardLink`, or `Junction`.
- `Target` shows the resolution target.
- Don't trust memory/docs claiming a path is a particular link type without checking — links get recreated/upgraded/moved over time.

**From MSYS2/git-bash:**
```bash
stat -c '%i %n' pathA pathB
```
Prints the inode number per path — two hard-linked files (or two paths to the same symlink target) share the same inode.

## The "source of truth lives in one place" convention

Any file the OS expects at a fixed path — a PowerShell profile, a bootstrap script Windows/tmux expects at a specific location — has its real content tracked inside the owning skill's `assets/`, and the OS-mandated fixed path becomes a link back to it. Benefit: exactly one editable copy; the OS-required path still works unchanged. Same rule for duplicate copies across two skills: only one copy is real, the other becomes a symlink to it, to avoid silent drift (this is exactly how a stale independent copy of a session-bootstrap script was found and fixed on 2026-08-06 — see the owning machine's infra skill for that specific incident).


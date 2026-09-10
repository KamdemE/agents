# k-windows — Silently uninstalling Windows software from a script

> Generalized from a de-bloat pass on `k-laptop` — the technique is generic; the exact app names/GUIDs stay in that machine's own `references/debloat-log.md`.

## Two paths, depending on what you know

### A. You know the exact MSI ProductCode GUID

Fastest and most reliable — vendor docs, a previous discovery pass (path B below), or the registry all give you this GUID (`{XXXXXXXX-XXXX-...}`) per installed product.

```powershell
Start-Process msiexec.exe -ArgumentList "/x {GUID} /quiet /norestart" -Wait
```

**Clean up afterwards** — `msiexec` often leaves empty/near-empty install directories behind:
```powershell
Remove-Item -Path "$env:ProgramFiles\<Vendor>" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "${env:ProgramFiles(x86)}\<Vendor>" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\<Vendor>" -Recurse -Force -ErrorAction SilentlyContinue
```

### B. You only know the app's display name (or a pattern)

Look it up in the registry's "installed programs" list yourself — the same list the Control Panel/Settings "Apps" page reads from — then uninstall whatever you find:

```powershell
function Uninstall-ByDisplayNamePattern {
    param([string]$Pattern)
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like $Pattern } |
        ForEach-Object {
            if ($_.UninstallString -match 'msiexec') {
                Start-Process msiexec.exe -ArgumentList "/x $($_.PSChildName) /quiet /norestart" -Wait
            } elseif ($_.UninstallString) {
                Start-Process cmd.exe -ArgumentList "/c $($_.UninstallString) /quiet /norestart" -Wait
            }
        }
}

Uninstall-ByDisplayNamePattern "*Some App*"
```

**Why three registry roots, not one:**

| Root | Covers |
|---|---|
| `HKLM:\...\Uninstall` | Native 64-bit apps, machine-wide install |
| `HKLM:\...\WOW6432Node\...\Uninstall` | 32-bit apps running under WOW64 on a 64-bit Windows — a *separate* mirrored registry view, not automatically included in the first path |
| `HKCU:\...\Uninstall` | Per-user installs (no admin rights used at install time) |

Missing any one of the three means some installed software becomes invisible to the search — this is the single most common reason a "why didn't this get uninstalled" script fails silently.

**MSI vs. EXE detection:** `UninstallString` for an MSI-installed app always contains `msiexec`; branch on that and use the clean `/x {GUID} /quiet /norestart` form. For a non-MSI (EXE) installer, the vendor's own `UninstallString` is whatever it is — appending `/quiet /norestart` is a reasonable default but **not guaranteed to work** (silent-uninstall flags vary per vendor, some ignore them entirely and show a UI anyway).


# k-windows — Windows Services: forcing a stubborn one to stay disabled

> Generalized from a de-bloat pass on a specific machine (`k-laptop`) — the *technique* here is company/machine-agnostic; the exact list of service names that needed it stays in that machine's own `references/debloat-log.md`.

## SCM `Start` value reference

The Service Control Manager stores a service's startup type as a registry DWORD under `HKLM:\SYSTEM\CurrentControlSet\Services\<name>\Start`:

| Value | Meaning |
|---|---|
| 0 | Boot |
| 1 | System |
| 2 | Automatic |
| 3 | Manual (Demand) |
| 4 | **Disabled** |

Every technique below ultimately drives this one value, through progressively lower-level tools when a higher-level one doesn't stick.

## The 4-tier escalation

Most services disable cleanly at tier 1. Some (observed: Windows Gaming Services, Program Compatibility Assistant, several `*_<per-user-suffix>` service instances) silently re-enable themselves or refuse — that's when you need tiers 2-4.

### Tier 1 — `Set-Service` (try this first, always)

```powershell
$svc = Get-CimInstance Win32_Service -Filter "Name='<name>'"
if (-not $svc) { return }  # skip — not present on this machine

$dependents = Get-Service -Name <name> |
    Select-Object -ExpandProperty DependentServices |
    Where-Object { $_.Status -eq 'Running' }
if ($dependents) { return }  # skip — something else needs it running right now

if ($svc.State -eq 'Running') {
    Stop-Service -Name <name> -Force
    Start-Sleep -Seconds 2
}
Set-Service -Name <name> -StartupType Disabled

# verify
(Get-Service -Name <name>).StartType -eq 'Disabled'
```

The dependent-service check matters: disabling something a *running* service still depends on can break that other service in a confusing way — always check first.

### Tier 2 — plain retry

A second, identical pass of tier 1 sometimes just succeeds where the first attempt failed transiently (observed empirically, no deeper explanation needed — some services need to fully settle after being stopped before `Set-Service` will accept the change).

### Tier 3 — `sc.exe` directly

If tier 1/2 keep failing, bypass the `Set-Service` cmdlet and talk to the SCM through the older, more direct `sc.exe` tool:

```powershell
sc.exe config <name> start= disabled
```

(Note the space after `start=` — it's part of `sc.exe`'s syntax, easy to typo.)

### Tier 4 — direct registry write + clear recovery actions

The last resort, for services that ignore even `sc.exe`:

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\<name>" -Name "Start" -Value 4 -Type DWord
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\<name>" -Name "FailureActions" -ErrorAction SilentlyContinue
sc.exe failure <name> reset= 0 actions= ""
Stop-Service -Name <name> -Force
sc.exe stop <name>
```

**The non-obvious part:** some "watchdog"-style services have SCM **recovery actions** configured (auto-restart-on-crash / auto-restart-on-stop). Writing `Start=4` alone doesn't stop a service that's already running and configured to restart itself — you also need to clear `FailureActions` and reset the failure policy (`sc.exe failure ... actions= ""`), or it'll come back up on its own moments later.

## Reversal (any tier)

```powershell
Set-Service -Name <name> -StartupType Manual   # or Automatic
Start-Service -Name <name>
```

## Last-resort companion: rename the executable to `.DEAD`

For helper/watchdog **executables** that aren't a controllable service themselves (or that another process respawns even after the owning service is disabled), the reliable fallback is renaming the binary so nothing can find it:

```powershell
Rename-Item "C:\Path\To\Helper.exe" "Helper.exe.DEAD"
```

Fully reversible (rename back) — unlike deleting the file. Standard technique for stubborn vendor bloatware helper processes.

## Windows 11 Widgets (a common, fully generic pair of toggles)

Two well-known Windows 11 registry values, unrelated to any specific vendor: the Widgets **service** policy (commonly `IsWidgetServiceOn` under `HKLM:\SOFTWARE\Policies\Microsoft\Dsh`, DWORD `0` to disable) and the taskbar Widgets **button** (`TaskbarDa` under `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`, DWORD `0` to hide). Flagged here as generic OS-level toggles rather than bloatware-specific — the originating log only captured the two value *names*, not a verified full path, so double-check the exact key before relying on it.


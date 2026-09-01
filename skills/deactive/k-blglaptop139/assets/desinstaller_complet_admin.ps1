#Requires -RunAsAdministrator
# desinstaller_complet_admin.ps1 — broad sweep: 16 named tools by registry
# DisplayName match, plus duplicate Python, old Windows SDK, NVIDIA Nsight,
# and anything matching "*Killer*".

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
            Write-Host "Uninstalling: $($_.DisplayName)"
            if ($_.UninstallString -match 'msiexec') {
                Start-Process msiexec.exe -ArgumentList "/x $($_.PSChildName) /quiet /norestart" -Wait
            } elseif ($_.UninstallString) {
                Start-Process cmd.exe -ArgumentList "/c $($_.UninstallString) /quiet /norestart" -Wait
            }
        }
}

# 1) 16 named tools
foreach ($name in @(
    "Log4View V2*", "Strawberry Perl*", "doxygen*", "ImageJ*", "GPL Ghostscript*",
    "Graphviz*", "WinDirStat*", "WinMerge*", "KDiff3*", "HxD*", "IrfanView*",
    "FastStone*", "LockHunter*", "ezwinports*", "VNC Viewer*", "NoMachine*"
)) { Uninstall-ByDisplayNamePattern $name }

# 2) Duplicate Python (keep 3.12.10)
Uninstall-ByDisplayNamePattern "Python 3.12.0*"

# 3) Old Windows SDK (keep newer)
Uninstall-ByDisplayNamePattern "*22621*SDK*"

# 4) NVIDIA Nsight
Uninstall-ByDisplayNamePattern "*NVIDIA Nsight*"

# 5) Anything Killer
Uninstall-ByDisplayNamePattern "*Killer*"

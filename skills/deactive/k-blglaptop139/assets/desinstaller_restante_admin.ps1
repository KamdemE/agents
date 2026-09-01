#Requires -RunAsAdministrator
# desinstaller_restante_admin.ps1 — final sweep for whatever survived the
# earlier passes.

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

Uninstall-ByDisplayNamePattern "NoMachine*"
Uninstall-ByDisplayNamePattern "VNC Viewer*"
Uninstall-ByDisplayNamePattern "WinDirStat*"
Uninstall-ByDisplayNamePattern "GPL Ghostscript*"
Uninstall-ByDisplayNamePattern "WinMerge*"
Uninstall-ByDisplayNamePattern "Killer Performance Driver Suite*"
Uninstall-ByDisplayNamePattern "ImageJ*"

# Broad Dell/AWCC/Killer/FX*/GameLibrary/XtuInstaller/CoreInstaller/AWDisplay/AWIOSmart sweep
Uninstall-ByDisplayNamePattern "*Dell*"
Uninstall-ByDisplayNamePattern "*AWCC*"
Uninstall-ByDisplayNamePattern "*Killer*"
Uninstall-ByDisplayNamePattern "FX*"
Uninstall-ByDisplayNamePattern "*GameLibrary*"
Uninstall-ByDisplayNamePattern "*XtuInstaller*"
Uninstall-ByDisplayNamePattern "*CoreInstaller*"
Uninstall-ByDisplayNamePattern "*AWDisplay*"
Uninstall-ByDisplayNamePattern "*AWIOSmart*"

# Duplicate Python (regex-matched in the original)
Uninstall-ByDisplayNamePattern "Python 3.12.0*"

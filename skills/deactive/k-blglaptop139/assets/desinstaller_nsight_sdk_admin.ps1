#Requires -RunAsAdministrator
# desinstaller_nsight_sdk_admin.ps1 — remove NVIDIA Nsight (Compute/Systems/
# VS Edition) and the old Windows SDK (22621), found by registry lookup.

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

Uninstall-ByDisplayNamePattern "*NVIDIA Nsight Compute*"
Uninstall-ByDisplayNamePattern "*NVIDIA Nsight Systems*"
Uninstall-ByDisplayNamePattern "*NVIDIA Nsight*VS Edition*"
Uninstall-ByDisplayNamePattern "*22621*SDK*"
Uninstall-ByDisplayNamePattern "*Windows Software Development Kit*22621*"

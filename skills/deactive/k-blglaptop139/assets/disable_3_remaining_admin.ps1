#Requires -RunAsAdministrator
# disable_3_remaining_admin.ps1 — second pass for 3 services that resisted
# the first disable attempt (desactiver_services_admin.ps1).

$names = @("GamingServices", "GamingServicesNet", "PcaSvc")

foreach ($name in $names) {
    Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
    Set-Service -Name $name -StartupType Disabled -ErrorAction SilentlyContinue
    $check = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($check.StartType -eq 'Disabled') {
        Write-Host "OK: $name disabled"
    } else {
        Write-Host "STILL FAILING: $name — see force_disable_services_admin.ps1"
    }
}

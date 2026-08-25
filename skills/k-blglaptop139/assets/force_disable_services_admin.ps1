#Requires -RunAsAdministrator
# force_disable_services_admin.ps1 — third pass, via sc.exe directly, for
# services that ignored Set-Service -StartupType Disabled.

$names = @(
    "GamingServices", "GamingServicesNet", "PcaSvc",
    "WpnUserService_85a508", "PimIndexMaintenanceSvc_85a508",
    "UnistoreSvc_85a508", "UserDataSvc_85a508"
)

foreach ($name in $names) {
    Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
    sc.exe config $name start= disabled | Out-Null
    $check = Get-Service -Name $name -ErrorAction SilentlyContinue
    Write-Host "$name -> $($check.StartType)"
}

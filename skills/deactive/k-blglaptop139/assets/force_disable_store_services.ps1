#Requires -RunAsAdministrator
# force_disable_store_services.ps1 — fourth and final pass: direct registry
# write for services that ignored even sc.exe config (force_disable_services_admin.ps1).

$names = @("GamingServices", "GamingServicesNet", "WpnUserService_85a508")

foreach ($name in $names) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$name"

    Set-ItemProperty -Path $regPath -Name "Start" -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $regPath -Name "FailureActions" -ErrorAction SilentlyContinue

    sc.exe config $name start= disabled | Out-Null
    sc.exe failure $name reset= 0 actions= "" | Out-Null

    Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
    sc.exe stop $name | Out-Null

    $val = Get-ItemProperty -Path $regPath -Name "Start" -ErrorAction SilentlyContinue
    Write-Host "$name -> registry Start=$($val.Start) (4=Disabled)"
}

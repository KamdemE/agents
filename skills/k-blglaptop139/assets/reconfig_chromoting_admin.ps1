#Requires -RunAsAdministrator
# reconfig_chromoting_admin.ps1 — force-enable Chrome Remote Desktop, kept
# on purpose after the de-bloat pass disabled it (phone-access requirement).

$name = "chromoting"

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$name" -Name "Start" -Value 2 -Type DWord
sc.exe config $name start= auto | Out-Null
Start-Service -Name $name -ErrorAction SilentlyContinue

$svc = Get-Service -Name $name -ErrorAction SilentlyContinue
if ($svc.Status -ne 'Running') {
    net start $name
}

Write-Host "$name -> Status=$((Get-Service -Name $name).Status) StartType=$((Get-Service -Name $name).StartType)"

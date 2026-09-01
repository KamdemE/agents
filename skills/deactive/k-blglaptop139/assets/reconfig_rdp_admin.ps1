#Requires -RunAsAdministrator
# reconfig_rdp_admin.ps1 — re-enable Remote Desktop, kept on purpose after
# the de-bloat pass disabled TermService/SessionEnv (RDP is needed from
# the Ubuntu workstation — see k-dxo for the DxO-specific target/account).

$services = @(
    @{ Name = "chromoting";   Type = "auto" }
    @{ Name = "TermService";  Type = "demand" }
    @{ Name = "SessionEnv";   Type = "demand" }
)

foreach ($svc in $services) {
    sc.exe config $svc.Name start= $svc.Type | Out-Null
    Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
    $check = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    Write-Host "$($svc.Name) -> Status=$($check.Status) StartType=$($check.StartType)"
}

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Type DWord
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host "RDP enabled: fDenyTSConnections=0, firewall group 'Remote Desktop' enabled."

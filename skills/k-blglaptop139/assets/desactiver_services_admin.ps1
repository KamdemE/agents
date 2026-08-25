#Requires -RunAsAdministrator
# desactiver_services_admin.ps1 — disable 22 non-essential Windows services.
# See k-blglaptop139/references/debloat-log.md for the full rationale/RAM figures.

$services = @(
    @{ Name = "AdobeARMservice";         Reason = "Adobe Update Manager" }
    @{ Name = "DiagTrack";                Reason = "Connected User Experiences and Telemetry" }
    @{ Name = "DolbyDAXAPI";              Reason = "Dolby Audio API" }
    @{ Name = "GameInputRedistService";   Reason = "Game Input redistribution" }
    @{ Name = "GamingServices";           Reason = "Xbox gaming services" }
    @{ Name = "GamingServicesNet";        Reason = "Xbox gaming services (network)" }
    @{ Name = "InventorySvc";             Reason = "Inventory & Compatibility Appraisal" }
    @{ Name = "PcaSvc";                   Reason = "Program Compatibility Assistant" }
    @{ Name = "Spooler";                  Reason = "Print Spooler (no printer in use)" }
    @{ Name = "SysMain";                  Reason = "Superfetch/Prefetch" }
    @{ Name = "WpnService";               Reason = "Windows Push Notifications (system)" }
    @{ Name = "chromoting";               Reason = "Chrome Remote Desktop host" }
    @{ Name = "GameInputSvc";             Reason = "Game Input service" }
    @{ Name = "lfsvc";                    Reason = "Geolocation service" }
    @{ Name = "SessionEnv";               Reason = "Remote Desktop Configuration" }
    @{ Name = "TermService";              Reason = "Remote Desktop Services" }
    @{ Name = "PimIndexMaintenanceSvc";   Reason = "Contact Data indexing" }
    @{ Name = "UnistoreSvc";              Reason = "User Data Storage" }
    @{ Name = "UserDataSvc";              Reason = "User Data Access" }
    @{ Name = "SQLWriter";                Reason = "SQL Server VSS Writer (unused)" }
    @{ Name = "WSearch";                  Reason = "Windows Search indexer" }
    @{ Name = "WpnUserService_85a508";    Reason = "Windows Push Notifications (user)" }
)

$success = 0; $failed = 0; $skipped = 0

foreach ($svc in $services) {
    $s = Get-CimInstance Win32_Service -Filter "Name='$($svc.Name)'" -ErrorAction SilentlyContinue
    if (-not $s) { Write-Host "SKIP (not found): $($svc.Name)"; $skipped++; continue }

    $dependents = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty DependentServices |
        Where-Object { $_.Status -eq 'Running' }
    if ($dependents) {
        Write-Host "SKIP (has running dependents): $($svc.Name)"; $skipped++; continue
    }

    if ($s.State -eq 'Running') {
        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }

    Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
    $check = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    if ($check.StartType -eq 'Disabled') {
        Write-Host "OK: $($svc.Name) — $($svc.Reason)"; $success++
    } else {
        Write-Host "FAILED: $($svc.Name)"; $failed++
    }
}

Write-Host "`nDone: $success disabled, $failed failed, $skipped skipped."
Write-Host "Reversal: Set-Service -Name <name> -StartupType Manual; Start-Service -Name <name>"

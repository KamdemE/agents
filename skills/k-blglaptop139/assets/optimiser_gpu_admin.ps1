#Requires -RunAsAdministrator
# optimiser_gpu_admin.ps1 — mitigate the external-4K-monitor-on-dGPU
# idle-utilization problem (see references/debloat-log.md → GPU root cause).

# 1) Force 100% display scaling (avoids extra compositor work)
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "LogPixels" -Value 96 -Type DWord

# 2) Manual step (no automation possible): lower the external monitor's
#    refresh rate to 30Hz via Settings > Display > Advanced display settings.
Write-Host "MANUAL STEP: set external monitor refresh rate to 30Hz in Windows Display settings."

# 3) Disable Cursor's GPU acceleration
$cursorSettings = "$env:APPDATA\Cursor\User\settings.json"
if (Test-Path $cursorSettings) {
    $json = Get-Content $cursorSettings -Raw | ConvertFrom-Json
    $json | Add-Member -NotePropertyName "editor.gpuAcceleration" -NotePropertyValue "off" -Force
    $json | ConvertTo-Json -Depth 10 | Set-Content $cursorSettings
    Write-Host "Cursor GPU acceleration disabled."
}

# 4) NVIDIA persistence/power-management mode
nvidia-smi -pm 1 -i 0

# 5) Manual step: Settings > System > Display > Graphics > set Cursor.exe
#    to "Power saving" (forces it onto the Intel iGPU).
Write-Host "MANUAL STEP: set Cursor.exe to 'Power saving' GPU preference in Windows Graphics settings."

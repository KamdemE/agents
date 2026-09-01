#Requires -RunAsAdministrator
# optimiser_gpu_final.ps1 — same intent as optimiser_gpu_admin.ps1, kept as
# a second pass: purely instructional for resolution/refresh-rate, plus a
# regex-based (not JSON-parsed) edit of Cursor's settings.json.

Write-Host "MANUAL STEP: lower external monitor resolution/refresh rate (Settings > Display)."
Write-Host "MANUAL STEP: force apps to the Intel iGPU via Settings > System > Display > Graphics."

$cursorSettings = "$env:APPDATA\Cursor\User\settings.json"
if (Test-Path $cursorSettings) {
    $content = Get-Content $cursorSettings -Raw
    if ($content -match '"editor\.gpuAcceleration"\s*:\s*"[^"]*"') {
        $content = $content -replace '"editor\.gpuAcceleration"\s*:\s*"[^"]*"', '"editor.gpuAcceleration": "off"'
    } else {
        $content = $content -replace '\{', "{`n  `"editor.gpuAcceleration`": `"off`",", 1
    }
    Set-Content -Path $cursorSettings -Value $content
    Write-Host "Cursor GPU acceleration disabled (regex edit)."
}

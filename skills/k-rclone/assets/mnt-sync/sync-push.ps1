# KpihX mnt-sync — push LOCAL_ROOT -> REMOTE_ROOT (Windows, one-way, mirrors
# exactly — /MIR removes orphans on the remote side).
# Mirrors sync-push.sh. Reads the same dirs.txt (blank/`#` lines ignored).
param(
    [string]$RemoteRoot = "O:\REPLACE_ME",
    [string]$LocalRoot  = (Join-Path $PSScriptRoot "..\..\assets")
)

$dirsFile = Join-Path $PSScriptRoot "dirs.txt"
if (-not (Test-Path $dirsFile)) {
    Write-Error "dirs.txt not found at $dirsFile — copy dirs.txt.example and adjust."
    exit 1
}
$dirs = Get-Content $dirsFile | ForEach-Object { ($_ -split '#')[0].Trim() } | Where-Object { $_ -ne "" }

Write-Host "Pushing: $LocalRoot -> $RemoteRoot (mirror, /MIR)"

foreach ($d in $dirs) {
    $src = Join-Path $LocalRoot $d
    $dst = Join-Path $RemoteRoot $d
    if (-not (Test-Path $src)) {
        Write-Warning "skip $d - not found at $src"
        continue
    }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Write-Host "  -> $d"
    robocopy $src $dst /MIR /Z /R:1 /W:1 /NFL /NDL | Out-Null
}

Write-Host "Push complete."

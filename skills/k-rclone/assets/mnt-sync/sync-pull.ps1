#  mnt-sync — pull REMOTE_ROOT -> LOCAL_ROOT (Windows, one-way, no delete).
# Mirrors sync-pull.sh. Reads the same dirs.txt (blank/`#` lines ignored).
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

Write-Host "Pulling: $RemoteRoot -> $LocalRoot"
New-Item -ItemType Directory -Force -Path $LocalRoot | Out-Null

foreach ($d in $dirs) {
    $src = Join-Path $RemoteRoot $d
    $dst = Join-Path $LocalRoot $d
    if (-not (Test-Path $src)) {
        Write-Warning "skip $d - not found at $src"
        continue
    }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Write-Host "  -> $d"
    # /E recurse incl. empty dirs, /Z restartable, /R:1 /W:1 fail fast on flaky mounts
    robocopy $src $dst /E /Z /R:1 /W:1 /NFL /NDL | Out-Null
}

Write-Host "Pull complete."

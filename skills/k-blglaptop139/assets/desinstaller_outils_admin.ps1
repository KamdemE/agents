#Requires -RunAsAdministrator
# desinstaller_outils_admin.ps1 — remove unused tools by exact MSI GUID,
# then clean orphaned directories.

$apps = @(
    @{ Name = "Log4View V2";                Guid = "{3C1D7E0F-6D28-4C0D-B787-2F634E49891F}" }
    @{ Name = "Strawberry Perl";            Guid = "{2331E434-70DE-4357-9D08-295A0B9F303D}" }
    @{ Name = "Python 3.12.0";              Guid = "{D2B580FC-6E22-469C-B141-0769B9888D37}" }
    @{ Name = "Killer Driver Suite";        Guid = "{9FD727F9-376A-4834-B11D-0E36C1485C81}" }
    @{ Name = "NVIDIA Nsight Systems";      Guid = "{1A7B91EF-6530-4B35-A646-22A1F069A7A5}" }
    @{ Name = "NVIDIA Nsight Graphics";     Guid = "{2B5D154C-5E34-4C33-B59E-3F4C7B87A2A3}" }
)

foreach ($app in $apps) {
    Write-Host "Uninstalling: $($app.Name)"
    Start-Process msiexec.exe -ArgumentList "/x $($app.Guid) /quiet /norestart" -Wait
}

foreach ($dir in @(
    "$env:ProgramFiles\NVIDIA Corporation\Nsight Systems",
    "$env:ProgramFiles\NVIDIA Corporation\Nsight Graphics",
    "$env:ProgramFiles\Strawberry",
    "$env:ProgramFiles\Killer",
    "${env:ProgramFiles(x86)}\Killer"
)) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed orphaned dir: $dir"
    }
}

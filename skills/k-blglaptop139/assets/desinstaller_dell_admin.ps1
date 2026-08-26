#Requires -RunAsAdministrator
# desinstaller_dell_admin.ps1 — remove Dell/Alienware bloatware by exact MSI GUID.

$apps = @(
    @{ Name = "Dell SupportAssist";                       Guid = "{5E5B7C3B-96BE-4A47-B28D-CAA7D87F95A8}" }
    @{ Name = "Alienware Digital Delivery Services";       Guid = "{87310396-FD49-4108-BBBB-28E1C3EA85E9}" }
    @{ Name = "Alienware SupportAssist Remediation";       Guid = "{2D452EA3-A8E6-4DF8-8135-6D8F2D61F693}" }
    @{ Name = "Alienware SupportAssist OS Recovery";       Guid = "{BE92A615-4964-403F-B965-827881C7CE4D}" }
    @{ Name = "AlienwareArena";                            Guid = "{74234BCD-70C4-40EC-BC36-0D7C376F3EC3}" }
    @{ Name = "Dell Command Update";                       Guid = "{1243A8BB-4137-47B3-BAAE-783E7D662407}" }
    @{ Name = "Dell Core Services";                        Guid = "{7AF25A53-31D7-4E74-8D7C-B5D59B3A92C7}" }
)

foreach ($app in $apps) {
    Write-Host "Uninstalling: $($app.Name) $($app.Guid)"
    Start-Process msiexec.exe -ArgumentList "/x $($app.Guid) /quiet /norestart" -Wait
}

foreach ($dir in @(
    "$env:ProgramFiles\Alienware",
    "${env:ProgramFiles(x86)}\Alienware",
    "$env:ProgramData\Alienware"
)) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed leftover dir: $dir"
    }
}

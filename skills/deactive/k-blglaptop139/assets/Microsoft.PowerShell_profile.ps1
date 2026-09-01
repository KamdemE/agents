# Microsoft.PowerShell_profile.ps1 — deployed at
# Documents\PowerShell\Microsoft.PowerShell_profile.ps1 on this machine.

if ($Host.Name -eq 'ConsoleHost' -and (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)) {
    Set-PSReadLineOption -MaximumHistoryCount 50000
    if (-not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
        try {
            Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
        } catch {}
    }
}

# f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
Import-Module -Name Microsoft.WinGet.CommandNotFound
# f45873b3-b655-43a6-b217-97c00aa0db58

function tx {
    param([string]$Session = "dxo")
    & "$env:USERPROFILE\KpihX-Labs\DxO\tmux-sessions.ps1"
    tmux attach -t $Session
}

# Auto-cd on every new shell
Set-Location ~/KpihX-Labs

function Get-FullHistory { Get-Content (Get-PSReadLineOption).HistorySavePath }
Remove-Item Alias:h -ErrorAction SilentlyContinue
Remove-Item Alias:hist -ErrorAction SilentlyContinue
Set-Alias -Name h -Value Get-FullHistory
Set-Alias -Name hist -Value Get-FullHistory

# Microsoft.PowerShell_profile.ps1 — GENERIC TEMPLATE (k-windows)
#
# Copy this into the owning machine's own infra skill (e.g. k-laptop)
# scripts/, personalize the marked REPLACE_ME spots, then deploy at
# Documents\PowerShell\Microsoft.PowerShell_profile.ps1 on that machine.
# See k-windows/SKILL.md -> "Pattern for a new Windows+WSL machine".

if ($Host.Name -eq 'ConsoleHost' -and (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)) {
    Set-PSReadLineOption -MaximumHistoryCount 50000
    if (-not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
        try {
            Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
        } catch {}
    }
}

# PowerToys CommandNotFound module — this exact block (including the GUID
# marker comments) is auto-inserted by the PowerToys installer; keep it
# verbatim so PowerToys can find/update its own block later.
# f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
Import-Module -Name Microsoft.WinGet.CommandNotFound
# f45873b3-b655-43a6-b217-97c00aa0db58

# tmux session launcher — REPLACE_ME: point at this machine's own
# tmux-sessions.ps1 (copied+personalized from k-windows/scripts/msys2/
# tmux-sessions.ps1) and its session name, if it differs from the generic
# "windows" default.
function tx {
    param([string]$Session = "windows")
    & "$env:USERPROFILE\Labs\REPLACE_ME\tmux-sessions.ps1"
    tmux attach -t $Session
}

# workspace convention: every new shell lands in ~/Labs
Set-Location ~/Labs

function Get-FullHistory { Get-Content (Get-PSReadLineOption).HistorySavePath }
Remove-Item Alias:h -ErrorAction SilentlyContinue
Remove-Item Alias:hist -ErrorAction SilentlyContinue
Set-Alias -Name h -Value Get-FullHistory
Set-Alias -Name hist -Value Get-FullHistory

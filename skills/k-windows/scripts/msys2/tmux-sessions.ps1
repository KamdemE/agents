#Requires -Version 5.1
<#
  Labs — tmux-sessions.ps1 (MSYS2 / Windows)

  Generic, machine-agnostic tmux bootstrap for a Windows box running tmux
  via MSYS2. Mirrors k-tmux's standard equipment layout exactly (see
  k-tmux/assets/tmux-init.sh, the Linux/bash original this ports):

    Session "windows"
      Window 0 "agents" — split 3 ways
        Pane 0 (left)        = agents pane   (e.g. opencode)
        Pane 1 (right-top)   = editors pane   (e.g. nvim)
        Pane 2 (right-bottom)= ops pane       (shell)
      Window 1 "default"
      Window 2 "tmp"

  Idempotent — never recreates an existing session or window.

  Usage:
    powershell -File tmux-sessions.ps1            # create if missing
    powershell -File tmux-sessions.ps1 -Attach     # create (if missing) + attach

  Fixed vs. the original migration source (see k-windows/references/msys2.md
  for the full incident write-up): the original had THREE mutually
  contradictory session/window maps (a session named "dxo" that nothing
  ever created, a "culling"/"server"/"alienware" set of DxO- and
  machine-specific sessions, and a script comment that called a local
  session "remote"). This version drops all of that — a generic skill
  should not carry one specific machine's historical bugs. DxO-specific
  and machine-specific tmux needs belong in k-dxo / the owning infra skill
  respectively, not here.
#>

param(
    [switch]$Attach
)

$SessionName = "windows"

# Locate tmux.exe (MSYS2 default install path; override by editing this
# if your MSYS2 install lives elsewhere).
$TMUX = "C:\msys64\usr\bin\tmux.exe"
if (-not (Test-Path $TMUX)) {
    $found = Get-Command tmux -ErrorAction SilentlyContinue
    if ($found) { $TMUX = $found.Source }
}
if (-not (Test-Path $TMUX) -and -not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Error "tmux.exe not found (checked $TMUX and PATH). Is MSYS2 tmux installed?"
    exit 1
}

function Test-TmuxSession {
    param([string]$Name)
    & $TMUX has-session -t $Name 2>$null
    return ($LASTEXITCODE -eq 0)
}

function Test-TmuxWindow {
    param([string]$Session, [string]$Window)
    $names = & $TMUX list-windows -t $Session -F '#{window_name}' 2>$null
    return ($names -contains $Window)
}

if (Test-TmuxSession -Name $SessionName) {
    Write-Host "Session '$SessionName' already exists."
} else {
    Write-Host "Creating tmux session: $SessionName"

    # Window 0: agents (3 panes) — created with the session itself
    & $TMUX new-session -d -s $SessionName -n agents
    & $TMUX split-window -h -t "${SessionName}:agents.0"
    & $TMUX split-window -v -t "${SessionName}:agents.1"

    # Window 1: default
    & $TMUX new-window -t $SessionName -n default

    # Window 2: tmp
    & $TMUX new-window -t $SessionName -n tmp
}

# Idempotent per-window check in case the session existed but a window
# was closed since (mirrors k-tmux's New-WindowIfMissing pattern).
foreach ($w in @("agents", "default", "tmp")) {
    if (-not (Test-TmuxWindow -Session $SessionName -Window $w)) {
        Write-Host "Recreating missing window: $w"
        & $TMUX new-window -t $SessionName -n $w
    }
}

Write-Host "Done."
if ($Attach) {
    & $TMUX attach -t $SessionName
} else {
    Write-Host "Attach: tmux attach -t $SessionName"
}

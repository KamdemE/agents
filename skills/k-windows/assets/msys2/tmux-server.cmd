@echo off
REM tmux-server.cmd — attach to tmux running ON a remote server, over SSH
REM (SSH key authentication, no password prompt with a correctly configured
REM ~/.ssh/config alias). Generic template, part of the k-windows "remote
REM server access" family — see scripts/remote-server/tmux-server.sh (the
REM bash equivalent) and references/remote-server-access.md for the full family.
REM
REM Usage: tmux-server.cmd ls              (list remote sessions)
REM        tmux-server.cmd attach          (attach the default session)
REM        tmux-server.cmd attach -t foo   (attach a named session)
REM        tmux-server.cmd new             (create a new session)
REM        tmux-server.cmd kill-server     (kill the remote tmux server)
REM
REM Personalize SSH_ALIAS below (or set it as an env var before calling) —
REM it must resolve via %USERPROFILE%\.ssh\config, exactly like the target
REM host in mount-server.bat.
REM -tt forces TTY allocation (required for `tmux attach` to work over SSH).
REM BatchMode=yes = never prompt for a password (fails hard instead of
REM hanging, matching tmux-server's issue-guidance philosophy).

if "%SSH_ALIAS%"=="" set SSH_ALIAS=REPLACE_ME
ssh -o BatchMode=yes -tt %SSH_ALIAS% "tmux %*"

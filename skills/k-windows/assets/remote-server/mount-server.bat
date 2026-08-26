@echo off
REM mount-server.bat — generic template: mount a remote SSH/SFTP host as a
REM local Windows drive letter via rclone, with boot-time retry + logging.
REM See k-windows/references/ssh-mount.md for the full setup (SSH config,
REM rclone.conf, nssm service). Part of the k-windows "remote server access"
REM template family (assets/remote-server/) — see
REM k-windows/references/remote-server-access.md for the whole family.
REM
REM Personalize the 3 variables below for the target host/drive, then
REM deploy the personalized copy at %USERPROFILE%\.rclone\<name>-mount.bat.

setlocal
set REMOTE_NAME=REPLACE_ME
set DRIVE_LETTER=Z:
set LOG=%USERPROFILE%\.rclone\%REMOTE_NAME%-mount.log
set RCLONE=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.74.3-windows-amd64\rclone.exe

if not exist "%RCLONE%" (
    for /f "delims=" %%i in ('where rclone 2^>nul') do set RCLONE=%%i
)

REM Wait for network at boot
timeout /t 15 /nobreak >nul

REM Clean any stale mount/process
taskkill /f /im rclone.exe >nul 2>&1
net use %DRIVE_LETTER% /delete >nul 2>&1

set RETRIES=3
:retry
"%RCLONE%" mount %REMOTE_NAME%: %DRIVE_LETTER% --network-mode --volname "%REMOTE_NAME% (%REMOTE_NAME%)" --vfs-cache-mode full --dir-cache-time 10m --vfs-cache-max-age 1h >> "%LOG%" 2>&1
set /a RETRIES-=1
if %RETRIES% gtr 0 (
    timeout /t 5 /nobreak >nul
    goto retry
)
endlocal

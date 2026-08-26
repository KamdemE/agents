@echo off
REM mount-deep-pc6.bat — autostart rclone mount of deep-pc6 as Z:
REM Waits for the network at boot, retries on failure, logs everything.
REM Deployed at %USERPROFILE%\.rclone\mount-deep-pc6.bat, launched by the
REM nssm service "rclone-deep-pc6" (see k-dxo/SKILL.md).

setlocal
set LOG=%USERPROFILE%\.rclone\mount-deep-pc6.log
set RCLONE=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.74.3-windows-amd64\rclone.exe

if not exist "%RCLONE%" (
    for /f "delims=" %%i in ('where rclone 2^>nul') do set RCLONE=%%i
)

REM Wait for network at boot
timeout /t 15 /nobreak >nul

REM Clean any stale mount/process
taskkill /f /im rclone.exe >nul 2>&1
net use Z: /delete >nul 2>&1

set RETRIES=3
:retry
"%RCLONE%" mount deep-pc6: Z: --network-mode --volname "deep-pc6 (deep-pc6)" --vfs-cache-mode full --dir-cache-time 10m --vfs-cache-max-age 1h >> "%LOG%" 2>&1
set /a RETRIES-=1
if %RETRIES% gtr 0 (
    timeout /t 5 /nobreak >nul
    goto retry
)
endlocal

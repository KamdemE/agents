@echo off
REM unmount-server.bat — generic template pair to mount-server.bat.
setlocal
set DRIVE_LETTER=Z:
net use %DRIVE_LETTER% /delete
taskkill /f /im rclone.exe
endlocal

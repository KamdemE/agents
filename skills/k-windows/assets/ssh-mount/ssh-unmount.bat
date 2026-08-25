@echo off
REM ssh-unmount.bat — generic template pair to ssh-mount.bat.
setlocal
set DRIVE_LETTER=Z:
net use %DRIVE_LETTER% /delete
taskkill /f /im rclone.exe
endlocal

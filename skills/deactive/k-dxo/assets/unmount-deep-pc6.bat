@echo off
REM unmount-deep-pc6.bat — deployed at %USERPROFILE%\.rclone\unmount-deep-pc6.bat
net use Z: /delete
taskkill /f /im rclone.exe

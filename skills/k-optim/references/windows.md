# k-optim — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-blglaptop139` (blglaptop139)

---

## Windows Native Cleanup

### Disk Cleanup

```powershell
# Built-in Disk Cleanup
cleanmgr /sageset:1  # Configure settings
cleanmgr /sagerun:1   # Run with saved settings

# Or use Storage Settings (GUI)
# Settings > System > Storage > Storage Sense
```

### Temp Files

```powershell
# Windows temp
del /q /s %TEMP%\*.*
del /q /s C:\Windows\Temp\*.*

# Using PowerShell
Get-ChildItem -Path $env:TEMP -Recurse -Force | Remove-Item -Recurse -Force
```

### App Caches

```powershell
# Edge/Chrome cache
Get-ChildItem -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache" -Recurse -Force | Remove-Item -Recurse -Force
Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache" -Recurse -Force | Remove-Item -Recurse -Force
```

---

## WSL Cleanup

WSL uses a Linux filesystem inside Windows. Cleanup follows Linux patterns:

```bash
# Inside WSL
sudo apt autoremove --purge
sudo apt autoclean
sudo journalctl --vacuum-size=100M
docker system prune -af --volumes
```

### WSL Disk Compaction

The WSL ext4.vhdx file grows over time but does not shrink automatically. Compact it from Windows:

```powershell
# From PowerShell (Admin)
wsl --shutdown
diskpart
# select vdisk file="%USERPROFILE%\AppData\Local\Packages\*\LocalState\ext4.vhdx"
# compact vdisk
# exit
```

---

## Editor Caches (Windows Native)

| Editor | Cache path |
|--------|-----------|
| VS Code | `%APPDATA%\Code\Cache` and `%APPDATA%\Code\CachedData` |
| Cursor | `%APPDATA%\Cursor\Cache` and `%APPDATA%\Cursor\CachedData` |

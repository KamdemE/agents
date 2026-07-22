# k-browser — Windows

> **OS reference:** Microsoft Windows
> **Applies to:** `k-blglaptop139` (blglaptop139) and any Windows machine

---

## Browser Automation on Windows

### Chrome / Edge Installation

On Windows, Chrome and Edge are installed natively (MSI installer or winget):

```powershell
winget install Google.Chrome
winget install Microsoft.Edge
```

Both browsers support the Chrome DevTools Protocol (CDP) on Windows identically to Linux. The automation tools (`chrome-agent-mcp`, Playwright) work the same way.

### Remote Debugging Port

CDP remote debugging port setup on Windows:
```powershell
# Launch Chrome with remote debugging
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

### Path Differences (when relevant)

| Resource | Linux path | Windows path |
|----------|-----------|-------------|
| Chrome binary | `/usr/bin/google-chrome` | `C:\Program Files\Google\Chrome\Application\chrome.exe` |
| Edge binary | `/usr/bin/microsoft-edge` | `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe` |
| User data dir | `~/.config/google-chrome/` | `%LOCALAPPDATA%\Google\Chrome\User Data\` |

### Browser Automation via WSL

When browser automation is initiated from WSL (e.g., running agent tools inside WSL):

1. Chrome/Edge must be installed on the **Windows host** (not inside WSL)
2. The `--remote-debugging-port=9222` flag must be set on the Windows Chrome instance
3. From WSL, connect to `localhost:9222` — WSL2 forwards Windows localhost automatically
4. The MCP `chrome-agent` connects to the same port regardless of host OS

### WSL-Specific Considerations

- WSL2 forwards `localhost` connections to Windows automatically
- The Windows Chrome instance manages its own extensions and profiles
- Closing the Windows Chrome window stops all CDP connections
- For persistent automation, run Chrome headlessly: `chrome.exe --headless --remote-debugging-port=9222`

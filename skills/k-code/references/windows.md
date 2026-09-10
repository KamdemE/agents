# k-code — Windows / WSL

> **OS reference:** Microsoft Windows (native + WSL subsystem)  
> **Applies to:** `k-laptop` (laptop) and any Windows machine

---

## Overview

On Windows, three editor ecosystems are relevant: VS Code, Cursor, and AGY (Antigravity). All three can be installed natively on Windows and configured to work with WSL for Linux development. The general pattern is:

1. Install the editor **natively on Windows** (via winget)
2. Use the **WSL Remote** extension to connect the Windows editor to the WSL environment
3. Editor configs and extensions live on Windows; project files can be on either side

---

## VS Code

### Installation

```powershell
winget install Microsoft.VisualStudio.Code
```

Or download from `https://code.visualstudio.com/Download` (User Installer recommended).

### Path Differences

| Resource | Linux (Ubuntu) | Windows |
|----------|---------------|---------|
| User config root | `~/.config/Code/User/` | `%APPDATA%\Code\User\` |
| Settings | `~/.config/Code/User/settings.json` | `%APPDATA%\Code\User\settings.json` |
| Keybindings | `~/.config/Code/User/keybindings.json` | `%APPDATA%\Code\User\keybindings.json` |
| MCP config | `~/.config/Code/User/mcp.json` | `%APPDATA%\Code\User\mcp.json` |
| Global storage | `~/.config/Code/User/globalStorage/storage.json` | `%APPDATA%\Code\User\globalStorage\storage.json` |
| Workspace storage | `~/.config/Code/User/workspaceStorage/<hash>/` | `%APPDATA%\Code\User\workspaceStorage\<hash>\` |
| Extensions | `~/.vscode/extensions/` | `%USERPROFILE%\.vscode\extensions\` |
| Profiles | `~/.config/Code/User/profiles/<hash>/` | `%APPDATA%\Code\User\profiles\<hash>\` |

### WSL Remote

VS Code connects to WSL via the **Remote — WSL** extension (`ms-vscode-remote.remote-wsl`):

1. Install the extension in the Windows VS Code
2. Open a WSL folder: `code .` from inside WSL, or use **Remote Explorer** in VS Code
3. The editor runs its UI on Windows but executes commands, extensions, and language servers inside WSL
4. Settings sync works across both environments

### Key Difference for Kernel Config

When running VS Code **inside WSL** (via `code .` from WSL terminal), the config paths follow the **Linux** convention (`~/.config/Code/User/`). The WSL Remote extension handles the mapping automatically.

When running VS Code **natively on Windows** (opening Windows-local files), paths use the **Windows** convention (`%APPDATA%`).

---

## Cursor

### Installation

```powershell
winget install Cursor.Cursor
```

Or download from `https://cursor.com/downloads`.

### Path Differences

| Resource | Linux | Windows |
|----------|-------|---------|
| Config root | `~/.cursor/` | `%USERPROFILE%\.cursor\` |
| Agent transcripts | `~/.cursor/projects/<slug>/agent-transcripts/` | `%USERPROFILE%\.cursor\projects\<slug>\agent-transcripts\` |

### WSL Integration

Cursor supports WSL via the same Remote — WSL extension. Open a WSL folder from Cursor's remote explorer or use `cursor .` inside WSL (if `cursor` is symlinked in the WSL PATH).

To make `cursor` available from WSL:
```bash
# Add to ~/.kshrc or ~/.zshrc
alias cursor='/mnt/c/Users/<user>/AppData/Local/Programs/Cursor/Cursor.exe'
```

---

## AGY (Antigravity)

### Current Status on Windows

AGY is primarily developed for Linux. On Windows:
- **AGY CLI**: Install via `pip install antigravity` (same as Linux — works in WSL Python)
- **AGY IDE**: Native Windows build may not be available. Use via WSL or VS Code/Cursor as the editor frontend
- **AGY Hub**: Same as IDE — check latest release for Windows support

### WSL Workaround

AGY tools that run on Linux can be used from WSL:
```bash
# Inside WSL
pip install antigravity
agy --help
```

For AGY IDE on Windows, check the official Antigravity releases page for Windows builds.

---

## Continue.dev

### Path Differences

| Resource | Linux | Windows |
|----------|-------|---------|
| Config | `~/.continue/config.yaml` | `%USERPROFILE%\.continue\config.yaml` |
| Rules | `~/.continue/rules/` | `%USERPROFILE%\.continue\rules\` |
| Secrets | `~/.continue/.env` | `%USERPROFILE%\.continue\.env` |

Continue.dev works identically in VS Code and Cursor on Windows. The WSL Remote extension handles config resolution when editing WSL files.

---

## Editor Cleanup

The cleanup scripts (`clean_vscode.sh`, `clean_cursor.sh`, `clean_agy.sh`) are Linux/bash scripts. On Windows:

- **Native**: Use Windows-native tools (Disk Cleanup, Storage Settings) or equivalent PowerShell scripts
- **WSL**: The cleanup scripts work inside WSL for WSL-side caches
- **Cross-boundary**: VS Code/Cursor caches on the Windows side (`%APPDATA%`, `%USERPROFILE%\.cursor\`) must be cleaned from Windows

---

## General WSL Workflow Pattern

For agent/kernel operations on Windows (`k-laptop`):

1. **Editors run on Windows** (native UI, better performance, GPU acceleration)
2. **Development tools run in WSL** (git, python, node, docker, tmux)
3. **The kernel `.agents/` clone lives in WSL** (Linux paths consistent with all infra)
4. **WSL files are accessible from Windows** via `\\wsl.localhost\Ubuntu\` (or `\\wsl$\Ubuntu\`)
5. **Windows files are accessible from WSL** via `/mnt/c/`
6. **Recommended**: Use VS Code/Cursor with WSL Remote for kernel development — this gives Linux-native paths inside the editor

# 🛠️ System Scripts & Utilities

Personal shell scripts, automation tools, and system management utilities. Modular structure with git submodules for major subsystems.

## 📦 Core Modules (Git Submodules)

### [🧹 Clean](https://github.com/KpihX/clean-sh)
Modular system cleanup suite with specialized modules for snap, cache, VSCode, work directories, docker, and AI tools.
- **Repository:** `git@github.com:KpihX/clean-sh.git`
- **Install:** `make install` (systemd timer-based automation)
- **Purge:** `make purge`

### [💾 Backup & Restore](https://github.com/KpihX/backup-restore-sh)
Automated backup and bare-metal restore suite for Ubuntu workstations. Archives `/home` + `/etc` via tar+zstd to an external HDD; Telegram notifications; systemd timer every 2 days.
- **Repository:** `git@github.com:KpihX/backup-restore-sh.git`
- **Install:** `make install` (systemd timer-based automation)
- **Purge:** `make purge`
- **Logs:** `make log`
- **[Detailed Documentation](https://github.com/KpihX/backup-restore-sh/blob/main/README.md)**

## 📜 Utilities

### Agent & Security Tools
_(none — `sui` deprecated, tmux is the sudo gate. See `rules/tool-discipline.md` and `k-tmux`.)_

### Networking
- **`debug_net.py`** — Network diagnostics utility

### Directory Shortcuts
- **`cd`** — Quick directory navigation shortcuts

## 🔧 Development

```bash
# Show available make targets
make help

# Install ksh dispatcher + user systemd unit (see Makefile install target)
make install

# Push to all remotes — run from ~/.agents/ (repo root)
# cd ~/.agents && make push
```

## 📁 Structure

```
sh/
├── backup_restore/       # Git submodule — backup/restore suite
├── clean/               # Git submodule — cleanup suite
├── cd                   # Directory shortcuts
├── debug_net.py         # Network diagnostics
├── Makefile             # Git workflow + task runner
└── .agents/             # AI agent context (never committed)
```

## ⚠️ Git Submodules

This project uses git submodules. After cloning:

```bash
git submodule update --init --recursive
```

Current submodules are tracked in `.gitmodules`.

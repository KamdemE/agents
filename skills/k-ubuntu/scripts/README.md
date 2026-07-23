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

### [sui](https://github.com/KpihX/sui)
Sudo User Interface — unified graphical `sudo` / `pkexec` gateway for local and SSH remote elevation (Zenity **`--forms`**, argv-safe remote `sudo` over SSH). Rationale: **`--reason "…"`** or **`-r "…"`** (same flag).
- **Tracked revision (parent repo):** advance **`sui/`** to latest tag (e.g. **v3.1.23**) via `git submodule update --remote sui`; [CHANGELOG](https://github.com/KpihX/sui/blob/main/CHANGELOG.md) lists stub CI, audit `reason=present`, and **`-r`** as shorthand for **`--reason`**.
- **Repository (GitHub):** `git@github.com:KpihX/sui.git`
- **Repository (GitLab):** `git@gitlab.com:kpihx/sui.git`
- **Install:** submodule [README](https://github.com/KpihX/sui/blob/main/README.md) — `sudo install -o root -g root -m 0755 sui.sh /usr/local/bin/sui` from the clone.
- **Develop / test (inside `sui/`):** `make test` (lint + automated stub tests; no real GUI or privilege).

## 📜 Utilities

### Agent & Security Tools
- **`sui/`** (git submodule) — see **Core Modules** section **sui** above.

### Networking
- **`debug_net.py`** — Network diagnostics utility

### Directory Shortcuts
- **`cd`** — Quick directory navigation shortcuts

## 🔧 Development

```bash
# Show available make targets
make help

# Push to all remotes (github + gitlab) — root repo and each submodule that has those remotes
make push

# Install ksh dispatcher + user systemd unit (see Makefile install target)
make install

# Submodule: run sui’s automated tests from a full clone
cd sui && make test
```

## 📁 Structure

```
sh/
├── backup_restore/       # Git submodule — backup/restore suite
├── clean/               # Git submodule — cleanup suite
├── sui/                 # Git submodule — Sudo User Interface (graphical sudo gateway)
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

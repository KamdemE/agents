# CONTRACT.md — sui

> **[100% COMPLETE, RIGOROUS, AND TOTALLY TRANSPARENT]**
> **0% Hardcode · 100% Flexibility · Sovereign Infrastructure**

---

## 🏛️ Facet 1: PROD (Usage Contract)

This facet defines the absolute usage contract for operators and AI agents interacting with `sui`.

### 1.1 Installation & Uninstallation Flows (Symmetric)

#### A. Release Flow (One-Shot / Appliance)
For quick deployment without full repository management.

*   **Sovereign Appliance (Docker Script)**:
    ```bash
    # Install (requires docker + python3)
    curl -sSL https://raw.githubusercontent.com/KpihX/sui/main/scripts/install.sh | bash
    
    # Uninstall (Total Purge)
    curl -sSL https://raw.githubusercontent.com/KpihX/sui/main/scripts/uninstall.sh | bash
    ```

*   **Python Package (Isolated Environment)**:
    ```bash
    # Install (UV)
    uv tool install sui
    # Uninstall (UV)
    uv tool uninstall sui
    ```

#### B. Source Flow (Git Clone)
For local installation from a cloned repository.
```bash
git clone https://github.com/KpihX/sui.git
cd sui

# Install Host Appliance
make uv-install
# Uninstall Host Appliance
make uv-uninstall

# Install Docker Appliance
make docker-install
# Uninstall Docker Appliance
make docker-uninstall
```

### 1.2 CLI Architecture & Execution Modes
`sui` supports two execution paths, ensuring 100% transparency on how commands reach the host elevation system.

```text
   ╔═════════════════════════╗          ╔════════════════════════════════════╗
   ║  Operator / AI Agent    ║          ║       Host Web Browser             ║
   ╚══════════════╦══════════╝          ╚══════════════════▲═════════════════╝
                  ║                                        ║
                  ▼                                        ║
    ┌───────────────────────────┐                [ xdg-open / open ]
    │      Execution Choice     │                          ║
    └─────┬──────────────┬──────┘                          ║
          │              │                                 ║
   [ MODE: DOCKER ]      [ MODE: LOCAL (UV) ]              ║
          │              │                                 ║
          ▼              ▼                                 ║
   ╔══════════════╗      ╔══════════════╗                  ║
   ║ scripts/     ║      ║ uv tool/     ║ ═════════════════╝
   ║ sui_shim.py  ║      ║ sui bin      ║      [ HITL: http://127.0.0.1:1143 ]
   ╚══════╦═══════╝      ╚══════╦═══════╝
          ║                     ║
  docker  ▼  run --rm           ║
   ╔══════════════╗             ║
   ║ Docker       ║             ║
   ║ Container    ║             ║
   ╚══════╦═══════╝             ║
          ║                     ║
          ╚═════════╦═══════════╝
                    ║
                    ▼
   ╔════════════════════════════════════╗
   ║        OS Native Elevation         ║
   ║      (sudo / gsudo / RunAs)        ║
   ╚════════════════════════════════════╝
```

### 1.3 Lifecycle & Storage Contract
Transparency on where data lives, how it persists, and its security policy.

| Data Type | Path (Host) | Mode: Docker | Mode: Local | Permission |
|-----------|-------------|--------------|-------------|------------|
| **Data Dir** | `~/.sui/` | Volume Mount | Local Dir | `700` |
| **Secrets** | `.../secrets.json` | Persisted | Persisted | `600` |
| **Config** | `.../config.yaml` | Persisted | Persisted | `600` |
| **Logs** | `.../sui.log` | Persisted | Persisted | `600` |
| **Autosave** | `/tmp/sui/` | Host Mount | Local Dir | `700` |

---

## 🛠️ Facet 2: DEV (Development Guide)

### 2.1 Project Structure
```text
sui/
├── .git/hooks/pre-commit  # Mandatory Gate: executes 'make uv-check'
├── scripts/               # Host-side logic and installers
│   ├── sui_shim.py        # Python Shim: Orchestrates Docker and HITL.
│   ├── install.sh         # Universal Installer: curl | bash support.
│   ├── uninstall.sh       # Universal Uninstaller: Total purge.
│   ├── sui_remote.sh      # Remote tunneling script.
│   └── audit_infra.py     # Infrastructure Security Auditor.
├── src/sui/               # Internal Appliance Core
│   ├── api.py             # Execution Engine: Platform backends.
│   ├── cli.py             # Typer Entrypoint: Routings and Documentation.
│   ├── config.py          # Dehardcoding Engine: Dynamic version/paths.
│   ├── config.yaml        # Configuration Source: Default settings.
│   ├── exceptions.py      # Error System: SuiError.
│   ├── hitl.py            # Approval Engine: Dual-channel validation.
│   ├── models.py          # Pydantic validation.
│   └── logger.py          # Sovereign Logger.
├── tests/                 # Quality Assurance
├── Dockerfile             # Multi-stage build.
├── docker-compose.yml     # Local dev orchestration.
├── pyproject.toml         # Manifest.
├── Makefile               # Universal Command Plane.
└── CONTRACT.md            # THIS DOCUMENT.
```

### 2.2 Mandatory Key Commands (Makefile)
| Command | Role | Scope |
|---------|------|-------|
| `make check` | **The Sovereign Guardian**: Runs uv-check + infrastructure audit. | Dev |
| `make uv-install` | Production install on host. | Host/Prod |
| `make docker-install`| Sovereign Appliance installation (Shim + Image). | Prod |

### 2.3 Immutable Edition Rules
#### R1: Alphabetical Order (`api.py`, `cli.py`)
- Every operation MUST be kept in strict ascending alphabetical order.
#### R2: Zero Hardcoding (`config.py`)
- Everything must be resolved via `config.py` using `pyproject.toml` or `config.yaml`.
#### R3: Pydantic Guard (`models.py`)
- Use Pydantic V2 for all payloads. `extra="forbid"` is mandatory.

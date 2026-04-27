# 🔬 KpihX-Labs: Sovereign Personal Cloud Architecture

> **The Ultimate Unification**
> KpihX-Labs is the supreme abstraction layer. It eradicates the friction of multi-OS environments, centralizes execution, and transforms end-user devices into stateless, zero-trust terminals.

---

## 🏛️ The Convergence Pyramid

The architecture separates the physical metal, the operating systems, and the universal execution fluid.

```ascii
                      [ KpihX-Labs ]
                   (The Sovereign Cloud)
                            ▲
                            │
               ┌────────────┴────────────┐
               │       docker-host       │ ◄── Supreme Abstraction Layer
               │ (Serverless MCP, K3s)   │     (Agnostic, Centralized Fluid)
               └────────────┬────────────┘
                            │
      ┌────────────┬────────┴────────┬────────────┐
      │            │                 │            │
  [ ubuntu ]   [ windows ]        [ mac ]    [ homelab ] ◄── Virtual / OS Layer
 (Dev Only)   (Gaming/Dev)     (Dev/Media)    (PVE OS)
      │            │                 │            │
      ├────────────┤                 │            │
      │            │                 │            │
  [  dell  ]   [   hp   ]      [ mac-studio ]     │      ◄── Physical Metal
      └────────────┴─────────────────┴────────────┘
```

### 1. Physical Layer (The Metal)
The raw compute nodes providing CPU, RAM, and Storage.
- `dell`: Mobile compute.
- `mac-studio`: High-performance ARM workstation.
- `hp`: Auxiliary/Legacy compute.

### 2. OS Layer (The Terminals)
The Operating Systems are treated as **dumb, stateless clients**. They host *only* IDEs (Cursor, VSCode), Web Browsers (Edge), and networking shims (Tailscale).
- `ubuntu`: Main Linux development environment.
- `windows`: Specialized workflows and gaming.
- `mac`: Future/Current macOS environment on the Studio.
- `homelab`: The hypervisor/Proxmox OS layer managing VMs.

### 3. Abstraction Layer (`docker-host`)
The heart of KpihX-Labs. It is not tied to a single machine; it is a distributed fluid managed by Kubernetes (K3s). 
All services, APIs, and CLI tools run here.

---

## 🚀 The "Serverless MCP" Strategy

The traditional MCP protocol (stdio) is resource-heavy, token-expensive, and tightly coupled to the local OS. 
**KpihX-Labs solves this by decoupling the intelligence from the execution:**

1.  **The Agent Brain (`.agents/skills`)**: The IA reads a `SKILL.md` to understand the tool.
2.  **The CLI Bridge (RPC 2.0)**: The tool is exposed as a structured CLI outputting JSON.
3.  **The Network Shim**: On the local `ubuntu` or `mac`, running `bw-proxy do ...` or `gh ...` does *not* execute a local binary. It triggers a lightweight tunnel (via Tailscale/SSH) to execute the containerized tool on `docker-host`.

> **Result**: Zero configuration drift. Update the tool on `docker-host` once, and all OS layers instantly use the new version.

---

## 🔐 Zero-Trust Secrets Pipeline (ESO)

**Problem**: Hardcoding secrets in GitLab CI or dotfiles is an anti-pattern that causes desync.
**Solution**: **External Secrets Operator (ESO)** native to K3s.

1.  **Vaultwarden**: The single source of truth for all tokens (GitHub, WhatsApp, Mail).
2.  **ESO**: Runs on `docker-host` and authenticates to Vaultwarden via a dedicated service account.
3.  **Injection**: When a CI pipeline deploys a container, K3s requests the secrets from Vaultwarden via ESO and injects them securely into the Pod's RAM. 
4.  **No Secrets on Disk**: Neither the `ubuntu` endpoint nor GitLab CI ever touches the real secrets.

---

## 🧠 The Distributed Brain (Nextcloud)

The `$HOME/.agents` directory is the cognitive memory of the AI ecosystem.
Instead of fragmenting it across OS installs:
- **Hosting**: `.agents` is stored centrally on the `docker-host` (Nextcloud/NFS).
- **Ubiquity**: Mounted seamlessly on `ubuntu`, `windows`, `mac`, and accessible via mobile app.
- **Sovereign Editing**: Allows KpihX to edit `AGENTS.md` or a Brainstorm file from an iPhone during a commute, with the changes instantly available to the local agents on the `mac-studio`.

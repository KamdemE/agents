# k-openclaw — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-laptop` (laptop)

---

## WSL Setup

OpenClaw is a Linux-native agent runtime. On Windows, it runs **exclusively inside WSL**.

**Prerequisites:**
1. WSL2 with Ubuntu installed
2. OpenClaw installed in WSL: `npm install -g openclaw` (inside WSL)
3. Kernel clone at `~/.agents/` inside WSL

## systemd in WSL

WSL2 supports systemd optionally. If enabled:
```bash
# Inside WSL
systemctl --user enable --now openclaw-gateway.service
```

If systemd is not enabled in WSL, run the gateway manually:
```bash
# Inside WSL
openclaw gateway start
```

## Context Injection

Workspace path is `$HOME/.agents/` — same path as on any other Linux machine. No Windows-specific path adjustment needed.

## Gateway Token

Gateway env file at `$HOME/.config/openclaw/gateway.env` inside WSL — separate from Windows environment.

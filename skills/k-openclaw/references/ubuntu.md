# k-openclaw — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (kpihx-ubuntu workstation)

---

## systemd User Service

OpenClaw gateway runs as a systemd user service. On Ubuntu:

```bash
systemctl --user enable --now openclaw-gateway.service
```

Service file: `$HOME/.config/systemd/user/openclaw-gateway.service`

Logs: `journalctl --user -u openclaw-gateway -f`

## Gateway Environment

Gateway token lives at `$HOME/.config/openclaw/gateway.env`. Ephemeral export at `/tmp/claw.env` (chmod 600).

## Context Injection

OpenClaw reads `$HOME/.agents/AGENTS.md` as workspace — no OS-specific config needed.

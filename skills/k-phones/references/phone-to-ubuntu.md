# Phone → Ubuntu PC (real remote-control path)

Goal: run shell + Cursor Agent (`agent`) + tmux on **kpihx-ubuntu** from the **S25 Termux** app.

## Architecture

```text
[S25 Termux]  --SSH Tailscale-->  [kpihx-ubuntu]
     ubuntu (alias)                tmux attach → session "default" (PC)
                                   agent -p "…"
```

Not the reverse (`ssh s25` = PC → phone). ADB on the phone does **not** control the PC.

## Where tmux runs (two layers)

| Command | tmux server | Data stays on |
|---------|-------------|---------------|
| **`ubuntu`** | **kpihx-ubuntu** (forced by `ssh -t tmux …`) | PC disk (`$HOME/.tmux/resurrect` as user `kpihx`) |
| **`tmux`** in Termux | **S25 Termux** only | Phone (`~/.tmux/resurrect` in Termux `$HOME`) |

The `ubuntu` alias does **not** nest phone tmux inside PC tmux unless you start tmux on both sides manually.

## One-time setup (PC)

1. Termux pubkey in `$HOME/.ssh/authorized_keys` (label `termux-s25`) — ed25519 from Termux `~/.ssh/id_ed25519_ubuntu.pub`.
2. PC powered on, Tailscale up, login session or `sshd` running (Ubuntu workstation).

## One-time setup (Termux — mostly done)

`~/.ssh/config` already has:

```sshconfig
Host ubuntu
    HostName kpihx-ubuntu
    User kpihx
```

Uses `~/.ssh/id_ed25519_ubuntu` (same key as in PC `authorized_keys`).

**Deployed on S25:** `~/.kphones-remote.zsh` (alias) + `~/.zshrc` sources it — see `references/termux-tmux.md`.

```bash
alias ubuntu='ssh ubuntu -t tmux attach -t default'
```

Plain SSH (no tmux): `ssh ubuntu`.

## Termux-local tmux

Full runbook: **`references/termux-tmux.md`** (Ctrl-a, continuum, **termux-api** clipboard, deploy script).

## Daily use (minimal commands on phone)

| Action | Command (in Termux) |
|--------|---------------------|
| **PC tmux (default)** | `ubuntu` |
| PC shell only | `ssh ubuntu` |
| Local Termux tmux | `tmux` (autosave/restore like PC) |
| One-shot agent task | `ssh ubuntu -t 'zsh -l -c "agent -p \"your task\" --trust --workspace \$HOME/KpihX-Labs"'` |
| Long agent run | `ubuntu` → PC session **`default`** (e.g. window `agents`) → `agent` |

Use **`zsh -l -c`** for one-liners so `agent` is on `PATH` (`$HOME/.local/bin`).

Keep **Termux `sshd`** running only when you need **PC → phone** (`ssh s25`). For **phone → PC**, only outbound SSH from Termux is required.

## Alternatives

| Channel | When |
|---------|------|
| **cursor.com/agents** (browser on phone) | PC runs `agent worker start`; no Termux |
| **Telegram → script on PC** | Push a task; async (future n8n / bot) |
| **Cursor mobile app** | Paid; not sovereign |
| **WebTop / Kasm** (homelab vision) | Full desktop in browser — later |

## Eduroam

Both on eduroam is fine for **Tailscale SSH** (mesh VPN). No need for same campus L2.

## Security

| Control | Detail |
|---------|--------|
| **Transport** | SSH inside **Tailscale** mesh (WireGuard); not campus L2, not public WAN by default. |
| **Exposure** | Ubuntu `sshd` must **not** listen on `0.0.0.0:22` on the public internet — Tailscale IP / LAN only. |
| **Auth** | **Key-only** from phone (`~/.ssh/id_ed25519_ubuntu` → PC `authorized_keys`, comment `termux-s25`). |
| **Account** | Remote session = normal user **`kpihx`** on PC — same privileges as local login (files, `agent`, homelab keys). |
| **Revoke phone** | Remove the `termux-s25` line from `$HOME/.ssh/authorized_keys`. |
| **Tailscale ACL** | Restrict to your devices in admin console. |
| **tmux on PC** | Joins existing session **`default`** — same trust as local tmux; no extra port; resurrect under `$HOME/.tmux/resurrect`. |
| **Resurrect files** | Pane text saved under `$HOME/.tmux/resurrect` on whichever host ran tmux (PC vs phone) — treat as sensitive as shell history. |

**Not in scope:** Termux `sshd` (PC → phone) is optional and separate — see `references/s25-termux-sshd.md`.

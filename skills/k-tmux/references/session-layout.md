# Standard Session Layout Per Equipment

**Every  equipment gets a tmux session named after itself** with this standard layout.
The agent auto-detects the equipment via Tailscale and creates the session on request.

| Equipment | Session name | k-<infra> skill |
|-----------|-------------|-----------------|
| Workstation (Ubuntu) | `ubuntu` | `k-ubuntu` |
| Proxmox hypervisor | `pve` | `k-pve` |
| Debian VM (Docker) | `pve-debian` | `k-pve-debian` |
| Docker CT | `dockerhost` | `k-pve-dockerhost` |
| S25 phone | `s25` | `k-phones` |

(No `kpihx-` prefix — short equipment names only.)

**Each session has exactly 3 windows (except phones — see below):**

| Window | Role |
|--------|------|
| `agents` | Agent workspace — opencode/nvim + ops |
| `default` | General shell, ad-hoc commands. CWD: `~/Labs` |
| `tmp` | Scratch / temporary work |

> **Phone exception (S25, tablet, etc.):** Phones only get 2 windows — `default` and `tmp`. The `agents` window (opencode/nvim) does not apply to Termux/Android since those tools do not run on the phone.

## `agents` window layout (3 panes, nothing pre-opened)

```
┌────────────────────┬────────────────────┐
│                    │                    │
│  Pane 0 (left)     │  Pane 1 (right-top)│
│  Agents pane       │  Editors pane      │
│  (opencode)        │  (nvim, etc.)      │
│  ~/Labs      │  ~/Labs      │
│                    │                    │
│                    ├────────────────────┤
│                    │                    │
│                    │  Pane 2 (right-btm)│
│                    │  Ops pane          │
│                    │  (shell)           │
│                    │  ~/Labs      │
└────────────────────┴────────────────────┘
```

| Pane | Role | Path | Usage |
|------|------|------|-------|
| `SESSION:agents.0` (left) | **Agents pane** | `~/Labs` | opencode / AI CLI runtimes |
| `SESSION:agents.1` (right-top) | **Editors pane** | `~/Labs` | nvim / editors |
| `SESSION:agents.2` (right-bottom) | **Ops pane** | `~/Labs` | **Designated sudo/ops shell** |

**Setup command (manual):**

For full equipment (Ubuntu, PVE, etc.) — 3 windows:
```bash
tmux new-session -d -s <equip> -c ~/Labs
tmux rename-window -t <equip>:0 agents
tmux split-window -h -t <equip>:agents.0 -c ~/Labs
tmux split-window -v -t <equip>:agents.1 -c ~/Labs
tmux new-window -t <equip> -n default -c ~/Labs
tmux new-window -t <equip> -n tmp -c /tmp
```

For phones (S25, no agents window) — 2 windows:
```bash
tmux new-session -d -s <equip> -c ~/Labs
tmux rename-window -t <equip>:0 default
tmux new-window -t <equip> -n tmp -c /tmp
```

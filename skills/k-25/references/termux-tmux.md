# Termux tmux (S25 local sessions)

Local tmux on the phone — separate from the **PC** session reached by the `ubuntu` alias.

## Where it runs

| Layer | Host | Trigger | Target on PC |
|-------|------|---------|----------------|
| **PC remote** | `kpihx-ubuntu` | Termux: `ubuntu` | **`tmux attach -t default`** (no new session) |
| **Termux local** | S25 Termux app | Termux: `tmux` | local sessions only |

`ubuntu` runs `ssh … -t tmux attach -t default` on the workstation — not Termux’s tmux server, and **not** a throwaway `ubuntu` session on PC.

## PC session `default` (reference)

On **kpihx-ubuntu**, inspect:

```bash
tmux list-sessions
tmux list-windows -t default
```

Typical layout (KπX): windows such as `default`, `agents`, `remote`, `browser` inside session **`default`**. Phone control = attach there; create tabs with **Ctrl-a c** inside that session.

## Config (aligned with Ubuntu)

Canonical: `assets/termux-tmux.conf` → deploy to `~/.tmux.conf`.

| Setting | Value |
|---------|--------|
| Prefix | **Ctrl-a** |
| Plugins | tpm, tmux-resurrect, tmux-continuum |
| Autosave | **5 min** (`@continuum-save-interval`) |
| Restore | first `tmux` after Termux restart (`@continuum-boot off`) |
| Manual | **Ctrl-a Ctrl-s** save · **Ctrl-a Ctrl-r** restore |

## Clipboard (required package)

Copy bindings pipe to **`termux-clipboard-set`** (from **`termux-api`**).

```bash
pkg install termux-api   # included in termux-deploy-tmux.sh
```

Grant **Termux:API** permission in Android settings if clipboard stays empty.

## Deploy / redeploy

From **Ubuntu** (PC → phone SSH must work):

```bash
$HOME/.agents/skills/k-25/scripts/termux-deploy-tmux.sh
```

Installs: `tmux`, `termux-api`, TPM plugins, `~/.tmux.conf`, `~/.k25-remote.zsh`, idempotent `~/.zshrc` hook.

## First use

1. Open Termux → `tmux` once (starts local continuum).
2. `ubuntu` → lands in PC session **`default`**.
3. Optional: `termux-clipboard-get` smoke-test outside tmux.

## Security (local layer)

- Local resurrect files live under Termux `$HOME/.tmux/resurrect` (app sandbox).
- PC session security: `references/phone-to-ubuntu.md` → **Security**.

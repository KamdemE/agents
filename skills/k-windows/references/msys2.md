# k-windows — MSYS2 + zsh + tmux (legacy, optional)

> **Status: superseded by WSL for KπX agent work.** This mechanism predates WSL2 being set up on KπX Windows machines. It is documented here as a possibility (a machine can still run MSYS2 alongside WSL), not a requirement — new setups should default to WSL only. Downsides that motivated the move: MSYS2's `fork()` emulation makes MSYS2-native tools noticeably slower than their Windows-native equivalents, especially over network drives (Windows-native `git.exe`/`curl.exe` reach an SMB share at ~2400 MB/s; MSYS2's emulated equivalents are much slower) — this gap is *why* the PATH-merge trick below exists at all — and it's a second, fully separate shell environment to keep in sync with the WSL one.
>
> All real config files referenced below, verbatim as actually deployed → **`assets/msys2/`**.

## Architecture

```
Windows C:\Users\<user>\ (USERPROFILE / $HOME)
  .zshrc → source /home/<user>/.zshrc
        │ mount
MSYS2 /home/<user>/
  .zshrc  ← main config (HOME override + oh-my-zsh)
  .msysrc ← MSYS2-only (hash -d m, gitm/makem/...)
  .tmux.conf ← tmux server config
        │ source
MSYS2 /etc/
  nsswitch.conf → db_home: windows
  profile.d/windows-user-path.sh ← HKLM+HKCU PATH merge
```

## Processing order for every new MSYS2 shell

1. `/etc/nsswitch.conf` → resolves `HOME` to the Windows profile (`C:\Users\<user>`) instead of the POSIX default.
2. `/etc/profile.d/windows-user-path.sh` → prepends Windows System PATH + User PATH to `$PATH`.
3. `~/.zshrc` → forces `HOME` again (tmux inherits the *parent* process's HOME, so this re-applies the override even inside tmux), then loads oh-my-zsh.
4. `~/.msysrc` (sourced from `.zshrc`) → named dir `~m`, MSYS2-native aliases.

## `nsswitch.conf` → `/etc/nsswitch.conf`

```
# Begin /etc/nsswitch.conf
passwd: files db
group: files db
db_enum: cache builtin
db_home: windows
db_shell: cygwin desc
db_gecos: cygwin desc
# End /etc/nsswitch.conf
```

`db_home: windows` (vs. the old default `cygwin desc`) makes `~`/`$HOME` resolve to the Windows user profile instead of a separate POSIX home — without it, MSYS2 lives in its own home, breaking paths shared with Windows tools (Git, pip, winget, Ollama), Python venvs resolve differently, and `~/.ssh` isn't the real Windows SSH config. Requires a **new login shell** to take effect — tmux windows preserve the parent process's `HOME` unless explicitly overridden, which is exactly why the zsh-level override below is also needed.

## `windows-user-path.sh` → `/etc/profile.d/windows-user-path.sh`

Full script → `assets/msys2/windows-user-path.sh`. Reads two registry keys via `reg.exe query`:
- `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment` (System PATH — high priority: git, curl, etc.)
- `HKCU\Environment` (User PATH — medium priority: winget, pip, etc.)

Converts each `;`-separated Windows path segment (`C:\path\to`) to MSYS2 form (`/c/path/to`), keeps only segments that actually exist as a directory, and prepends them to `$PATH` — final precedence: **System PATH → User PATH → original MSYS2 PATH**. This is why `winget`, `pwsh.exe`, `python.exe`, `make.exe` (itself installed via `winget`) become available from MSYS2 without any manual aliasing.

**Convention this enables:** `commande` = the Windows-native binary (now first on `$PATH`); `commandem` = the MSYS2-native fallback, explicitly aliased in `.msysrc` (`gitm`, `makem`, `grepm`, `sedm`, `awkm`, `curlm` → `/usr/bin/<cmd>.exe`).

## `~/.zshrc` → `assets/msys2/zshrc`

Key facts (full file in the asset):
- `export HOME="$(cygpath -u "$USERPROFILE")"` — forced at the very top, before oh-my-zsh loads. This is the fix for tmux inheriting the wrong `HOME` from its parent process.
- Oh-My-Zsh block with a fallback path if `$ZSH` (`$HOME/.oh-my-zsh`) isn't found there (because `HOME` was just overridden to the Windows profile, but oh-my-zsh's actual files live at `/home/<user>/.oh-my-zsh`):
  ```zsh
  export ZSH="$HOME/.oh-my-zsh"
  [ ! -d "$ZSH" ] && ZSH="/home/<user>/.oh-my-zsh"
  ```
  `DISABLE_AUTO_UPDATE="true"` / `DISABLE_UPDATE_PROMPT="true"` — avoids a startup hang from an update check.
- Loads `~/.kshrc` at the end (the KπX shared shell layer) and `/home/<user>/.msysrc` last, by absolute path (deliberately not `$HOME`-relative, since `$HOME` has been overridden).
- `alias ssh="/c/Windows/System32/OpenSSH/ssh.exe"` — uses the Windows OpenSSH client (consistent SSH agent/config behavior with the rest of Windows), not MSYS2's own.

## Windows-home stub → `assets/msys2/zshrc_windows_home`

`C:\Users\<user>\.zshrc`, one line:
```zsh
source /home/<user>/.zshrc
```
Once `HOME` becomes the Windows profile, zsh looks for `.zshrc` there — this stub redirects back to the real config in `/home/<user>/`.

## `~/.msysrc` → `assets/msys2/msysrc`

Full content in the asset. Defines `~m` (named dir, `hash -d m=/home/<user>`) and `$HOMEM` as ways to reach the MSYS2-native home explicitly, plus the `*m`-suffixed fallback aliases (`gitm`, `makem`, `grepm`, `sedm`, `awkm`, `curlm`) for when the Windows-native binary needs bypassing.

## `~/.tmux.conf` → `assets/msys2/tmux.conf`

Full content in the asset. The one setting that matters most for correctness: `set -g default-shell "/usr/bin/zsh"` — **must** be zsh, not bash, because bash doesn't source `.zshrc` and would never pick up the `HOME` override, silently breaking every window opened after the first.

> **Unresolved dependency (flagged, not fabricated):** `tmux.conf`'s status-bar/save/restore bindings shell out to `/home/<user>/.tmux/scripts/tmux-save.sh` (three call sites: `auto-status`, `save`, `restore`). That script's content was not found in either migration source and is not captured anywhere in this kernel — copied here verbatim as a real external dependency of the config, not invented. If tmux save/restore ever misbehaves on Windows, this missing script is why.

## SSH tunnel + remote-tmux pattern (generic mechanism)

Two independent, composable patterns for reaching a remote Linux box with GPU compute from Windows via MSYS2 — shown here as a **mechanism**, with the concrete deep-pc6 example values (host, IP, tunnel port) living in `k-dxo` since that specific target is DxO-internship-internal:

1. **Local port-forward to a remote service** (e.g. a remote Ollama server): `ssh -L <local_port>:127.0.0.1:<remote_port> <ssh_alias> -N -v`, then set `OLLAMA_HOST=http://127.0.0.1:<local_port>` (or whichever env var the local CLI needs) before invoking it. `assets/msys2/ollama6.cmd` is the concrete `.cmd` wrapper implementing this pattern — it hardcodes only a *local* port, no remote host/IP, so it stays generic.
2. **Direct remote tmux over SSH** (no local tunnel needed): `ssh -o BatchMode=yes -tt <ssh_alias> "tmux $*"` — `-tt` forces TTY allocation (required for `tmux attach` to work over SSH); `BatchMode=yes` disables the password fallback (fails hard instead of hanging on a prompt); all CLI args forward verbatim to the remote `tmux` binary. `assets/msys2/tmux6.cmd` implements this — it only ever references the SSH alias name, never a raw IP.

Both `.cmd` files rely entirely on the target alias (e.g. `deep-pc6`) being resolved by `~/.ssh/config` — the actual `Host` block (real IP, real domain-qualified username) is DxO-internship-internal and lives in `k-dxo`, not here.

## Local tmux sessions on Windows (fixed, generic example)

The original migration source had **three mutually-contradictory** session/window maps for this machine's local tmux layout (different window counts, a session named `dxo` that the PowerShell profile defaulted to but that no script actually created, a script's own comment calling a locally-running session "remote"). Rather than propagate that confusion into a generic skill, `assets/msys2/tmux-sessions.ps1` here is a corrected, minimal, machine-agnostic version: one session, literally named `windows`, with exactly the same 3-window equipment layout `k-tmux` uses on the WSL side (`agents` — split 3 ways, `default`, `tmp`) — see `k-tmux/assets/tmux-init.sh` for the Linux/bash original this mirrors.

```powershell
powershell -File tmux-sessions.ps1          # create the "windows" session + any missing windows
powershell -File tmux-sessions.ps1 -Attach  # create + attach
```

Idempotent — never recreates an existing session/window; safe to re-run any time the tmux server was restarted or a window got closed.

## Quick Reference

**Shortcuts:**

| Action | Key |
|--------|-----|
| Tmux prefix | `Ctrl+A` |
| New pane (h) | `Ctrl+A \|` |
| New pane (v) | `Ctrl+A -` |
| Fuzzy history | `Ctrl+R` |

**Paths:**

| Symbol | Resolves to | How |
|--------|-------------|-----|
| `~` | `/c/Users/<user>` | `nsswitch.conf` + `HOME` override |
| `~m` | `/home/<user>` | `hash -d m=` in `.msysrc` |
| `$HOMEM` | `/home/<user>` | `export` in `.msysrc` |

**Aliases:**

| Command | Which binary |
|---------|--------------|
| `git` | Windows Git (via PATH merge) |
| `gitm` | MSYS2 `/usr/bin/git.exe` |
| `make` | Windows Make (installed via `winget`, via PATH merge) |
| `makem` | MSYS2 `/usr/bin/make.exe` |
| `curl` | Windows `curl.exe` |
| `curlm` | MSYS2 `/usr/bin/curl.exe` |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-25 | [CLAUDE] | v1.0.0 — Created. Migrated the generic MSYS2 mechanism from the unversioned Windows-side `k-win-msys2` skill: HOME-resolution saga, PATH-merge script, `commande`/`commandem` convention, SSH-tunnel/remote-tmux patterns (genericized — concrete deep-pc6 values moved to `k-dxo`). Replaced the original 3-mutually-contradictory tmux session maps with one corrected, DxO-agnostic example (`tmux-sessions.ps1`: session `windows`, windows `agents`/`default`/`tmp`, mirroring `k-tmux`'s standard layout exactly) rather than preserving the contradiction. |

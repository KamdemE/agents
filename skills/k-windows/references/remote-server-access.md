# k-windows — Remote dev/GPU server access stack (generic template family)

> Generalized from a real, working setup reaching a company-internal GPU server (`k-dxo` → `deep-pc6`) from two client machines (Ubuntu workstation + `k-blglaptop139`, Windows/WSL). **Zero company-specific values below** — no hostname, no IP, no domain, no VPN portal, no account name. The concrete DxO instance stays in `k-dxo`/`k-deep-pc6` (both disposable, purged at internship end); this doc + its templates are what survives that purge.
>
> **Why this exists as one doc, not scattered pieces:** the original setup is 6 small, individually-simple pieces (VPN → tunnel → tmux launcher → CLI proxy → OpenCode sync → drive mount) that only make sense together, as a stack. Documenting them separately would lose that shape. Read this top-to-bottom once; each piece links to its template.

## The stack, end to end

```
[VPN client]  →  reachability to the company-internal network
      │
      ├──► [tmux-server.sh / tmux-server.cmd]  — SSH straight into a remote tmux session (no local tunnel needed)
      │
      └──► [tunnel-server.service]  — SSH local port-forward, keeps a local port mapped to a remote service
                  │
                  ├──► [ollama-server.sh / ollama-server.cmd]  — CLI proxy: point any local CLI's *_HOST env var at the tunnel
                  │           │
                  │           └──► [opencode-ollama-server.sh]  — sync the proxied models into a config file automatically
                  │
                  └──► [rclone-serve.service (Linux) / mount-server.bat (Windows)]  — mount the remote filesystem locally
```

Every piece follows the same **core-only, no-merged-responsibility** philosophy: a launcher/proxy script never starts the VPN or the tunnel itself — on failure it prints exactly what to run, and exits. This keeps each piece independently testable and avoids one script silently masking another's failure.

## 1. VPN (system-wide reachability)

Template: **`assets/remote-server/vpn-intranet.service`** — generic systemd **system** service, `ExecStart`/`ExecStop` and `Environment=` left as placeholders for the actual VPN client (GlobalProtect/`gpclient`, Cisco AnyConnect/`openconnect`, plain OpenVPN/WireGuard, …). Managed on-demand by default (not enabled at boot — zero RAM until started).

**Windows equivalent:** native VPN client, no systemd — see `references/remote-desktop.md` → "The generic corporate remote-access pattern" for the Windows-side flow (install vendor client, connect to portal, MFA).

```bash
sudo systemctl start vpn-intranet
systemctl status vpn-intranet
journalctl -u vpn-intranet -f
```

## 2. Direct remote tmux over SSH (no tunnel needed)

Template: **`scripts/remote-server/tmux-server.sh`** (bash/WSL/Linux) + **`assets/msys2/tmux-server.cmd`** (Windows/MSYS2 legacy path). Both attach to a `tmux` session running **on the remote server itself** over a plain SSH connection — no local port-forward involved, this is the simplest piece of the stack.

- `SSH_ALIAS` (env var, or edit the script) — must resolve via `~/.ssh/config` (bash) / `%USERPROFILE%\.ssh\config` (Windows). Never a raw IP inline.
- `VPN_UNIT` (bash only, optional) — if set, pre-checks `systemctl is-active` before attempting SSH and gives clear guidance if the VPN is down; leave empty for a target that needs no VPN gate.
- `-tt` forces TTY allocation (required for `tmux attach` over SSH). `BatchMode=yes` (Windows `.cmd`) disables the password fallback — fails hard instead of hanging on a prompt.

```bash
TMUX_SERVER_SSH_ALIAS=myserver TMUX_SERVER_VPN_UNIT=vpn-intranet.service tmux-server.sh attach
```

## 3. SSH tunnel (local port-forward to a remote service)

Template: **`assets/remote-server/tunnel-server.service`** — generic systemd **user** service. `-L <local-port>:127.0.0.1:<remote-port> <ssh-alias>` — the remote service only needs to be listening on `127.0.0.1` on the far side; nothing needs to change there. `-v` (verbose) makes `journalctl --user -u tunnel-server.service -f` show live connection/forwarding logs. `ExitOnForwardFailure=yes` fails fast instead of silently staying up with no actual forward. Managed on-demand (not enabled at boot); `Restart=on-failure` recovers from a VPN blip without a manual restart.

```bash
systemctl --user start tunnel-server.service
systemctl --user status tunnel-server.service
journalctl --user -u tunnel-server.service -f
```

## 4. CLI proxy through the tunnel (example: Ollama)

Template: **`scripts/remote-server/ollama-server.sh`** (bash) + **`assets/msys2/ollama-server.cmd`** (Windows). Pure proxy — checks the tunnel endpoint answers (`curl` the local port), then `exec`s the real CLI with its `*_HOST` env var pointed at `127.0.0.1:<local-port>`. On a dead tunnel it prints the exact 2-3 commands to fix it and exits — never starts anything itself.

The pattern generalizes past Ollama trivially: any CLI that reads a `*_HOST`/`*_URL` env var for its backend (not just Ollama) can be proxied the same way — swap the final `exec ollama "$@"` line for the target CLI.

```bash
OLLAMA_SERVER_LOCAL_PORT=11435 OLLAMA_SERVER_TUNNEL_UNIT=tunnel-server.service ollama-server.sh list
```

## 5. Auto-sync into a local config (example: OpenCode provider block)

Template: **`scripts/remote-server/opencode-ollama-server.sh`** — sourced from `~/.kshrc` (not invoked directly). Wraps `pull`/`rm`/`delete` on the CLI proxy from step 4 and, on any of those, surgically rewrites **only its own named sub-block** inside a JSONC config (finds the block by brace-depth, replaces just that range) — every other provider/section in the file is left untouched. Skips silently (no error) when the tunnel is down, matching the CLI proxy's own "never surprise, never crash the shell" philosophy.

Personalize `OPENCODE_OLLAMA_SERVER_PROVIDER` (the JSONC key name) and `OPENCODE_OLLAMA_SERVER_PORT` (must match step 4's `LOCAL_PORT`) at the top of the file.

## 6. Mounting the remote filesystem locally

- **Windows** → full mechanism already documented in **`references/ssh-mount.md`** (rclone + WinFsp + nssm, `Z:`-style drive letter). Templates: **`assets/remote-server/mount-server.bat`** + **`unmount-server.bat`**.
- **Linux (Ubuntu/WSL)** → template **`assets/remote-server/rclone-serve.service`**, a systemd **user** service doing the equivalent `rclone mount` under `~/<mount-name>` instead of a drive letter (`%h` = the invoking user's home, resolved by systemd itself — no hardcoded path). Same `rclone.conf` remote definition (host/user/key) is shared between the Windows and Linux mounts if both target the same server — only the `ExecStart` shape differs (drive letter vs. local directory).

```bash
systemctl --user start rclone-serve.service
```

## Personalizing this stack for a new company/machine

1. Copy the relevant files from `assets/remote-server/` and `scripts/remote-server/` (plus `assets/msys2/tmux-server.cmd`/`ollama-server.cmd` if targeting Windows/MSYS2) into the new company/machine skill's own `assets/`/`scripts/`.
2. Fill in `~/.ssh/config` with a `Host <alias>` block for the real target (IP, user, key) — this is the **only** place a real hostname/IP/account belongs; every template above resolves everything through the alias, never inline.
3. Fill in the VPN `ExecStart`/`ExecStop` in `vpn-intranet.service` for the actual VPN client, and the real portal URL.
4. Pick local/remote ports for the tunnel, matching the remote service's actual listening address.
5. Register the systemd units in that company/machine skill's own service registration (see `assets/services.jsonc`/`assets/links.jsonc` pattern documented in the root `AGENTS.md` → Config Management Standard) — never re-register a template file itself, only the personalized copy.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-27 | [COLAB] | v1.0.0 — Created. Generalized the full remote dev/GPU server access stack (VPN, SSH tunnel, tmux launcher, CLI proxy, OpenCode auto-sync, filesystem mount) from a real working setup (`k-dxo`/`k-deep-pc6`/`k-blglaptop139` — all three disposable, purged at internship end). Templates: `assets/remote-server/{vpn-intranet.service,tunnel-server.service,rclone-serve.service,mount-server.bat,unmount-server.bat}`, `scripts/remote-server/{tmux-server.sh,ollama-server.sh,opencode-ollama-server.sh}`, `assets/msys2/{tmux-server.cmd,ollama-server.cmd}` (renamed+regenericized from `tmux6.cmd`/`ollama6.cmd`, which hardcoded an alias/port with no override). Zero company-specific values verified via grep before writing. |

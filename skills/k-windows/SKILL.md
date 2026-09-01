---
name: k-windows
description: >
  KπX Windows platform hub — generic knowledge for any Windows machine in the
  fleet that also runs WSL: WSL bootstrap (wsl.conf, .wslconfig), the
  gh-clone-then-symlink setup flow into the sovereign kernel, winget, NTFS
  symlink/hardlink/junction mechanics, and MSYS2 (legacy, optional — WSL
  supersedes it for KπX agent work). NOT machine-specific (→ the relevant
  k-* infra skill, e.g. k-blglaptop139) and NOT DxO-internship-specific
  (→ k-dxo). Load before any Windows-native setup task or WSL bootstrap on a
  new Windows machine.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
  scope: windows-platform
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Windows Platform Hub

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master map, checklist) · `k-zsh` (shell hub — WSL side) · `k-tmux` (agents/default/tmp layout — WSL side) · `k-dxo` (DxO-internship-specific VPN/RDP/accounts/deep-pc6 access — never here, deactivated) · `k-openvino` (local LLM serving, replaces k-ollama)
>
> **Scope discipline:** this skill is for facts true of **any** Windows machine running WSL in the KπX fleet. A fact that's true only of one physical machine belongs in that machine's own infra skill. A fact that's true only because of the DxO internship (VPN, RDP target, deep-pc6 access, accounts) belongs in `k-dxo`, never here — `k-dxo` must stay the single skill that can be deleted at internship end with zero residue elsewhere.

---

## WSL Bootstrap

### `/etc/wsl.conf` (inside the WSL distro)

Copyable template → **`assets/wsl.conf`** (drop at `/etc/wsl.conf` inside the distro, `sudo` required to write it):

```ini
[boot]
systemd=true

[user]
default=kpihx
```

`systemd=true` is required for the systemd-unit patterns used throughout the kernel (tailscaled, vpn-dxo.service, ollama6-tunnel.service, etc. — see `k-infras`).

### `.wslconfig` (Windows side, `%USERPROFILE%\.wslconfig`)

Copyable template → **`assets/wslconfig`** (copy to `%USERPROFILE%\.wslconfig` on the Windows side, then adjust `memory`/`processors` to the machine's actual specs):

```ini
[wsl2]
memory=24GB
processors=20
networkingMode=mirrored
swap=8GB

[experimental]
hostAddressLoopback=true
autoMemoryReclaim=gradual
```

- `networkingMode=mirrored` — shares `localhost` between Windows and WSL (e.g. a native Windows Ollama on `:11434` is transparently reachable from WSL without extra port-forwarding).
- Leave enough RAM/CPU headroom for Windows-side tools (Ollama GUI, VS Code/Cursor) — the split above reserves ~7-8 GB to Windows on a 32 GB machine.

### Setup flow (new Windows+WSL machine)

Standard KπX bootstrap — see `k-infras` → New Infra Setup Checklist for the full ordered checklist (tmux → zsh → tailscale → ssh → clis → nvim → opencode). The Windows-specific first steps:

1. Install WSL2 + an Ubuntu distro (`wsl --install` from an elevated PowerShell, or via the Microsoft Store).
2. Inside the WSL distro: `gh auth login` (or plain `git clone git@github.com:kpihx-labs/agents.git`) into `~/KpihX-Labs/.agents` — the **real** clone, per `k-infras` Step 0.
3. `ln -sfn ~/KpihX-Labs/.agents ~/.agents` — symlink, never a second clone.
4. From here on, follow `k-infras`, `k-clis`, `kpihx-labs` exactly like any other infra — nothing Windows-specific left in the flow itself.

---

## winget (Windows Package Manager)

Native Windows package manager, invoked from PowerShell/cmd:

```powershell
winget install --id <Publisher.Package> -e
winget uninstall <Publisher.Package>
```

Used on Windows+WSL machines in this fleet to install: `make.exe` (for MSYS2's PATH-merged `make` alias — see `references/msys2.md`), `WinFsp.WinFsp`, `SSHFS-Win.SSHFS-Win`, `Rclone.Rclone` (see the relevant infra skill for the exact rclone-mount use case). `-e` (`--exact`) avoids fuzzy-match surprises when the package ID is already known.

---

## Child Windows-type infra skills

Machine-specific infra skills that personalize content from this template — check here first when creating a new one, and when auditing whether a child skill has drifted into carrying content that's actually generic (which should move back here):

| Infra skill | Machine |
|---|---|
| `k-blglaptop139` | Windows + WSL laptop, DxO internship (Grenoble) |

> **Why this matters more than it looks:** a company-issued laptop's infra skill (like `k-blglaptop139`) gets abandoned along with the company-specific skill (`k-dxo`) when that chapter ends — **the physical machine itself doesn't come along.** Anything genuinely reusable that's still only sitting in the abandoned machine's skill at that point is knowledge lost for the *next* machine at the *next* place. This is why the discipline of pushing generic content up into `k-windows` (rather than letting it accumulate in the machine-specific skill "because it's easier right now") isn't just tidiness — it's the difference between rebuilding a new Windows+WSL setup from scratch next time vs. reusing this kernel's accumulated knowledge.

## Pattern for a new Windows+WSL machine

`k-windows` is a **seed/template**, exactly like `k-zsh/assets/kshrc.base` is for shell config — never used directly as a live config on a specific machine. When a new Windows+WSL machine joins the fleet:

1. Create that machine's own infra skill (e.g. a future `k-<newmachine>`, following `k-blglaptop139`'s shape).
2. If that machine needs a generic asset/script documented here (MSYS2 files in `assets/msys2/` + executable scripts in `scripts/msys2/`, the PowerShell profile `scripts/Microsoft.PowerShell_profile.ps1`, the remote-server-access family in `assets/remote-server/` + `scripts/remote-server/`), **copy** it into the new infra skill's own `assets/`/`scripts/` and personalize the copy there (machine-specific paths, tmux session name if it should differ from the generic `windows` example, etc.) — the same copy-then-customize relationship `kshrc.base` has with each infra's own `assets/kshrc`. **`assets/` vs `scripts/` split (fixed 2026-08-27):** executable code (`.sh`, `.ps1`) lives in `scripts/`; passive config/data (`.conf`, `.service`, `.cmd`/`.bat` launchers) stays in `assets/` — mirrors the root kernel's own `scripts/` vs `assets/` split (see root `AGENTS.md` → Kernel Structure Map).
3. **Exception: `assets/kshrc` is sourced, never copied.** Add one `source` line near the top of the new machine's own `assets/kshrc` (see "`assets/kshrc` — the Windows+WSL shell base" above) — do not copy its content in.
4. Everything genuinely generic (the NTFS mechanics, the WSL bootstrap flow, the MSYS2 *mechanism* itself) stays referenced from here, never duplicated into the new machine's skill — only the instance-specific, personalized copies move out.

**🔴 Direction of fixes matters — always push generalizable improvements UP before personalizing DOWN.** If, while working on a *child* skill's personalized copy of an asset, you find a fix or improvement that's actually generic (not specific to that one machine), apply it to **this skill's template first**, then re-copy/re-personalize into the child — never leave the parent template stale while only the child copy gets the fix. Concretely: before editing a child skill's copy of e.g. `Microsoft.PowerShell_profile.ps1`, ask "is this change true for any Windows machine, or only this one?" — if the former, edit `k-windows/scripts/Microsoft.PowerShell_profile.ps1` first.

## NTFS Links (symlink / hardlink / junction)

Full mechanics, the Developer Mode incident, probe/conversion snippets → **`references/ntfs-links.md`**.

## PowerShell profile (generic template)

`scripts/Microsoft.PowerShell_profile.ps1` — PSReadLine history/prediction tuning, the PowerToys `CommandNotFound` module import, `h`/`hist` full-history-dump aliases, and landing every new shell in `~/KpihX-Labs`. Copy into the owning machine's infra skill and personalize (see "Pattern for a new Windows+WSL machine" below) — a filled-in example lives at `k-blglaptop139/assets/Microsoft.PowerShell_profile.ps1` (that child skill's own copy stays in its `assets/`, unaffected by this skill's `scripts/` split — see "Child Windows-type infra skills" note above about not modifying `k-blglaptop139` without a dedicated pass there).

## Windows service / software management techniques

- **Force-disabling a stubborn service** (4-tier escalation: `Set-Service` → retry → `sc.exe` → direct registry + clear recovery actions) + the SCM `Start` value reference + the `.exe.DEAD` rename fallback → **`references/windows-services.md`**.
- **Silently uninstalling software from a script** (by known MSI GUID, or by registry `DisplayName` pattern across all three Uninstall registry roots) → **`references/software-removal.md`**.
- **Remote access services** — native RDP and Chrome Remote Desktop (`chromoting`) enable/disable, the generic corporate-VPN+RDP access pattern, and the Ubuntu-side Remmina client fields → **`references/remote-desktop.md`**.
- **Dual-GPU laptops** — diagnosing display-wiring-caused dGPU idle load, and the Windows/app-level mitigations → **`references/dual-gpu.md`**.

All four generalized from a specific machine's de-bloat pass (`k-blglaptop139`) — exact service/app names, GUIDs, and hardware numbers stay there; the techniques here are company/machine-agnostic.

## KpihX-Datas legacy applications inventory

The **current** post-refactor snapshot is under **`references/applications/README.md`**. The pre-cleanup full inventory is preserved at **`references/applications.full/README.md`**. Both preserve exact application, archive, and installer names without treating historical files as recommended software or live configuration.

## SSH Server (OpenSSH) — Windows side + Ubuntu client pairing

Full mechanism, verified live on a real machine (`k-blglaptop139`): `Get-Service` vs `Get-WindowsCapability` install-state mismatch on corporate images, firewall rule display-name false-negatives, `administrators_authorized_keys` vs per-user `authorized_keys`, `DefaultShell` registry key + the `pwsh` (blocked by AppLocker) vs `powershell.exe` (works) asymmetry, and the `AutoRun` non-interactive-exec footgun (considered, rejected) → **`references/ssh-server-setup.md`**. Ubuntu-side key naming/config still follows `k-ssh` — not duplicated here.

## Mounting a remote SSH/SFTP host as a Windows drive

Generic rclone+WinFsp+nssm pattern (why rclone over SSHFS-Win, SSH/rclone config shape, nssm-service-not-scheduled-task autostart, troubleshooting) → **`references/ssh-mount.md`**. Fill-in-the-blanks templates → **`assets/remote-server/`** (moved from `assets/ssh-mount/` 2026-08-27 — now part of the wider remote-server-access family, see below). A concrete DxO-specific instance (mounting `deep-pc6` as `Z:`) lives in `k-dxo` — that's where the real IP/account/target belongs, not here.

## Remote dev/GPU server access stack (generic template family)

The full stack for reaching a remote dev/GPU server from a Windows/WSL (or Ubuntu) client machine — VPN → SSH tunnel → tmux launcher → CLI proxy → OpenCode auto-sync → filesystem mount — generalized from a real, working setup (`k-dxo`/`k-deep-pc6`, both disposable/purged at internship end) with **zero company-specific values**. Full mechanism, the "why one doc not scattered pieces" rationale, and the stack diagram → **`references/remote-server-access.md`**.

| Piece | Config/data template (`assets/`) | Executable script (`scripts/`) |
|---|---|---|
| VPN | `assets/remote-server/vpn-intranet.service` | — |
| SSH tunnel | `assets/remote-server/tunnel-server.service` | — |
| Remote tmux launcher | `assets/msys2/tmux-server.cmd` (Windows) | `scripts/remote-server/tmux-server.sh` (bash/WSL) |
| CLI proxy (Ollama example) | `assets/msys2/ollama-server.cmd` (Windows) | `scripts/remote-server/ollama-server.sh` (bash/WSL) |
| OpenCode auto-sync | — | `scripts/remote-server/opencode-ollama-server.sh` |
| Filesystem mount | `assets/remote-server/{mount,unmount}-server.bat` (Windows) · `assets/remote-server/rclone-serve.service` (Linux) | — |

---

## MSYS2 (legacy — optional, WSL supersedes it)

MSYS2 + zsh + tmux was the pre-WSL way to get a POSIX shell and SSH/tmux access to remote Linux boxes from Windows. **Now that WSL2 (this kernel) is set up, MSYS2 is no longer the recommended path** — its downsides are real: `fork()` emulation makes MSYS2-native tools slow, especially over network drives (Windows-native Git/curl/make reach the SMB share at ~2400 MB/s vs. MSYS2's much slower emulated equivalents — this is *why* the PATH-merge trick documented below exists at all), and it's a second, entirely separate shell environment to keep in sync with the WSL one.

It is documented here **as a possibility**, not a requirement — a machine can run MSYS2 alongside WSL if there's a specific reason to, but new KπX Windows+WSL setups should default to WSL only.

Full mechanism (HOME resolution saga, PATH merge from the Windows registry, the `commande`/`commandem` convention) → **`references/msys2.md`**. Every real config file (verbatim, as actually deployed) → **`assets/msys2/`**.

> **Windows-side duplication is intentional, not an oversight:** the live MSYS2 config files stay on the Windows machine's own filesystem (MSYS2 has no meaningful way to symlink back to a WSL-side canonical copy across the Windows/WSL boundary, and Windows-side symlinking itself needs Developer Mode — see `references/ntfs-links.md`). `assets/msys2/` here is the **documented, versioned copy** for reference/recovery, not a live symlink target.

---

## `assets/kshrc` — the Windows+WSL shell base (SOURCED, not copied)

Unlike this skill's other assets (PowerShell profile, MSYS2 files, SSH-mount
templates — all **copy-then-personalize**), `assets/kshrc` is **live-sourced**
by every Windows+WSL machine's own per-infra `assets/kshrc`, near the very
top, before that file's own Section 1 body:

```sh
[ -f "$HOME/.agents/skills/k-windows/assets/kshrc" ] && \
  . "$HOME/.agents/skills/k-windows/assets/kshrc"
```

**Why sourced and not copied, unlike everything else here:** a per-machine
infra skill (e.g. `k-blglaptop139`) is scoped to one physical, company-issued
laptop and **will be purged** when that chapter ends. Content that only
exists as a copy inside that skill is lost the day it is purged. Sourcing
this file instead means a fix made here reaches every Windows+WSL machine
immediately, with no re-copy step anywhere, and nothing is lost when a
machine-specific skill is eventually deleted. This is the one asset in this
skill that behaves differently from the "seed/template" pattern described
below — everything else here is still copy-then-personalize.

It carries two mini-sections with their own idempotency guards
(`__KSHRC_WINDOWS_LOADED` / `__KSHRC_WINDOWS_INTERACTIVE_LOADED`,
independent from the parent file's own `__KSHRC_LOADED` /
`__KSHRC_INTERACTIVE_LOADED`), mirroring the universal/interactive split of
`k-zsh/assets/kshrc.base` itself.

### SSH agent — headless WSL has no `gcr-ssh-agent`

WSL2 (no desktop session) doesn't run GNOME Keyring, so there's no
`gcr-ssh-agent` socket the way there is on a full Ubuntu/GNOME workstation.
`ssh-add`/git-over-SSH need an agent regardless. Fix — a plain, persistent
`ssh-agent` reused across shells/panes via an env file, in the universal
mini-section of `assets/kshrc`:

```sh
_ssh_agent_env="$HOME/.ssh/agent.env"
[ -f "$_ssh_agent_env" ] && . "$_ssh_agent_env" >/dev/null 2>&1
ssh-add -l >/dev/null 2>&1
if [ $? -eq 2 ]; then
  # exit 2 = no agent reachable (stale/missing socket); 0/1 = agent alive, leave it
  (umask 077; ssh-agent -s > "$_ssh_agent_env")
  . "$_ssh_agent_env" >/dev/null 2>&1
fi
unset _ssh_agent_env
```

No-op on machines with a working agent already (e.g. `gcr-ssh-agent` on a
GNOME workstation — `ssh-add -l` exits 0/1 there, never 2). Keys still load
manually with `ssh-add ~/.ssh/id_ed25519_<target>` (passphrase prompt — needs
a TTY, never auto-loaded). This snippet was previously duplicated by copy
into each Windows+WSL machine's own `assets/kshrc` — now centralized here
and sourced instead (see 2026-08-25 changelog entry). It is still
WSL-headless-specific, not universal across every KπX infra — it belongs in
this skill's base, never in `k-zsh/assets/kshrc.base` (see `k-zsh` →
Changelog 2026-08-24 for the incident where a similar snippet got wrongly
added to the truly universal base and had to be reverted).

### Windows interop — `$HOMEW` / `$USERW` / `~w`

`$HOME`/`$USER` are the WSL (Linux) side on any Windows+WSL machine.
`$HOMEW`/`$USERW` are the Windows-side equivalents, derived — never
hardcoded — via `cmd.exe` interop, so the same line works unchanged on any
Windows+WSL machine regardless of the Windows account name:

```sh
if [ -z "$USERW" ] && command -v cmd.exe >/dev/null 2>&1; then
  USERW="$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')"
fi
[ -n "$USERW" ] && export USERW && export HOMEW="/mnt/c/Users/$USERW"
```

In zsh interactive shells, a named-directory shortcut `~w` also points at
`$HOMEW` (`hash -d w="$HOMEW"`) — the mirror image of the old MSYS2 `~m`
pattern (`references/msys2.md`): there, `~m` was the Linux home despite
`$HOME` being overridden to the Windows home; here, `~w` is the Windows home
despite `$HOME` being the native Linux one (WSL).

---

## GPU / local ML inference on Windows+WSL

**Ollama: reuse the Windows-hosted server from WSL, don't run a second one.** `.wslconfig`'s `networkingMode=mirrored` (see WSL Bootstrap above) already makes a native Windows Ollama server transparently reachable from WSL at `localhost:11434` — no tunnel, no port-forward. All that's missing is the WSL-side **client binary** (not the full server+GPU-libs bundle `install.sh` pulls in, and never with `systemctl enable ollama`, which would race the Windows server for the same port) → **`k-ollama/scripts/install-wsl-client.sh`** (idempotent client-only installer) + **`k-ollama/references/windows.md`** (full mechanism, options, gotchas). Verified working 2026-08-25 on a Windows+WSL machine in this fleet — this is generic to any of them, not tied to one machine's skill.

Actual hardware-tuning content (a specific GPU's CUDA setup, driver-passthrough traps) belongs in the owning machine's infra skill — but that skill is disposable (company hardware), so treat any such content there as a *snapshot*, not the canonical home; if a technique proves reusable, it belongs here instead, same rule as everywhere else in this file. See also `k-qmd/references/wsl.md` for the general "WSL driver passthrough ≠ CUDA runtime" trap (found via `qmd embed` silently running on CPU despite a real GPU being present).

**`ollama-cuda-windows-intel`** — a self-contained, independently git-tracked repo documenting CUDA/hybrid-GPU (Intel iGPU + NVIDIA dGPU) Ollama tuning on Windows laptops (own commit history, own benchmark data). Not migrated into the kernel (it already has its own versioned home) — referenced here for discoverability only:

```
git clone https://github.com/KpihX/ollama-cuda-windows-intel.git
```

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-windows/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-windows/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-29 | [LIVE] | v1.6.0 Applications inventory preserved (`references/applications/`). v1.5.0 Applications category-split snapshot. |
| 2026-08-27 | [COLAB] | v1.4.0 Remote dev/GPU server access stack + `references/remote-server-access.md`. v1.3.0 SSH Server (OpenSSH) section + `references/ssh-server-setup.md`. |
| [SUMMARY] | — | v1.2.0 GPU/Ollama section self-contained · v1.1.0 `assets/kshrc` created (SOURCED, not copied) · v1.0.0 baseline · full detail in `references/log.md` |

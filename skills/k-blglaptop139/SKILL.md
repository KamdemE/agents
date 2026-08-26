---
name: k-blglaptop139
description: >
  BLGLAPTOP139 — Windows + WSL laptop at DxO internship (Grenoble).
  Primary development workstation on Windows with WSL for Linux tooling.
  Known Tailscale identity and RDP access from Ubuntu workstation.
  This skill documents the Windows-specific environment, WSL setup,
  and cross-platform access patterns.
license: private
metadata:
  author: KpihX
  version: "1.8.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# BLGLAPTOP139 — Windows + WSL

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-ubuntu` (SSH client — RDP from this machine) · `k-windows` (generic Windows/WSL/MSYS2 mechanics — anything on this page that's true of *any* Windows+WSL machine lives there instead, not duplicated here) · `k-dxo` (DxO-internship-specific access — VPN/RDP target/deep-pc6 — never here)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Setup (WSL — once)

> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to understand the setup rule: everything lives in `.agents/` (single source of truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own `assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized).

```bash
# 1. Clone .agents repo inside WSL distro (canonical location; ~/.agents is only a symlink)
mkdir -p ~/KpihX-Labs
[ -d ~/KpihX-Labs/.agents ] || git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents
[ -e ~/.agents ] || ln -sfn ~/KpihX-Labs/.agents ~/.agents
# 1b. Branch per infra: cd ~/KpihX-Labs/.agents && git switch <infra>-wsl  (Windows/WSL naming)

# 2. kshrc — symlink ($HOME item), source of truth is k-blglaptop139/assets/kshrc
ln -sf ~/.agents/skills/k-blglaptop139/assets/kshrc ~/.kshrc

# 3. SSH config — Include canonical
echo "Include ~/.agents/skills/k-ssh/assets/ssh.conf" > ~/.ssh/config

# 4. Secrets
cp ~/.agents/.env.example ~/.agents/.env
```

> **Windows Terminal** → zsh by default. Requires `chsh -s $(which zsh)` inside WSL (see `k-zsh`).

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `BLGLAPTOP139` |
| Short name (tmux) | `blglaptop139` |
| Tailscale (Windows, native) | `blglaptop139` (`100.99.196.32`) |
| Tailscale (WSL, separate node) | `blglaptop139-wsl` (`100.118.76.46`) |
| OS | Windows (with WSL) |
| Location | DxO internship, Grenoble |
| Tailscale connection | Direct (`172.16.142.143:41641`) |
| GPU | NVIDIA GeForce RTX 5070 Ti Laptop GPU (12 GB VRAM), CUDA Toolkit installed for WSL — see `references/gpu.md` |

> **Two Tailscale identities, one physical machine.** WSL runs its own `tailscaled` (installed 2026-08-24 during the full infra setup) rather than routing through Windows' native Tailscale — needed so the WSL distro is independently reachable (SSH, tmux) as a Linux node. Naming convention: `<host>-wsl` — see `k-tailscale/references/windows.md` → "Naming convention — dual Windows/WSL identity". The tmux short name (`blglaptop139`) is unaffected — tmux runs inside WSL only, no ambiguity there.

---

## Hardware Specs

Snapshot dated 2026-07-02 (migrated from an unversioned Windows-side `.agents`; see `references/debloat-log.md` for the full de-bloat history taken the same day).

| Component | Value |
|---|---|
| Model | Alienware 16 Area-51 AA16250, motherboard `0X1GY3`, BIOS `1.7.0` (08/12/2025) |
| CPU | Intel Core Ultra 9 275HX — 24 cores/threads, base 2700 MHz, Arrow Lake (15th gen), L2 40 MB, L3 36 MB |
| RAM | 32 GB DDR5 6400 MT/s (2× 16 GB SODIMM, Micron `MTC8C1084S1VC64BD1`) |
| GPU 0 (iGPU) | Intel(R) Graphics (Arrow Lake) — drives the internal 2560×1600 panel |
| GPU 1 (dGPU) | NVIDIA GeForce RTX 5070 Ti Laptop GPU, 12 GB VRAM — drives the external 4K monitor; see `references/gpu.md` for the WSL/CUDA setup |
| Disk | 1.9 TB NVMe (`C:`) |
| Network | Killer WiFi/Ethernet (driver 40.26.107), Realtek USB Ethernet (11.17.20.10) |
| Audio | Realtek Audio (10.0.218.1), Dolby DAX API |
| Antivirus | ESET Endpoint Antivirus (corporate-managed; ~550 MB RAM footprint) |
| OS | Windows 11 Pro, build 26200, 64-bit, VBS + Hyper-V active |

**GPU-idle-at-rest root cause (found 2026-07-02):** the external 4K monitor is wired to the NVIDIA GPU, so `dwm.exe` (desktop compositor) and `Cursor.exe` (Electron GPU acceleration) render on it instead of the Intel iGPU — this alone accounted for the dGPU sitting at 61-89% utilization even at idle, before mitigation. Mitigations available (see `references/debloat-log.md` for this machine's exact numbers, **`k-windows/references/dual-gpu.md`** for the general diagnosis + mitigation technique reusable on any dual-GPU laptop): lower external-monitor resolution/refresh rate, disable Cursor's GPU acceleration, force apps to the Intel GPU via Windows Graphics settings, or use NVIDIA Optimus power-saving mode.

---

## Access from Ubuntu Workstation

### RDP (via Remmina)

| Field | Value |
|-------|-------|
| Server | `BLGLAPTOP139.corp.dxo.com` |
| Username | `ikamdem` (no domain) |
| Password | DxO password |
| Domain | `corp.dxo.com` |

**Profile file:** `~/.local/share/remmina/group_rdp_dxo_blglaptop139-corp-dxo-com.remmina` (on the Ubuntu workstation)

### Tailscale SSH

When WSL is running with `sshd`, direct SSH via Tailscale is possible:
```bash
ssh kapoivha@blglaptop139
```

---

## OS-Specific Notes (cross-reference)

- **Browser:** Windows Chrome/Edge paths differ from Ubuntu. See `k-browser/refs/windows.md` when complete.
- **tmux in WSL:** requires `alias tmux='wsl tmux'` or equivalent. See `k-tmux/refs/windows.md` when complete.
- **Code:** VS Code user data directory differs on Windows. See `k-code/refs/windows.md` when complete.
- **Dotfiles:** WSL environment uses `$HOME/.kshrc` via the KπX kernel clone.
- **Windows PowerShell profile:** `assets/Microsoft.PowerShell_profile.ps1` — personalized copy of the generic template at `k-windows/assets/Microsoft.PowerShell_profile.ps1` (PSReadLine history/prediction, PowerToys CommandNotFound, auto-`cd ~/KpihX-Labs`, `h`/`hist` full-history dump); this machine's `tx` function still defaults to session `dxo`, which nothing actually creates — a known drift, kept as-is (see `k-windows/references/msys2.md` for why the generic template uses `windows` instead). Deployed at `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` on this machine.
- **MSYS2 tmux (superseded):** before this WSL setup, this machine ran local tmux sessions via MSYS2 (`alienware`, `ubuntu`, plus DxO-specific ones now documented in `k-dxo`) — see `k-windows/references/msys2.md` for the generic mechanism, now demoted to "optional, not the default path" now that WSL's own `blglaptop139-wsl` tmux session (via `k-tmux`) covers the same need.
- **`$HOMEW` / `$USERW` / `~w`:** this machine's `assets/kshrc` sources `k-windows/assets/kshrc` (near the top, before its own Section 1) for everything generic to any Windows+WSL machine — the WSL-headless SSH-agent snippet, and `$HOMEW`/`$USERW`/`~w` (Windows-side home/user, derived via `cmd.exe`, never hardcoded). Nothing machine-specific was lost: only genuinely generic content moved out, per `k-windows` → "Direction of fixes matters". See `k-windows/SKILL.md` → "`assets/kshrc`" for the full mechanism.
  - **Ollama client, WSL-side, talking to the Windows server:** verified 2026-08-25 — the WSL distro has `ollama` (client-only, `~/.local/bin/ollama`, no `ollama.service`) talking to the native Windows Ollama server (`0.32.15`, 7 models) via `.wslconfig`'s `networkingMode=mirrored`; `ollama list` from WSL returns the Windows host's models with zero tunnel/port-forward setup. Installed via `k-ollama/scripts/install-wsl-client.sh` (idempotent, re-run anytime to update); generic mechanism + why never to `systemctl enable ollama` here → `k-ollama/references/windows.md`.
  - **WSLg Voice (STT/TTS) 2026-08-25:** `Ctrl+X R` showed `Recording in progress` with zero deps (see `k-opencode` v2.50.0 guard). Fixed: `apt` `sox`/`libsox-fmt-all`/`ffmpeg`/`pulseaudio-utils`/`alsa-utils` + `piper` `2023.11.14-2` (`~/.local/share/piper`, `~/.local/bin/piper`) + `whisper-cli` `b4938` (`whisper-bin-ubuntu-x64`, wrapper `~/.local/bin/whisper-cli` → `~/.local/share/whisper-bin/` via `LD_LIBRARY_PATH`) + `ggml-small.bin` 466 MB (`~/.local/share/whisper-cpp/`) + voices `en_US-ryan-medium`/`fr_FR-siwis-medium` (`~/.local/share/piper-voices/`). Audio via `PULSE_SERVER=unix:/mnt/wslg/PulseServer`, `RDPSource`/`RDPSink`. TTS uses `play` (sox) pipeline `piper --output_raw | play -t raw …`. Checklist: `which sox rec whisper-cli piper play ffplay && pactl info && parecord` smoke — see `k-opencode/references/voice.md` → Per-Machine Deployment.

---

## Assets

`assets/Microsoft.PowerShell_profile.ps1` — see "OS-Specific Notes" above.

The de-bloat pass scripts below are the actual commands run on 2026-07-02 —
kept for reference/re-run (disabled services/apps do not come back on their
own after a Windows update). Full narrative, numbers, and what stayed
disabled → `references/debloat-log.md`. The reusable *techniques* behind
them (not this machine's specific service/app names) live in `k-windows`,
cross-referenced per script below.

| Script | What it did | Generic technique |
|---|---|---|
| `desactiver_services_admin.ps1` | First pass disabling non-essential Windows services | `k-windows/references/windows-services.md` |
| `force_disable_services_admin.ps1` | Escalated disable for services that resisted the first pass | `k-windows/references/windows-services.md` |
| `disable_3_remaining_admin.ps1` | Final 3 stubborn services, registry-level disable | `k-windows/references/windows-services.md` |
| `force_disable_store_services.ps1` | Microsoft Store background services specifically | `k-windows/references/windows-services.md` |
| `desinstaller_dell_admin.ps1` | Removed Dell/Alienware bloatware | `k-windows/references/software-removal.md` |
| `desinstaller_nsight_sdk_admin.ps1` | Removed NVIDIA Nsight developer tooling (not needed for inference/gaming) | `k-windows/references/software-removal.md` |
| `desinstaller_outils_admin.ps1` | Removed duplicate SDKs/Perl/misc dev tools | `k-windows/references/software-removal.md` |
| `desinstaller_restante_admin.ps1` | Cleanup pass for what the earlier uninstall scripts missed | `k-windows/references/software-removal.md` |
| `desinstaller_complet_admin.ps1` | Combined/final uninstall pass | `k-windows/references/software-removal.md` |
| `reconfig_rdp_admin.ps1` | Re-enabled `TermService` (RDP) after the service de-bloat pass disabled it by mistake | `k-windows/references/remote-desktop.md` |
| `reconfig_chromoting_admin.ps1` | Re-enabled `chromoting` (Chrome Remote Desktop) for the same reason | `k-windows/references/remote-desktop.md` |
| `optimiser_gpu_admin.ps1` | First pass at the dual-GPU idle-load mitigation | `k-windows/references/dual-gpu.md` |
| `optimiser_gpu_final.ps1` | Final, working dual-GPU mitigation (see Hardware Specs → GPU-idle-at-rest root cause above) | `k-windows/references/dual-gpu.md` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-blglaptop139/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-blglaptop139/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [CLAUDE] | v1.8.0 — Persistent SSH agent block added to `assets/kshrc` Section 1 (gpg-agent ssh-emulation, guarded no-op) — WSL needs its own systemd verification (`systemctl --user status gpg-agent-ssh.socket`; WSL2 only runs systemd if enabled in `/etc/wsl.conf`) before this activates; native Windows-side git is unaffected (Windows has its own `ssh-agent` service, out of scope here). See `k-zsh` v2.5.0 for the mechanism; mirrored here per the SYNC RULE. *(Renumbered from v1.3.0 at PR merge — collided with this skill's own historical v1.3.0 "completed full WSL infra setup" entry.)* |
| 2026-08-25 | [COLAB] | v1.7.0 — **WSLg Voice STT/TTS live (fix Ctrl+X R):** `sox`/`libsox-fmt-all`/`ffmpeg`/`pulseaudio-utils`/`alsa-utils` (apt via tmux ops) + `piper` + `whisper-cli` wrapper + `ggml-small.bin` + 2 voices; `PULSE_SERVER=unix:/mnt/wslg/PulseServer` `RDPSource`/`RDPSink`; smoke `parecord`, `play` pipeline, `whisper-cli` OK. See `k-opencode` → Config-link ≠ runtime-ready rule + `references/voice.md` deployment checklist. |
| [SUMMARY] | — | v1.6.1 Ollama client installed WSL-side (client-only, verified vs Windows-hosted server) · v1.6.0 `assets/kshrc` sources `k-windows/assets/kshrc` + `$HOMEW`/`$USERW`/`~w` + Assets table (→ `references/log.md`) · v1.5.0 Hardware Specs + debloat-log + generic-technique extraction to k-windows (→ `references/log.md`) · v1.4.0 `references/gpu.md` (CUDA/WSL trap) (→ `references/log.md`) · v1.3.0 completed full WSL infra setup (zsh/neovim/tailscale/opencode natively in WSL, dual tailscaled identity) · v1.2.0 setup rule added · v1.1.0 renamed from k-alienware · v1.0.0 created as k-alienware — full detail in `references/log.md` |

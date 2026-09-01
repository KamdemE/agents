# k-blglaptop139 — changelog archive (append-only, GRAVÉ)

## Changelog rotation from `k-blglaptop139/SKILL.md` (2026-08-15)

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.0.0 — Created as k-alienware. Windows+WSL internship PC. Tailscale identity, RDP access. |

## Changelog rotation from `k-blglaptop139/SKILL.md` (2026-08-24)

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.1.0 — Renamed from k-alienware to k-blglaptop139. Updated metadata to match hostname-based naming. |
| 2026-08-14 | [COLAB] | v1.2.0 — **Setup rule added (per KπX infra setup standard)**: added Setup (WSL) section (read `k-infras` → New Infra Setup Checklist first); `kshrc` symlink → `k-blglaptop139/assets/kshrc` (created from `kshrc.base`); registered `kshrc-blglaptop139` in `assets/links.jsonc`. |

## Changelog rotation from `k-blglaptop139/SKILL.md` (2026-08-25)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [CLAUDE] | v1.3.0 — Completed full WSL infra setup (zsh, neovim, tailscale, opencode all installed natively inside WSL; shell symlinks, `.kshrc`, SSH `Include`, tmux session already in place). WSL now runs its own `tailscaled` as a **separate node** `blglaptop139-wsl` (`100.118.76.46`), distinct from the native Windows node `blglaptop139` (`100.99.196.32`) — added dual-identity row + note to Host Identity table (naming convention documented in `k-tailscale/references/windows.md`). |

## Changelog rotation from `k-blglaptop139/SKILL.md` (2026-08-25, second pass)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [CLAUDE] | v1.4.0 — Added `references/gpu.md`: this machine's NVIDIA RTX 5070 Ti Laptop GPU was silently running local ML inference (`qmd embed`) on CPU — WSL passes the driver through (`nvidia-smi` works) but ships no CUDA runtime toolkit and no NVIDIA Vulkan ICD. Fixed via NVIDIA's driver-less `wsl-ubuntu` CUDA Toolkit repo (see `k-qmd/references/wsl.md` for the general trap). Added GPU row to Host Identity table. |
| 2026-08-25 | [CLAUDE] | v1.5.0 — Added Hardware Specs table (CPU/RAM/GPU0/disk/network/audio/AV) and `references/debloat-log.md`, migrated from an unversioned Windows-side `.agents` at real risk of loss. Added `assets/Microsoft.PowerShell_profile.ps1`. Noted the pre-WSL MSYS2 tmux sessions as superseded (generic mechanism now in `k-windows/references/msys2.md`). Added Insights Discipline + `references/insights.md` (were missing). Follow-up re-audit the same day: this laptop belongs to DxO, so this skill gets abandoned at internship end too (not just `k-dxo`) — extracted 4 more genuinely generic techniques that were trapped in this skill's de-bloat scripts into `k-windows` (`references/windows-services.md`, `software-removal.md`, `remote-desktop.md`, `dual-gpu.md`), cross-referenced from `references/debloat-log.md` and the Hardware Specs GPU note. |

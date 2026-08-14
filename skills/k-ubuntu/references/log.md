# Ubuntu Workstation — Operation Log

> **Purpose:** Append-only record of significant system operations on the KpihX-Ubuntu workstation.
> Related: `k-context/references/log.md` (session-level operations) · `k-optim/references/ubuntu.md` (optimization passes)

---

## 2026-07-24 — Global pip purge + UV migration

Cleaned up all legacy pip-installed packages from `~/.local/lib/python3.14/site-packages/` and migrated remaining tools to uv.

| Package | Action | Reason |
|---------|--------|--------|
| `manim` | `pip3 uninstall --break-system-packages` | Used by ScienCurious (2 files) but broken (numpy missing) — should be in project venv |
| `ManimPango` | `pip3 uninstall --break-system-packages` | Orphaned dependency of manim |
| `rich` | `pip3 uninstall --break-system-packages` | apt version (13.9.4) remains — sufficient |
| `google-antigravity` | `pip3 uninstall --break-system-packages` | Never imported by any KpihX code |
| `google-genai` | `pip3 uninstall --break-system-packages` | Never imported by any KpihX code |
| `google-auth` | `pip3 uninstall --break-system-packages` | Never imported by any KpihX code |
| `protobuf` (orphan) | `pip3 uninstall --break-system-packages` | Orphaned dependency of google-antigravity |
| `python3-pynvim` | `sudo apt remove` | Neovim migrated to `uv-nvim` venv — system pynvim unused |
| `yt-dlp` | Migrated: `uv tool install yt-dlp` | Was using pyenv Python — now uv-managed v2026.7.4 |
| `/usr/local/bin/yt-dlp` | `sudo rm` | Leftover from old global install (root-owned) |

**Cleanup context:**
- The `opencode-antigravity-auth` plugin is an npm package (JS/TS), not Python. It does NOT depend on the Python `google-antigravity` SDK.
- A dedicated uv-managed venv was created at `~/.local/share/uv/antigravity-env` with `google-antigravity==0.1.8` + deps for potential future use.

**Post-cleanup health check:**
- Python 3.14.4 system: OK
- pip3: OK
- All 116 apt python3-* packages: OK
- dpkg --audit: clean
- Neovim Python provider: OK (uv-nvim venv)
- UV tool list: 19 tools
- `make audit`: ALL_OK

---

## 2026-05-31 — UV tool purge (k-optim pass)

Removed 7 unused uv tools: `grip`, `huggingface-hub`, `ipynb-pdf`, `kpihx-ai`, `kpihx-todo`, `viperx`, `wayland-mcp`. Freed ~200MB.

Details in `k-context/references/log.md`.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-24 | [OPENCODE] | Created initial log with 2026-07-24 global pip purge + migration and 2026-05-31 uv tool purge entries. |

## Archived changelog rows from `k-ubuntu/SKILL.md` (2026-08-04 rotation)

| 2026-07-27 | [OPENCODE] | v1.9.0 — **Cinema Mode (Gamescope) Integration**: Added scale-compensated launcher wrapper `gamescope-cinema.sh` with AZERTY layout sync, `cinema-mode.conf` config, and `inject-cinema-actions.py` crawler. |
| [SUMMARY] | — | v1.8.0 with-env helper; v1.5.0–v1.7.0 clean docs + secrets + kshrc symlink + idempotency guard; v1.4.0 backup_restore; v1.3.0 scripts/ centralization; v1.2.0 shell → k-zsh; v1.1.0 Tailscale/Ollama/WaveTerm |

## Archived changelog rows from `k-ubuntu/SKILL.md` (2026-08-14 rotation)

| 2026-08-03 | [OPENCODE] | v1.10.0 — **Dell Battery Charging Limits**: Documented hard BIOS/sysfs lock on Dell 7640, deprecation of `libsmbios-bin` on Ubuntu 26.04, required use of CCTK, and the critical QWERTY/AZERTY BIOS terminal password trap for setting thresholds. |


## Complete changelog rotation from `k-ubuntu/SKILL.md` (2026-08-04)

| [SUMMARY] | — | Older changelog entries were copied to `references/log.md`; the live table keeps only the two newest entries. |

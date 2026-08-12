# k-dxo Operation Log

Append-only archive for durable skill history.

## Archived changelog rows from `k-dxo/SKILL.md` (2026-08-04 rotation)

| 2026-08-01 | [OPENCODE] | v1.3.0 — Migrated `vpn-dxo` to a systemd root service (`assets/vpn-dxo.service` symlinked to `/etc/systemd/system/`) with `SUDO_USER` injection to preserve keyring SAML auth, eliminating tmux dependency and reducing idle RAM footprint to zero. |
| 2026-08-01 | [OPENCODE] | v1.2.0 — Added `ollama6` CLI (Ollama proxy to deep-pc6 via verbose SSH tunnel on port 11436, tmux session `ollama`, window `ollama6`, auto-spawn + quit). |
| 2026-07-25 | [OPENCODE] | v1.1.0 — Added tmux6 CLI and rclone-deep-pc6.service in assets/. |
| 2026-07-24 | [OPENCODE] | v1.0.0 — Created k-dxo: moved vpn-dxo from k-ubuntu, added accounts, VPN, RDP, setup procedures. |
| 2026-08-03 | [OPENCODE] | v1.4.0 — Removed the `vpn-dxo` CLI wrapper (`~/.local/bin/vpn-dxo` symlink + `scripts/vpn-dxo`). VPN is now managed natively via `systemctl` / `journalctl` against the `vpn-dxo.service` unit. Skill updated to pure systemd usage. |
| [SUMMARY] | — | — |

## Complete changelog rotation from `k-dxo/SKILL.md` (2026-08-04)

| [SUMMARY] | — | Older changelog entries were copied to `references/log.md`; the live table keeps only the two newest entries. |

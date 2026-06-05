# k-tg — runtime action log

> Append **one entry** after non-trivial `tg` / Telegram work (BotFather turns, `tg user *`, `tg updates`, investigations). Newest at top.

---

| ISO date (UTC) | Agent | Action | Outcome |
|----------------|-------|--------|---------|
| 2026-05-27 | [CLINE] | Mail recap sent via KpihX bot | `gws` fetched 16 inbox msgs (kapoivha); formatted MarkdownV2; sent to KπX user `1397540599` via TELEGRAM_GENERAL_TOKEN → msg_id=176. |

| 2026-05-27 | [CURSOR] | OpenClaw bot migration | BotFather **`@kpihx_openclaw_bot`**; folder **KpihX-Labs** (id 11) + pin; mistaken supergroup deleted; token **`/tmp/claw.env`**; allowlist DM; replies verified. |
| 2026-05-25 | [CURSOR] | Ingest Lebara eSIM PDF | `tg user download @kpihx_general_capture_bot 7991` → `$HOME/Gdrive_X/KpihX/Phone_Lebara/eSIM_Lebara_ML045066180_KAMDEM_Ivann_20260525.pdf`; `k-tg` default-bot rule v3.2.11. |
| 2026-04-25 | [ANTIGRAVITY] | BotFather `/setname` | Renamed Sentinel back to **Homelab**. |
| 2026-04-25 | [ANTIGRAVITY] | BotFather `/setname` + broadcast | Renamed Whats→Whatsapp, Tick→Ticktick; broadcasted "Hi! [timestamp]" to all 11 infra bots. |
| 2026-04-25 | [ANTIGRAVITY] | BotFather `/deletebot` + `/setname` | Deleted `@kflow_ubuntu_bot` and renamed `@kflow_homelab_bot` to **Flow**. |
| 2026-04-25 | [ANTIGRAVITY] | BotFather `/newbot` | Created **Docker-Host** bot (`@docker_host_kpihx_bot`) id **8036146758**; token stored in `/tmp/a.txt`. |
| 2026-04-18 | [GEMINI] | `tg user send me` | Sent the "Piano & Logic" bio snippet to Saved Messages (msg_id 7025). |
| 2026-04-09 | [CURSOR] | `.agents` session finalization | **`k-context` v2.74.55** + **`k-tg` v3.1.0** bundle committed; `k-tg/references/` triage log rows normalized; **`k-ticktick/references/log.md`** LEN_43314_EP row fixed; Session Log overflow → **`k-context/references/log.md`**; `make audit` + `make push`. |
| 2026-04-09 | [CURSOR] | BotFather `/token` batch + skill sync | Wrote **six** `TELEGRAM_*.env` files under `/tmp/tokens` (General, Issues, Tick/Whats/LinkedIn/Mail homelab); **`k-tg` v3.0.3** BotFather compact map + bridge @handles; Openclaw Ubuntu absent from `/mybots` (treated as removed). |
| 2026-04-09 | [CURSOR] | `.agents` session finalization | Skill folder + `AGENTS` ladder + `.skill-lock` committed; **`k-tg` v3.0.2** (implementation gate) on record. |
| 2026-04-09 | [CURSOR] | BotFather `/setname` ×2 | Display names set to **General** (`@kpihx_general_capture_bot`) and **Issues** (`@kpihx_issues_capture_bot`). |
| 2026-04-09 | [CURSOR] | BotFather `/newbot` ×2 | Created capture bots `@kpihx_general_capture_bot` id **8089748360**; `@kpihx_issues_capture_bot` id **8656241501**; user `/start` both via `tg user send` |
| 2026-04-09 | [CURSOR] | *What's up* Telegram triage (read-only) | Issues: 5 photos; General: 4 photos; Homelab: PVE backup error; Ubuntu: backup PC OK — cursors updated in `telegram-processed-state.md` |
| 2026-04-09 | [CURSOR] | *What's up* Telegram triage (deep) | Issues: UCSI laptop boot hypothesis; General: Shakespeare/Brutus notes; Homelab: PVE backup error (GDrive quota hypothesis) — pistes only per implementation gate |
| 2026-04-11 | What's up triage | Parsed general screenshots and homelab errors. Found GDrive full for proxmox backups, network issues, and IME poll photo. |
| 2026-05-06 | Processed Julius Caesar PDFs from @kpihx_general_capture_bot (msg 7532, 7533). Extracted via OCR and updated revision_anglais.md. |
2026-05-31 00:22 UTC | Mail Recap | Sent 3 MarkdownV2 messages (497,498,499) to Telegram (1397540599) | 30 messages, 22 unread, 0 important, 5 security alerts
[2026-05-31T02:50:54+02:00] 📬 Mail Recap → Telegram | 30 messages fetched from kapoivha@gmail.com | 26 unread | 0 Important | 5 security alerts (Google×2, Link, Venice.ai, SG) | Sent to chat 1397540599 (msg ID 505) | MarkdownV2

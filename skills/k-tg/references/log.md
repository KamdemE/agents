# k-tg — runtime action log

> Append **one entry** after non-trivial `tg` / Telegram work (BotFather turns, `tg user *`, `tg updates`, investigations). Newest at top.

---

| ISO date (UTC) | Agent | Action | Outcome |
|----------------|-------|--------|---------|
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

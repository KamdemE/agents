# k-whatsapp Runtime Log

Purpose: detailed runtime execution log for WhatsApp operations (different from `SKILL.md` changelog).

## 2026-09-09

- **15:0x** `find-messages` "CAF" (global, account 33605957785) → 2 msgs in `ENSPY 2026 - France` (`120363419277624888@g.us`, 07/09/2026): Pluton tip (Acadomia/Anacours contracts + fiche de paie + Attestation de prolongation → APL renewal, his CAF just renewed) + Florette follow-up (advisor called, contract sent 2 months ago, going to CAF office).
- **15:0x** `chat-read` ENSPY 2026-France (limit 100, 66 msgs) → full 07/09 discussion captured: Delano procedure Q, Florette law Q, Pluton voice note (20:57), Arthur legal explanation (law suspends automatic APL for foreigners, June decree, working foreigners recognized as boursiers), Florette confirmation.
- **15:0x** `media-download` voice note `3EB0DC76DDF1447000BAFE` → `/home/kpihx/Downloads/Whats-Proxy/33605957785/*.ogg` (227 KB, opus) → transcribed via `k-whisper 1 -p` (large-v3-turbo, Vulkan Arc): go to CAF accueil with work contract (+2 docs), account unblocked + backpay days later.
- **Lesson:** vague numeric refs (KπX "k-whats 336") resolve via global `find-messages`, never by guessing a JID prefix (actual group did NOT start with 336).

## 2026-09-08

- **21:10** `chat-read` Badminton X24 (`120363393577104884@g.us`, 30 msgs) — daily chat (verres, ecocups, blagues), no relevant content on first pass.
- **21:10** `find-messages` queries: "nvlink"=0, "openai"=2 (Spam X24 + Info X24, hackathon announcement only), "nvidia"=0, "resolution"=0, "chip"=0, "gpu"=0, "bourse"=12 (various groups).
- **21:12** `find-messages` "navier"=1 → **FOUND**: Paul Ruggeri @ 20:52 in Badminton X24: `https://openai.com/index/navier-stokes-solution/` + "OpenAI dit avoir résolu Navier Stokes 🤯🤯"
- **21:12** `find-messages` "stokes"=1 → same message confirmed.
- **Task:** Retrieved article, searched researcher reactions (Tao, Buckmaster/Alpöge, TNW, New Scientist, OfficeChai), drafted LinkedIn post, published via `link-proxy do post-create-full` → `urn:li:share:7503200532732289024` (PUBLIC, URL card + editorial body).
- **Lesson:** "nvier et stock" = "Navier-Stokes" with phonetic typos. Always try both halves of compound terms separately + phonetic variants when `find-messages` returns 0.

## Entry Format

| Timestamp (UTC) | Agent | Channel | Action | Inputs | Outcome | IDs / Links | Notes |
|-----------------|-------|---------|--------|--------|---------|-------------|-------|
| 2026-04-08T11:15:00Z | [CODEX] | whats-mcp http | `search_messages` | contact=Sivluy, query=project TP1 | results found | chat/thread ids | context recovery |
| 2026-04-08T11:17:00Z | [CODEX] | whats-mcp http | `send_message` | follow-up text | sent | message id | neutral tone |
| 2026-04-09T02:55:42Z | [CURSOR] | whats-mcp http + stdio | `connection_status`, `list_chats` | compared `user-whats-mcp-http` vs `user-whats-mcp--stdio` | HTTP rejected (`No valid session ID provided`), stdio returned data (`state=disconnected`, store available, list_chats OK) | n/a | indicates MCP HTTP session-handshake issue client-side while account auth remains paired |
| 2026-04-09T03:16:05Z | [CURSOR] | shell + homelab logs | `whats-admin auth/status/info`, Edge profile inspection, `docker logs whats-mcp` | checked stdio auth store, browser storage, and remote reconnect churn | stdio auth persisted (`$HOME/.mcps/whatsapp/auth`), Edge WhatsApp data located in IndexedDB, server shows repeated disconnect/reconnect cycles (408/428/500/503) with eventual recovery | n/a | supports central-auth-service recommendation over browser-session reuse |
| 2026-04-09T03:35:00Z | [CURSOR] | whats-mcp http | `connection_status` | simple health probe after server restart | failed (`Bad Request: No valid session ID provided`) | n/a | backend restart alone did not fix HTTP MCP client-session issue |
| 2026-04-13T12:00:00Z | [CODEX] | whats-mcp http | `search_messages` + `get_messages` | jid `245006442971219@lid` (Natacha) | 4 msgs; her reply confirms Signal + criteria list | thread ids in MCP | history_sync timeout; reply visible in local store |
| 2026-04-13T12:10:00Z | [CODEX] | whats-mcp http | `send_text` + `edit_message` | jid `245006442971219@lid`; quoted her criteria msg | Signal summary + cadre modalités; fixed leading char via edit | `3EB0CE62B1AB128BEF23BE` | MCP JSON mangled leading byte on first send |
| 2026-04-13T12:25:00Z | [CODEX] | whats-mcp http | `send_text` | jid `245006442971219@lid` (Natacha) | Resent summary: Signal vs hosted canal + questions1 ext vs groupe identifiants + timing | `3EB0676E5ED88EB0D949D8` | User deleted prior msg; no quote; ASCII opener |
| 2026-04-13T13:05:00Z | [CODEX] | whats-mcp http | `get_messages` | jid `245006442971219@lid` | Retrieved latest reply for feasibility analysis | `ACC748CC75A34DFDAFF237E7D0959863`, `AC15AD1A9F14263985BC21F9920B8117` | constraints clarified: short-term, 2-3 individual contacts |

- `2026-04-09` `[GEMINI]` run `whatsup` WhatsApp daily overview for today. Only 1 active group (X24-X25 Cameroun) returned with 2 messages.
- `2026-04-09` `[GEMINI]` run `whatsup` WhatsApp Monday to Wednesday overview. Heavy traffic in Badminton (Biprom event), Hackathon team (prize payout), PSC, and Offres de missions (BNP).
- `2026-04-20` `[ANTIGRAVITY]` whats-mcp stdio | `list_contacts`, `get_messages` | Nelson Mbeunang / 23797950433@s.whatsapp.net | Failed: "WhatsApp is not connected. Run the server and scan the QR code to connect." | n/a | AUTH BLOCK enforcement
- `2026-04-20` `[ANTIGRAVITY]` whats-mcp stdio | `get_messages` | Nelson Mbeunang / 23797950433@s.whatsapp.net | Failed: EOF | n/a | User successfully re-authenticated, but stdio pipe died (EOF) after clearing stuck background processes. Requires window/agent reload.
- `2026-04-21` `[ANTIGRAVITY]` whats-mcp stdio | `list_contacts`, `send_document` | Allan X-Cam / 33759026570@s.whatsapp.net | Failed: "WhatsApp is not connected. Run the server and scan the QR code to connect." | n/a | AUTH BLOCK enforcement

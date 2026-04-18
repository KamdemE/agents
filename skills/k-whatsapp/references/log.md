# k-whatsapp Runtime Log

Purpose: detailed runtime execution log for WhatsApp operations (different from `SKILL.md` changelog).

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

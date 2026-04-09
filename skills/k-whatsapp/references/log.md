# k-whatsapp Runtime Log

Purpose: detailed runtime execution log for WhatsApp operations (different from `SKILL.md` changelog).

## Entry Format

| Timestamp (UTC) | Agent | Channel | Action | Inputs | Outcome | IDs / Links | Notes |
|-----------------|-------|---------|--------|--------|---------|-------------|-------|
| 2026-04-08T11:15:00Z | [CODEX] | whats-mcp http | `search_messages` | contact=Sivluy, query=project TP1 | results found | chat/thread ids | context recovery |
| 2026-04-08T11:17:00Z | [CODEX] | whats-mcp http | `send_message` | follow-up text | sent | message id | neutral tone |
| 2026-04-09T02:55:42Z | [CURSOR] | whats-mcp http + stdio | `connection_status`, `list_chats` | compared `user-whats-mcp-http` vs `user-whats-mcp--stdio` | HTTP rejected (`No valid session ID provided`), stdio returned data (`state=disconnected`, store available, list_chats OK) | n/a | indicates MCP HTTP session-handshake issue client-side while account auth remains paired |
| 2026-04-09T03:16:05Z | [CURSOR] | shell + homelab logs | `whats-admin auth/status/info`, Edge profile inspection, `docker logs whats-mcp` | checked stdio auth store, browser storage, and remote reconnect churn | stdio auth persisted (`~/.mcps/whatsapp/auth`), Edge WhatsApp data located in IndexedDB, server shows repeated disconnect/reconnect cycles (408/428/500/503) with eventual recovery | n/a | supports central-auth-service recommendation over browser-session reuse |
| 2026-04-09T03:35:00Z | [CURSOR] | whats-mcp http | `connection_status` | simple health probe after server restart | failed (`Bad Request: No valid session ID provided`) | n/a | backend restart alone did not fix HTTP MCP client-session issue |


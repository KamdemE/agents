---
name: k-whatsapp
description: whats-mcp operational memory — KπX WhatsApp identity, messaging style, key contacts with JIDs, group index (HIGH→VERY LOW), community map, and contact search pitfalls. Load before any whats-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.4"
allowed-tools: mcp__whats-mcp__*, mcp__whats-mcp--fallback__*
---

# Tool Memory — WhatsApp (whats-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Identity

- **Number:** +33 6 05 95 77 85
- **Own JID:** `33605957785@s.whatsapp.net`

## Messaging Style

- **Default language:** French — always reply in French unless chat history shows otherwise
- Casual, natural French with SMS-style shortcuts; emoji reactions preferred over long replies
- French/English mix in tech groups (X, Hackathon, AI)
- Warmer, more affectionate register in family/Cameroonian groups

## Key Contacts

| Saved As | JID | Style |
|----------|-----|-------|
| Maman | `23795844360@s.whatsapp.net` | Affectionate, reassuring, short messages, religious tone |
| Ma Ange TOUKO | `23777947720@s.whatsapp.net` | Warm family register |
| Ma Jakeline SIME | `23777680325@s.whatsapp.net` | Occasional family exchanges |

## Group Index (HIGH → VERY LOW)

| Group | JID | Members | Priority |
|-------|-----|---------|----------|
| Badminton X24 | `120363393577104884@g.us` | 41 | HIGH |
| X24 — Announcements | `120363400296786956@g.us` | 816 | HIGH (X24 Community, announce=true) |
| Info X24 | `120363417591278511@g.us` | 721 | HIGH (X24 Community, announce=false) |
| IPAI Hackathon group 7 | `120363405436750278@g.us` | 6 | HIGH |
| Sympathisants Binet IA — Announcements | `120363382112481618@g.us` | 453 | HIGH (Binet IA Community, announce=true) |
| Sympathisants Binet IA — Discussion | `120363251841330923@g.us` | 444 | HIGH (Binet IA Community, announce=false) |
| Offres de Missions | `120363377060744481@g.us` | 634 | HIGH (XProjets Community, announce=true) |
| Opportunites IA : Stages, PSC, Projets | `120363379979578334@g.us` | 257 | HIGH |
| X24⚔️🔥 | `120363293201252722@g.us` | 8 | HIGH (ENSPY classmates — standalone) |
| Missions XProjets | `120363359089349774@g.us` | 675 | MEDIUM (XProjets Community) |
| X-Afrique Sympathisants | `120363327608135460@g.us` | 79 | MEDIUM |
| X - Cameroun (large) | `120363419403445255@g.us` | 73 | MEDIUM |
| Competiteurs FFSU | `120363422527120376@g.us` | 14 | MEDIUM |
| PSC IA | `120363422379816902@g.us` | 5 | MEDIUM |
| Binet Bad | `120363149474153094@g.us` | 160 | MEDIUM |
| ENSPY ALUMNI ABROAD | `120363029059198260@g.us` | 555 | LOW (ENSPY Community, announce=true) |
| ENSPY Alumni Abroad 0 | `33659825066-1537198811@g.us` | 460 | LOW (ENSPY Community, announce=false) |
| X24 - X25 Cameroun | `120363419537806175@g.us` | 30 | LOW (X-Cameroun Community) |
| X23 - X24 Cameroun | `120363283853277949@g.us` | 22 | LOW (X-Cameroun Community) |
| Spam X24 | `120363322114150116@g.us` | 785 | VERY LOW (X24 Community) |

**Agent rule:** Maintain HIGH → MEDIUM → LOW → VERY LOW order when inserting rows.

## Community Map

Community roots are NOT chats — never message them directly.

| Community | Root JID | Sub-groups |
|-----------|----------|------------|
| Binet IA | `120363377205265375@g.us` | Announcements · Discussion |
| XProjets | `120363360032776776@g.us` | Offres de Missions · Missions XProjets |
| ENSPY Alumni Abroad | `120363028960717937@g.us` | ALUMNI ABROAD · Alumni Abroad 0 |
| X-Cameroun | `120363420960425072@g.us` | X24-X25 Cameroun · X23-X24 Cameroun |
| X24 | `120363399574799388@g.us` | Announcements · Info X24 · Spam X24 |

## Contact Search Pitfalls

```
WRONG: search_messages(query="maman")   → searches message content, not names → 0 results
WRONG: list_contacts + name filter      → Baileys stores name: null for most contacts

CORRECT:
  1. Get phone number from KπX
  2. Strip '+' and spaces → E.164 digits only (e.g. +237 77947720 → 23777947720)
  3. JID = <digits>@s.whatsapp.net
  4. Confirm: get_contact_info(jid="23777947720@s.whatsapp.net")

## MCP Setup Reference

- Generic setup (HTTP + stdio + fallback): `$HOME/.agents/skills/k-whatsapp/references/mcp.md`
```

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-06 | [CLAUDE] | v2.0.3–v2.0.1 — reverted Whats MCP to stable npm-global local-source ownership after Bun runtime failure, then documented the Bun-first experiment and the MCP setup reference pointer (`references/mcp.md`) |
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte, migrated to skills/kpihx/whatsapp/ |
| [SUMMARY] | — | Prior: initial scan 19 groups, community maps built, Binet Bad added, X24⚔️🔥 added |

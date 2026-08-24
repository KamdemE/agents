# Agent & MCP Infrastructure — Architecture & Vision

> Merged from: `agents-memory-curator-hybrid-vision.md`, `mcp-central-sync-vision.md`, `mcp-visual-validation-vision.md`, `sh-mcp-agent-sandbox-vision.md`, `voice-kernel-ollama-vision.md`, `google-workspace-full-mcp-vision.md`
> Sources archived: 2026-07-22

---

## 1. Hybrid Memory-Curation

### Problem
Real-time updates across `k-*` files improve long-term quality but slow execution flow during active work.

### Model
**Immediate (minimal) during run:** record only critical facts — IDs (UID, task/message/JID), concrete actions, incidents/errors.

**Deferred automatic curation:** dedicated agent reads transcript at session end → extracts durable learnings → proposes/patches `k-*` skills in batch (version + changelog + context sync).

**Guardrails (always immediate):** broken auth/transport, security rules, workflow-breaking regressions, irreversible decisions.

### Curation Hints Protocol
Inside responses, leave compact hints:
- `CURATION_HINT: <fact>`
- `CURATION_PRIORITY: high|medium|low`
- `CURATION_TARGET: k-mail|k-whatsapp|...`

---

## 2. Central MCP Synchronization

### Problem
MCP servers must be configured across multiple agent providers (Gemini, Claude Code, Codex, Vibe, Cursor, OpenClaw) — each with its own config format.

### Solution: Config-as-Code Centralization

**Source of truth:** `$HOME/.agents/mcp-registry.yaml`

**Sync engine:** `sync-mcps.py` (encapsulated in `k-mcp` skill)

**Distribution map:**

| Runtime | Target config |
|---------|---------------|
| Claude Code | `$HOME/.claude.json` |
| Gemini CLI | `$HOME/.gemini/gemini-extension.json` |
| Codex | `$HOME/.codex/config.toml` (`[mcp_servers]`) |
| Vibe | `$HOME/.vibe/config.toml` |
| Cursor / VS Code (Cline) | `$HOME/.cursor/mcp.json` / `*_cline_mcp_settings.json` |

**Flow:** new MCP discovered → test → add to `mcp-registry.yaml` → run `make sync-mcps` → all agents possess the tool.

---

## 3. MCP Visual Validation (HITL)

### Vision
Transform all write operations (`send`, `create`, `update`, `delete`, `move`) across the MCP ecosystem into Human-In-The-Loop flows with visual preview.

### Priority Targets

| MCP | Actions | Preview |
|-----|---------|---------|
| tick-mcp | create_task, update_task | Visual task card with dates/reminders |
| whats-mcp | send_text/image/document | Chat bubble with recipient + media metadata |
| mail-mcp | send_message, reply, draft | Full email composer |
| linkedin-mcp | publish_post, send_message | Post preview with text/image |

### Architecture

1. **Shim Layer:** interceptor on write calls
2. **Visual Editor:** web-based preview (artifact, local server, or WebTop)
3. **Validation Loop:** agent proposes → shim intercepts → preview generated → user approves/edits/rejects → shim executes validated payload

### Roadmap
1. Wireframes per preview type
2. Prototype interception for tick-mcp
3. Standardize validation payload format
4. Generalize across all communication MCPs

---

## 4. sh-mcp: Agent Sandbox

### Purpose
Network-facing MCP service exposing a dedicated persistent Linux sandbox for LLM agents — isolated from the interactive workstation.

### Two Trust Domains

| Domain | Role | Trust |
|--------|------|-------|
| **Agent sandbox (sh-mcp)** | Hosted on docker-host, persistent volume, agent-owned installs | Bounded: no host `$HOME`, no Docker socket by default |
| **User workstation (future sh-exec)** | Local shell, sudo, personal keys | User-mediated, secrets stay local |

### Architecture (5 layers)

1. **Execution perimeter:** Container on docker-host with single writable root (`/workspace`)
2. **Control plane:** MCP process — authenticate, validate paths/timeouts, delegate to restricted executor
3. **Data plane:** Named Docker volume, regenerate from git where possible
4. **Ingress:** Traefik on proxy network — private hostname, TLS, IP restrictions
5. **MCP surface (minimal v1):** Prefer one `exec` tool + strict policy. Skills (`SKILL.md`) teach CLIs; MCP does not embed that knowledge.

### Security
- No sudo password path through HTTP
- Auth (token/mTLS) mandatory for any routed URL
- Prompt injection → mitigate with path allowlists, output caps, timeouts

### Deployment
- Run on docker-host, same stack as other lab services (Traefik + proxy network)
- Not on Proxmox host directly

---

## 5. Voice Kernel (Oriyama)

### Problem
Voice module (STT/TTS) is coupled to OpenCode via `@renjfk/opencode-voice` (TUI-only). Cannot be used by Codex, Cline, Copilot, Gemini CLI, or Vibe without duplicating setup.

### Goal
Centralize STT/TTS as sovereign cross-agent voice kernel — any runtime consumes via HTTP API, MCP tool, or CLI bridge.

### Architecture

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   STT        │  │   TTS        │  │ Language     │
│   Engine     │  │   Engine     │  │ Router       │
│ whisper.cpp  │  │ piper ONNX   │  │ detect +     │
│ (Vulkan GPU) │  │              │  │ route voice  │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                  │
       └─────────────────┼──────────────────┘
                         │
               HTTP API (localhost:PORT)
               POST /stt  ← audio → text
               POST /tts  ← text → audio
               GET  /lang
```

### Model Specs

| Component | Model | Size | RAM |
|-----------|-------|------|-----|
| STT | ggml-large-v3-turbo-q5_0 | 548 MB | ~1.5 GB |
| TTS EN | en_US-ryan-high.onnx | 116 MB | ~150 MB |
| TTS FR | fr_FR-siwis-medium.onnx | 61 MB | ~100 MB |

### Interfaces

- **A: HTTP API (recommended)** — persistent service, any agent calls `/stt` and `/tts`
- **B: MCP Server** — expose STT/TTS as MCP tools
- **C: CLI bridge** — `voice-stt < audio.wav` → stdout, `echo "text" | voice-tts` → audio

### Next Steps
1. Extract STT into standalone HTTP server (whisper-cli already has `whisper-server`)
2. Extract TTS into standalone server (piper + HTTP wrapper)
3. Add language auto-detection + voice routing
4. Expose as MCP server
5. Document resource requirements per platform

---

## 6. Google Workspace Full-MCP

### Objective
Manage Google Workspace end-to-end from MCP-based agents using Google-native APIs.

### Target Capabilities
- Gmail: read/search/archive/labels/send/drafts/templates
- Calendar: events, reminders, shared calendars, conflict checks
- Drive: file lifecycle, sharing, permissions, retention
- Docs/Sheets/Slides: create/update/export
- Contacts: lookup, enrichment, dedup
- Admin: users/groups/org policies/audit (where authorized)
- Chat/Meet: signals (if APIs and scopes permit)

### Architecture

**Modular MCP stack:** one MCP per domain (mail, calendar, drive, docs, optional admin) + shared auth core. Each module exposes a narrow contract; orchestrator agents compose them.

**Auth:** OAuth2/service-account managed centrally, least-privilege scopes per module, explicit account routing for multi-account contexts.

**Skill layer:** Dedicated `k-google-workspace` skill defines account map, operation playbooks, incident patterns, cross-MCP choreography examples.

### Delivery Strategy
1. Start with Gmail + Calendar + Drive high-value workflows
2. Add docs automation (Docs/Sheets/Slides)
3. Add admin/audit only when governance validated
4. Keep all workflows source-of-truth-first and policy-auditable

### Extension Lane
Combine Google with other MCPs: mail deadlines → TickTick, drive docs → presentation pipelines, calendar events → WhatsApp summaries (with approval gates).

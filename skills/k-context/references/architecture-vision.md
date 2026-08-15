# Architecture Vision — Sovereign Cloud, Personal OS & Agentic Foundation

> Merged from: `KpihX-Labs.md`, `k-personal-os-learning-laboratory-vision.md`, `agentic-architecture-brainstorm.md`, `sovereign-email-universe-vision.md`
> Sources archived: `tmp/` (2026-07-22)

---

## 1. KpihX-Labs: Sovereign Personal Cloud Architecture

KpihX-Labs is the supreme abstraction layer. It eradicates multi-OS friction, centralizes execution, and transforms end-user devices into stateless zero-trust terminals.

### The Convergence Pyramid

```
                      [ KpihX-Labs ]
                   (The Sovereign Cloud)
                            ▲
                            │
               ┌────────────┴────────────┐
               │        homelab          │ ◄── Sovereign Abstraction Layer
               │ (Fluid Cloud / Docker)  │     (Agnostic, Centralized Fluid)
               └────────────┬────────────┘
                            │
      ┌────────────┬────────┴────────┬────────────┐
      │            │                 │            │
  [ ubuntu ]   [ windows ]        [ mac ]      [ pve ] ◄── OS Layer
      │            │                 │            │
      └──────┬─────┘                 │            │
             │                       │            │
         [  dell  ]            [ mac-studio ]  [   hp   ] ◄── Physical Metal
```

**1. Physical Layer:** `dell` (mobile), `hp` (Proxmox PVE), `mac-studio` (ARM AI compute).

**2. OS Layer:** Treated as dumb stateless clients — host only IDEs, browsers, Tailscale. `ubuntu` (dev), `windows` (art/studio), `mac` (AI), `pve` (hypervisor).

**3. Abstraction Layer (`homelab`):** Distributed fluid managed by K3s. All services, APIs, CLI tools run here.

### Serverless MCP Strategy

Decouple intelligence from execution:

1. **Agent Brain** (`.agents/skills`): reads `SKILL.md` to understand a tool
2. **CLI Bridge** (JSON RPC 2.0): tool is exposed as structured CLI output
3. **Network Shim**: local execution tunnels via Tailscale/SSH to containerized tool on `homelab`

**Result:** Zero configuration drift. Update on `homelab` once, all OS layers instantly use the new version.

### Zero-Trust Secrets Pipeline (ESO)

- **Vaultwarden** = single source of truth for all tokens
- **ESO** on K3s authenticates to Vaultwarden via service account
- **Injection**: K3s requests secrets from Vaultwarden via ESO → injects into Pod RAM
- **No secrets on disk**: neither terminals nor CI ever touch real secrets
- **⚠️ SPOF risk**: Vaultwarden/ESO failure blocks CI/CD. Maintain HA or emergency offline backup.

### Distributed Brain (`.agents/`)

- Hosted centrally on homelab (Nextcloud/NFS)
- Mounted on all devices, accessible via mobile
- **Critique:** SQLite on network mounts = file locking risk → migrate to centralized Postgres if data volume grows

---

## 2. Sovereign Personal OS & Learning Laboratory

### Three Pillars

| Pillar | Name | What |
|--------|------|------|
| **1** | The Workbench (Self-OS) | Homelab, K3s, local LLMs, 0-trust, sovereign identity |
| **2** | The Coach (Agentic Proxy) | HITL visual validation, TickTick orchestration, cross-agent memory |
| **3** | The Laboratory (Instant Content) | Live visual generation (Manim/Napkin/Mermaid), adaptive intelligence, ScienCurious convergence |

### Evolutionary Path

```
Homelab / K3s → Self-OS → Professional Coach → Visual HITL → Instant Learning Lab → SOVEREIGN PERSONAL OS
[Phase 1: Technical] → [Phase 2: Professional] → [Phase 3: Intellectual]
```

### Key Strategic Goals

- **Zero magic, 100% transparency:** every visual and code block must be inspectable and modifiable
- **Instant context recall:** k-context + QMD ensure no redundant learning
- **Content cost reduction:** hours of production → seconds of generation

---

## 3. Sovereign Agentic Architecture

### Hot vs Cold Capabilities Framework

```
COLD capabilities                    HOT capabilities
─────────────────────────────────   ─────────────────────────────────
Stable, versioned interface          Evolving, zero-deploy
Deployed (remote process)            In-context (in the prompt)
Slow to change (dev cycle)           Immediate (edit a .sh/.md)
Strong isolation / security          Low token overhead
Good for: auth, infra, KB            Good for: workflows, API wraps
→ MCP server                         → SKILL.md + scripts/
```

### Target 3-Layer Architecture

| Layer | Contents | Examples |
|-------|----------|----------|
| **0 — Primitives** (MCPs, never replaceable) | shell-mcp, code-executor, qmd | Complex auth, sandbox, embedding |
| **1 — Remote Gateways** (HTTP MCPs) | mail-mcp, homelab-http | OAuth, private network services |
| **2 — Hot Capabilities** (git-versioned skills) | k-whatsapp, k-ticktick, k-linkedin, k-napkin | curl-to-API, zero-deploy scripts |

### MCP Qualification Test

An MCP is justified if: complex auth, private network protocol, ultra-stable interface, non-negotiable security, too complex to script (embedding/BM25).

Unjustified if: just curl to REST API, API changes often, missing functions block work, <5 actions used in practice.

**Decisions:**

| MCP | Verdict | Rationale |
|-----|---------|-----------|
| `bw-mcp` | ✅ Purged 2026-08-14 → `bw-proxy` | Non-scriptable security primitive (superseded) |
| `qmd` | ✅ Keep | Indexing/embedding too complex |
| `shell-mcp` | ✅ Create | Fundamental compute primitive |
| `code-executor-mcp` | ✅ Create | Isolated Python sandbox |
| `mail-mcp` | 🟡 Keep | Zimbra OAuth is complex |
| `whatsapp-mcp` | ❌ Convert | curl + API |
| `ticktick-mcp` | ❌ Convert | Simple REST API |
| `linkedin-mcp` | ❌ Convert | REST API + OAuth via bw |

### Why shell and code-executor Stay Separate

- **shell** = system ops, filesystem, env vars, orchestration
- **code-executor** = sandboxed computation, analysis, rendering

If arbitrary Python runs inside the main shell → loss of filesystem control boundary. Maps to clear Unix principle.

### Skill Centralization

- **Current:** Hybrid git + auto-sync (`make sync-skills`, post-commit hook)
- **Future:** Skill-server HTTP MCP (`GET /skill/k-napkin` → SKILL.md in context)
- **Standard:** SKILL.md format + `scripts/references/assets/` is becoming industry standard (SkillReg compatible)

### skill-creator Drift Protection

```
skill-creator/         ← upstream, never touched
k-skill-creator/       ← KπX overlay (delta only: changelog, edit reminders, version rules)
```

When upstream updates → diff → update k-skill-creator only if delta is affected.

### Cross-Platform Agnosticism

- `SKILL.md` → metadata and LLM instructions (Claude/Gemini/Codex)
- `scripts/*.sh` → actual code, executed via shell MCP from any agent
- Gap: Gemini has its own extension format, but shell MCP bridges that

### Key Nuance

Converting MCP → skill script does NOT remove the API maintenance problem. The real gain: update velocity and full control — no npm/uv/docker cycle.

### Roadmap

| Phase | Actions |
|-------|---------|
| **1 (now)** | k-skill-creator overlay, document hot/cold rule |
| **2 (next)** | Convert whatsapp/ticktick/linkedin → skills with scripts/ |
| **3 (remote)** | Minimal shell MCP, code executor MCP, skill-server HTTP MCP |
| **4 (governance)** | skill-lock.json semver, SkillReg maturity |

---

## 4. Sovereign Email Universe

Establish a 100% sovereign email infrastructure for `@kpihx-labs.com`.

### Environment

- Domain: `kpihx-labs.com` (Cloudflare)
- Infrastructure: Homelab ready for Docker/Traefik
- Connectivity: Tailscale
- Current: mail-mcp (IMAP/SMTP) + m365 CLI

### Pathways

| Path | Approach | Best for |
|------|----------|----------|
| **A — Sovereign Routing** | Cloudflare Email Routing + SMTP Relay (Postmark/Brevo/SES) | Reliability, professional identity |
| **B — Full Sovereign Server** | Mailcow/Stalwart on Homelab via VPS tunnel (Port 25 blocked on residential IPs) | Total ownership |
| **C — Managed Pro** | M365 Business with custom domain | Collaboration, academic/pro flows |

### KpihX-Labs Aliases

| Alias | Purpose |
|-------|---------|
| `ivann@kpihx-labs.com` | Primary sovereign identity |
| `sentinel@kpihx-labs.com` | System heartbeat (monitoring, alerts, logs) |
| `lab@kpihx-labs.com` | Research, AI tool registrations |
| `ops@kpihx-labs.com` | Infrastructure administration |
| `bot@kpihx-labs.com` | Automated agents |

### Trust Trinity

SPF + DKIM + DMARC required for all paths.

### Next Steps

1. Audit Cloudflare Email Routing eligibility
2. Standardize visual signatures for `@kpihx-labs.com`
3. Plan migration of Sentinel alerts to `sentinel@kpihx-labs.com`

---

## References

| Document | URL | Relevance |
|----------|-----|-----------|
| ToolRegistry paper | arxiv 2507.10593 | Protocol-agnostic tool management |
| SkillReg | skillreg.dev | SKILL.md registry, governance |
| MCP gaps analysis | Thomas Scola (Medium) | Agent discovery, policy, state |
| A2A vs MCP | Apigene blog | Stateful + cross-provider comparison |

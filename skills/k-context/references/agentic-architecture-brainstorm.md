# Brainstorm — Sovereign Agentic Architecture

> **Date:** 2026-04-01 · **Agent:** [CLAUDE] · **Status:** Draft / decisions pending

---

## Context & Problem

Specific MCPs (whatsapp, ticktick, linkedin...) are costly to maintain. If the API changes → full dev/test/deploy cycle. If functions are missing → immediate blocker. Too many tools in context → token overhead + measurable performance degradation (>20 tools threshold confirmed by research).

Research confirms: the MCP community is converging on the same diagnosis (Garry Tan, Perplexity CTO, arxiv 2507.10593 ToolRegistry paper, SkillReg 2026).

---

## Framework: Hot vs Cold Capabilities

```
COLD capabilities                  HOT capabilities
─────────────────────────────────  ─────────────────────────────────
Stable, versioned interface        Evolving, zero-deploy
Deployed (remote process)          In-context (in the prompt)
Slow to change (dev cycle)         Immediate (edit a .sh/.md)
Strong isolation / security        Low token overhead
Good for: auth, infra, KB          Good for: workflows, API wraps
→ MCP server                       → SKILL.md + scripts/
```

---

## Target 3-Layer Architecture

```
Layer 0 — PRIMITIVES (MCPs — never replaceable)
  shell-mcp        : bash exec, file ops, env injection
  code-executor    : isolated sandbox Python/uv
  bw-mcp           : Vaultwarden — absolute security primitive
  qmd              : indexed KB — embedding/BM25 too complex to script

Layer 1 — REMOTE GATEWAYS (HTTP MCPs — complex auth only)
  mail-mcp         : Zimbra OAuth — candidate to keep
  [homelab-http]   : kpihx-labs.com services

Layer 2 — HOT CAPABILITIES (git-versioned skills, zero-deploy)
  k-whatsapp       : curl scripts → whatsapp-web API
  k-ticktick       : curl scripts → TickTick API
  k-linkedin       : curl scripts → LinkedIn API
  k-napkin         : already converted ✅
  k-* (all)        : executed via shell/code-executor MCP
```

---

## MCP Qualification Test

```
An MCP is justified if:
  ✅ Complex auth that cannot be scripted (OAuth, bw secrets)
  ✅ Network protocol to a private remote service
  ✅ Ultra-stable interface (API will not change)
  ✅ Non-negotiable security boundary
  ✅ Too complex to script (qmd — embedding, BM25, etc.)

An MCP is UNJUSTIFIED if:
  ❌ It's just curl to a public REST API
  ❌ The API changes often
  ❌ Missing functions block work → no hot-fix path
  ❌ <5 actions actually used in practice
```

### Decision per MCP

| MCP | Keep? | Rationale |
|-----|-------|-----------|
| `bw-mcp` | ✅ Absolute | Non-scriptable security primitive |
| `qmd` | ✅ | Indexing/embedding too complex |
| `shell-mcp` | ✅ To create | Fundamental compute primitive |
| `code-executor-mcp` | ✅ To create | Isolated Python sandbox |
| `mail-mcp` | 🟡 Maybe | Zimbra OAuth is complex |
| `whatsapp-mcp` | ❌ Convert | curl + whatsapp-web API |
| `ticktick-mcp` | ❌ Convert | Simple REST API |
| `linkedin-mcp` | ❌ Convert | REST API + OAuth manageable via bw |

---

## Why Keep shell and code-executor Separate

Not just about heavy libs — deeper architectural reason:
- **shell** = system ops, filesystem, env vars, orchestration scripts
- **code-executor** = sandboxed computation, analysis, rendering

If arbitrary Python runs inside the main shell → loss of filesystem control boundary. The separation maps to a clear Unix principle and preserves security guarantees.

---

## Skill Centralization

### Retained option: Hybrid git + auto-sync

```
~/.agents/           ← git repo (already in place)
  make sync-skills   ← git pull → rsync → all agents
  post-commit hook   → automatic propagation
```

### Future evolution: Skill-server HTTP MCP

```
Agent → GET /skill/k-napkin → SKILL.md content in context
```

Benefit: access from claude.ai + remote agents. ~100 lines, exposed via existing Traefik.

### SkillReg (2026)

SKILL.md format + `scripts/references/assets/` standard is becoming the de facto industry standard (SkillReg supports it natively). KπX's current conventions are aligned — no reason to diverge.

---

## skill-creator Drift Problem (upstream vs customization)

Clean pattern:

```
skill-creator/         ← external, never touched (upstream Anthropic)
k-skill-creator/       ← KπX overlay (k-prefixed = owned)
  SKILL.md             ← delta only:
                          - Changelog format convention
                          - ⚠️ edit reminder rule
                          - Version bump rule
                          - scripts/assets/references standard
```

When skill-creator is updated upstream → diff → update k-skill-creator only if the delta is affected.

---

## Cross-Platform Agnosticism

Real portability comes from the **executable**, not the manifest:

```
SKILL.md     → metadata, instructions for the LLM (Claude/Gemini/Codex)
scripts/*.sh → actual code, executed via shell MCP from any agent
```

Current gap: Gemini has its own `gemini-extension.json` format. But with shell MCP, Gemini can execute scripts without reading SKILL.md. Portability is guaranteed at the script level.

---

## Key Nuance on Maintenance

Converting whatsapp-mcp → skill script does NOT remove the API maintenance problem. The real difference:

- **With MCP:** change = deploy/test/restart cycle, can break other agents
- **With skill script:** change = edit a .sh, available immediately, git-versioned

The real gain is **update velocity and full control** within the native dev environment — no npm/uv/docker cycle.

---

## Roadmap

```
Phase 1 (now)
  → Create k-skill-creator overlay (customization delta)
  → Document hot/cold rule + qualification test in AGENTS.md

Phase 2 (next sprint)
  → Convert whatsapp/ticktick/linkedin → skills with scripts/
  → make sync-skills: git pull → rsync → all agents

Phase 3 (when remote need identified)
  → Minimal shell MCP (wraps bash, exposed via Traefik)
  → Code executor MCP (uv Python sandbox, Daytona or local)
  → Skill-server HTTP MCP (serves SKILL.md on demand)

Phase 4 (governance)
  → skill-lock.json → proper semver + auto changelog
  → SkillReg when mature enough
```

---

## References

| Project | URL | Relevance |
|---------|-----|-----------|
| ToolRegistry paper | arxiv 2507.10593 | Protocol-agnostic tool management |
| SkillReg | skillreg.dev | SKILL.md registry, governance |
| Cased Sandboxes | github.com/cased/sandboxes | E2B/Daytona/Modal abstraction |
| MCP gaps analysis | Thomas Scola (Medium) | Agent discovery, policy, state |
| A2A vs MCP | Apigene blog | Stateful + cross-provider comparison |

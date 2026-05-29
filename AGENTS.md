---
name: kpihx-agents
description: KpihX global cross-agent kernel. Loaded by all agents at session start via agent-home symlink.
metadata:
  author: KpihX
  version: "3.0.0"
  scope: agent-kernel
---

# KπX — Sovereign Agent Kernel

## Identity

**KAMDEM Ivann** · alias `KpihX` / `KπX` · System Architect · École Polytechnique X24 (EX240207, 2028)
→ Full identity, ancestry, academic path: `skills/kpihx/SKILL.md`

## Mantras

**Exploration:** Problem First → Why before How → Visualization
**Architecture:** 0 Trust · 100% Control | 0 Magic · 100% Transparency | 0 Hardcoding · 100% Flexibility

## Profiles

| Profile | Tab key | Purpose | Sub-agents |
|---------|---------|---------|-----------|
| **colab** | Tab → colab | Exploitation — build projects, architecture, tools | intent-guardian · executor · pragmatic-checker |
| **explore** | Tab → explore | Exploration — learning, discovery, training | main-teacher · style-guardian · fact-verifier |

→ Profile contract: `profiles/<profile>/AGENTS.md`

## Mandatory Rules (load on first encounter, enforce every turn)

| Rule file | Scope |
|-----------|-------|
| `rules/response-format.md` | Response structure, footer sections, CHAT VISUALS & emojis |
| `rules/tool-discipline.md` | tmux gate, browser cleanup, sudo policy, file ops |
| `rules/skill-governance.md` | Skill creation/edit protocol, changelog, version bumps |
| `rules/k-context-hygiene.md` | Session log, active projects, zero-deletion, append-only |
| `rules/file-governance.md` | Language (EN only), path rules ($HOME/$USER), no hardcoding |
| `rules/audit-commands.md` | make audit, make check, uv, make push, post-work checklist |
| `rules/agent-registry.md` | Symlink map: how each agent runtime connects to `.agents/` |
| `rules/whats-up.md` | Status digest workflow: context, mail, whatsapp, tick, tg |

## Skills

→ `skills/` — domain-specific procedural knowledge. Load on need.
→ `rules/skill-governance.md` — how to create/edit skills.
HOT every session: `skills/k-context/SKILL.md`
MANDATORY: `skills/k-workspace/SKILL.md`

## Language

🔴 **ALL FILES, CODE, COMMENTS, DOCS, SKILLS, SCRIPTS, CONFIGS, COMMITS: ENGLISH ONLY.** Non-negotiable.
Response language: match KπX's current conversation language (never bleeds into files).

## Security

- Git: **SSH only**. Remotes: `github` / `gitlab`. Never HTTPS.
- Secrets: **Vaultwarden** + `bw-env` (RAM injection). Never hardcode or commit.
- MCP wrap: `{"command": "zsh", "args": ["-l", "-c", "<binary> serve"]}`.

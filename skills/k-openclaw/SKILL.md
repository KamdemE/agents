---
name: agent-runtime-openclaw
description: >
  OpenClaw runtime — Workspace configuration, skills path ~/.agents/skills/,
  symlinked kernel and agent files. Load when configuring OpenClaw behaviors.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenClaw

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `/home/kpihx/.openclaw/`
- **Workspace:** `/home/kpihx/.openclaw/workspace/`
- **Global kernel:** `SOUL.md` → `~/.agents/KERNEL.md`
- **Runtime shortcut:** `AGENTS.md` → this file
- **Skills path:** `/home/kpihx/.openclaw/workspace/skills/` → `~/.agents/skills/` (symlink)

## Configuration

OpenClaw is managed via the `openclaw` CLI and the Gateway.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [COPILOT] | v1.0.0 — initialized k-openclaw skill and symlinked to workspace |

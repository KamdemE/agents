---
name: k-deep-pc6
description: >
  Deep-PC6 — Linux server at DxO internship. Accessed via DxO VPN from the
  Ubuntu workstation. Known SSH configuration and purpose. This skill serves
  as the entry point for Deep-PC6 operations as information is gathered.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# Deep-PC6 — Linux Server (DxO Internship)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map) · `k-ubuntu` (SSH client — VPN access required first)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `deep-pc6` |
| LAN IP | `172.16.150.163` |
| OS | Linux |
| Location | DxO network (Grenoble) |
| Access | Via DxO VPN only (not on Tailscale) |

---

## SSH Access

| Alias | Target | Key | Notes |
|-------|--------|-----|-------|
| `deep-pc6` | `172.16.150.163` | `id_ed25519_deep_pc6` | Requires DxO VPN active first |

**User:** `ikamdem@corp.dxo.com`  
**Connection:** SSH over DxO VPN (GlobalProtect via OpenConnect on Ubuntu workstation)

**Prerequisite:** DxO VPN must be connected first (`vpn-dxo` on Ubuntu). See `k-ubuntu` → Remote Work.

---

## Purpose

Deep-PC6 is a Linux development/server machine at the DxO internship. Its exact role, services, and configuration are to be documented as discovered.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.0.0 — Created k-deep-pc6. Linux server at DxO internship. SSH config, VPN prerequisite. Purpose TBD as discovered. |
| [SUMMARY] | — | — |

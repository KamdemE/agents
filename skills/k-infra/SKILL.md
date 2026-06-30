---
name: k-infra
description: >
  KπX infrastructure configuration — BIOS/UEFI settings, OS dual-boot
  arrangement, disk partitioning, filesystem recovery, and low-level hardware
  configuration. Load before any partition/disk/BIOS operation.
metadata:
  author: KpihX
  version: "1.1.0"
  scope: infrastructure
license: private
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Infrastructure

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Static rules:** `rules/audit-commands.md` (make audit, make check) · `rules/tool-discipline.md` (shared tmux gate — mandatory for all sudo commands)
> **Always use shared tmux for sudo** — never raw sudo in agent shell. See `k-tmux/SKILL.md` → Shared interactive gate.

## Role

`k-infra` is the compact operational map for KπX infrastructure work, organized by scope:

- **Disk & Partitioning** — GPT, NTFS, ext4 resize, partition recovery, dual-boot arrangement
- **BIOS/UEFI** — firmware settings, boot order, Secure Boot, TPM
- **Filesystem recovery** — NTFS boot sector repair, ext4 undelete fallback, interrupted resize recovery
- **OS configuration** — dual-boot maintenance, Windows/Linux coexistence, bootloader repair

## Source of Truth

| Topic | Where to look |
|-------|---------------|
| NTFS shrink + dual-boot prep | `references/ntfs-shrink-dual-boot.md` |
| Disk layout | `sudo parted <device> unit s print free`, `sudo lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL` |
| Boot configuration | `efibootmgr -v`, `sudo grub-install`, `sudo update-grub` |
| GRUB config | `/etc/default/grub` — `GRUB_DISABLE_OS_PROBER=false` |
| Tool discipline | `k-tmux/SKILL.md` (shared tmux gate) |
| Safe file editing (reco) | `sudoedit` (aka `sudo -e`) pour tout fichier système |

## Disk & Partitioning

### Last Known State

- **nvme0n1** (KIOXIA 1024GB, GPT): `[p1 ESP 100M] [p2 MSR 16M] [p4 Linux 281G] [p3 Datas 522.5G] [free 150G]`
- Datas (`nvme0n1p3`): NTFS, mounts with `ntfs-3g -o force` (bitmap inconsistencies from interrupted ntfsresize)
- **Windows 11 installé** dans le free space 150G (2026-06-11). GRUB detects it via os-prober.
- Dual-boot final: `GRUB_DISABLE_OS_PROBER=false` in `/etc/default/grub` → Windows Boot Manager found on `nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi`

### Actions

1. Always read `references/ntfs-shrink-dual-boot.md` before any NTFS shrink or dual-boot prep
2. Use tmux pane (`default:0.2` or dedicated) for all `sudo` disk commands
3. Verify with `sudo parted ... unit s print free` before and after any partition change
4. Unmount filesystems before resize operations
5. Align partition boundaries to 2048-sector (1 MiB) boundaries

## BIOS/UEFI

### Actions

1. Check current boot mode: `[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS`
2. List EFI boot entries: `sudo efibootmgr -v`
3. TPM presence: `ls -l /dev/tpm*` (also `sudo cat /sys/class/tpm/tpm0/device/description`)

## Filesystem Recovery

### Last Known State

- Interrupted `ntfsresize` recovery validated 2026-06-11: data relocation completed 100%, boot sector field 0x28 manually patched via `dd`, mount succeeds with `ntfs-3g -o force`. Full runbook: `references/ntfs-shrink-dual-boot.md#recovery-interrupted-ntfsresize`.

## OS Configuration

### Actions

1. After Windows install: enable os-prober → `sudo update-grub` (no need for live USB if GRUB is intact)
2. Enable Windows detection: set `GRUB_DISABLE_OS_PROBER=false` in `/etc/default/grub`, then `sudo update-grub`
3. To set boot order: `sudo efibootmgr -o XXXX,YYYY` (numbers from `efibootmgr -v`)
4. Config file editing: always use `sudoedit <file>` or `sudo nvim <file>` — never `nvim /etc/...` (readonly trap)

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-06-11 | [OPENCODE] | v1.1.0 — Dual-boot finalisé: GRUB os-prober, Windows détecté, sudoedit best practice. |
| 2026-06-11 | [OPENCODE] | v1.0.0 — Created from NTFS shrink dual-boot prep session. Moved from k-optim. |
| [SUMMARY] | — | — |


# Skill Infrastructure Scope Rule

## Principle

Skills must be written **cross-infrastructure first**. The main `SKILL.md` describes the general case that works across all relevant platforms. OS-specific or infra-specific details go in `references/<os>.md` files.

## Pattern

```
skills/k-<name>/
├── SKILL.md              ← general case (cross-Linux, cross-platform)
├── references/
│   ├── ubuntu.md          ← Ubuntu-specific: apt, snap, systemd, GNOME
│   ├── windows.md         ← Windows/WSL-specific: winget, named pipes, PowerShell
│   ├── pve.md             ← Proxmox-specific: VM/CT, storage, network
│   └── insights.md        ← durable runtime lessons
```

## When to split

| Content type | Where it goes |
|---|---|
| Works on **all Linux** (Ubuntu, PVE Debian, WSL) | `SKILL.md` — the general/default path |
| Works on **all OS** (Linux, Windows, macOS) | `SKILL.md` — the general/default path |
| Ubuntu-specific (snap, systemd, .deb) | `references/ubuntu.md` |
| Windows/WSL-specific (winget, named pipes, PowerShell) | `references/windows.md` |
| Proxmox-specific (qm, pct, ZFS) | `references/pve.md` |
| macOS-specific (brew, launchd) | `references/macos.md` |
| Device/infra specific (klaptop, server) | `references/<infra>.md` |

## How to reference

In `SKILL.md`, point to the OS-specific file with a clear note:

```markdown
> **OS references:** `references/ubuntu.md` (Ubuntu setup) ·
> `references/windows.md` (WSL setup)
```

Then in `references/ubuntu.md`, put the full Ubuntu-specific procedure.
In `references/windows.md`, put the full Windows/WSL-specific procedure.

## Exceptions

If a skill is **inherently single-platform** (e.g., `k-ubuntu` only makes sense on Ubuntu), it can keep everything in `SKILL.md`. But if cross-platform patterns emerge later, extract them to references.

## Enforcement

The main `SKILL.md` must not contain large OS-specific blocks that only apply to one platform. If you find yourself writing "On Ubuntu..." or "On Windows..." in the main skill, that content belongs in `references/`.

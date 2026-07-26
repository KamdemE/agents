---
name: k-zsh
description: >
  Cross-platform Zsh + shell hub (.kshrc) setup for all KπX equipment:
  Ubuntu, PVE, Debian, Windows/WSL. Covers installation, Oh My Zsh,
  the .kshrc centralisation pattern, and how to simplify .bashrc.
  ⚠️ MANDATORY READ before any CLI install, PATH change, or env var addition.
license: private
metadata:
  author: KpihX
  version: "2.2.0"
  scope: kernel
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Zsh / Shell Hub

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-tmux` (setup BEFORE zsh — kshrc.base has auto-tmux at end) · `k-infras` (master map, checklist step 1b) · `k-skill-creator` (create infra skill if absent) · `k-ubuntu` / `k-pve` / `k-25` (infra skills with their own `assets/kshrc`)
>
> **Asset files:**
> - `assets/kshrc.base` → **infrastructure template** — seed for new infra skill's `assets/kshrc` (🔴 NEVER MODIFY base, edit infra copy)
> - `assets/bashrc` → **bash fallback template** — used by `k-ubuntu/assets/bashrc`
> - `assets/zshrc` → **zsh template** — used by `k-ubuntu/assets/zshrc`
>
> **Per-infra startup files** (in each infra skill's `assets/`):
> - `kshrc` → **the hub** — 2 sections (universal + interactive), symlinked from `~/.kshrc`
> - `zshrc` → **interactive zsh** — symlinked from `~/.zshrc` (🔴 NEVER MODIFY)
> - `zshenv` → **zsh universal** — symlinked from `~/.zshenv` (🔴 NEVER MODIFY)
> - `zprofile` → **zsh login** — symlinked from `~/.zprofile` (🔴 NEVER MODIFY)
> - `bashrc` → **bash interactive** — symlinked from `~/.bashrc` (🔴 NEVER MODIFY)
> - `profile` → **sh/bash login** — symlinked from `~/.profile` (🔴 NEVER MODIFY)
>
> The startup files are **per-infra** (k-ubuntu, k-25, etc.) because each may differ slightly
> (tmux session name, machine-specific completions). They are NEVER edited in place —
> always through the infra skill's asset.

---

## ⚠️ CRITICAL — Read This Skill Before Any CLI Install or PATH Change

**Whenever you install a CLI, add a PATH, set an environment variable, or modify shell behavior anywhere, you MUST load this skill first.**

The shell config follows a strict hierarchy:

| File | Scope | Editable? |
|------|-------|-----------|
| **Infra skill** `assets/kshrc` (e.g. `k-ubuntu/assets/kshrc`) | **THIS machine** — the actual shell config | ✅ **YES** — edit the asset |
| `k-zsh/assets/kshrc.base` | **Template** — base content for new infra skills | ✅ **YES** — update template |
| `k-zsh/assets/zshrc` | Zsh plugins/theme only | 🔴 **NEVER** |
| `k-zsh/assets/bashrc` | Bash fallback → sources .kshrc | 🔴 **NEVER** |

**How it works — setup order (tmux BEFORE zsh):**

The `.kshrc.base` template has an **auto-tmux block** at the end that auto-attaches to the infra's tmux session on shell open. Therefore **tmux must be set up first** (see `k-tmux`), so the session exists when the first shell opens.

```
New machine setup:
  0. Setup tmux first (k-tmux) — creates the infra tmux session
  1. 5 shared files from k-zsh (zshrc, zshenv, zprofile, bashrc, profile):
     ln -sf ~/.agents/skills/k-zsh/assets/zshrc    ~/.zshrc
     ln -sf ~/.agents/skills/k-zsh/assets/zshenv   ~/.zshenv
     ln -sf ~/.agents/skills/k-zsh/assets/zprofile ~/.zprofile
     ln -sf ~/.agents/skills/k-zsh/assets/bashrc   ~/.bashrc
     ln -sf ~/.agents/skills/k-zsh/assets/profile  ~/.profile
  2. Check if infra skill has assets/kshrc (e.g. k-ubuntu, k-pve, k-25)
     ├─ YES → ln -sf ~/.agents/skills/<infra>/assets/kshrc ~/.kshrc
     └─ NO  → cp k-zsh/assets/kshrc.base → <infra-skill>/assets/kshrc
               replace <INFRA_SESSION> with infra short name
               add machine-specific lines, then symlink
  3. Verify: open new shell — auto-attaches to infra tmux session
```

The 5 shared files (`.zshrc`, `.zshenv`, `.zprofile`, `.bashrc`, `.profile`) source `~/.kshrc` — that's how the hub pattern flows.

---

## Philosophy: .kshrc Universal Hub

One central hub (`.kshrc`) sourced by every shell. No duplicated env vars, no PATH drift.

```
.kshrc         ← THE hub — infra-specific (k-ubuntu, k-25, etc.) — symlink from infra skill
.zshrc         ← sources .kshrc → interactive zsh — symlink from k-zsh/assets/
.zshenv        ← sources .kshrc → ALL zsh (scripts too) — symlink from k-zsh/assets/
.zprofile      ← login-only actions — symlink from k-zsh/assets/
.bashrc        ← sources .kshrc → bash fallback — symlink from k-zsh/assets/
.profile       ← sources .bashrc if bash — symlink from k-zsh/assets/
```

### Benefits

| Before | After |
|--------|-------|
| Duplicated PATH in `.zshrc`, `.bashrc`, `.profile` | Single `.kshrc` — one edit updates everything |
| Bash and zsh drift apart over time | Identical env on both shells |
| Secrets loaded in N different files | One idempotent guard in `.kshrc` |
| Each new machine means copy-pasting dotfiles | Same `.kshrc.base` template everywhere |

---

## `kshrc.base` — The Template

`assets/kshrc.base` is the **seed template** for creating a new infra skill's `assets/kshrc`. It is never used directly as `~/.kshrc` — always through the infra skill chain:

```bash
# New infra skill: cp to infra skill, customize, then symlink
cp $HOME/.agents/skills/k-zsh/assets/kshrc.base <infra-skill>/assets/kshrc
# Edit <infra-skill>/assets/kshrc:
#   - Replace <INFRA_SESSION> with this infra's tmux session name
#   - Add machine-specific PATH, env vars, source calls
# Then: ln -sf <infra-skill>/assets/kshrc ~/.kshrc
```

Each infra skill's `assets/kshrc` contains:
- **PATH entries** for binaries specific to this machine
- **Env vars** (EDITOR, language, tool configs)
- **Source calls** for skill-specific assets
- **Auto-tmux block** at the end (session name customized per infra)

> **Rule of thumb:** if a PATH or env var could serve another KπX machine, add it to `kshrc.base` instead so seed stays rich. If it's truly local (hardware paths, temporary experiments), add it to the infra skill's `assets/kshrc`.

---

## 🔴 Frozen Files — Never Modify

5 shared files are symlinked from `k-zsh/assets/`. They are NEVER edited directly:

| File | Why frozen |
|------|------------|
| `.zshrc` | Zsh-specific (theme, plugins, completions). Only update the asset for structural fixes. Never for PATH or env vars. |
| `.zshenv` | Zsh universal — minimal, just sources .kshrc. Never add aliases/eval here. |
| `.zprofile` | Zsh login — minimal (example: exec tmux). Only login-specific actions. |
| `.bashrc` | Bash fallback. Sources .kshrc + bash options. No env vars here. |
| `.profile` | Sh/bash login — sources .bashrc if bash. PATH handled by .kshrc. |

**The only exception**: if an automated installer appends to one of these files. The append goes through the symlink into the asset — review and either keep it (genuine structural addition) or move the content to `~/.kshrc` and revert the asset.

---

## The .kshrc Pattern

`.kshrc` is **the hub**, not a function library. Keep it thin. See `assets/kshrc.base` for the canonical template.

**Rules:**
1. **No bloat** — .kshrc is not a function library. Keep env vars, PATH, and source calls only.
2. **Prefer installable CLIs** (uv tool, bun link, packages) over sourced shell helper files.
3. **Secrets guard** — idempotent check prevents infinite reload loops.

---

## Deploying to a New Machine

**Prerequisite:** tmux must be set up first (see `k-tmux`) — the kshrc auto-tmux block needs the session to exist.

1. **Install zsh + Oh My Zsh**:
   ```bash
   sudo apt install zsh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   chsh -s $(which zsh)
   ```

2. **5 shared files from k-zsh** (all symlinks → `k-zsh/assets/`):
   ```bash
   ln -sf ~/.agents/skills/k-zsh/assets/zshrc    ~/.zshrc
   ln -sf ~/.agents/skills/k-zsh/assets/zshenv   ~/.zshenv
   ln -sf ~/.agents/skills/k-zsh/assets/zprofile ~/.zprofile
   ln -sf ~/.agents/skills/k-zsh/assets/bashrc   ~/.bashrc
   ln -sf ~/.agents/skills/k-zsh/assets/profile  ~/.profile
   ```

3. **Infra skill & kshrc**: follow the **How it works** section above (step 2):
   - Check infra skill: if `assets/kshrc` exists → symlink; if not → cp base, customize, symlink
   - `ln -sf ~/.agents/skills/<infra>/assets/kshrc ~/.kshrc`

4. **Verify**: open new shell → auto-attaches to infra tmux session.

> **Existing files on the machine** should not be deleted — just replace with symlinks to `.agents/` assets. The hub pattern adds, never replaces.

---

## OS-Specific Notes

All infra skills now follow the same pattern: `assets/kshrc` in the skill, `~/.kshrc` is a symlink to it.

### Ubuntu (kpihx-ubuntu)
See `k-ubuntu` → Shell. `~/.kshrc` → `k-ubuntu/assets/kshrc`.

### PVE (kpihx-pve)
See `k-pve` → Shell. Same pattern: `assets/kshrc` in skill, symlink from home.

### WSL (blglaptop139)
WSL needs `chsh -s $(which zsh)` inside the WSL distro. Windows Terminal → zsh by default. See `k-blglaptop139` → Shell.

### Debian VM (kpihx-pve-debian)
See `k-pve-debian` → Shell. Same symlink pattern.

### S25 Phone (Termux)
See `k-25` → Setup. `~/.kshrc` → `k-25/assets/kshrc`.

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-zsh/references/insights.md` before non-trivial work in this skill domain.
- Update insights at task end with durable lessons.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-26 | [OPENCODE] | v2.2.0 — **with-env helper added**: Added the `with-env` function to `kshrc.base` and `k-ubuntu/assets/kshrc` to allow secure command execution with isolated `.env` loading. |
| 2026-07-24 | [OPENCODE] | v2.1.0 — **kshrc pattern redesigned**: `~/.kshrc` is now a symlink to infra skill `assets/kshrc` (not a direct copy). If infra skill absent, create it (k-skill-creator), seed with kshrc.base, customize. Setup order: tmux first, then zsh. OS notes updated for all infra types. |
| [SUMMARY] | — | v2.0.1 rm alias fix; v2.0.0 purged .kshrc.local; v1.1.0 frozen files |

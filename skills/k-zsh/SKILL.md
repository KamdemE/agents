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
  version: "2.0.1"
  scope: kernel
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Zsh / Shell Hub

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (workstation shell) · `k-pve` (PVE shell) · `k-pve-debian` (Debian VM shell) · `k-blglaptop139` (WSL shell) · `k-tmux` (shared interactive gate) · `k-clis` (CLI registry)
>
> **Asset files:**
> - `assets/kshrc.base` → **template** — copy to `$HOME/.kshrc` on new machines, then customize
> - `assets/zshrc` → **interactive zsh** — symlinked from `~/.zshrc` (🔴 NEVER MODIFY)
> - `assets/bashrc` → **bash fallback** — symlinked from `~/.bashrc` (🔴 NEVER MODIFY)
>
> **Not managed by k-zsh (real files, never touched):** `.zprofile`, `.zshenv`

---

## ⚠️ CRITICAL — Read This Skill Before Any CLI Install or PATH Change

**Whenever you install a CLI, add a PATH, set an environment variable, or modify shell behavior anywhere, you MUST load this skill first.**

The shell config follows a strict hierarchy:

| File | Scope | Editable? |
|------|-------|-----------|
| `.kshrc` | **THIS machine** — the actual shell config for this equipment | ✅ **YES** — edit directly, this IS the local file |
| `.kshrc.base` | **Template** — base content for new machines | ✅ **YES** — update the template when adding common defaults |
| `.zshrc` | Zsh plugins/theme only | 🔴 **NEVER** |
| `.bashrc` | Bash fallback → sources .kshrc | 🔴 **NEVER** |

**How it works:**

```
New machine setup:
  1. cp assets/kshrc.base → ~/.kshrc
  2. Add machine-specific env vars, PATHs, source calls to ~/.kshrc
  3. Symlink assets/zshrc → ~/.zshrc  (or leave default)
  4. Symlink assets/bashrc → ~/.bashrc (or leave default)

On an existing machine (Ubuntu, etc.):
  ~/.kshrc IS the local config — edit it directly.
  It was built from .kshrc.base + machine additions.
```

---

## Philosophy: .kshrc Universal Hub

One central hub (`.kshrc`) sourced by every shell. No duplicated env vars, no PATH drift.

```
.kshrc         ← THE hub — env vars, PATH, source calls (shared by ALL shells)
.zshrc         ← sources .kshrc → interactive shells (terminal tabs, tmux)
.bashrc        ← sources .kshrc → bash fallback
```

### Benefits

| Before | After |
|--------|-------|
| Duplicated PATH in `.zshrc`, `.bashrc`, `.profile` | Single `.kshrc` — one edit updates everything |
| Bash and zsh drift apart over time | Identical env on both shells |
| Secrets (bw-env) loaded in N different files | One idempotent guard in `.kshrc` |
| Each new machine means copy-pasting dotfiles | Same `.kshrc.base` template everywhere |

---

## .kshrc.base — The Template

`assets/kshrc.base` is the **minimal starting point** for any new KπX machine. Copy it, then add what that machine needs:

```bash
cp $HOME/.agents/skills/k-zsh/assets/kshrc.base ~/.kshrc
```

Then edit `~/.kshrc` and add:
- **PATH entries** for binaries specific to this machine
- **Env vars** (EDITOR, language, tool configs)
- **Source calls** for skills assets (phones, gws profiles, etc.)
- **bw-env** secret injection (see `k-bw`)

> **Rule of thumb:** if a PATH or env var could serve another KπX machine, add it to `.kshrc.base` instead so the template stays rich. If it's truly local (hardware paths, temporary experiments), add it directly to `~/.kshrc`.

---

## 🔴 Frozen Files — Never Modify

`.zshrc` and `.bashrc` are symlinked from `k-zsh/assets/`. They are NEVER edited directly:

| File | Why frozen |
|------|------------|
| `.zshrc` | Zsh-specific (theme, plugins, completions). Only update the asset for structural fixes (broken plugin, new omz feature). Never for PATH or env vars. |
| `.bashrc` | Bash fallback. Sources .kshrc + bash options. No env vars here. |

**The only exception**: if an automated installer (Antigravity, broot, cargo, etc.) appends to one of these files. The append goes through the symlink into the asset — review and either keep it (genuine structural addition) or move the content to `~/.kshrc` and revert the asset.

---

## The .kshrc Pattern

`.kshrc` is **the hub**, not a function library. Keep it thin:

```bash
# EXAMPLE .kshrc — add what YOUR machine needs

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="micro"

# Source skill assets
[[ -f "$HOME/.agents/skills/k-phones/assets/phones.ksh" ]] && source "$_"

# bw-env (idempotent)
[ -f "$HOME/Work/sh/bw_env profile.sh" ] && source "$_"

# ── Interactive-only below ──
case $- in *i*) ;; *) return ;; esac
# ... aliases, history, colors
```

**Rules:**
1. **No bloat** — .kshrc is not a function library. Keep env vars, PATH, and source calls only.
2. **Prefer installable CLIs** (uv tool, bun link, packages) over sourced shell helper files.
3. **bw-env guard** — `BW_ENV_LOADED=$$` prevents infinite reload loops (PID-scoped).

---

## Deploying to a New Machine

1. **Install zsh + Oh My Zsh**:
   ```bash
   sudo apt install zsh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   chsh -s $(which zsh)
   ```

2. **Create `~/.kshrc` from base template**:
   ```bash
   cp $HOME/.agents/skills/k-zsh/assets/kshrc.base ~/.kshrc
   ```
   Then edit `~/.kshrc` to add machine-specific env vars and PATHs.

3. **Symlink zshrc and bashrc** (optional — if you want the KπX defaults):
   ```bash
   SKILL="$HOME/.agents/skills/k-zsh/assets"
   ln -sf "$SKILL/zshrc"  ~/.zshrc
   ln -sf "$SKILL/bashrc" ~/.bashrc
   ```

4. **Verify**: open new shell → `echo $EDITOR` should show your configured editor.

> **Existing files on the machine** (`.bashrc`, `.profile`, etc.) should not be deleted — just append a `.kshrc` source line and leave the original content intact. The hub pattern adds, never replaces.

---

## OS-Specific Notes

### Ubuntu (kpihx-ubuntu)
`~/.kshrc` is a real file (NOT managed by the skill — edited directly on the machine). Built from `.kshrc.base` + machine additions. See `k-ubuntu` → Shell.

### PVE (kpihx-pve)
PVE uses its own minimal shell. Install zsh + copy `.kshrc.base` → `~/.kshrc`, then add PVE-specific paths. See `k-pve` → Shell.

### WSL (blglaptop139)
WSL needs `chsh -s $(which zsh)` inside the WSL distro. Windows Terminal can be configured to launch zsh by default. See `k-blglaptop139` → WSL Shell.

### Debian VM (kpihx-pve-debian)
Standard apt install + `.kshrc.base` → `~/.kshrc`. See `k-pve-debian` → Shell.

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-zsh/references/insights.md` before non-trivial work in this skill domain.
- Update insights at task end with durable lessons.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v2.0.1 — Removed `alias rm='trash-put'` from .kshrc.base — replaced by `~/.local/bin/rm` wrapper (k-clis/assets/rm). |
| 2026-07-22 | [OPENCODE] | v2.0.0 — Removed .kshrc.local. Purged Ubuntu-specific details. Added .kshrc.base deploy template. |
| [SUMMARY] | — | v1.1.0 — Added .kshrc.local, frozen files, mandatory-consult. |

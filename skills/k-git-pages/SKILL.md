---
name: k-git-pages
description: >
  GitHub Pages + Docsify — index.html (VS Code dark theme), _sidebar.md,
  .nojekyll setup, placeholder guide, and GitHub Pages activation steps.
  Use cases: project docs site, blog, article/tutorial site, knowledge base, portfolio.
  Load whenever creating a standalone Docsify/GitHub Pages site of any kind.
  For docs/ inside a project repo → see k-project/docs-site.md.
license: private
metadata:
  author: 
  version: "1.0.0"
allowed-tools: Bash(*), "*"
---

#  — GitHub Pages + Docsify

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **Related skills:** `k-git` (push, remotes) · `k-project` (init, naming)
> **Templates:** inspiration and baseline — adapt freely to project specifics; never follow blindly.
> **Concrete examples:** `$HOME/Work/techskills/` (live Docsify site), `$HOME/Work/Homelab/presentation/` — check via `k-qmd` or shell.
> **Live example — `envision-copilot-presentation`:**
> - Local: `$HOME/Labs/AI/Envision/envision-copilot-presentation`
> - GitHub: `https://github.com/<user>/envision-copilot-presentation`
> - GitHub: `https://github.com/<user>/envision-copilot-presentation`

## Stack

**Docsify** — client-side Markdown renderer, no build step.

```
my-site/
├── index.html        ← Docsify bootstrap (VS Code dark theme + search + sidebar)
├── _sidebar.md       ← Navigation panel
├── .nojekyll         ← MANDATORY — tells GitHub Pages not to run Jekyll
├── README.md         ← Site homepage content
├── CHANGELOG.md
├── TODO.md
├── Makefile          ← from k-git/assets/Makefile.git (push, status, log)
├── assets/           ← images, diagrams
└── AGENTS.md         ← project context for AI agents (repo root, NEVER committed, gitignored by name)
```

`.nojekyll` is critical: without it, Jekyll silently drops `_*` files (including `_sidebar.md`) → blank navigation panel.

## Templates

| File | Description |
|------|-------------|
| `assets/github-pages-index.html` | Docsify + VS Code dark theme, search, sidebar, inline code color fix |
| `assets/_sidebar.md` | Generic Docsify sidebar with `.nojekyll` reminder |

> **Template → gitlab URL unification (2026-08-15):** the techskills / 𝛱/TechSkills repo `templates/` files that pointed at these assets were **local symlinks**, now **unplugged**. External repos must reference these templates by their **GitHub URL** of the real `.agents` file, not a local symlink: `https://github.com/KamdemE/agents/blob/main/skills/k-git-pages/assets/<file>`. Source of truth stays in `.agents`.

### Placeholders in `index.html`

| Placeholder | Example |
|-------------|---------|
| `SITE_TITLE` | ` Ubuntu Live` |
| `SITE_NAME` | `🐧  Ubuntu Live` |
| `GITHUB_REPO_URL` | `https://github.com/kpihx/techskills` |
| `SEARCH_PLACEHOLDER` | `🔍 Search tutorials...` |

### Placeholders in `_sidebar.md`

| Placeholder | Replace with |
|-------------|-------------|
| `SITE_NAME` | Display name |
| `USERNAME/REPO` | GitHub/GitLab repo path |

## Setup Steps

1. Copy `assets/github-pages-index.html` → repo root as `index.html`
2. Copy `assets/_sidebar.md` → repo root as `_sidebar.md`
3. `touch .nojekyll` at repo root
4. Copy `k-git/assets/Makefile.git` → repo root as `Makefile`
5. Create `README.md` (site homepage), `CHANGELOG.md`, `TODO.md`
6. Copy `k-project/assets/AGENTS.md` → `AGENTS.md` at repo root (gitignored by name via `k-git`'s global excludes)
7. Push to GitHub
8. GitHub repo → **Settings → Pages → Source: Deploy from branch → `main` / root**
9. Wait ~1 min → live at `https://<username>.github.io/<repo>/`

## ⚠️ Link Rules in Docsify `.md` Files

Docsify intercepts **all relative links** in `.md` files and tries to fetch the target as a Markdown document — causing 404s or garbled output for non-MD files.

| File type | Correct link format | Wrong |
|-----------|--------------------|----|
| `.md` pages | relative: `[Guide](guide.md)` ✅ | — |
| Non-MD files (`.html`, `.yaml`, `.py`, `.json`, `.toml`, images) | **Absolute GitHub blob URL** ✅ | `[file](assets/file.yaml)` ❌ |

**Absolute GitHub blob URL format:**
```
https://github.com/USERNAME/REPO/blob/BRANCH/path/to/file.ext
```
Example from techskills:
```markdown
[`config.py`](https://github.com/kpihx/techskills/blob/master/assets/config.py)
```

> This rule applies to every `.md` in the Docsify site — tutorials, README, _sidebar references, etc.
> Images: use relative `![alt](assets/img.png)` — Docsify renders `<img>` tags differently from text links.

## Docsify Features Used

- **VS Code dark/light theme** (`docsify-darklight-theme`) — toggle button top-right
- **Search plugin** — full-text, cached 24h, configurable placeholder
- **PrismJS** — syntax highlighting for bash, yaml, ini (add more as needed)
- **`subMaxLevel: 2`** — auto-generates H2/H3 anchors in sidebar
- **`alias`** — all `_sidebar.md` in subdirs fallback to root

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-git-pages/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-git-pages/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.


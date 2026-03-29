# KπX — Project docs/ Site

> **Standalone docs site (blog, KB, tutos)?** → load `k-git-pages` directly. This file covers only the `docs/` subdirectory pattern for a project that also has source code.
> **Templates + Docsify setup + link rules** → `k-git-pages`.

---

## Pattern — `docs/` Subdirectory

Source code lives at repo root; docs live in `docs/`.

```
my-project/
├── src/
├── docs/
│   ├── index.html        ← copy from k-git-pages templates
│   ├── _sidebar.md       ← copy from k-git-pages templates
│   ├── README.md         ← docs homepage
│   └── .nojekyll         ← MANDATORY
├── Makefile              ← from k-project/templates/Makefile.uv or .npm-bun
├── README.md
├── CHANGELOG.md
├── TODO.md
└── .agents/
    └── AGENTS.md         ← NEVER committed
```

GitHub Pages: **Settings → Pages → Source: `main` / `docs`**

Setup: follow `k-git-pages` Setup Steps but copy files into `docs/` instead of repo root.

---

## Makefile Targets

Add to the project `Makefile`:

```makefile
push-docs:  ## Commit + push docs/ changes
	@git add docs/ && git commit -m "docs: update site" || true; \
	branch="$$(git branch --show-current)"; \
	for remote in $$(git remote); do git push "$$remote" "$$branch"; done
```

> `make push` already handles everything; `push-docs` is a focused shortcut when only docs changed.

---

## Checklist

- [ ] `docs/` created with `index.html`, `_sidebar.md`, `.nojekyll`
- [ ] Placeholders filled (see k-git-pages)
- [ ] GitHub Pages: **Settings → Pages → `main` / `docs`**
- [ ] `push-docs` target added to Makefile
- [ ] First push done

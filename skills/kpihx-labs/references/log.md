# kpihx-labs Operation Log

Append-only archive for durable skill history. One single `##` section — rows are stacked underneath it in chronological order, oldest first.

## Archived Changelog Rows

| Date | Agent | Action |
|------|-------|--------|
| [SUMMARY] | — | v2.2.0 and earlier |
| 2026-07-22 | [OPENCODE] | v2.0.0 — Rewritten as kernel top reference. Full kernel structure tree, project registry, knowledge base, OS refs governance. |
| 2026-07-22 | [OPENCODE] | v2.1.0 — Added OS-Specific References Governance section. Rules: refs/ are always OS-oriented (ubuntu.md, windows.md, debian.md, pve.md). WSL under windows.md. Main SKILL.md stays generic. |
| 2026-07-22 | [OPENCODE] | v2.2.0 — Added Workspace Conventions (XDG routing + Engineering Standards ported from k-workspace). |
| 2026-08-13 | [COLAB] | v2.4.0 — Reactivated k-ai skill and registered it in the kernel hierarchy tree. |
| 2026-08-14 | [COLAB] | v2.5.0 — **kernel tree cleanup**: removed `k-bw` from the generic top-skills list (bw-mcp/bw-admin purged 2026-08-14; secrets no longer injected via bw). |
| 2026-08-14 | [COLAB] | v2.6.0 — **Config Standard (JSONC) + assets registry**: documented JSONC as the KπX config standard (comments allowed; code projects use `config.py`/`config.ts`; secrets in `.env`). Added `## Config & Assets (JSONC)` section listing `assets/{infras_skills,services,links}.jsonc` + `libs/jsonc_lib.sh` + the update mandate (always update the JSONC asset when creating/changing a `.agents` service or symlink). |
| 2026-08-15 | [COLAB] | v2.7.0 — **Shared JSONC libs + lint/type config single source of truth**: `## Config & Assets (JSONC)` now documents the three JSONC helper twins `libs/jsonc_lib.{sh,py,js}` (Python/JS import from `libs/` — added 2026-08-15) + a note that `ruff.toml` (rule ignores + `[lint.per-file-ignores]` for `E402`) and `pyrightconfig.json` (`extraPaths = ["libs", "scripts/check_skills"]`) live at `.agents/` root as the single source of truth — never scattered inline. |
| 2026-08-15 | [COLAB] | v2.8.0 — **External repo references convention**: `## Config & Assets (JSONC)` now states that references to `.agents` files **from external repos** (techskills, 𝛱/TechSkills, Homelab, presentation, tutorials) use the **gitlab URL** of the real `.agents` file (`https://gitlab.com/kpihx/agents/-/blob/main/<path>`), **not a local template symlink**. `.agents` stays the single source of truth. |
| 2026-08-20 | [COLAB] | v2.8.1 — Updated the kernel hierarchy to the renamed `k-phones` Android infrastructure skill. |
| 2026-07-22 | [OPENCODE] | v2.3.0 — Added Infrastructure Directory Standard: every machine must have ~/.agents/ (kernel clone), ~/KpihX-Labs/ (work dir), symlink, and per-infra AGENTS.md. Current machine compliance table. |

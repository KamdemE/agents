# Skill Governance

> Rules for creating, editing, and maintaining  skills.

## Skills Are Never Deleted (MANDATORY)
🔴 **SKILLS ARE NEVER DELETED. NEVER.** A skill is a permanent knowledge asset. When the application/tool/service a skill is linked to is removed from the system (purged, retired, deactivated), the skill itself is **MOVED** (not deleted, not merged, not dropped) to `skills/deactivate/`. This is automatic: any purge of an app that has a dedicated `k-*` skill must also move that skill to `skills/deactivate/`. The only exception is an explicit  instruction. Moving a skill preserves its full content (SKILL.md + references/ + assets/ + scripts/), keeping it available for re-activation. This rule overrides any cleanup that would delete a skill.

## Post-Purge Verification (MANDATORY — plocate)
🔴 **AFTER ANY PURGE, ALWAYS RUN `plocate` — even when you believe everything is removed.** Never assume a purge is complete without verifying with `plocate` (search the filesystem index for the purged name/path, including `~`, `~/.local`, `~/.config`, `~/.cache`, `/opt`, `/usr/bin`, systemd units, `.desktop` files). This catches residual debris that `apt purge` / `npm uninstall` / `rm -rf` miss. Only when `plocate` returns no relevant hits is the purge considered complete. Log the `plocate` command + output in the issue/session trace.

## Full Debris Scan Methodology (MANDATORY — purge completeness)
🔴 **A purge is NOT complete by removing the package/binary alone.** The full purge scan must cover every location where a tool leaves config, caches, symlinks, or references. When purging any app/tool, walk this checklist in order (adapt to the tool):

| # | Location | What to check | Typical debris |
|---|----------|---------------|----------------|
| 1 | `~/.local/bin/` | stale binaries + **broken symlinks** (`ls -la`; `readlink -f` to find dangling targets) | `k-desktop-mcp.py`, `bw-admin`, `bw-mcp` |
| 2 | `~/.config/` | app config dirs of no-longer-installed apps | `BraveSoftware`, `Slack`, `Termius`, `Wave`, `Windsurf`, `zoom.conf`, `asciinema`, `viperx`… |
| 3 | `~/.local/share/` | app data dirs of no-longer-installed apps | `qalculate`, `totem`, `vlc`, `hyprland`, `devin`, `tirith`, `nemo`, `onedriver`… |
| 4 | `~/.cache/` | app caches of purged apps | `*zoom*`, `*signal*`, `*wine*`, `*asciinema*`… |
| 5 | `/opt/` | proprietary heavy-client dirs | `/opt/Signal`, `/opt/zoom` |
| 6 | `snap list` | GUI/headless snaps | `telegram-desktop`… |
| 7 | `/etc/apparmor.d/` | AppArmor profiles (root-owned) | `opt.bw-mcp.bin.bw-mcp`, `zoom`, `signal-desktop` |
| 8 | `apt sources` + `/usr/share/applications/*.desktop` | `*.sources` leftovers + stale launchers | `signal-desktop.sources`, `Zoom.desktop` |
| 9 | `systemd` (user+system) | unit files, timers, socket activators | `tg-homelab.service`, purged daemons |
| 10 | **Skills (`~/.agents/skills/`)** | any doc/registry/skill referencing the purged tool as active | `bw-mcp`/`bw-admin` in `k-bw`, `k-clis`, `k-google`, `k-cloudflare`, `k-final`, `kpihx`, `deactive/*` |

**Verification technique — how to confirm a config dir belongs to a dead app (never delete live-app config):**
```bash
# For each candidate config dir name D:
command -v D          # binary?  (careful: 'which' prints "D not found" to stdout — use command -v, returns empty when absent)
dpkg -l | grep -E "^ii\s+D"   # apt-installed?
snap list | grep -w D         # snap?
uv tool list | grep -w D      # uv tool?
npm ls -g --depth=0 | grep -w D  # npm global?
ls /usr/share/applications/*.desktop | grep -i D  # desktop launcher present?
# If ALL empty → config dir is debris → safe to remove (trash-safe rm).
```

**After the purge:** run `plocate <name>` again (stale index will show remaining hits — re-check REAL existence with `ls`/`command -v` before trusting the index) and verify no residual path resolves. Log full commands + output in `k-context/references/issues.md`.

> **Mutual reference (MANDATORY):** this Debris Scan Methodology is the **static rule** mirror of **`k-optim`** (the operational skill to READ FIRST on any "nettoyer / purge / clean / optimiser" request). `k-optim` → `### Debris Scan — Where & How to Dig` carries the same dir-by-dir table + confirm-debris-vs-live-app command. Update BOTH when the methodology changes — single source of truth across `rules/` and `skills/k-optim/`.

## Symlinks to Skills / Agents — Centralization + Registration (MANDATORY)
🔴 **RED RULE — any symlink pointing to a skill asset/script or tied to the agents kernel MUST ALWAYS be centralized via `$HOME/.agents`, and MUST be registered in `assets/links.jsonc`** so that BOTH `make set-links` (creates/recreates) and `make check-links` (verifies, joined into `make check`) cover it automatically. When you create a new `.agents` symlink:
1. keep the canonical file in `.agents/skills/<skill>/` (source of truth) — never a standalone copy,
2. add its `{source,target,skill,infras}` entry to `assets/links.jsonc` under its owning skill (that is the ONLY registration point),
3. run `make set-links` to create it and `make check-links` to verify it.
This JSONC registry is the single source of truth for `.agents`-owned symlinks; see `k-optim` → link/check-links methodology.

## Config Standard (JSONC) + Assets Update Mandate (MANDATORY)
🔴 ** config standard is JSONC** (JSON with `//` comments) for `.agents/` config assets and any non-code config (self-documenting, single source of truth). Code projects prefer plain `config.py` / `config.ts` (no import needed); secrets always in `.env` (never committed). See `k-project` → Config Standard and `<github-user>` → Config & Assets.
🔴 **Update mandate — whenever you create or change a `.agents` service or symlink, ALWAYS update the corresponding JSONC asset** so the checks stay accurate:
- `.agents` service → update `assets/services.jsonc` (direct list grouped by skill; each entry `infras:[...]` or `*` = new MANDATORY).
- `.agents` symlink → update `assets/links.jsonc` (direct list grouped by skill; each entry `{source,target,skill,infras:[...] or *}`, all sources in `$HOME/.agents/...`).
Shared JSONC helpers live in `libs/jsonc/jsonc_lib.sh` (strip_jsonc / jsonc_valid / load_jsonc / current_infra / infra_matches). Consumers: `scripts/services/{check-services,reload-services}.sh`, `scripts/links/{set-links,check-links}.sh`. Verify with `make check-services` / `make check-links` / `make check-tailscale`.

## Deactivation
When the linked application/tool/service is removed from the system, move the skill directory to `skills/deactivate/<skill>/`. Never delete it. Update `.skill-lock.json` accordingly. A deactivated skill stays fully loadable on explicit request.

## Before ANY skill edit
1. Map first: `tree -L 2 $HOME/.agents/skills/` · `rg -l '<keyword>' $HOME/.agents/skills/`
2. Read the domain's `SKILL.md` fully
3. Extend existing — never duplicate identity tables, path lists, or runbooks
4. Create only if nothing equivalent exists

| Rule | Detail |
|------|--------|
| Single owner | Identity/admin/PDF paths → `kpihx`. Browser → `k-browser`. Mail → `k-mail`. |
| No duplicates | Never recopy identity tables or path lists in a second skill |
| No desync | Same fact = one source file; others POINT (relative link or `$HOME/.agents/skills/...` path) |
| Location | New skill `k-<domain>/` under `$HOME/.agents/skills/` + entry in `.skill-lock.json` |
| After edit | Bump `metadata.version` + `## Changelog` in the touched skill; **propose** `make check` before commit and run it only after the user's explicit request or validation |

## Cross-References (MANDATORY)
🔴 **When editing a skill, MENTION the related skills instead of repeating the same information.** Every time you touch a skill, identify the other `k-*` skills that cover the same domain/tool/domain-adjacent knowledge and add a short pointer line to them (e.g. "See **`k-ai`** for the runtime registry", "MCP details → `k-ai/references/runtime-registry.md`"). Never duplicate an existing table, list, or fact that already lives in another skill — POINT to it. This keeps each skill compact and the kernel free of duplication.

## Skill Structure (MANDATORY)
Every `k-*` skill: `SKILL.md` at root (YAML frontmatter, `⚠️ WHEN EDITING...` reminder, `## Changelog` at bottom). Optional: `scripts/`, `references/`, `assets/`.

## Skill Size Limits (MANDATORY)
To keep the documentation clean, scannable, and maintainable, `SKILL.md` files must never exceed **300 lines**.
- When a `SKILL.md` file approaches or exceeds this limit, agents must proactively **propose** synthesizing the content, extracting detailed installation guides, command references, and troubleshooting steps into standalone markdown files under the `references/` subdirectory of that skill, and wait for the user's go-ahead before writing (exception: carte blanche/feu vert).
- **Harmonious Skill Compaction Rule:** When compacting a skill, agents must do so intelligently by identifying the least frequently or potentially used elements to move to references (preferring existing reference files if they fit, and only creating new ones if none fits). The main `SKILL.md` must retain a clear, coherent summary/reference of what was moved so the skill remains harmonious and readable.
- No information must be lost: the creation of these reference files is mandatory to preserve details.
- This limit is strictly enforced by the audit pipeline.
- **Exception — `k-context`:** this flat 300-line target does NOT apply to `k-context/SKILL.md`. `k-context` already has its own dedicated capacity-management mechanism (see `rules/k-context-hygiene.md`): `## Session Log` capped at 10 explicit rows, `## Changelog` capped at 2 explicit rows, both rolling overflow to `references/log.md` — while `## Active Projects` and `## Active TODOs` are allowed to grow (append-only, condensed into `[ARCHIVE]`/removed only per k-context's own rules, never by a blanket line-count cutoff). The audit pipeline explicitly skips the 300-line check for `k-context`.

## Changelog Rules (fresh fork — no history carried)
- `SKILL.md` files carry NO changelog section and no `references/log.md` exists. Do not recreate them.
- On every skill edit: bump `version:` (patch/minor) + set `updated:` to today. History lives in git, not in docs.

## Agent-Owned Runtime Memory
Each agent owns its `k-<agent>/SKILL.md`. When you learn a new runtime fact, workaround, or config rule — PROPOSE the update in the same workstream and wait for the user's go-ahead before writing (exception: carte blanche/feu vert). See `rules/tool-discipline.md` → `## Propose ≠ Act`.

## k-* Proactive Freshness (MANDATORY)
After using any `k-*` skill: confirm the owning `SKILL.md` still matches reality. If wrong/incomplete → propose the patch (operational text + version bump) and wait for go-ahead before writing.

## Insights Governance
Every skill domain maintains `references/insights.md`. Agents manage these files autonomously (add/update/restructure). If missing → create it immediately. After creating → mention it in SKILL.md.

## .skill-lock.json Sync
Skill added/removed/moved → update `$HOME/.agents/.skill-lock.json`.

## Agent Provenance
Tag edits with `[CLAUDE]`, `[GEMINI]`, `[OPENCODE]`, etc. Last writer wins.

# QMD Optimization

Use this note when QMD feels noisy, too large, too slow, or keeps indexing the wrong things.

## Source Of Truth

| Topic | Where to inspect |
|------|-------------------|
| Declarative collection scope | `$HOME/.config/qmd/index.yml` |
| Live collection inventory | `qmd collection list` |
| One collection details | `qmd collection show <name>` |
| Index health and size | `qmd status` |
| Files inside a collection | `qmd ls <collection>` |
| One indexed document | `qmd get qmd://<collection>/<path>` |
| Hook template | `$HOME/.agents/skills/k-qmd/references/post-commit-hook.sh` |
| Local runtime implementation | `$HOME/.npm-global/lib/node_modules/@tobilu/qmd/dist/` |

## Default Optimization Goal

Keep QMD **hot-only**:

- index compact human-readable docs and stable configs
- exclude raw chat/session histories by default
- avoid auto-embedding large volatile archives
- keep post-commit refresh cheap and non-blocking

## Fast Checks

```bash
qmd status
qmd collection list
$HOME/.agents/skills/k-qmd/scripts/check_collections.sh
qmd collection show agents
qmd ls gemini
qmd ls codex
```

Use these to answer:

- Is the index too large?
- Which collections are active?
- Are raw histories still indexed?
- Are default collections really hot-only?

## Noise Checklist

Inspect in this order:

1. `qmd collection list`
   - look for collections that should not exist anymore
   - verify excluded/archive collections are not part of default queries
2. `qmd ls <collection>`
   - look for giant `.json`, `.jsonl`, chat dumps, rollout transcripts
   - look for copied marketplace content or redundant generated files
3. `qmd get qmd://...`
   - confirm whether a suspicious file is useful searchable knowledge or just runtime noise
4. `$HOME/.config/qmd/index.yml`
   - narrow `pattern`
   - add `ignore`
   - prefer docs/config over raw machine logs

## Useful SQLite Checks

Read-only inspection:

```bash
sqlite3 $HOME/.cache/qmd/index.sqlite \
  "select collection, count(*) from documents where active=1 group by collection order by collection;"

sqlite3 $HOME/.cache/qmd/index.sqlite \
  "select d.collection, count(v.hash) from documents d left join content_vectors v on v.hash=d.hash where d.active=1 group by d.collection order by d.collection;"

sqlite3 $HOME/.cache/qmd/index.sqlite \
  "select name from store_collections order by name;"
```

Use them to answer:

- how many active docs remain per collection
- where vectors still accumulate
- whether old collections still linger in the DB even after config cleanup

## Cleanup Playbook

### 1. Narrow config first

Edit `$HOME/.config/qmd/index.yml` before touching the DB.

### 2. Re-sync collections

```bash
qmd update
```

### 3. Purge dead DB state

```bash
qmd cleanup
```

This removes:

- orphaned vectors
- inactive document records
- stale cache entries
- wasted DB pages via vacuum

### 4. Only embed what matters

```bash
qmd embed agents
qmd embed techskills
```

Do **not** run blanket `qmd embed` unless all active collections truly need fresh vectors.

## Post-Commit Policy

The bundled git hook template is intentionally conservative:

- default mode: `update-only`
- optional mode: `debounced`
- no unconditional background embedding
- if a repository name already matches its QMD collection name, `.git/hooks/post-commit` can be a direct symlink to `$HOME/.agents/skills/k-qmd/references/post-commit-hook.sh`

Reason:

- `update` is cheap and keeps paths fresh
- `embed` is the expensive step and should be explicit or heavily throttled

## Runtime Perf Notes

If `qmd embed` falls back to CPU:

- inspect the stderr for `node-llama-cpp` backend errors
- on this machine, Vulkan fallback happened because `glslc` was missing

Useful checks:

```bash
which glslc
qmd embed agents
```

If `glslc` is present and embeddings still look CPU-bound, inspect the local `node-llama-cpp` stderr rather than assuming QMD config drift.

Also distinguish two phases:

- during the first local Vulkan rebuild, `qmd embed` may still print a temporary `no GPU acceleration` warning while `node-llama-cpp` is rebuilding its native backend
- after the rebuild, trust `qmd status` for the real steady-state device report

## Action Log

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-31 | [OPENCODE] | QMD rebuilt after better-sqlite3 Node mismatch (NODE_MODULE_VERSION 137 vs 127). `npm install -g @tobilu/qmd@2.0.1 --force` fixed it. `qmd cleanup` purged 31 cached API responses + 474 orphaned embedding chunks, DB vacuumed. Index: 581 files, 3320 vectors, 135.7MB. GPU: Vulkan Intel Arc OK. |
| 2026-04-04 | [CODEX] | Documented the temporary false-negative GPU warning during the first `qmd embed` Vulkan rebuild; steady-state device truth should be checked with `qmd status` |
| 2026-04-04 | [CODEX] | Confirmed `glslc` availability (`/usr/bin/glslc`) and re-ran `qmd embed agents`; Vulkan toolchain blocker is cleared and the embed path no longer fails on missing shader compiler |
| 2026-04-04 | [CODEX] | Reworked the shared `post-commit` hook for repo-name-derived collections and pointed `$HOME/Work/techskills/.git/hooks/post-commit` plus `$HOME/Work/Homelab/presentation/.git/hooks/post-commit` back to the shared template via symlink |
| 2026-04-04 | [CODEX] | Switched QMD to hot-only indexing: raw `codex`, `gemini`, and `k-ai` histories removed from `$HOME/.config/qmd/index.yml`; index shrank from ~1.4GB to ~1003.5MB; active docs 536→270; vectors 115625→640 |
| 2026-04-04 | [CODEX] | Purged stale archive vectors and inactive ghost documents directly from `$HOME/.cache/qmd/index.sqlite`, then ran `qmd cleanup` to vacuum the DB |

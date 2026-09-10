# Plugin Ecosystem Watch

Research log + installed-state tracker for third-party OpenCode plugins evaluated
and/or adopted beyond the sovereign hooks and auth plugins documented in
`references/plugins-architecture.md`. Origin: 2026-08-27 web research pass
(KπX request: "suggère-moi ce que je pourrais utiliser comme plugin OpenCode...
top 5... analyse et présente"), followed by a live install + debug session the
same day.

## Installed & active (`assets/opencode.jsonc` → `"plugin"`)

| Plugin | npm package | Purpose | Setup performed | Daily usage |
|---|---|---|---|---|
| **opencode-tasks** | `opencode-tasks` (jdormit, npm `0.5.1`) | Cron scheduler daemon — recurring tasks as markdown files + one-off `schedule_task` tool + in-session `/loop` | Global install via **`npm install -g opencode-tasks`** (see Known Issues — `bunx`/`bun add -g` fail on this package), then `opencode-tasks --install` (systemd `--user` timer, 60s tick) + `--install-skill` (skill + `/loop*` slash commands). Plugin string added to array. | Write `~/.config/opencode/tasks/<name>.md` with cron frontmatter (`schedule`, `cwd`, `agent`, `permission` — never `"ask"`, only `"allow"`/`"deny"`, non-interactive tasks fail closed on `ask`). Check status: `bun "$(npm root -g)/opencode-tasks/dist/cli.js" --status`. In-session: `/loop 5m <prompt>`, `/loop-list`, `/loop-stop`. |
| **opencode-models-discovery** | `opencode-models-discovery` (community, npm `latest`) | Auto-discovery for generic `openai-compatible` providers — queries `GET /v1/models` at startup, injects `id`/`name`/`context_length` | Enable per-provider via `"modelsDiscovery": { "enabled": true }`. For pathy Zen/Go URLs set `endpoint` to the full origin-relative path (e.g. `/zen/go/v1/models`) — **not** a localhost reverse proxy. Optional `modelInfoFormat: "models.dev"`. | `openvino` + **`opencode-labs`** (Go 2nd account) auto-discover without hardcoded model lists. |
| **opencode-npm-from-models-dev** | local `file://…/opencode-npm-from-models-dev.js` | After discovery, copies per-model `provider.npm` from models.dev when `options.enrichNpmFromModelsDev: true` (muse/luna → `@ai-sdk/openai` / Responses) | Loaded **immediately after** `opencode-models-discovery@latest` in `assets/opencode.jsonc`. | Required for `opencode-labs` so Responses models work without listing them. |
| **opencode-cursor** | `@stablekernel/opencode-cursor` (stablekernel fork of WayneSimpson, npm `0.9.0`) | Cursor subscription as native `cursor/*` provider via the **official** `@cursor/sdk` — live account catalog + local agent runtime + `cursor_delegate`/`cursor_cloud_agent` tools | Plugin string `"@stablekernel/opencode-cursor@latest"` in `assets/opencode.jsonc` + minimal `"provider": { "cursor": { "npm", "name" } }` (NO explicit `options.apiKey` — see Known Incident below). Auth: `opencode auth login` → Cursor (stored credential first, `CURSOR_API_KEY` env fallback). Requires opencode 1.17+ + Node.js 22.13+. | `opencode models \| grep cursor` → 39 models on Pro (composer-2.5, opus/sonnet, gpt-5.x, grok, gemini-flash, kimi, `default` router). Daily driver `cursor/composer-2.5` (Cursor Models pool). **Known incident 2026-09-09**: explicit `"options": { "apiKey": "{env:CURSOR_API_KEY}" }` killed the stored-credential fallback → `Cursor API key missing` in TUI despite valid login while `models` still listed the catalog; fixed by deleting the override. Quota: Cursor dashboard usage/spending (no IDE `cursor quota`). Full recipe in `references/providers.md` → Cursor. |
| **opencode-agy-auth** | `@anthonyhaussman/opencode-agy-auth` (npm `1.1.27`, `@latest`) | Google One / AI Pro via local **`agy` CLI** — OAuth provider `google-agy`, dynamic Gemini+Claude+GPT-OSS catalog, `/agyquota` + `/agyquotasummary` | Replaced `opencode-antigravity-auth@latest` (2026-09-09). Plugin string + `"provider": { "google-agy": { "npm": "@ai-sdk/google", "name": "Google AGY" } }` (**npm must stay `@ai-sdk/google`**, never the auth package). Install CLI: `curl -fsSL https://antigravity.google/cli/install.sh \| bash`. Auth: `opencode auth login --provider google-agy` (OAuth Antigravity CLI — not API key). | Live: Claude Opus works while Gemini weekly bucket = 0 until reset. Quotas: `agy -p '/quota' --output-format text --print-timeout 30s` or TUI `/agyquotasummary`. Two families: Gemini vs Claude+GPT (weekly + 5h). Full recipe → `references/providers.md` → Google AGY. |

## Purged / replaced — OpenCode Labs path proxy

### opencode-go-proxy (`scripts/opencode-go-proxy.js` + systemd `:4999`) — purged 2026-09-09

**What it was**: reverse proxy so `modelsDiscovery` could hit `/v1/models` while rewriting to `/zen/go/v1/*` for the 2nd Go account (`opencode-go-2`).

**Why purged**: imperfect middleware (TLS hang-ups, Responses/muse server errors). Replaced by `opencode-labs` + `modelsDiscovery.endpoint: "/zen/go/v1/models"` + `opencode-npm-from-models-dev.js`. Service/link registry entries removed; bak in `/tmp/opencode-go-proxy.*`.

## Purged / replaced — Google auth bridge

### opencode-antigravity-auth (`opencode-antigravity-auth`, NoeFabris / dopesalmon) — replaced 2026-09-09

**What it was**: Cloud Code / Code Assist OAuth into OpenCode as `google/*` (Gemini CLI-family IDs). Thin catalog (Flash / 3.1 Pro-ish only — no Claude/GPT-OSS in picker). Errors like `403 SUBSCRIPTION_REQUIRED` `#3501` looked permanent; live diagnosis showed Gemini **weekly quota exhausted** while Claude still available on the AGY path.

**Why replaced**: KπX wants Google One subscription models in OpenCode the Cursor way (real catalog + readable quotas). Swap → `@anthonyhaussman/opencode-agy-auth` + local `agy` CLI. Removed from `assets/opencode.jsonc` → `"plugin"`; Explore/help defaults moved off dead `google/gemini-3-*` pins to `opencode-go` / `cursor` fallbacks until Gemini weekly resets.

**Anti-repeat**: do not reinstall `opencode-antigravity-auth` / `opencode-gemini-auth` / forks that only hit Code Assist consumer OAuth without checking `agy -p '/quota'` first. Official `google-antigravity` Python SDK ≠ subscription OAuth (API key / Vertex only).

## Purged (same day, superseded by sovereign replacement)

### opencode-notifications (`opencode-notifications`, pedrordgs, npm `1.0.0`) — removed 2026-08-27 (KπX directive: "desinstalle car j'aime pas")

**What it was**: desktop notification (`notify-send`) fired ONLY when the terminal was NOT focused — dual check (X11 window focus + active tmux pane, via its own `X11FocusDetector`/`TmuxFocusDetector`/`AlwaysNotifyDetector` chain read from `dist/index.js`). Subscribed to `session.idle` (complete), `session.error`, `permission.updated`/`permission.asked`, `question.asked` events + the `permission.ask` hook. Config: optional `~/.config/opencode/opencode-notifications.json`.

**Why purged**: explicit KπX directive — simple "I don't like it" removal, replaced same-day by the sovereign `opencode-notify` plugin (see `scripts/plugins/opencode-notify/`) which fires unconditionally (no focus-detection gate — KπX wanted a dead-simple ALWAYS-notify signal) and adds Telegram delivery (via the shared `libs/notif/notifier.sh`) + device/session-info-rich notification bodies, neither of which the third-party plugin had.

**Cleanup performed**: removed `"opencode-notifications"` from `assets/opencode.jsonc` → `"plugin"` array; removed `~/.cache/opencode/packages/opencode-notifications@latest/` (cached npm package); removed the orphan `~/.config/opencode/plugin/notificator.jsonc` (a DIFFERENT, unrelated dead config file found during the same cleanup pass — wrong filename for this plugin's actual config path, wrong directory `plugin/` singular which is not any OpenCode discovery path, zero references anywhere in the kernel via `grep`/`plocate` — a genuine orphan from an even earlier, unidentified experiment, not this plugin's own config). Post-purge `plocate -i notificator` clean.

**Replacement — `opencode-notify` (sovereign, `scripts/plugins/opencode-notify/`)**: NOT a hook (read-only/observational plugin, see `scripts/plugins/AGENTS.md` → "Hooks vs Plugins"). `opencode-notify.js` subscribes to `event`/`session.idle` (finished), `event`/`session.error` (error), and the `"permission.ask"` hook callback (waiting for approval) — verified against the currently installed `@opencode-ai/sdk`'s `types.gen.d.ts`: `question.asked`/`permission.asked` (used by the old third-party plugin) do NOT exist as event types in this SDK version, only `permission.updated`/`permission.replied`/the `"permission.ask"` hook callback exist, so the replacement uses the real, currently-valid trigger set. Delivers via the sibling `opencode-notify.sh`, which sources `$HOME/.agents/libs/notif/notifier.sh` — never a private re-implementation of `notify-send`/Telegram logic. Every notification includes device hostname (`libs/device-info.js`, extracted out of `startup-context.js` to stop duplicating that logic), resolved agent name (`libs/agent-scope.js`), and session title + project directory (`client.session.get`).

**Telegram delivery — STRICTLY the dedicated bot, no fallback (fixed 2026-08-27, real bug found live)**: `opencode-notify.sh` first called `notify_mixed`, which resolves its Telegram token via the shared `notify_tg_token()` — but that function's "explicit override" branch only short-circuits when `NOTIFY_TG_TOKEN` is **non-empty**; setting `NOTIFY_TG_TOKEN="${TELEGRAM_OPENCODE_TOKEN:-}"` while `TELEGRAM_OPENCODE_TOKEN` was still unset (bot didn't exist yet) left it empty, so `notify_tg_token()` silently fell through to its own generic chain (`TELEGRAM_PVE_TOKEN`→`UBUNTU_TOKEN`→...) and picked up `TELEGRAM_UBUNTU_TOKEN` — a live smoke test sent a real message through the Ubuntu bot instead of staying silent, exactly the "dedicated bot" guarantee KπX asked for, twice. **Fix**: `opencode-notify.sh` no longer calls `notify_mixed`/relies on the shared token-resolution chain at all — it calls `notify_system` unconditionally, then ONLY calls `notify_telegram` (with `NOTIFY_TG_TOKEN` forced to the exact `TELEGRAM_OPENCODE_TOKEN` value) inside an explicit `[ -n "${TELEGRAM_OPENCODE_TOKEN:-}" ]` guard. If the dedicated token is unset, Telegram delivery is skipped entirely (system notify still fires) — it can now NEVER borrow another skill's bot identity, verified live (single system-only log line, no Telegram attempt, with the token still unset).

## Purged

### Kagan (`@kagan-sh/kagan`) — removed 2026-08-27 (KπX directive: "purge le plugin kagan")

**What it was**: Kanban/Jira-style board for agent tasks (Python CLI via `uv tool install kagan`, PyPI `kagan==0.18.0`) — each card ran in an isolated **git worktree** + session; `REVIEW → DONE` required human approval (non-bypassable gate). `kagan` (TUI) or `kagan web` (browser board) → `n` new card → review diff at `REVIEW` column → approve/send-back. Confirmed working live by KπX on 2026-08-27, same day it was installed, right after the default-model breakage fix documented below.

**Reason for purge**: explicit KπX directive, no root-cause bug reported (unlike Oh My OpenAgent below) — simple "don't want this one" removal, same session it was installed in.

**Debris found and cleaned (worth flagging for any future re-adoption)**: while auditing state for the purge, discovered Kagan had `git init`'d a **rogue git repository directly at `$HOME` (`/home/kpihx/.git`)**, birth-timestamped 2026-08-27 01:42:50 (same minute as the plugin install), with one empty `chore: initial commit` (no files tracked, no secrets committed — verified via `git ls-tree -r --name-only HEAD` returning nothing) and a linked worktree at `~/.local/state/kagan/worktrees/f95233e41847499b` (Kagan's own card-isolation worktree). Root cause: Kagan was invoked at least once with `$HOME` itself as the working directory / "project", and since `$HOME` was not already a git repo, Kagan silently `git init`'d it to create its worktree-isolated card. This is a real footgun for anyone running Kagan from a non-project directory — it will happily turn `$HOME` into a git repo with no `.gitignore`, which could pick up untracked secrets on a later unaware `git add -A`. Cleanup performed: `git worktree remove --force` the Kagan worktree, then removed `/home/kpihx/.git` entirely via the trash-safe `rm` wrapper. Also removed (all via trash-safe `rm`): `~/.local/bin/{kagan,kg}` (via `uv tool uninstall kagan`), `~/.local/share/kagan/` (kagan.db + wal/shm), `~/.cache/kagan/` (update-check.json), `~/.local/state/kagan/` (log + worktrees), `~/.cache/opencode/packages/@kagan-sh/` (cached plugin package). Removed `"@kagan-sh/kagan"` from `assets/opencode.jsonc` → `"plugin"` array. Post-purge verification: `plocate -i kagan` + targeted `find ~ -iname "*kagan*"` both clean, `which kagan kg` both empty, `git -C /home/kpihx worktree list`/`ls -la /home/kpihx/.git` both confirm no residue.

**If re-adopting later**: always launch `kagan`/`kagan web` from inside an actual project's git repo, never from `$HOME` or another non-project directory — Kagan does not warn before `git init`-ing its target.

## Tried, found a real bug, purged — kept here for flexibility

### Oh My OpenAgent (`oh-my-openagent`, npm `4.19.4`)

**What it brings**: multi-agent orchestration harness — Sisyphus (autonomous
"ultraworker"), Prometheus (interview-driven planner), Atlas (plan executor),
Hephaestus (deep-agent solo mode), support subagents Oracle/Librarian/**Explore**/
Metis/Momus/Sisyphus-Junior, background parallel agents, category-based
model routing (auto-picks cheap vs strong model per task type), `ultrawork`/
`goal` autonomous continuation, own web dashboard (Hono/Express), own TUI
overlay (opentui). Genuine differentiators vs the rest of the KπX stack:
Prometheus↔Atlas interactive planning workflow, and automatic model routing.

**Why it was purged — confirmed root cause, not a guess**: OMO ships its own
subagent literally named `explore`. Empirical A/B test on 2026-08-27:

```
WITH oh-my-openagent enabled  → `opencode agent list` shows NO "Explore (primary)"
                                  anywhere — only "explore (subagent)" (OMO's own).
                                  `opencode run --agent Explore` → "agent not found".
WITHOUT oh-my-openagent        → "Explore (primary)" reappears immediately.
                                  `opencode run --agent Explore "OK"` → works,
                                  `Explore · google/gemini-3-flash-preview` → "OK 🎯".
```

KπX's primary agent `Explore` (capital, `mode: "primary"`, defined in
`opencode.jsonc` since long before this session) gets **silently shadowed and
dropped from the registry** by OMO's bundled subagent of the same name
(different case). Most likely mechanism (reasoned from the observed config-then-
plugin-init boot order in `--print-logs --log-level DEBUG` output, NOT
confirmed by reading OpenCode's source): the agent registry keys are
normalized case-insensitively (so `--agent explore`/`--agent Explore` resolve
the same entry from the CLI's point of view), and since plugins register their
agents at `init` time — after config parsing — OMO's `explore` overwrites
KπX's `Explore` on that shared key, last-write-wins.

**Purge performed 2026-08-27**: removed from `assets/opencode.jsonc` plugin
array; cleaned all state it created even without ever running its setup
wizard — `~/.cache/opencode/packages/oh-my-openagent@latest/`, `~/.omo/`
(codegraph, lsp-daemon, runtime), `~/KpihX-Labs/.omo/` (run-continuation),
`~/.cache/oh-my-opencode/` (connected-providers.json, model-capabilities.json
~1.3 MB, provider-models.json), `~/.local/share/oh-my-opencode/`
(posthog-activity.json) — all via the trash-safe `rm` wrapper, verified gone.

**Kept here deliberately, per KπX (2026-08-27): "je préfère avoir de la
flexibilité, laisse quand même sa mention dans le skill au cas où"** — i.e.
do NOT treat this as a closed case. Revisit if/when either becomes true:
1. Upstream `oh-my-openagent` adds a way to disable/rename its own `explore`
   subagent (check their changelog/issues before retrying), OR
2. KπX decides the Prometheus↔Atlas planning workflow or auto model-routing
   is valuable enough to justify renaming KπX's own `Explore` agent kernel-wide
   instead (large blast radius — referenced across AGENTS.md, rules, hooks,
   prompts, `k-context` — not undertaken lightly).

Before any retry: re-run the exact A/B test above (`opencode agent list` with/
without the plugin) as the acceptance check — do not assume a newer OMO
version fixed it without proof.

## Known Issues

- **`opencode-tasks` bunx/bun-global install bug (found 2026-08-27):** `bunx opencode-tasks --install` and `bun add -g opencode-tasks` + `opencode-tasks --install` both fail with `Fatal error: Cannot stage daemon: required directory "node_modules" not found in .../node_modules/opencode-tasks`. Root cause: the package declares real dependencies (`cron-parser`, `gray-matter`) but bun's global/bunx install layout hoists them to a flat top-level `node_modules/` rather than nesting them under `<pkg>/node_modules/` (npm's layout) — the installer's `installer.ts` hardcodes the npm-style nested path. **Workaround**: `npm install -g opencode-tasks` (creates the nested layout npm-style), then run the maintenance CLI via `bun "$(npm root -g)/opencode-tasks/dist/cli.js" --install` / `--install-skill` / `--status`. The OpenCode-loaded plugin itself (`dist/plugin.js`, installed independently by OpenCode's own Bun plugin loader from the npm registry string in `opencode.jsonc`) is unaffected by this bug — only the standalone maintenance CLI needs the npm-installed copy to stage the systemd daemon.

## Default model breakage — found and fixed 2026-08-27

Root cause of the original "Kagan handshake failed / OpenCode service failure"
report — **unrelated to any plugin**, found via `opencode run --print-logs
--log-level DEBUG` (never used before this session):

```
ProviderModelNotFoundError: Model not found: opencode/x-preview-f-free.
Did you mean: hy3-free, mimo-v2.5-free, muse-spark-1.2-contributor-free?
```

`opencode/x-preview-f-free` (the global `model`/`small_model`, and the
per-agent `model` on `Auto` and `Explore`) had rotated out of the
`opencode zen` free-tier catalog. Any session without an explicit
already-resolved model (Kagan-spawned sessions, `opencode run` with no
`--model`) crashed at first prompt. Sessions with an explicit model (like a
normal interactive `Colab`/`claude-sonnet-5` session) never hit this path,
which is why it went unnoticed until Kagan started spawning sessions.

**Fix applied** (KπX directive — "partout sauf Lite le default model soit
mimo 2.5 de opencode zen... mais pour Explore le défaut est le gemini 3 flash
preview de google"):

| Scope | Before | After |
|---|---|---|
| Global `model`/`small_model` (inherited by `Colab`, `Agent`, `Auto`) | `opencode/x-preview-f-free` | `opencode/mimo-v2.5-free` |
| Agent `Auto` | `opencode/x-preview-f-free` | `opencode/mimo-v2.5-free` |
| Agent `Explore` | `opencode/x-preview-f-free` | `google/gemini-3-flash-preview` |
| Agent `Lite` | `ollama/phi4-mini` | unchanged |

Verified live: `opencode run "OK"` → `providerID=opencode modelID=mimo-v2.5-free`
→ response received. `opencode run --agent Explore "OK"` → `Explore ·
gemini-3-flash-preview` → response received. KπX confirmed live that Kagan's
kanban board works after this fix + the OMO purge.

**Operational risk to remember**: `opencode zen` free-tier model IDs rotate
periodically (this is the second `-free` slot name change observed). If a
similar `ProviderModelNotFoundError` reappears, check
`https://opencode.ai/zen/go/v1/models` for the current catalog and cross-check
the exact `-free` suffix naming via a throwaway `opencode run` — the runtime
error's fuzzy "Did you mean" suggestion is the most authoritative source
(reflects the exact live-valid ID set), more reliable than the static catalog
dump alone.

## Hook scoping technique for `opencode run` — discovered/documented 2026-08-27

KπX asked whether hooks like `startup-context.js` can be made to skip firing
in `opencode run` (CLI) invocations. Checked the `@opencode-ai/plugin` type
definitions (`Hooks` interface, `experimental.chat.messages.transform` input
is a literal empty `{}`) — **no invocation-mode field (run/TUI/web) is exposed
to any hook by the plugin API.** Two existing mechanisms solve this without
any code change:

1. **`opencode run --pure "..."`** — built-in CLI flag, disables ALL plugins
   (npm + every KπX sovereign hook) for that single invocation. Verified live:
   no `<startup-context>` injected, default model still resolved correctly.
2. **`opencode run --agent <name-not-in-TARGET_AGENTS> "..."`** — scoped skip.
   `startup-context.js`'s `TARGET_AGENTS = ["Colab", "Agent", "Auto", "Build",
   "Plan"]` already excludes `Lite` and `Explore`. Verified live:
   `--agent Lite` skipped the `<startup-context>` dump while other plugins
   (auth, Kagan, opencode-tasks, opencode-notifications) stayed active.

No reliable way exists to make ONE specific hook skip `run` mode while keeping
it active in TUI/web (no signal to key off), short of an unverified
`process.env` probe (not attempted — would need a disposable test hook to
confirm whether OpenCode sets any CLI-entrypoint-specific env var).

## Auto-injection map for `opencode run` — researched 2026-08-27

Captured from `opencode run --print-logs --log-level DEBUG` boot sequence
(direct log evidence, not inference):

| Element | Auto-injected in `run`? | Mechanism |
|---|---|---|
| Config (`opencode.jsonc`/`.json`) | Always | 6 candidate paths merged: `~/.config/opencode/{config.json,opencode.json,opencode.jsonc}` **and** the legacy `~/.opencode/{opencode.json,opencode.jsonc}` (distinct from `~/.config/opencode/`, previously undocumented in this skill) |
| `AGENTS.md` | Always, even with `--pure` | Native OpenCode instructions mechanism (like CLAUDE.md), not a plugin — loads the kernel root (`~/.agents/AGENTS.md` via symlink) plus the run directory's local `AGENTS.md` |
| Skills catalog (`<available_skills>`) | Always | Native indexing at `init` — name+description+path only, full content loads on-demand via the `skill` tool. Boot log showed ~85 raw scans (KπX's `~/.agents` symlink ↔ `~/KpihX-Labs/.agents` real path both scanned) deduplicated down to `init count=71` unique skills — cosmetic `WARN "duplicate skill name"` spam, not a functional bug, left unfixed (out of scope for this pass) |
| `<startup-context>` (k-context dump + device + tmux) | Conditional — KπX's own hook, not native | `startup-context.js`, gated by `TARGET_AGENTS` — see scoping technique above |

## Evaluated but not installed (honorable mentions / future candidates)

| Plugin | Category | Why not installed |
|---|---|---|
| `opencode-mem` | Local vector memory (Turso/libSQL, ONNX embeddings) | Sovereign/local-first fit confirmed, not requested for install |
| `kenryu42/cc-safety-net` | Destructive-command guard (static parser, zero LLM — see mechanism below) | Explicitly supports Hermes Agent + OpenClaw by name; not requested for install |
| `@devtheops/opencode-plugin-otel` | Self-hosted OTel telemetry (cost/tokens/tool duration) | Needs an OTLP collector target decision (candidate: Grafana Alloy on `kpihx-pve-debian`) before wiring |
| `opencode-worktree` (kdcokenny) | Zero-friction git worktrees, tmux-aware | Not requested for install |
| Antigravity Multi-Auth fork (`NoeFabris`/`theblazehen`) | Multi-Google-account quota rotation | **Superseded 2026-09-09** by `@anthonyhaussman/opencode-agy-auth` + `agy` CLI; do not reinstall old Cloud Code OAuth forks without KπX feu vert |
| Beads (`bd`, gastownhall) | Dependency-aware issue graph for agents | Standalone CLI, not an OpenCode plugin — evaluated as a Kanban-dashboard backend, not adopted |
| `opencode-dynamic-context-pruning` | Token/context pruning | Cache-hit trade-off documented by maintainers (~65% vs ~95%); revisit only if telemetry shows real cost pressure |

### How CC Safety Net actually works (no LLM — reference answer, came up mid-research)

- **Pure static analysis, zero LLM/agent call.** A custom-built POSIX/PowerShell parser (not a third-party grammar, not regex-first) tokenizes the command once into structural facts reused by every pipeline stage.
- **Ordered pipeline** (12 fixed stages): bounded input extraction → single parse → parser/structural budget checks → Git-metadata + policy-file protection → sensitive-path (secrets) check → destructive-command analysis.
- **"Intent" is hand-authored classification, not free text and not inferred** — baked into per-tool analyzers (`analyzeGit`, `analyzeRm`, `analyzeFind`, `analyzeXargs`, `analyzeParallel`) that understand each tool's real option grammar (e.g. `git checkout -b` = branch creation = allow; `git checkout -- file` = discard = block). Wrapper nesting (`bash -c`, interpreter one-liners, up to 10 levels) and flag reordering cannot bypass it.
- **Fallback only on unparseable input**: regex scan on raw text (`dangerousInText`) — last resort only.
- **Runs as**: stdin subprocess hook (Claude Code, Codex, Gemini CLI, Cursor, Copilot CLI, Kimi Code) or in-process plugin (**OpenCode**, Amp Code, **OpenClaw**, Pi). **Hermes Agent** shells out to the same stdin hook (`npx cc-safety-net hook --hermes-agent`, 30s timeout), fails closed if that subprocess can't complete.
- One runtime dependency (`zod`, config validation only). Zero network calls during analysis.

## Registered symlinks / services

None of the currently-active installs (opencode-tasks, opencode-notifications; Kagan purged 2026-08-27, see above) required a new `.agents`-governed symlink or systemd unit registration in `assets/links.jsonc` / `assets/services.jsonc` — all state they created (`~/.local/share/opencode-tasks/`, `~/.config/systemd/user/opencode-tasks.{service,timer}`, `~/.config/opencode/skills/scheduled-tasks/`, `~/.config/opencode/commands/loop*.md`, `~/.npm-global/`) is plugin-owned, self-managed, and regenerable by each plugin's own installer/updater — same governance class as `~/.cache/opencode/node_modules/` (external tool cache, not a first-party kernel asset).

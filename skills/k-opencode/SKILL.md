---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
license: private
metadata:
  version: 1.4.0
  author: KpihX
  scope: agent-runtime
  target-agent: opencode
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenCode CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Binary:** `$HOME/.opencode/bin/opencode`
- **Global config dir:** `$HOME/.config/opencode/`
- **Config file:** `$HOME/.config/opencode/opencode.jsonc`
- **Auth store:** `$HOME/.local/share/opencode/auth.json`
- **Global kernel symlinks (KπX):**
  - `$HOME/.config/opencode/AGENTS.md` → `$HOME/.agents/AGENTS.md`
  - `$HOME/.config/opencode/skills` → `$HOME/.agents/skills`
- **PATH source of truth:** `$HOME/.kshrc` (`export PATH="$HOME/.opencode/bin:$PATH"`)

## Source Of Truth

| File | Role |
|------|------|
| `$HOME/.config/opencode/opencode.jsonc` | OpenCode runtime config — model, permissions, MCPs |
| `$HOME/.config/opencode/AGENTS.md` | Global instruction kernel (symlink target: `$HOME/.agents/AGENTS.md`) |
| `$HOME/.config/opencode/skills/` | Skill discovery path (symlink target: `$HOME/.agents/skills/`) |
| `$HOME/.local/share/opencode/auth.json` | Provider login credentials |

## MCP Config Format (OpenCode — JSONC)

OpenCode MCP servers are configured under the top-level `mcp` key in `opencode.jsonc`.

Local (stdio-equivalent) server:

```json
{
  "mcp": {
    "mail_fallback": {
      "type": "local",
      "command": ["zsh", "-l", "-c", "/home/kpihx/.local/bin/mail-mcp serve"],
      "enabled": true,
      "timeout": 60000
    }
  }
}
```

Remote HTTP server:

```json
{
  "mcp": {
    "exa": {
      "type": "remote",
      "url": "https://mcp.exa.ai/mcp",
      "oauth": false,
      "enabled": true
    }
  }
}
```

Remote bearer token via env variable:

```json
{
  "mcp": {
    "n8n_homelab": {
      "type": "remote",
      "url": "https://n8n.kpihx-labs.com/mcp",
      "headers": {
        "Authorization": "Bearer {env:N8N_HOMELAB_API_KEY}"
      },
      "enabled": false
    }
  }
}
```

## Verification Commands

```bash
zsh -l -c 'which opencode && opencode --version'
opencode debug config
opencode mcp list
opencode providers list
opencode models
```

## Operational Rules (KπX)

- Keep OpenCode runtime config centralized in `$HOME/.config/opencode/opencode.jsonc`; avoid per-project overrides unless explicitly requested.
- Prefer `zsh -l -c` wrappers for local MCP servers that need secret-bearing login-shell context.
- Do not hardcode secrets in `opencode.jsonc`; use `{env:VAR_NAME}` placeholders.
- Keep AGENTS/skills linked to `$HOME/.agents/` so OpenCode shares the same sovereign kernel as Codex, Vibe, Copilot, and Zed.

## Permission System (2026-05-29 — Confiance Totale)

OpenCode uses a 3-tier hierarchy: **Agent defaults → User config → Session runtime**. Rules evaluated by `findLast` — last matching pattern wins.

### Architecture

- **Global default** (`permission.bash`): `"ask"` — toute commande non listée demande approval
- **Agent `build`**: ~100 `allow` patterns + 35 explicit `ask` patterns — pas de catch-all, le global gère les oublis
- **Agent `plan`**: `edit: deny`, `bash: deny` sauf `git diff*`/`log*`/`rg *` — read-only strict
- **No `"*": "ask"` in agent** — retiré car redondant avec le global, et les patterns `ask` sont explicites pour l'auditabilité

### Organisation des patterns

| Zone | Niveau | Nb patterns | Exemples |
|------|--------|-------------|----------|
| 🟢 **Zone 1** | Read-only purs | 65+ | `echo`, `cat`, `head`, `grep`, `jq`, `find`, `stat`, `man`, `md5sum`, `shasum`, `tac`, `users`, `who`, `lscpu` |
| 🟡 **Zone 2** | Faible risque | 22 | `curl`, `wget`, `ping`, `dig`, `traceroute`, `ss`, `tmux`, `watch` |
| 🟠 **Zone 3** | Confiance | 50+ | `awk`, `git`, `docker`, `python3`, `ssh`, `rsync`, `make`, `tar`, `zip`, `ip`, `npm`, `node`, `tee` |
| 🔴 **Explicit Ask** | Dangereux | 35 | `rm`, `rmdir`, `shred`, `sed`, `pkill`, `sudo`, `chmod`, `dd`, `fdisk`, `systemctl`, `apt`, `passwd` |

### `external_directory` — 9 paths allow

`~/.agents/**`, `~/.config/opencode/**`, `/tmp/**`, `~/Downloads/**`, `~/Pictures/**`, `~/Gdrive_X/**`, `~/Gdrive/**`, `~/KpihX-Labs/**`, `~/Work/**`

### Utilisation

- Les commandes non listées tombent sur `"bash": "ask"` global — elles popent en approval
- Pour ajouter un pattern : l'insérer dans la bonne zone (allow avant ask) dans `opencode.jsonc`
- `findLast` gagnant : le dernier pattern qui match l'emporte
- Source de vérité : `$HOME/.config/opencode/opencode.jsonc`

## Neovim Integration

OpenCode integrates with Neovim via `nickjvandyke/opencode.nvim` (the active fork).

| Item | Value |
|------|-------|
| Plugin | `nickjvandyke/opencode.nvim` (Lazy-loaded) |
| Config file | `$HOME/.config/nvim/lua/kpihx/opencode.lua` |
| Deps | `folke/snacks.nvim` (input + picker) |
| Key | Action |
| `<C-a>` (visual) | `opencode.ask("@this: ", { submit = true })` |
| `<C-x>` (visual) | `opencode.select()` |
| `<C-.>` (n/t mode) | `opencode.toggle()` |

**Requires:** `opencode` binary in `$PATH` (sourced via `$HOME/.kshrc`).

## OpenCode Web (Tailscale + systemd)

OpenCode Web runs as a persistent systemd user service, exposed via `tailscale serve` on a dedicated HTTPS port.

| Item | Value |
|------|-------|
| Service file | `$HOME/.config/systemd/user/opencode-web.service` |
| Port (local) | `4097` (localhost only) |
| Tailscale URL | `https://kpihx-ubuntu.tail2527bd.ts.net:8443/` |
| Port 443 | Reserved by OpenClaw (`127.0.0.1:18789`) — do not conflict |
| Password env | `$HOME/.config/opencode/web.env` (mode `600`) |

**Password status:** Currently **disabled** (EnvironmentFile line commented out in service). To re-enable:
1. Uncomment `EnvironmentFile=%h/.config/opencode/web.env` in the service file
2. Adjust the health check ExecStartPost to accept HTTP 401 (see commented-out version in service file history)
3. `systemctl --user daemon-reload && systemctl --user restart opencode-web`

**Commands:**
```bash
systemctl --user status opencode-web     # status
systemctl --user restart opencode-web    # restart
journalctl --user -u opencode-web -f     # live logs
tailscale serve status                   # verify tailscale proxy
```

## Init & Connectivity

OpenCode connects to the KπX kernel via:

```bash
ln -sf $HOME/.agents/AGENTS.md $HOME/.config/opencode/AGENTS.md
ln -sf $HOME/.agents/skills $HOME/.config/opencode/skills
ln -sf $HOME/.agents/agents $HOME/.config/opencode/agents
```

**Agent discovery:** Agents defined in `$HOME/.agents/agents/` (`.agents` protocol) are symlinked to `$HOME/.config/opencode/agents/`. Files in `~/.config/opencode/agents/` become discoverable as subagents.

**Skills discovery:** Symlink `$HOME/.config/opencode/skills` → `$HOME/.agents/skills/`. All `k-*` skills discoverable.

**Config source of truth:** `$HOME/.config/opencode/opencode.jsonc` — model, MCP, permissions, defaults. See `k-opencode` for full proxy/MCP/plugin mapping.

## References

- `references/GO.md` — OpenCode GO system reference (Go-based MCP servers and tooling)

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-opencode/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-opencode/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-29 | [OPENCODE] | v1.4.0 — Init & Connectivity section: symlinks, agent discovery, skills discovery (migrated from INIT.md). |
| 2026-05-29 | [OPENCODE] | v1.3.0 — Permission System section: 3-zone allow + explicit ask (35 patterns). external_directory with 9 paths. |
| [SUMMARY] | — | v1.2.x OpenCode Web sysd + tailscale, Neovim integration; v1.1.0 init; v1.0.0 release. |

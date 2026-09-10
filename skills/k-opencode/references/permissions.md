# Permission System (2026-05-30 — Confiance Totale)

OpenCode uses a 3-tier hierarchy: **Global config → Agent deltas → Session runtime**. Rules are evaluated by `findLast` — the last matching pattern wins.

## Architecture

- **Global default** (`permission`): Single source of truth — ALL bash patterns, MCP rules, external_directory
- **Agent blocks**: Define ONLY deltas from global (minimal, no duplication)
  - `Build`: `{}` — inherits everything from global
  - `Plan`: `edit: deny`, restricted bash (read-only)
  - `Colab`: only `task` delta — which sub-agents it can launch. edit/bash inherit from global (3-zone)
  - `Explore`: only `task` delta — which sub-agents it can launch. edit/bash inherit from global (3-zone)
  - `Lite`: `skill: deny`, all MCPs `deny`, `task: deny`. Bash/edit inherit from global.
  - `Auto`: `*: allow` — catches ALL tools, ALL sub-agents, ALL skills. Unrestricted.
  - `Agent`: `task: *: allow` (all sub-agents) + bash delta `tmux send-keys*` / `tmux capture-pane*` allow (ops pane). Edit/bash inherit from global (3-zone).

## Global permission zones (bash)

| Zone | Level | Nb patterns | Examples |
|------|-------|-------------|----------|
| 🟢 **Zone 1** | Pure read-only | 65+ | `echo`, `cat`, `head`, `grep`, `jq`, `find`, `stat`, `man`, `md5sum`, `shasum`, `tac`, `users`, `who`, `lscpu` |
| 🟡 **Zone 2** | Low risk | 22 | `curl`, `wget`, `ping`, `dig`, `traceroute`, `ss`, `tmux`, `watch` |
| 🟠 **Zone 3** | Trusted | 50+ | `awk`, `git`, `docker`, `python3`, `ssh`, `rsync`, `make`, `tar`, `zip`, `ip`, `npm`, `node`, `tee` |
| 🔴 **Explicit Ask** | Dangerous | 35 | `rm`, `rmdir`, `shred`, `sed`, `pkill`, `sudo`, `chmod`, `dd`, `fdisk`, `systemctl`, `apt`, `passwd` |

## `.env` + `*auth.json` + `*credentials.json` protection (edit + bash + read — 2026-07-24 / 2026-08-03)

All access to `*.env`, `*.auth.json` and `*.credentials.json` files is forbidden (`deny`). The `*.env.example` files are allowed (`allow`). Applied on `edit`, `bash`, and `read` via `findLast`:

```jsonc
"edit": { "*": "ask", "*.env": "deny", "*.env.example": "allow", "*.auth.json": "deny", "*.credentials.json": "deny" },
"read": { "*.env": "deny", "*.env.example": "allow", "*.auth.json": "deny", "*.credentials.json": "deny" },
"bash": { /* ... */ "*.env": "deny", "*.env.example": "allow", "*.auth.json": "deny", "*.credentials.json": "deny" }
```

## MCP permissions

Wildcard allows all, specific destructive tools override to `ask` (last match wins):

- `chrome-agent_*`: `allow`
- `mail_fallback_*`: `allow` + `send_message`, `reply_message`, `forward_message`, `delete_messages`, `delete_folder`, `trash_messages`: `ask`
- `tick_fallback_*`: `allow` + `delete_task`, `delete_project`, `delete_tag`, `delete_habit`, `delete_query_preset`, `batch_delete_tasks`, `merge_tags`: `ask`

## `external_directory` — 11 paths allow

`~/.agents/**`, `~/.config/opencode/**`, `/tmp/**`, `~/Downloads/**`, `~/Pictures/**`, `~/Gdrive/**`, `~/Gdrive/**`, `~/Labs/**`, `~/Work/**`, `~/.config/nvim/**`, `~/.local/share/nvim/**`

## Usage

- Unlisted commands fall to the global `"bash": "ask"` — they pop up for approval
- To add a pattern: insert it in the right zone (allow before ask) in `opencode.jsonc`
- `findLast` wins: the last pattern that matches wins
- Source of truth: `$HOME/.config/opencode/opencode.jsonc`

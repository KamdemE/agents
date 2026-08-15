# KπX — .agents kernel

Sovereign agent kernel: rules, skills, scripts, assets, configs. Single source of
truth for every KπX machine, wired via symlinks (`make link`) and systemd services
(`assets/services.jsonc`). See `AGENTS.md` for the full kernel identity & rules.

## Git remotes (org `kpihx-labs`)

Both remotes are the same content, kept in sync — push to either, pull from either:

| Remote | URL |
|--------|-----|
| `github` | `git@github.com:kpihx-labs/agents.git` |
| `gitlab` | `git@gitlab.com:kpihx-labs/agents.git` |

`make push` pushes the current branch to **both** (`github` then `gitlab`).

## Plugin submodules

The opencode plugins under `skills/k-opencode/scripts/plugins/` are **git
submodules** pointing at forks on org `kpihx-labs` (each also carries a `gitlab`
remote for sync):

| Submodule | GitHub (url in `.gitmodules`) | GitLab (second remote, subgroup `opencode`) |
|-----------|-------------------------------|------------------------|
| `opencode-context` | `kpihx-labs/opencode-context` | `kpihx-labs/opencode/opencode-context` |
| `web/opencode-lens` | `kpihx-labs/opencode-lens` | `kpihx-labs/opencode/opencode-lens` |
| `web/opencode-web-voice` | `kpihx-labs/opencode-web-voice` | `kpihx-labs/opencode/opencode-web-voice` |

The submodules' `vendor/`, `node_modules/`, and `dist/` are gitignored (not
versioned) — reinstall locally. The plugin source of truth lives in the forks.

## Install on a new KπX machine

```bash
git clone git@github.com:kpihx-labs/agents.git ~/.agents
cd ~/.agents
git submodule update --init --recursive        # or: make submodule-init
make link                                        # create .agents-owned symlinks
make check                                       # must be ALL OK
```

## Common targets

```bash
make push              # push current branch to github + gitlab
make link              # (re)create .agents-owned symlinks
make check             # full validation (must be clean before commit/push)
make check-tailscale   # tailscale up + current user is an operator (no group check)
make submodule-init    # init + checkout plugin submodules
make submodule-update  # pull latest on each submodule from github + gitlab
```

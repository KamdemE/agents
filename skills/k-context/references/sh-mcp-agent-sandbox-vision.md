# sh-mcp — agent sandbox MCP (vision)

> **Status:** brainstorm / architecture draft — not an implementation spec.  
> **Related:** homelab topology → `k-homelab`; future implementation → `$HOME/Work/AI/MCPs/` (repo TBD).

## Purpose

**sh-mcp** is a **network-facing MCP service** that exposes a **dedicated, persistent Linux environment** (“mini PC”) for an LLM agent. The agent installs tools, clones repos, runs commands, and maintains working copies **inside that boundary** — isolated from KπX’s interactive workstation.

A **separate** future component (**sh-exec**, name TBD) would allow the same agent model to act on **the user’s local machine** (shared-terminal style). **sh-mcp** must not conflate those two trust domains.

## Why two worlds

| World | Role | Trust |
|-------|------|--------|
| **Agent sandbox (sh-mcp)** | Hosted on homelab **docker-host**; persistent volume; agent-owned installs (`gh`, `glab`, `uv`, …) | Bounded: no host `$HOME`, no Docker socket by default |
| **User workstation (future sh-exec)** | Local shell, `sudo`, personal keys, IDE-adjacent workflows | User-mediated; secrets stay local |

Cross-boundary workflows should use **explicit steps** (artifact in sandbox → approved action on user side), not a single magical shell.

## Architecture (layers)

1. **Execution perimeter**  
   Container (or later VM) on **docker-host** with a **single writable root** (e.g. `/workspace` or `/agent`). Everything persistent for the agent lives there.

2. **Control plane**  
   MCP process: authenticate, validate paths/timeouts/size limits, delegate to a **restricted executor** (non-root where possible).

3. **Data plane**  
   Named **Docker volume** attached only to this service = the sandbox disk. Regenerate from git where possible; backup volume for caches and non-committed state.

4. **Ingress**  
   **Traefik** on the internal **proxy** network: private hostname, TLS, optional IP / middleware restrictions (Tailscale / lab-only patterns).

5. **MCP surface (minimal v1)**  
   Prefer one core tool (e.g. `exec` with `cwd` under the sandbox root) plus strict policy. Optional later: bounded `read_file` / `write_file`. **Skills** (`SKILL.md`) teach *how* to use CLIs; the MCP does not embed that knowledge.

## Content inside the sandbox (directional)

- **Git clones:** e.g. mirror or fork of `$HOME/.agents` (kernel), `techskills`, `presentation` — for QMD indexing, docs, and agent-maintained commits **inside the sandbox copy**, with normal **pull / branch / push** discipline (hooks and CI as on any other clone).
- **QMD:** optional phase 1.5 — CLI + index inside the volume, or a thin MCP tool that wraps the existing `qmd` / `qmdr` contract.

## Git and multi-writer reality

KπX and the agent may both push to the same remotes. The MCP does not resolve merge conflicts. **Enforce:** pull before edit, branches, CI, or server-side hooks — same as human teams.

## Backup and restore

- **Volume snapshots** on a schedule from **docker-host** (host-level script, not inside the untrusted sandbox).
- **Git remotes** as logical restore for tracked work.
- Future: a **backup trigger** could call a **host-side** API with tight auth — not raw secret or sudo over HTTP to the MCP.

## Security notes

- No user **sudo password** path through sh-mcp HTTP.
- **Auth** on the MCP endpoint (token / mTLS) is mandatory for any routed URL.
- **Prompt injection** → arbitrary `exec`: mitigate with path allowlists, command allowlists (optional), output caps, timeouts.

## Deployment fit (KπX homelab)

- **Run:** docker-host, same stack family as other lab services (Traefik + `proxy` network).
- **Do not** treat the Proxmox host (`pve`) as the default Docker execution target for this service — operational commands go where **Docker** runs.

## Document history

| Date | Change |
|------|--------|
| 2026-04-06 | Initial vision captured from brainstorm (sh-mcp vs sh-exec, layers, sandbox content, git/backup). |

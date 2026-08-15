# Ollama — Home-Directory Structure (`~/.ollama`, `~/.ollama-ipex`)

> **Purpose:** document the on-disk layout of Ollama's per-user data dirs so agents can navigate, troubleshoot, and clean them safely. Load when inspecting/cleaning Ollama storage or when asked "what is in `~/.ollama` / `~/.ollama-ipex`?".
> **Last verified:** 2026-08-14 (history files emptied by `truncate -s 0` per KπX — see below).

---

## `~/.ollama` — Default Ollama data dir

| Path | Type | Role |
|------|------|------|
| `~/.ollama/config.json` | file | Runtime config. Keys observed: `integrations` (`claude`, `codex`, `openclaw`, `opencode` → each with `models`), `last_model`, `last_selection` |
| `~/.ollama/history` | file | Shell/usage history log (see **history hygiene** below) |
| `~/.ollama/id_ed25519` + `id_ed25519.pub` | keypair | Ollama identity keys (server auth / signed requests) |
| `~/.ollama/models/` | dir | Model storage |
| `~/.ollama/models/blobs/` | dir | Model blobs (the actual weights/digests) |
| `~/.ollama/models/manifests/` | dir | Model manifests (index/digest references) — may be absent on some installs |

> **Env override:** `OLLAMA_MODELS` can point model storage elsewhere (default `~/.ollama/models`).

---

## `~/.ollama-ipex` — Ollama-IPEX (Intel Arc GPU) variant data dir

| Path | Type | Role |
|------|------|------|
| `~/.ollama-ipex/config.json` | file | Runtime config — same schema shape as `~/.ollama/config.json` (integrations/last_model/last_selection) |
| `~/.ollama-ipex/history` | file | Usage history log |
| `~/.ollama-ipex/id_ed25519` + `id_ed25519.pub` | keypair | Ollama identity keys for the IPEX build |
| `~/.ollama-ipex/server.log` | file | Server/daemon log for the IPEX variant |
| `~/.ollama-ipex/models/` | dir | Model storage |
| `~/.ollama-ipex/models/blobs/` | dir | Model blobs |
| `~/.ollama-ipex/models/manifests/` | dir | Model manifests |

> `~/.ollama-ipex` is the data dir used by the `ollama-ipex` / `ipex` wrapper (see `k-ai`). It keeps GPU/IPEX model state separate from the CPU build.

---

## History hygiene (emptied 2026-08-14)

Per KπX directive, the usage history in both dirs was **emptied** (not deleted — files preserved, set to 0 bytes):

```bash
truncate -s 0 ~/.ollama/history ~/.ollama-ipex/history
```

Both `history` files remain in place (0 bytes) so Ollama does not error; they will re-populate on next use.

---

## Safe clean/delete (GRAVÉ — read before any `rm`)

- **Blobs/manifests** → use `ollama rm <model>` / `ollama list` (removes both safely), or `ollama-ipex rm <model>` for the IPEX build. Never hand-delete blobs.
- **Full reset** → `rm -rf ~/.ollama` (destroys all models + config + identity). Only with explicit KπX green light.
- **Identity keys** (`id_ed25519*`) → do NOT touch unless re-provisioning a fresh identity.
- **`server.log`** → safe to truncate during optimization (`truncate -s 0 ~/.ollama-ipex/server.log`).
- **Config** → edit via the skill's `assets/` source of truth + symlink; never edit `~/.ollama*/config.json` directly unless KπX says so.

> Cross-reference: model storage + IPEX tuning also covered in `references/ubuntu.md` and `k-ai`. Cleanup context → `k-optim`.

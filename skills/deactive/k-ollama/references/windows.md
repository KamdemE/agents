# k-ollama — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-blglaptop139` (blglaptop139)

---

## Native Windows Ollama

Ollama has a native Windows build. Download from https://ollama.com/download and run the installer.

- Runs as a Windows service (background)
- Exposes `http://127.0.0.1:11434` (same as Linux)
- GPU acceleration available for NVIDIA CUDA and some DirectML-supported GPUs

## Ollama in WSL

Two real options, not equivalent:

### Option A — full WSL server (its own models, its own GPU/CUDA setup)

```bash
# Inside WSL
curl -fsSL https://ollama.com/install.sh | sh
```

Installs client + server + GPU backend libs, and **enables + starts an `ollama.service`** (systemd) automatically. If Windows-native Ollama is ALSO running, they conflict on port 11434 — pick one.

### Option B — WSL client only, talking to the Windows-hosted server (recommended when Windows already runs Ollama)

`.wslconfig`'s `networkingMode=mirrored` (see `k-windows/SKILL.md` → WSL Bootstrap) shares `localhost` between Windows and WSL — the Windows-native Ollama server on `:11434` is transparently reachable from WSL, **no tunnel, no port-forward, no WSL-side server at all**. Verified 2026-08-25: `ollama list` from WSL returned the Windows host's models directly.

All that's missing in that case is the **client binary** — the official `install.sh` bundles it with the full server + CUDA/ROCm libs (1.4+ GB compressed) and unconditionally enables `ollama.service`, both wrong for a client-only role. Install it with:

```bash
bash $HOME/.agents/skills/k-ollama/scripts/install-wsl-client.sh
```

**`scripts/install-wsl-client.sh`** — resolves the latest release tag, downloads `ollama-linux-amd64.tar.zst` (recent releases no longer ship `.tgz`), decompresses it via a throwaway `uv run --with zstandard` env (no `sudo`, no `zstd` system package needed — GNU tar's own `--zstd` flag still shells out to an external `zstd` binary that isn't installed by default), and extracts **only** `bin/ollama` — `lib/ollama/{cuda_v12,cuda_v13,rocm}/*` (the multi-GB GPU backend libs) are skipped entirely, since the client binary doesn't need them to talk to a remote `$OLLAMA_HOST`, only `ollama serve` would. Idempotent — re-running it when already at the latest version is a no-op. Never touches systemd. Two gotchas hit and fixed while writing it are in `references/insights.md` (a `curl | grep -m1` pipe-breakage, and a PATH-blind version check).

**🔴 Never `systemctl enable ollama` on the WSL side in this setup.** No server should ever run in WSL when Windows already hosts one on the same (mirrored) `localhost:11434` — a WSL-side server would either silently fail to bind (port taken) or, worse, both would race for it. `$OLLAMA_HOST` (see Environment Variables in `SKILL.md`) already defaults to `http://localhost:11434` in the KπX `.kshrc` hub — nothing else to configure.

- **Native Windows**: Better GPU support (DirectML/CUDA), and this option lets WSL reuse it for free via the client-only install above.
- **Full WSL server**: only if you specifically need Linux-native model storage/tooling independent of the Windows install.

## GPU Support

- Windows native Ollama supports NVIDIA CUDA and AMD DirectML
- WSL supports NVIDIA CUDA via GPU passthrough
- Intel Arc GPUs in WSL are experimental — see `k-ubuntu` for Intel Arc setup (applies to native Ubuntu only)

## Uninstalling

```powershell
# Windows native
winget uninstall Ollama.Ollama
# or via Settings > Apps
```

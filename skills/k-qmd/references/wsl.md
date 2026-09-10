# k-qmd — WSL (GPU passthrough for local embedding models)

> **OS reference:** WSL2 (Windows Subsystem for Linux). Applies to any infra running qmd inside WSL with an NVIDIA GPU on the Windows host (e.g. `k-laptop`).

## The trap: driver present ≠ CUDA usable

WSL2 exposes the Windows-side NVIDIA driver into the Linux distro via `/dev/dxg` and `/usr/lib/wsl/lib/` (`libcuda.so`, `nvidia-smi` work out of the box). This is **driver-level passthrough only** — it is NOT the CUDA runtime/toolkit that `node-llama-cpp` (qmd's local embedding backend) needs to actually run inference on the GPU.

Symptom: `qmd embed` runs, `nvidia-smi` shows the GPU present and idle (0% util), but embedding runs entirely on CPU (`583%` CPU in `ps`, GPU-Util stays `0%`). Root cause, confirmed via:

```bash
~/.npm-global/lib/node_modules/@tobilu/qmd/node_modules/.bin/node-llama-cpp inspect gpu
# → "CUDA: NVIDIA driver is installed, but CUDA runtime is not"
# → "Vulkan: available" but "Vulkan free VRAM: 0% (0B/0B)"
```

The Vulkan fallback is also unusable here: `/usr/share/vulkan/icd.d/` only has Mesa software/open-source ICDs (`nouveau_icd.json`, `lvp_icd.json`, `intel_icd.json`, …) — no `nvidia_icd.json`. WSL's GPU paravirtualization doesn't register a proper NVIDIA Vulkan ICD by default, so Vulkan silently falls back to LLVMpipe (software, 0 VRAM reported).

## Fix: install the CUDA Toolkit from NVIDIA's WSL-Ubuntu repo

Do **NOT** install the regular Ubuntu CUDA package or a driver — the driver already lives on Windows and must not be touched from inside WSL. Use NVIDIA's dedicated `wsl-ubuntu` repo (toolkit only, no driver):

```bash
# 1. Add the WSL-specific CUDA repo (driver-less — Windows owns the driver)
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update

# 2. Install the toolkit (nvcc, cuBLAS, cudart, …) — ~3-4 GB
sudo apt-get -y install cuda-toolkit
```

## Verify

```bash
nvcc --version   # toolkit present
~/.npm-global/lib/node_modules/@tobilu/qmd/node_modules/.bin/node-llama-cpp inspect gpu
# → "CUDA: available" expected after this fix
qmd status   # re-embed / new embed runs should show GPU-Util > 0% in nvidia-smi while running
```

## Scope

This applies to **any** WSL infra with local GGUF/llama.cpp-based inference — not just qmd. `k-ollama`/`k-ai` local model serving on a WSL machine hits the identical trap if ever moved off the Ubuntu-native GPU path documented there.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-qmd/references/insights.md` before non-trivial work in this skill domain.
- Update it at task end with durable lessons.


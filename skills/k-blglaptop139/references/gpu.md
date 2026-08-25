# k-blglaptop139 — GPU (NVIDIA RTX 5070 Ti Laptop GPU, WSL CUDA)

## Hardware

| Property | Value |
|----------|-------|
| GPU | NVIDIA GeForce RTX 5070 Ti Laptop GPU |
| VRAM | 12227 MiB (~12 GB) |
| Driver | 592.02 (Windows-side, passed through to WSL) |
| CUDA (driver max) | 13.1 |
| CPU | Intel(R) Core(TM) Ultra 9 275HX (20 math cores) |
| RAM | 23.47 GB |

## WSL GPU passthrough — what's real vs missing by default

WSL2 exposes the Windows NVIDIA driver into this distro automatically:

- `/dev/dxg` present, `nvidia-smi` works out of the box (via `/usr/lib/wsl/lib/nvidia-smi`).
- This is **driver passthrough only** — no CUDA toolkit (`nvcc`, cuBLAS, cudart) ships with it, and no proper NVIDIA Vulkan ICD is registered (`/usr/share/vulkan/icd.d/` only has Mesa software ICDs).

**Consequence found 2026-08-24:** any local GGUF/llama.cpp-based inference (first hit: `qmd embed` for `k-qmd`) silently ran on CPU (`GPU-Util` stayed `0%` in `nvidia-smi` the whole time) despite the GPU being fully visible. Full trap + fix: **`k-qmd/references/wsl.md`**.

## Fix applied (CUDA Toolkit, WSL-Ubuntu repo)

```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit
```

Driver-less package (the driver stays owned by Windows) — never install the regular Ubuntu CUDA/driver package or `apt install nvidia-driver-*` inside this WSL distro.

## Verify

```bash
nvcc --version
nvidia-smi   # GPU-Util should move away from 0% during a GPU-accelerated workload
```

## Scope

Any future local-model workload on this machine (Ollama, whisper-cli, piper, qmd, node-llama-cpp-based tools) should use this GPU — check `nvidia-smi -l 1` during the workload if unsure it's actually engaging the GPU rather than silently falling back to CPU.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [CLAUDE] | v1.0.0 — Created. Documents the RTX 5070 Ti Laptop GPU hardware, the WSL driver-passthrough-without-CUDA-runtime trap (found via `qmd embed` running 100% CPU-bound), and the CUDA Toolkit fix applied. |

# Whisper.cpp (`k-whisper`) Reference Guide

Sovereign local Speech-to-Text (STT) setup, wrapper options, and optimization.

## Installation & Compilation (Vulkan GPU Acceleration)

To run transcription in real-time on Intel GPUs (like the Intel Arc iGPU on Core Ultra 7 155H), compile `whisper.cpp` with Vulkan support:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ggerganov/whisper.cpp.git /tmp/whisper.cpp
    cd /tmp/whisper.cpp
    ```
2.  **Compile with Vulkan enabled:**
    ```bash
    cmake -B build -DGGML_VULKAN=1
    cmake --build build --config Release --target whisper-cli
    ```
3.  **Install user-local (no sudo — sovereign pattern):**
    ```bash
    cp build/bin/whisper-cli ~/.local/bin/whisper-cli
    cp build/bin/libwhisper.so* build/bin/libggml*.so* ~/.local/lib/
    ```
    The wrapper `k-whisper.sh` exports `LD_LIBRARY_PATH="$HOME/.local/lib"` so the
    binary finds its shared libraries. `~/.local/bin` precedes `/usr/local/bin` in
    the PATH (via `~/.kshrc`), so the Vulkan build wins over the system CPU build.
    Verify GPU detection: `whisper-cli -m <model> -f /dev/null` must show
    `ggml_vulkan: 0 = Intel(R) Arc(tm) Graphics (MTL)`.
    *Measured on this machine (2026-08-13): 10s audio transcribed in ~4.7s with
    Vulkan GPU vs ~25s with the CPU build (~5x speedup).*

## Installation & Compilation (CUDA GPU Acceleration — NVIDIA)

On machines with a discrete NVIDIA GPU (e.g. `deep-pc6`, 2× RTX 3090), compile with CUDA instead of Vulkan — up to ~100× faster encode on `medium`/`large` models:

1. **Toolkit (apt, sudo, via tmux ops pane):**
   ```bash
   sudo apt install build-essential cmake nvidia-cuda-toolkit
   ```
   Confirmed safe (2026-08-26): `nvidia-cuda-toolkit` on Ubuntu 22.04 pulls CUDA 11.5 userspace libs (+ Java for nsight tools, ignorable) — it does **NOT** touch or replace the existing NVIDIA driver package. Verify first with `apt-get install --simulate nvidia-cuda-toolkit | grep nvidia-driver` (must be empty) before running for real on a shared GPU box.
2. **GCC/NVCC version mismatch (real incident, 2026-08-26):** Ubuntu 22.04's default `nvcc` (11.5) fails to compile against the default `g++` (11.4) — `parameter packs not expanded with '...'` errors in `<bits/std_function.h>`. Fix: install an older host compiler and point CUDA at it explicitly:
   ```bash
   sudo apt install gcc-10 g++-10   # via tmux ops pane
   ```
3. **Clone + configure + build** (arch code from the table below, RTX 30-series = Ampere = `86`):
   ```bash
   git clone --depth 1 https://github.com/ggml-org/whisper.cpp ~/opt/whisper.cpp
   cmake -B ~/opt/whisper.cpp/build -S ~/opt/whisper.cpp \
     -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=ON \
     -DCMAKE_CUDA_ARCHITECTURES=86 \
     -DCMAKE_CUDA_HOST_COMPILER=/usr/bin/g++-10 \
     -DWHISPER_BUILD_TESTS=OFF
   cmake --build ~/opt/whisper.cpp/build -j --target whisper-cli
   ```
   | GPU family | Arch | `CMAKE_CUDA_ARCHITECTURES` |
   |---|---|---|
   | RTX 20 / T4 | Turing | `75` |
   | RTX 30 / A100 | Ampere | `86` |
   | RTX 40 / L40 | Ada | `89` |
   | H100 | Hopper | `90` |
4. **Install user-local (same sovereign pattern as Vulkan):**
   ```bash
   cp ~/opt/whisper.cpp/build/bin/whisper-cli ~/.local/bin/whisper-cli
   cp ~/opt/whisper.cpp/build/bin/libwhisper.so* ~/opt/whisper.cpp/build/bin/libggml*.so* ~/.local/lib/
   ```
   Verify: `LD_LIBRARY_PATH="$HOME/.local/lib" whisper-cli -m <model> -f <audio>` must print `ggml_cuda_init: found N CUDA devices` and `whisper_backend_init_gpu: using CUDA0 backend`. Measured on deep-pc6 (2026-08-26): `large-v3-turbo-q5_0` encode ≈ 911ms for a 4.8s clip on RTX 3090.
   Never build both Vulkan and CUDA on the same machine unless intentional — whichever `whisper-cli` lands in `~/.local/bin` last wins (PATH precedence over `/usr/local/bin`).

## Wrapper CLI (`k-whisper`)

The wrapper `k-whisper` (linked at `~/.local/bin/k-whisper` from `skills/k-ai/scripts/k-whisper.sh`) wraps `whisper-cli` and isolates the model management.

### Model Storage
All models are stored in:
`~/.local/share/whisper-cpp/`

### Subcommands:
*   **List models:**
    ```bash
    k-whisper ls
    ```
    Lists all `.bin` models in your directory under a numbered index (e.g. `1) ggml-large-v3-turbo-q5_0.bin`).
*   **Fetch models from API:**
    ```bash
    k-whisper fetch
    ```
    Queries the HuggingFace API to list all available `ggml-*.bin` models that can be downloaded.
*   **Pull a model:**
    ```bash
    k-whisper pull <model_name>
    ```
    Downloads the model ggml file from the official HuggingFace repository (e.g., `k-whisper pull large-v3-turbo-q5_0`).
*   **Remove a model:**
    ```bash
    k-whisper rm <index|name|path>
    ```
    Deletes the model specified by its listing index, simple name, or absolute path.

### Transcription:
*   **Syntax:**
    ```bash
    k-whisper <model_spec> -p <audio_path> [-o <output_dir>]
    # Or:
    k-whisper -m <model_spec> -p <audio_path> [-o <output_dir>]
    ```
    *   `<model_spec>`: Index number from `k-whisper ls`, model filename, or full path.
    *   `-p, --path`: Absolute path to the input audio file (required).
    *   `-o, --output`: Destination directory for the transcription `.txt` file.
    *   *Comportement si `-o` est omis (défaut) :* La transcription est sauvegardée **juste à côté du fichier audio source**, sous le même nom avec l'extension `.txt`.
    *   *Auto-conversion :* Si le fichier d'entrée n'est pas au format WAV PCM 16kHz mono, `k-whisper` appelle silencieusement `ffmpeg` pour générer un fichier temporaire dans `/tmp/` avant l'inférence.

## Optimizations & Performance Tuning

1.  **Vulkan GPU Offloading:** Ensure that `whisper-cli` output shows Vulkan device detection. In Vulkan mode, the processing is offloaded to the Intel Arc GPU, reducing latency under the second for short files.
2.  **Quantization:** Use quantized ggml weights (like `q5_0` or `q8_0`) to decrease memory footprints and latency with negligible loss in accuracy.
3.  **Threads:** Customize thread counts (default: 4) using the `-t` parameter. Match this count to your physical CPU cores for best performance.

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

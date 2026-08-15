# Piper (TTS) Reference Guide

Sovereign local Text-to-Speech (TTS) setup, wrapper options, and optimization.

## Installation & Deployment

Piper is a fast, local neural text-to-speech system that runs efficiently on consumer hardware.

1.  **Download the pre-compiled C++ standalone release:**
    ```bash
    wget https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_amd64.tar.gz -O /tmp/piper.tar.gz
    tar -xf /tmp/piper.tar.gz -C /tmp/
    ```
2.  **Install the binary, libraries, and espeak-ng data:**
    ```bash
    cp /tmp/piper/piper ~/.local/bin/piper
    cp /tmp/piper/lib* ~/.local/lib/
    mkdir -p ~/.local/share/espeak-ng-data
    cp -r /tmp/piper/espeak-ng-data/* ~/.local/share/espeak-ng-data/
    ```
3.  **Runtime wiring (handled automatically by `k-piper`, no manual step):**
    *   `LD_LIBRARY_PATH="$HOME/.local/lib"` — the wrapper exports it at the top of `k-piper.sh`.
    *   `--espeak_data "$HOME/.local/share/espeak-ng-data"` — the wrapper passes it on every invocation.

## Wrapper CLI (`k-piper`)

The wrapper `k-piper` (linked at `~/.local/bin/k-piper` from `skills/k-ai/scripts/k-piper.sh`) wraps the `piper` binary and manages voice models and synthesis parameters.

### Voice Models Storage
All voice models and config files are stored in:
`~/.local/share/piper-voices/`

### Subcommands:
*   **List voices:**
    ```bash
    k-piper ls
    ```
    Lists all `.onnx` voices in your directory under a numbered index (e.g. `1) fr_FR-siwis-medium`).
*   **Fetch voices from API:**
    ```bash
    k-piper fetch
    ```
    Queries the HuggingFace Rhasspy repository to list all available voices and their native languages.
*   **Pull a voice:**
    ```bash
    k-piper pull <locale-nom-qualité>
    ```
    Parses the voice name (e.g. `fr_FR-siwis-medium`), automatically resolves the download URL from the official Rhasspy repository, and downloads both the `.onnx` and the `.onnx.json` configuration file via `wget -c`.
*   **Remove a voice:**
    ```bash
    k-piper rm <index|name|path>
    ```
    Deletes the voice file (and its `.json` config) specified by its listing index, name, or absolute path.

### Synthesis:
*   **Syntax:**
    ```bash
    k-piper <voice_spec> -p <text_spec> [-o <output_dir>] [-s <speed>]
    # Or:
    k-piper -m <voice_spec> -p <text_spec> [-o <output_dir>] [-s <speed>]
    ```
    *   `<voice_spec>`: Index number from `k-piper ls`, voice filename, or full path.
    *   `-p, --path`: Absolute path to the input text file, or raw text string to synthesize (required).
    *   `-o, --output`: Destination directory for the generated WAV file.
    *   `-s, --speed`: Speech speed length scale (default: `0.9`).
    *   *Comportement si `-o` est omis (défaut) :*
        *   Si `-p` est un **fichier texte existant**, le fichier WAV généré est écrit **juste à côté de ce fichier texte source**, sous le même nom avec l'extension `.wav`.
        *   Si `-p` est du **texte brut à la volée**, Piper génère un fichier WAV temporaire sous `/tmp/k-piper/{timestamp}.wav`, le lit immédiatement avec `mpv` (ou `ffplay`) et **ne le supprime pas**.

## Optimizations & Performance Tuning

1.  **CPU Infeence ONNX Runtime:** Piper uses ONNX Runtime in CPU mode by default, which is highly optimized and fast enough for real-time speech generation on modern processors without GPU overhead.
2.  **Speech Rate Adjustment:** Neural voices can sound slow or robotic at default speeds. Specifying `--length_scale` (or `-s` in the wrapper) to `0.9` or `0.85` generates a much more natural, conversational reading flow.
3.  **WAV File Bitrate:** High-quality Piper models use a sample rate of 22050Hz, mono, 16-bit.

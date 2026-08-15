#!/usr/bin/env sh
# ============================================================
# k-whisper — Sovereign wrapper around whisper-cli (Whisper.cpp)
# ------------------------------------------------------------
# Always executed as a standalone script (never sourced).
#
# Model management:   k-whisper ls | pull <name> | rm <spec>
# Transcription:      k-whisper <model|index|path> -p <audio> [-o <dir>]
#                     k-whisper -m <model|index|path> -p <audio> [-o <dir>]
#
# The model is ALWAYS required at call time — there is no default.
# ============================================================

# ── Constants (tunable at the top of the file) ───────────────
DEFAULT_THREADS="4"   # CPU threads passed to whisper-cli (-t)

# ── Shared libraries for the user-local whisper-cli (Vulkan build) ─
# The Vulkan build lives in ~/.local/bin + libs in ~/.local/lib
# (no sudo, no global ldconfig). Same pattern as k-piper.sh.
export LD_LIBRARY_PATH="$HOME/.local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# ── Model store (override via WHISPER_MODELS_DIR if needed) ──
WHISPER_MODELS_DIR="${WHISPER_MODELS_DIR:-$HOME/.local/share/whisper-cpp}"

# ── Usage / help ─────────────────────────────────────────────
usage() {
  cat <<'EOF'
Usage:
  k-whisper ls                               List installed models
  k-whisper pull <model_name>                Download a model (HuggingFace whisper.cpp repo)
  k-whisper fetch                            List all available models from HuggingFace
  k-whisper rm <index|name|path>             Remove a model
  k-whisper <model|index|path> -p <audio>    Transcribe audio (model is REQUIRED)
  k-whisper -m <model|index|path> -p <audio> Same, with explicit -m option

Options:
  -m, --model <model|index|path>  Model to use: index from 'k-whisper ls', name, or path
  -p, --path <audio_file>         Input audio file (required)
  -o, --output <dir>              Output directory for the .txt transcript (default: next to audio)
  -t, --threads <num>             CPU threads (default: 4)
EOF
}

# No arguments or help requested → show usage
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  exit 0
fi

check_net_deps() {
  command -v curl >/dev/null 2>&1 || echo "[Warning] 'curl' is missing. Fetch/pull may fail." >&2
  command -v wget >/dev/null 2>&1 || echo "[Warning] 'wget' is missing. Pull may fail." >&2
}

# ── Command: fetch — list available models from API ──────────
if [ "$1" = "fetch" ]; then
  check_net_deps
  echo "[k-whisper] Fetching available models from HuggingFace..."
  curl -s https://huggingface.co/api/models/ggerganov/whisper.cpp/tree/main | python3 -c '
import sys, json
try:
    for d in json.load(sys.stdin):
        p = d.get("path", "")
        if p.startswith("ggml-") and p.endswith(".bin"):
            print(f"  - {p}")
except Exception as e:
    sys.exit(1)
' || echo "Error fetching models."
  exit $?
fi

# ── Command: ls — list models as a numbered index ────────────
if [ "$1" = "ls" ]; then
  echo "=== Installed Whisper Models ==="
  idx=1
  for model in "$WHISPER_MODELS_DIR"/*.bin; do
    if [ -f "$model" ]; then
      echo "  $idx) $(basename "$model")"
      idx=$((idx + 1))
    fi
  done
  [ "$idx" -eq 1 ] && echo "No models found in $WHISPER_MODELS_DIR (use: k-whisper pull <name>)"
  exit 0
fi

# ── Command: pull — download a ggml model from HuggingFace ──
if [ "$1" = "pull" ]; then
  check_net_deps
  model_name="$2"
  [ -z "$model_name" ] && { echo "Error: specify a model name (e.g. 'large-v3-turbo-q5_0')"; exit 1; }
  # Normalize the name to the canonical ggml-*.bin form
  case "$model_name" in
    ggml-*.bin) ;;
    *.bin)      model_name="ggml-${model_name}" ;;
    *)          model_name="ggml-${model_name}.bin" ;;
  esac
  echo "[k-whisper] Downloading $model_name into $WHISPER_MODELS_DIR..."
  mkdir -p "$WHISPER_MODELS_DIR"
  wget -c --show-progress -P "$WHISPER_MODELS_DIR" \
    "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/${model_name}"
  exit $?
fi

# ── Command: rm — remove a model by index, name, or path ─────
if [ "$1" = "rm" ]; then
  target="$2"
  [ -z "$target" ] && { echo "Error: specify a model index, name, or path"; exit 1; }
  # Resolve the target to an absolute file path
  case "$target" in
    [0-9]*) # numeric index → look up in the ls order
      idx=1
      file_to_remove=""
      for model in "$WHISPER_MODELS_DIR"/*.bin; do
        if [ -f "$model" ]; then
          [ "$idx" -eq "$target" ] && { file_to_remove="$model"; break; }
          idx=$((idx + 1))
        fi
      done
      ;;
    /*)     file_to_remove="$target" ;;
    *.bin)  file_to_remove="$WHISPER_MODELS_DIR/ggml-$target" ;;
    *)      file_to_remove="$WHISPER_MODELS_DIR/ggml-${target}.bin" ;;
  esac
  if [ -f "$file_to_remove" ]; then
    echo "[k-whisper] Removing model: $file_to_remove"
    rm "$file_to_remove"
    exit $?
  fi
  echo "Error: model not found for specifier '$target'"
  exit 1
fi

# ── Default command: transcribe ──────────────────────────────
# The first non-flag argument (or -m/--model) is the model spec.
case "$1" in
  -*) model_spec="" ;;
  *)  model_spec="$1"; shift ;;
esac

audio_path=""
output_dir=""
format="txt"
start_time=""
duration=""
end_time=""
lang=""
translate=0
threads="$DEFAULT_THREADS"
verbose=1
extra_args=""

while [ $# -gt 0 ]; do
  case "$1" in
    -m|--model)     model_spec="$2";  shift 2 ;;
    -p|--path)      audio_path="$2";  shift 2 ;;
    -o|--output)    output_dir="$2";  shift 2 ;;
    -f|--format)    format="$2";      shift 2 ;;
    -s|--start)     start_time="$2";  shift 2 ;;
    -d|--duration)  duration="$2";    shift 2 ;;
    -e|--end)       end_time="$2";    shift 2 ;;
    -l|--lang)      lang="$2";        shift 2 ;;
    -tr|--translate) translate=1;     shift 1 ;;
    -t|--threads)   threads="$2";     shift 2 ;;
    -q|--no-verbose) verbose=0;       shift 1 ;;
    *)              extra_args="$extra_args $1"; shift ;;
  esac
done

# Mandatory arguments: model AND audio path
[ -z "$model_spec" ] && { echo "Error: model is required (number, name, or path)"; exit 1; }
[ -z "$audio_path" ] && { echo "Error: audio path (-p/--path) is required"; exit 1; }
[ ! -f "$audio_path" ] && { echo "Error: audio file '$audio_path' not found"; exit 1; }

# Resolve the model spec to an absolute .bin path
case "$model_spec" in
  [0-9]*) # numeric index → look up in the ls order
    idx=1
    model_path=""
    for model in "$WHISPER_MODELS_DIR"/*.bin; do
      if [ -f "$model" ]; then
        [ "$idx" -eq "$model_spec" ] && { model_path="$model"; break; }
        idx=$((idx + 1))
      fi
    done
    ;;
  /*)    model_path="$model_spec" ;;
  *.bin) model_path="$WHISPER_MODELS_DIR/ggml-$model_spec" ;;
  *)     model_path="$WHISPER_MODELS_DIR/ggml-${model_spec}.bin" ;;
esac

[ ! -f "$model_path" ] && { echo "Error: model not found at '$model_path' (see: k-whisper ls)"; exit 1; }

# whisper.cpp requires 16kHz mono WAV — convert / slice anything else on the fly
timestamp=$(date +%Y%m%d_%H%M%S)
final_audio="/tmp/whisper-temp-$timestamp.wav"

ffmpeg_opts=""
[ -n "$start_time" ] && ffmpeg_opts="$ffmpeg_opts -ss $start_time"
[ -n "$duration" ] && ffmpeg_opts="$ffmpeg_opts -t $duration"
[ -n "$end_time" ] && ffmpeg_opts="$ffmpeg_opts -to $end_time"

ff_verbosity="-hide_banner -loglevel info -stats"
[ "$verbose" -eq 0 ] && ff_verbosity="-hide_banner -loglevel error"

if [ "$verbose" -eq 1 ]; then
  echo "[k-whisper] Processing audio (16kHz mono conversion/slicing)..."
fi
# Split variables correctly for ffmpeg
ffmpeg -y $ffmpeg_opts -i "$audio_path" -ar 16000 -ac 1 -c:a pcm_s16le $ff_verbosity "$final_audio"
is_temp=1

# Output: explicit -o dir, otherwise next to the audio source
base_name=$(basename "$audio_path")
base_name="${base_name%.*}"
audio_dir="$(dirname "$audio_path")"
audio_dir="${audio_dir%/}"

if [ -n "$output_dir" ]; then
  output_dir="${output_dir%/}"
  mkdir -p "$output_dir"
  output_file="$output_dir/${base_name}"
else
  if [ "$audio_dir" = "." ]; then
    output_file="${base_name}"
  else
    output_file="$audio_dir/${base_name}"
  fi
fi

whisper_opts="-nt -t $threads"
[ -n "$lang" ] && whisper_opts="$whisper_opts -l $lang"
[ "$translate" -eq 1 ] && whisper_opts="$whisper_opts -tr"
[ "$verbose" -eq 1 ] && whisper_opts="$whisper_opts -pp"

# Determine format output flag
case "$format" in
  json) whisper_opts="$whisper_opts -oj" ;;
  srt)  whisper_opts="$whisper_opts -osrt" ;;
  vtt)  whisper_opts="$whisper_opts -ovtt" ;;
  csv)  whisper_opts="$whisper_opts -ocsv" ;;
  txt)  whisper_opts="$whisper_opts -otxt" ;;
  *)    whisper_opts="$whisper_opts -otxt" ;; # Default to txt
esac

# If not verbose, append -np (no prints) to whisper
[ "$verbose" -eq 0 ] && whisper_opts="$whisper_opts -np"

if [ "$verbose" -eq 1 ]; then
  echo "[k-whisper] Transcribing '$(basename "$audio_path")' with model $(basename "$model_path")"
  echo "[k-whisper] Output: ${output_file}.${format}"
fi

# Run whisper. Whisper outputs to the file automatically if -o<format> is used.
# Note: whisper-cli output file flag is -of (output file prefix)
whisper-cli -m "$model_path" -f "$final_audio" -of "$output_file" $whisper_opts $extra_args
exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  if [ "$verbose" -eq 1 ]; then
    echo "[k-whisper] Transcription complete."
    echo "[k-whisper] Transcript saved to: ${output_file}.${format}"
  fi
else
  echo "[k-whisper] Error during transcription"
fi

# Clean up the temporary converted file
[ "$is_temp" -eq 1 ] && [ -f "$final_audio" ] && rm -f "$final_audio"

exit "$exit_code"

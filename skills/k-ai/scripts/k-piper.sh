#!/usr/bin/env sh
# ============================================================
# k-piper — Sovereign wrapper around the piper C++ binary (TTS)
# ------------------------------------------------------------
# Always executed as a standalone script (never sourced).
#
# Voice management:   k-piper ls | pull <voice> | rm <spec>
# Synthesis:          k-piper <voice|index|path> -p <text|file> [-o <dir>]
#                     k-piper -m <voice|index|path> -p <text|file> [-o <dir>]
#
# The voice is ALWAYS required at call time — there is no default.
# ============================================================

# ── Constants (tunable at the top of the file) ───────────────
DEFAULT_SPEED="1" # --length_scale passed to piper (lower = faster speech)

# ── Voice store & binary (override via env if needed) ────────
PIPER_VOICES_DIR="${PIPER_VOICES_DIR:-$HOME/.local/share/piper-voices}"
PIPER_BIN="${PIPER_BIN:-$HOME/.local/bin/piper}"

# ── Shared libraries for the user-local piper binary ─────────
# The standalone C++ build lives in ~/.local/lib (no sudo, no global ldconfig).
export LD_LIBRARY_PATH="$HOME/.local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# ── espeak-ng data directory (installed alongside the binary) ─
ESPEAK_DATA_DIR="$HOME/.local/share/espeak-ng-data"

# ── Usage / help ─────────────────────────────────────────────
usage() {
  cat <<'EOF'
Usage:
  k-piper ls                               List installed voices
  k-piper pull <locale-name-quality>       Download a voice (.onnx + .json) from Rhasspy repo
  k-piper fetch                            List all available voices from Rhasspy repo
  k-piper rm <index|name|path>             Remove a voice
  k-piper <voice|index|path> -p <text>     Synthesize text (voice is REQUIRED)

Options:
  -m, --model <voice|index|path>  Voice to use: index from 'k-piper ls', name, or path
  -p, --path <text|file>          Raw text string or path to a text file (required)
  -o, --output <dir>              Output directory for the .wav file
  -s, --speed <val>               Speech speed (length scale, default: 0.9)
  -k, --speaker <id>              Speaker ID for multi-speaker models
  -q, --no-verbose                Suppress progress output

Default output: .wav next to the source text file; raw text goes to /tmp/k-piper/<timestamp>.wav (played, kept).
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

# ── Command: fetch — list available voices from API ──────────
if [ "$1" = "fetch" ]; then
  check_net_deps
  echo "[k-piper] Fetching available voices from Rhasspy..."
  curl -sL https://huggingface.co/rhasspy/piper-voices/raw/main/voices.json | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    for k, v in sorted(data.items()):
        lang = v.get("language", {}).get("name_native", "")
        print(f"  - {k}  ({lang})")
except Exception as e:
    sys.exit(1)
' || echo "Error fetching voices."
  exit $?
fi

# ── Command: ls — list voices as a numbered index ────────────
if [ "$1" = "ls" ]; then
  echo "=== Installed Piper Voices ==="
  idx=1
  for voice in "$PIPER_VOICES_DIR"/*.onnx; do
    if [ -f "$voice" ]; then
      echo "  $idx) $(basename "$voice" .onnx)"
      idx=$((idx + 1))
    fi
  done
  [ "$idx" -eq 1 ] && echo "No voices found in $PIPER_VOICES_DIR (use: k-piper pull <voice>)"
  exit 0
fi

# ── Command: pull — download a voice + config from HuggingFace ─
# Voice names follow the pattern <locale>-<name>-<quality>,
# e.g. fr_FR-siwis-medium → https://huggingface.co/rhasspy/piper-voices/resolve/main/fr/fr_FR/siwis/medium/
if [ "$1" = "pull" ]; then
  check_net_deps
  voice_name="$2"
  [ -z "$voice_name" ] && {
    echo "Error: specify a voice name (e.g. 'fr_FR-siwis-medium')"
    exit 1
  }
  voice_name="${voice_name%.onnx}"

  # Split the name into locale / name / quality parts
  locale="${voice_name%%-*}"
  rest="${voice_name#*-}"
  name="${rest%%-*}"
  quality="${rest#*-}"
  lang="${locale%%_*}"

  # Reject malformed names (missing a part)
  if [ -z "$locale" ] || [ -z "$name" ] || [ -z "$quality" ] || [ "$locale" = "$voice_name" ]; then
    echo "Error: invalid voice format, expected <locale>-<name>-<quality> (e.g. fr_FR-siwis-medium)"
    exit 1
  fi

  base_url="https://huggingface.co/rhasspy/piper-voices/resolve/main/${lang}/${locale}/${name}/${quality}"
  onnx_file="${locale}-${name}-${quality}.onnx"
  json_file="${locale}-${name}-${quality}.onnx.json"

  echo "[k-piper] Downloading $onnx_file and its config..."
  mkdir -p "$PIPER_VOICES_DIR"
  wget -c --show-progress -P "$PIPER_VOICES_DIR" "${base_url}/${onnx_file}"
  wget -c --show-progress -P "$PIPER_VOICES_DIR" "${base_url}/${json_file}"
  exit $?
fi

# ── Command: rm — remove a voice by index, name, or path ─────
if [ "$1" = "rm" ]; then
  target="$2"
  [ -z "$target" ] && {
    echo "Error: specify a voice index, name, or path"
    exit 1
  }
  # Resolve the target to an absolute .onnx path
  case "$target" in
  [0-9]*) # numeric index → look up in the ls order
    idx=1
    file_to_remove=""
    for voice in "$PIPER_VOICES_DIR"/*.onnx; do
      if [ -f "$voice" ]; then
        [ "$idx" -eq "$target" ] && {
          file_to_remove="$voice"
          break
        }
        idx=$((idx + 1))
      fi
    done
    ;;
  /*) file_to_remove="$target" ;;
  *.onnx) file_to_remove="$PIPER_VOICES_DIR/$target" ;;
  *) file_to_remove="$PIPER_VOICES_DIR/${target}.onnx" ;;
  esac
  if [ -f "$file_to_remove" ]; then
    echo "[k-piper] Removing voice: $file_to_remove"
    rm "$file_to_remove"
    rm -f "${file_to_remove}.json" # remove the paired config file too
    exit $?
  fi
  echo "Error: voice not found for specifier '$target'"
  exit 1
fi

# ── Default command: synthesize ──────────────────────────────
# The first non-flag argument (or -m/--model) is the voice spec.
case "$1" in
-*) model_spec="" ;;
*)
  model_spec="$1"
  shift
  ;;
esac

text_path=""
output_dir=""
speed="$DEFAULT_SPEED"
speaker=""
verbose=1
extra_args=""

while [ $# -gt 0 ]; do
  case "$1" in
  -m | --model)
    model_spec="$2"
    shift 2
    ;;
  -p | --path)
    text_path="$2"
    shift 2
    ;;
  -o | --output)
    output_dir="$2"
    shift 2
    ;;
  -s | --speed)
    speed="$2"
    shift 2
    ;;
  -k | --speaker)
    speaker="$2"
    shift 2
    ;;
  -q | --no-verbose)
    verbose=0
    shift 1
    ;;
  *)
    extra_args="$extra_args $1"
    shift
    ;;
  esac
done

# Mandatory arguments: voice AND text
[ -z "$model_spec" ] && {
  echo "Error: voice is required (number, name, or path)"
  exit 1
}
[ -z "$text_path" ] && {
  echo "Error: text or file path (-p/--path) is required"
  exit 1
}

# Resolve the voice spec to an absolute .onnx path
case "$model_spec" in
[0-9]*) # numeric index → look up in the ls order
  idx=1
  voice_path=""
  for voice in "$PIPER_VOICES_DIR"/*.onnx; do
    if [ -f "$voice" ]; then
      [ "$idx" -eq "$model_spec" ] && {
        voice_path="$voice"
        break
      }
      idx=$((idx + 1))
    fi
  done
  ;;
/*) voice_path="$model_spec" ;;
*.onnx) voice_path="$PIPER_VOICES_DIR/$model_spec" ;;
*) voice_path="$PIPER_VOICES_DIR/${model_spec}.onnx" ;;
esac

[ ! -f "$voice_path" ] && {
  echo "Error: voice not found at '$voice_path' (see: k-piper ls)"
  exit 1
}

# Decide the output file:
#   -o <dir>            → <dir>/<base>.wav
#   text FILE           → same directory as the file, same base name, .wav
#   raw TEXT (default)  → /tmp/k-piper/<timestamp>.wav (played, then kept)
timestamp=$(date +%Y%m%d_%H%M%S)
if [ -f "$text_path" ]; then
  base_name=$(basename "$text_path")
  base_name="${base_name%.*}"
  text_dir="$(dirname "$text_path")"
  text_dir="${text_dir%/}"
  if [ -n "$output_dir" ]; then
    output_dir="${output_dir%/}"
    mkdir -p "$output_dir"
    output_file="$output_dir/${base_name}.wav"
  else
    if [ "$text_dir" = "." ]; then
      output_file="${base_name}.wav"
    else
      output_file="$text_dir/${base_name}.wav"
    fi
  fi
  play=0
else
  if [ -n "$output_dir" ]; then
    output_dir="${output_dir%/}"
    mkdir -p "$output_dir"
    output_file="$output_dir/piper-synthesis.wav"
    play=0
  else
    mkdir -p /tmp/k-piper
    output_file="/tmp/k-piper/${timestamp}.wav"
    play=1
  fi
fi

if [ "$verbose" -eq 1 ]; then
  echo "[k-piper] Synthesizing with voice $(basename "$voice_path" .onnx)"
  echo "[k-piper] Speed: $speed | Output: $output_file"
fi

piper_opts="--model \"$voice_path\" --espeak_data \"$ESPEAK_DATA_DIR\" --length_scale \"$speed\" --output_file \"$output_file\""
[ -n "$speaker" ] && piper_opts="$piper_opts --speaker $speaker"

# Hide Piper stderr logs if not verbose
piper_redirect=""
[ "$verbose" -eq 0 ] && piper_redirect="2>/dev/null"

# Feed piper from the file content, or from the raw string
if [ -f "$text_path" ]; then
  eval "cat \"$text_path\" | \"$PIPER_BIN\" $piper_opts $extra_args $piper_redirect"
else
  eval "echo \"$text_path\" | \"$PIPER_BIN\" $piper_opts $extra_args $piper_redirect"
fi
exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  if [ "$play" -eq 1 ]; then
    [ "$verbose" -eq 1 ] && echo "[k-piper] Playing synthesized audio..."
    mpv --quiet "$output_file"
    [ "$verbose" -eq 1 ] && echo "[k-piper] Speech played and kept at $output_file"
  else
    if [ "$verbose" -eq 1 ]; then
      echo "[k-piper] Synthesis complete."
      echo "[k-piper] Audio saved to: $output_file"
    fi
  fi
else
  echo "[k-piper] Error during speech synthesis"
fi

exit "$exit_code"

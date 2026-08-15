#!/usr/bin/env sh
# ============================================================
# k-translate — Sovereign wrapper for CTranslate2 (NLLB-200)
# ------------------------------------------------------------
# Always executed as a standalone script (never sourced).
#
# Model management:   k-translate ls | pull <name> | rm <spec>
# Translation:        k-translate <model|index|path> -p <text|file> -t <target_lang> [-s <source_lang>] [-o <dir>]
#                     k-translate -m <model|index|path> -p <text|file> -t <target_lang> [-s <source_lang>] [-o <dir>]
#
# The model is ALWAYS required at call time.
# ============================================================

# ── Constants ────────────────────────────────────────────────
DEFAULT_THREADS="4"
DEFAULT_TARGET="eng_Latn"

# ── Model store ──────────────────────────────────────────────
CTRANSLATE_MODELS_DIR="${CTRANSLATE_MODELS_DIR:-$HOME/.local/share/ctranslate2}"

# ── Python Environment ───────────────────────────────────────
# Fully sovereign: uses uv run with ephemeral dependencies. No central dir.

usage() {
  cat <<'EOF'
Usage:
  k-translate ls                               List installed models
  k-translate pull <model_name>                Download a model (e.g. nllb-200-distilled-600M-ct2-int8)
  k-translate fetch                            List suggested models from HuggingFace
  k-translate rm <index|name|path>             Remove a model
  k-translate <model|index|path> -p <text> -t <tgt> Translate text (model is REQUIRED)

Options:
  -m, --model <model|index|path>  Model to use: index from 'k-translate ls', name, or path
  -p, --path <text|file>          Raw text string or path to a text file (required)
  -o, --output <dir>              Output directory for the .txt file
  -s, --src <lang>                Source language code (e.g., fra_Latn). If omitted, auto-detected.
  -t, --tgt <lang>                Target language code (e.g., eng_Latn)
  --threads <num>                 CPU threads (default: 4)
  -q, --no-verbose                Suppress progress output

Default output: .txt next to the source text file; raw text outputs to console.
EOF
}

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  exit 0
fi

check_net_deps() {
  command -v curl >/dev/null 2>&1 || echo "[Warning] 'curl' is missing." >&2
}

if [ "$1" = "fetch" ]; then
  check_net_deps
  echo "[k-translate] Suggested CTranslate2 models:"
  echo "  - nllb-200-distilled-600M-ct2-int8 (Fast, multilingual, 200+ languages)"
  echo "  - nllb-200-1.3B-ct2-int8 (Balanced)"
  echo "  - nllb-200-3.3B-ct2-int8 (High quality)"
  exit 0
fi

if [ "$1" = "ls" ]; then
  echo "=== Installed CTranslate2 Models ==="
  idx=1
  for model in "$CTRANSLATE_MODELS_DIR"/*; do
    if [ -d "$model" ]; then
      echo "  $idx) $(basename "$model")"
      idx=$((idx + 1))
    fi
  done
  [ "$idx" -eq 1 ] && echo "No models found in $CTRANSLATE_MODELS_DIR (use: k-translate pull nllb-200-distilled-600M-ct2-int8)"
  exit 0
fi

if [ "$1" = "pull" ]; then
  check_net_deps
  model_name="$2"
  [ -z "$model_name" ] && { echo "Error: specify a model name (e.g. 'nllb-200-distilled-600M-ct2-int8')"; exit 1; }
  
  echo "[k-translate] Downloading $model_name into $CTRANSLATE_MODELS_DIR..."
  mkdir -p "$CTRANSLATE_MODELS_DIR"
  uv run --with huggingface_hub python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='JustFrederik/$model_name', local_dir='$CTRANSLATE_MODELS_DIR/$model_name')"
  exit $?
fi

if [ "$1" = "rm" ]; then
  target="$2"
  [ -z "$target" ] && { echo "Error: specify a model index, name, or path"; exit 1; }
  case "$target" in
    [0-9]*)
      idx=1
      file_to_remove=""
      for model in "$CTRANSLATE_MODELS_DIR"/*; do
        if [ -d "$model" ]; then
          [ "$idx" -eq "$target" ] && { file_to_remove="$model"; break; }
          idx=$((idx + 1))
        fi
      done
      ;;
    /*) file_to_remove="$target" ;;
    *)  file_to_remove="$CTRANSLATE_MODELS_DIR/$target" ;;
  esac
  if [ -d "$file_to_remove" ]; then
    echo "[k-translate] Removing model: $file_to_remove"
    rm -rf "$file_to_remove"
    exit $?
  fi
  echo "Error: model not found for specifier '$target'"
  exit 1
fi

case "$1" in
  -*) model_spec="" ;;
  *)  model_spec="$1"; shift ;;
esac

text_path=""
output_dir=""
src_lang=""
tgt_lang="$DEFAULT_TARGET"
threads="$DEFAULT_THREADS"
verbose=1

while [ $# -gt 0 ]; do
  case "$1" in
    -m|--model)   model_spec="$2"; shift 2 ;;
    -p|--path)    text_path="$2";  shift 2 ;;
    -o|--output)  output_dir="$2"; shift 2 ;;
    -s|--src)     src_lang="$2";   shift 2 ;;
    -t|--tgt)     tgt_lang="$2";   shift 2 ;;
    --threads)    threads="$2";    shift 2 ;;
    -q|--no-verbose) verbose=0;    shift 1 ;;
    *)            shift ;;
  esac
done

[ -z "$model_spec" ] && { echo "Error: model is required (number, name, or path)"; exit 1; }
[ -z "$text_path" ]  && { echo "Error: text or file path (-p/--path) is required"; exit 1; }

case "$model_spec" in
  [0-9]*)
    idx=1
    model_path=""
    for model in "$CTRANSLATE_MODELS_DIR"/*; do
      if [ -d "$model" ]; then
        [ "$idx" -eq "$model_spec" ] && { model_path="$model"; break; }
        idx=$((idx + 1))
      fi
    done
    ;;
  /*)  model_path="$model_spec" ;;
  *)   model_path="$CTRANSLATE_MODELS_DIR/$model_spec" ;;
esac

[ ! -d "$model_path" ] && { echo "Error: model not found at '$model_path'"; exit 1; }

is_file=0
output_file=""
if [ -f "$text_path" ]; then
  is_file=1
  base_name=$(basename "$text_path")
  base_name="${base_name%.*}"
  text_dir="$(dirname "$text_path")"
  text_dir="${text_dir%/}"
  if [ -n "$output_dir" ]; then
    output_dir="${output_dir%/}"
    mkdir -p "$output_dir"
    output_file="$output_dir/${base_name}_${tgt_lang}.txt"
  else
    if [ "$text_dir" = "." ]; then
      output_file="${base_name}_${tgt_lang}.txt"
    else
      output_file="$text_dir/${base_name}_${tgt_lang}.txt"
    fi
  fi
fi

if [ "$verbose" -eq 1 ]; then
  echo "[k-translate] Translating using model $(basename "$model_path")"
  echo "[k-translate] Target Language: $tgt_lang"
fi

# We use uv run to execute python script inline with ephemeral dependencies
export CTRANSLATE_MODEL="$model_path"
export CTRANSLATE_SRC="$src_lang"
export CTRANSLATE_TGT="$tgt_lang"
export CTRANSLATE_TEXT="$text_path"
export CTRANSLATE_IS_FILE="$is_file"
export CTRANSLATE_OUT="$output_file"
export CTRANSLATE_THREADS="$threads"

export TRANSFORMERS_VERBOSITY=error
export HF_HUB_DISABLE_SYMLINKS_WARNING=1

uv run --with ctranslate2==4.8.1 --with transformers==5.15.0 python -c "
import os, sys
import ctranslate2
import transformers
import warnings

warnings.filterwarnings('ignore')
transformers.logging.set_verbosity_error()

model_path = os.environ['CTRANSLATE_MODEL']
src_lang = os.environ.get('CTRANSLATE_SRC') or 'fra_Latn'
tgt_lang = os.environ.get('CTRANSLATE_TGT') or 'eng_Latn'
text_path = os.environ['CTRANSLATE_TEXT']
is_file = os.environ['CTRANSLATE_IS_FILE'] == '1'
out_path = os.environ.get('CTRANSLATE_OUT')
threads = int(os.environ.get('CTRANSLATE_THREADS', '4'))

try:
    translator = ctranslate2.Translator(model_path, device='cpu', intra_threads=threads)
    tokenizer = transformers.AutoTokenizer.from_pretrained(model_path)
except Exception as e:
    print(f'Error loading model: {e}')
    sys.exit(1)

if is_file:
    with open(text_path, 'r', encoding='utf-8') as f:
        text = f.read()
else:
    text = text_path

tokenizer.src_lang = src_lang
source = tokenizer.convert_ids_to_tokens(tokenizer.encode(text))
target_prefix = [tgt_lang]

results = translator.translate_batch([source], target_prefix=[target_prefix])
target = results[0].hypotheses[0][1:]

output = tokenizer.decode(tokenizer.convert_tokens_to_ids(target))

if is_file and out_path:
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(output)
    print(f'[k-translate] Translation saved to: {out_path}')
else:
    print(output)
"
exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  echo "[k-translate] Error during translation"
fi

exit "$exit_code"

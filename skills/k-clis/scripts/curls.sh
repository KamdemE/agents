#!/usr/bin/env bash
# curls.sh — secure curl wrapper with provider-based secret injection
# Usage: with-env curls --provider <name> URL [curl options...]
# Reads assets/providers.json for provider→secret mapping
# Never exposes secret values in command line, ps, or history

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROVIDERS_JSON="${SCRIPT_DIR}/../assets/providers.json"

# Parse --provider argument
PROVIDER=""
URL_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --provider)
      PROVIDER="$2"
      shift 2
      ;;
    --provider=*)
      PROVIDER="${1#--provider=}"
      shift
      ;;
    -p)
      PROVIDER="$2"
      shift 2
      ;;
    -p=*)
      PROVIDER="${1#-p=}"
      shift
      ;;
    *)
      URL_ARGS+=("$1")
      shift
      ;;
  esac
done

# Interactive HITL: POST/PUT/PATCH require y/N confirmation on stdin (KπX only)
METHOD="GET"
for i in "${!URL_ARGS[@]}"; do
  [[ "${URL_ARGS[$i]}" == "-X" ]] && METHOD="${URL_ARGS[$((i+1))]}"
done

if [[ "$METHOD" =~ ^(POST|PUT|PATCH)$ ]]; then
  echo "⚠️ Mutation $METHOD detected for URL: ${URL_ARGS[-1]:-<unknown>}" >&2
  read -p "Confirm mutation $METHOD? [y/N] " ans
  case "$ans" in
    [yY])
      ;;
    *)
      echo "❌ Mutation $METHOD cancelled — run in a tmux pane (k-tmux) for interactive KπX validation." >&2
      exit 1
      ;;
  esac
fi

# No provider → plain curl (API publique)
if [ -z "$PROVIDER" ]; then
  exec curl -sS "${URL_ARGS[@]}"
fi

# Check providers.json exists
if [ ! -f "$PROVIDERS_JSON" ]; then
  echo "ERROR: providers.json not found at $PROVIDERS_JSON" >&2
  exit 1
fi

# Parse provider from JSON (capture stderr separately)
PROVIDER_STDOUT=$(mktemp)
PROVIDER_STDERR=$(mktemp)

python3 -c "
import json, sys
with open('$PROVIDERS_JSON') as f:
    data = json.load(f)
providers = data.get('providers', {})
if '$PROVIDER' not in providers:
    print('ERROR: unknown provider \"$PROVIDER\"', file=sys.stderr)
    print('Available: ' + ', '.join(providers.keys()), file=sys.stderr)
    sys.exit(1)
for s in providers['$PROVIDER'].get('secrets', []):
    env = s['env']
    header = s.get('header', 'Authorization')
    scheme = s.get('scheme', '')
    optional = s.get('optional', False)
    print(f'{env}|{header}|{scheme}|{optional}')
" > "$PROVIDER_STDOUT" 2> "$PROVIDER_STDERR"

EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  cat "$PROVIDER_STDERR" >&2
  rm -f "$PROVIDER_STDOUT" "$PROVIDER_STDERR"
  exit 1
fi

PROVIDER_BLOCK=$(cat "$PROVIDER_STDOUT")
rm -f "$PROVIDER_STDOUT" "$PROVIDER_STDERR"

# Build headers from provider secrets
HEADERS=()
while IFS='|' read -r env_var header scheme optional; do
  [ -z "$env_var" ] && continue
  val="${!env_var:-}"
  if [ -n "$val" ]; then
    if [ -n "$scheme" ]; then
      HEADERS+=(-H "$header: $scheme $val")
    else
      HEADERS+=(-H "$header: $val")
    fi
  elif [ "$optional" != "True" ]; then
    echo "ERROR: provider \"$PROVIDER\" requires $env_var (not set)" >&2
    exit 1
  fi
done <<< "$PROVIDER_BLOCK"

# Execute curl with injected headers
exec curl -sS "${HEADERS[@]}" "${URL_ARGS[@]}"

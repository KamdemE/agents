# Ollama helpers — sourced by $HOME/.kshrc

_OLLAMA_IPEX_PROJECT="$HOME/Work/AI/ollama/ipex"

_ollama_ipex() {
  (cd "$_OLLAMA_IPEX_PROJECT" && uv run ipex "$@")
}

ollama-use() {
  case "$1" in
    native)
      _ollama_ipex native
      ;;
    ipex)
      _ollama_ipex start
      ;;
    down)
      _ollama_ipex down
      ;;
    restart)
      _ollama_ipex restart
      ;;
    status)
      _ollama_ipex status
      ;;
    *)
      echo "Usage: ollama-use native | ipex | down | restart | status"
      return 1
      ;;
  esac
}

ollama-unload() {
  if [ -n "${1:-}" ]; then
    _ollama_ipex unload "$1"
  else
    _ollama_ipex unload
  fi
}

ollama-preload() {
  local model_args=()
  if [ -n "${1:-}" ]; then
    model_args+=("$1")
  fi
  if [ -n "${OLLAMA_PRELOAD_TIMEOUT:-}" ]; then
    _ollama_ipex preload "${model_args[@]}" --timeout "$OLLAMA_PRELOAD_TIMEOUT"
  else
    _ollama_ipex preload "${model_args[@]}"
  fi
}

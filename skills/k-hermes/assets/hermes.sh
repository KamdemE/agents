#!/usr/bin/env zsh
# KπX Sovereign Wrapper for Hermes Agent
# Managed by k-hermes skill. Do not edit directly in ~/.local/bin/

export HERMES_HOME="$HOME/.hermes"

# Resolve the real hermes binary from known installation paths
_REAL_HERMES=""
for _p in \
  "$HOME/.local/share/pipx/venvs/hermes/bin/hermes" \
  "$HOME/.local/share/uv/tools/hermes/bin/hermes" \
  "$HOME/.local/bin/hermes-real" \
; do
  if [[ -x "$_p" ]]; then
    _REAL_HERMES="$_p"
    break
  fi
done

if [[ -z "$_REAL_HERMES" ]]; then
  echo "[KπX] ERROR: Hermes Agent binary not found. Install via: uv tool install hermes-agent"
  echo "[KπX] Or set HERMES_REAL_BINARY env var to the real hermes binary path."
  exit 1
fi

exec "$_REAL_HERMES" "$@"

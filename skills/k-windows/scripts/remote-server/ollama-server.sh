#!/bin/bash
# ollama-server.sh — run the ollama CLI against a remote server's Ollama
# through a local SSH tunnel (see assets/remote-server/tunnel-server.service
# in this same skill). Generic template — personalize the variables below
# or override via env (e.g. `OLLAMA_SERVER_LOCAL_PORT=11440 ollama-server.sh list`).
#
# CORE FUNCTION ONLY: this script does NOT manage the VPN or the tunnel —
# no merged responsibility. On failure it only tells you what to do; you
# start the services yourself with systemctl.
set -eu

LOCAL_PORT="${OLLAMA_SERVER_LOCAL_PORT:-11435}"
TUNNEL_UNIT="${OLLAMA_SERVER_TUNNEL_UNIT:-tunnel-server.service}"
VPN_UNIT="${OLLAMA_SERVER_VPN_UNIT:-}"                       # optional — leave empty if no VPN gate
HOST="http://127.0.0.1:${LOCAL_PORT}"
CHECK_URL="${HOST}/api/version"

# --- port_ready: exit 0 if the tunnel endpoint answers, 1 otherwise ----------
port_ready() {
  curl -s --max-time 2 "${CHECK_URL}" >/dev/null 2>&1
}

if ! port_ready; then
  echo "ollama-server: cannot reach the remote Ollama at ${HOST} (tunnel down)." >&2
  echo "               What to do:" >&2
  [ -n "$VPN_UNIT" ] && echo "                 1. Start the VPN:     sudo systemctl start ${VPN_UNIT%.service}" >&2
  echo "                 2. Start the tunnel:  systemctl --user start ${TUNNEL_UNIT}" >&2
  echo "                 3. Check tunnel logs:  journalctl --user -u ${TUNNEL_UNIT} -f" >&2
  exit 1
fi

export OLLAMA_HOST="${HOST}"
exec ollama "$@"

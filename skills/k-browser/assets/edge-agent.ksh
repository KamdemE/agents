# KπX Edge agent — visible browser + CDP for MCP attach
# Source from $HOME/.kshrc

export KPIHX_EDGE_DATA="${KPIHX_EDGE_DATA:-$HOME/.config/kpihx-edge-automation}"
export KPIHX_EDGE_DEBUG_PORT="${KPIHX_EDGE_DEBUG_PORT:-9222}"
export KPIHX_EDGE_CDP_URL="http://127.0.0.1:${KPIHX_EDGE_DEBUG_PORT}/json/version"

_edge_agent_script() {
  "$HOME/.agents/skills/k-browser/scripts/edge-agent.sh" "$@"
}

edge-agent() {
  _edge_agent_script "$@"
}

edge-agent-status() {
  if curl -sf "$KPIHX_EDGE_CDP_URL" >/dev/null 2>&1; then
    print -u2 "OK — Edge CDP listening on port $KPIHX_EDGE_DEBUG_PORT"
    curl -s "$KPIHX_EDGE_CDP_URL" | head -c 200
    print ""
    return 0
  fi
  print -u2 "Edge CDP not reachable on $KPIHX_EDGE_DEBUG_PORT — run: edge-agent"
  return 1
}

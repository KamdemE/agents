#!/bin/bash
# tmux-server.sh — SSH to a remote server and attach to its tmux session.
# Generic template — copy into a machine/company-specific skill and
# personalize SSH_ALIAS/VPN_UNIT below (or override via env before calling,
# e.g. `TMUX_SERVER_SSH_ALIAS=myserver tmux-server.sh attach`).
# Issue guidance: when the VPN or SSH fails, echoes exactly what to do —
# this script never starts services itself (no merged responsibility, same
# philosophy as ollama-server.sh / vpn-intranet.service in this skill).
set -u

SSH_ALIAS="${TMUX_SERVER_SSH_ALIAS:-<server-alias>}"   # must resolve via ~/.ssh/config
VPN_UNIT="${TMUX_SERVER_VPN_UNIT:-}"                     # optional — leave empty if no VPN gate

# --- vpn_active: exit 0 if no VPN is configured, or the unit is running ------
vpn_active() {
  [ -z "$VPN_UNIT" ] && return 0
  systemctl is-active --quiet "$VPN_UNIT"
}

if ! vpn_active; then
  echo "tmux-server: ERROR — the VPN (${VPN_UNIT}) is not connected." >&2
  echo "             What to do:" >&2
  echo "               sudo systemctl start ${VPN_UNIT%.service}" >&2
  echo "               systemctl status ${VPN_UNIT%.service}" >&2
  echo "               journalctl -u ${VPN_UNIT%.service} -f" >&2
  exit 1
fi

# Attach over SSH; if it fails (host down, auth), explain what to check.
if ssh -t "$SSH_ALIAS" tmux "$@"; then
  exit 0
else
  echo "tmux-server: ERROR — SSH to ${SSH_ALIAS} failed." >&2
  echo "             What to do:" >&2
  [ -n "$VPN_UNIT" ] && echo "               systemctl status ${VPN_UNIT%.service}   # is the VPN still connected?" >&2
  echo "               ssh ${SSH_ALIAS}                     # test the SSH alias directly" >&2
  exit 1
fi

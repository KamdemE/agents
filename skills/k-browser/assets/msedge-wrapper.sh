#!/bin/bash
# msedge wrapper — permanently adds --remote-debugging-port=9222
# Source: ~/.agents/skills/k-browser/assets/msedge-wrapper.sh
#
# This wrapper survives Edge updates because it's in YOUR .agents/,
# not in /opt/microsoft/msedge/ (which gets overwritten on each update).
#
# Installed via: ln -sf ~/.agents/skills/k-browser/assets/msedge-wrapper.sh ~/.local/bin/msedge

exec /opt/microsoft/msedge/msedge --remote-debugging-port=9222 "$@"

#!/bin/bash
# KπX — Standard tmux session per equipment
# Usage: ./setup-session.sh [session-name]
#   If session-name omitted, auto-detects equipment via Tailscale.
#   Creates standard 3-window session: agents, default, tmp.
#
# Auto-detection:
#   1. tailscale status --json → hostname (stripped of kpihx- prefix)
#   2. fallback: hostname -s

set -e

# --- Auto-detect ---
detect_equipment() {
    local ts_name
    ts_name=$(tailscale status --json 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    name = d.get('Self', {}).get('DNSName', '').split('.')[0]
    print(name.lower() if name else '')
except Exception:
    print('')
" 2>/dev/null)

    if [ -n "$ts_name" ]; then
        ts_name="${ts_name#kpihx-}"
        echo "$ts_name"
        return 0
    fi

    local h
    h=$(hostname -s | tr '[:upper:]' '[:lower:]')
    echo "${h#kpihx-}"
}

SESSION_NAME="${1:-$(detect_equipment)}"

if [ -z "$SESSION_NAME" ]; then
    echo "Error: could not detect equipment."
    echo "Usage: $0 [session-name]"
    exit 1
fi

# --- Idempotent ---
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists."
    echo "Attach: tmux attach -t $SESSION_NAME"
    exit 0
fi

# --- Create ---
echo "Creating tmux session: $SESSION_NAME"

# Window 0: agents (3 panes)
#  Pane 0 (left) = agents pane (opencode)
#  Pane 1 (right-top) = editors pane (nvim)
#  Pane 2 (right-bottom) = ops pane (sudo/ssh)
tmux new-session -d -s "$SESSION_NAME" -c ~/KpihX-Labs
tmux rename-window -t "$SESSION_NAME:0" agents
tmux split-window -h -t "$SESSION_NAME:agents.0" -c ~/KpihX-Labs
tmux split-window -v -t "$SESSION_NAME:agents.1" -c ~/KpihX-Labs

# Window 1: default
tmux new-window -t "$SESSION_NAME" -n default -c ~/

# Window 2: tmp
tmux new-window -t "$SESSION_NAME" -n tmp -c /tmp

echo "Done. Attach: tmux attach -t $SESSION_NAME"

#!/bin/bash
set -e

# Sovereign sui Remote Wrapper
DEFAULT_HOST="homelab"
DEFAULT_PORT="1143"
SSH_CTRL_DIR="${HOME}/.ssh/control"

CYAN='\033[0;36m'
NC='\033[0m'

function usage() {
    echo "Usage: sui [WRAPPER_OPTIONS] [COMMANDS]"
    echo "Options: --host, -H HOST | --port, -P PORT | --close"
    exit 1
}

REMOTE_HOST="${SUI_HOST:-$DEFAULT_HOST}"
TUNNEL_PORT="${SUI_PORT:-$DEFAULT_PORT}"
REMOTE_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --host|-H) REMOTE_HOST="$2"; shift 2 ;;
        --port|-P) TUNNEL_PORT="$2"; shift 2 ;;
        --close)
            CTRL_PATH="${SSH_CTRL_DIR}/sui-remote"
            if [ -S "${CTRL_PATH}" ]; then
                ssh -S "${CTRL_PATH}" -O exit "${REMOTE_HOST}" 2>/dev/null || true
                echo "✅ Tunnel closed."
            fi
            exit 0
            ;;
        *) REMOTE_ARGS+=("$1"); shift ;;
    esac
done

if [ ${#REMOTE_ARGS[@]} -eq 0 ]; then usage; fi

mkdir -p "${SSH_CTRL_DIR}"
CTRL_PATH="${SSH_CTRL_DIR}/sui-${REMOTE_HOST}"

if ! ssh -S "${CTRL_PATH}" -O check "${REMOTE_HOST}" 2>/dev/null; then
    echo -e "${CYAN}🚀 Initializing SSH tunnel for Sui validation to ${REMOTE_HOST}...${NC}"
    ssh -M -f -N -S "${CTRL_PATH}" \
        -L "${TUNNEL_PORT}:localhost:${TUNNEL_PORT}" \
        -o ExitOnForwardFailure=yes \
        -o ControlPersist=10m \
        "${REMOTE_HOST}"
fi

ssh -S "${CTRL_PATH}" -t "${REMOTE_HOST}" \
    "SUI_PORT=${TUNNEL_PORT} sui ${REMOTE_ARGS[*]}"

#!/bin/bash
set -e

# sui Universal Installer (Release Mode)
GITHUB_RAW_URL="https://raw.githubusercontent.com/KpihX/sui/main"
DOCKER_IMAGE="kpihx/sui:latest"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}🚀 sui — Sovereign Unified Interface Installer${NC}"

if ! command -v docker &> /dev/null; then echo -e "${RED}❌ docker not found.${NC}"; exit 1; fi
if ! command -v python3 &> /dev/null; then echo -e "${RED}❌ python3 required for shim.${NC}"; exit 1; fi

BIN_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.sui"
SHIM_DEST="${BIN_DIR}/sui"

mkdir -p "${BIN_DIR}" "${DATA_DIR}"
chmod 700 "${DATA_DIR}"

if [ -f "Dockerfile" ]; then
    docker build -t "${DOCKER_IMAGE}" .
else
    docker pull "${DOCKER_IMAGE}"
fi

if [ -f "scripts/sui_shim.py" ]; then
    chmod +x "scripts/sui_shim.py"
    ln -sf "$(pwd)/scripts/sui_shim.py" "${SHIM_DEST}"
else
    curl -sSL "${GITHUB_RAW_URL}/scripts/sui_shim.py" -o "${SHIM_DEST}"
    chmod +x "${SHIM_DEST}"
fi

echo -e "\n${GREEN}✅ sui installed successfully!${NC}"

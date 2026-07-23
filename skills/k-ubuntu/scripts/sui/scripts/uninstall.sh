#!/bin/bash
set -e

# sui Universal Uninstaller
BIN_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.sui"
SHIM_DEST="${BIN_DIR}/sui"

RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}🗑️ Uninstalling sui...${NC}"

rm -f "${SHIM_DEST}"
docker rmi kpihx/sui:latest 2>/dev/null || true

read -p "Do you want to delete all configuration and logs in ${DATA_DIR}? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "${DATA_DIR}"
    echo "✅ Purged ${DATA_DIR}"
fi

echo "✅ sui uninstalled."

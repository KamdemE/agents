#!/bin/bash
# ==============================================================================
# Script Name: clean_editors.sh
# Description: Wrapper script to clean caches for Code, Cursor, and Antigravity
# API: --infos/-i, --safe/-s, --purge/-p
# Author: KpihX / AI
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
PARAMS="$@"

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Show cache sizes for all editors"
    echo "  -s, --safe      Clear standard GPU/Workspace Cache for all editors"
    echo "  -p, --purge     Clear ALL caches + Ext/User state for all editors"
    exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then usage; fi

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}===      EDITORS CLEANUP START       ===${NC}"
echo -e "${PURPLE}========================================${NC}"

EDITORS=("clean_vscode.sh" "clean_cursor.sh" "clean_agy.sh")

for editor in "${EDITORS[@]}"; do
    if [ -f "$SCRIPT_DIR/$editor" ]; then
        echo -e "\n${BLUE}>>> EDITOR STAGE: ${editor^^}${NC}"
        "$SCRIPT_DIR/$editor" $PARAMS
    fi
done

echo -e "\n${PURPLE}========================================${NC}"
echo -e "${PURPLE}===       EDITORS CLEANUP END        ===${NC}"
echo -e "${PURPLE}========================================${NC}"

#!/bin/bash
# ==============================================================================
# Script Name: clean_all.sh
# Description: Master script for full system cleanup (Snap, Cache, Work, Docker, AI)
# API: --infos/-i, --safe/-s, --purge/-p, --system, --yes/-y
# ==============================================================================
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

PARAMS=("$@")
SCRIPT_DIR="$(dirname "$0")"

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Combined system analysis"
    echo "  -s, --safe      Run safe cleanup on all modules"
    echo "  -p, --purge     Run deep purge on all modules"
    echo "  --system        Run system cleanup (sudo when needed)"
    echo "  -y, --yes       Auto-confirm all prompts"
    echo ""
    echo "Examples:"
    echo "  $0 -s            # safe mode, interactive"
    echo "  $0 -s -y         # safe mode, auto-confirm"
    echo "  $0 -p --system   # deep purge + system (sudo)"
    exit 0
}

if [ ${#PARAMS[@]} -eq 0 ]; then usage; exit 0; fi

# Check if --help/-h is anywhere in args
for arg in "${PARAMS[@]}"; do
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then usage; fi
done

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}===    TOTAL SYSTEM CLEANUP START    ===${NC}"
echo -e "${PURPLE}========================================${NC}"

# Stages
STAGES=("clean_snap.sh" "clean_cache.sh" "clean_editors.sh" "clean_work.sh" "clean_docker.sh" "clean_ai.sh")

for stage in "${STAGES[@]}"; do
    if [ -f "$SCRIPT_DIR/$stage" ]; then
        echo -e "\n${BLUE}>>> STAGE: ${stage^^}${NC}"
        "$SCRIPT_DIR/$stage" "${PARAMS[@]}"
    fi
done

echo -e "\n${PURPLE}========================================${NC}"
echo -e "${PURPLE}===    TOTAL SYSTEM CLEANUP END      ===${NC}"
echo -e "${PURPLE}========================================${NC}"

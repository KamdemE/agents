#!/bin/bash
# ==============================================================================
# Script Name: clean_ai.sh
# Description: AI Models and Caches cleanup (Ollama, HuggingFace)
# API: --infos/-i, --safe/-s, --purge/-p
# Author: Gemini-CLI / KpihX
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

MODE_SAFE=false
MODE_PURGE=false
MODE_INFOS=false

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Show AI models and cache sizes"
    echo "  -s, --safe      Safe cleanup: Clear HuggingFace temp logs"
    echo "  -p, --purge     Deep cleanup: Purge phantom Ollama models and HF cache"
    exit 0
}

confirm() {
    [[ "$PARAMS" =~ "-y" || "$PARAMS" =~ "--system" ]] && return 0
    echo -en "${YELLOW}[CONFIRM]${NC} $1 (y/n)? "
    read -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

show_infos() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}===       AI STORAGE ANALYSIS        ===${NC}"
    echo -e "${PURPLE}========================================${NC}
"
    echo -e "${BLUE}[Ollama System (/usr/share/ollama)]${NC}"
    sudo du -sh /usr/share/ollama 2>/dev/null || echo "Not found"
    echo -e "
${BLUE}[Ollama User (~/.ollama)]${NC}"
    du -sh ~/.ollama 2>/dev/null
    echo -e "
${BLUE}[HuggingFace (~/.cache/huggingface)]${NC}"
    du -sh ~/.cache/huggingface 2>/dev/null
}

clean_safe() {
    echo -e "
${BLUE}>>> STEP: SAFE AI CLEANUP${NC}"
    if [ -d ~/.cache/huggingface ]; then
        if confirm "Remove HuggingFace locks and logs"; then
            find ~/.cache/huggingface -name "*.lock" -delete
            echo -e "${GREEN}[SUCCESS]${NC} AI temp files removed."
        fi
    fi
}

clean_purge() {
    echo -e "
${RED}>>> STEP: PURGE AI MODELS (Aggressive)${NC}"
    if [ -d ~/.ollama/models/blobs ]; then
        if confirm "Purge phantom Ollama models from Home (keeping System models)"; then
            rm -rf ~/.ollama/models/blobs/*
            rm -rf ~/.ollama/models/manifests/*
            echo -e "${GREEN}[SUCCESS]${NC} Phantom models purged."
        fi
    fi
    if [ -d ~/.cache/huggingface ]; then
        if confirm "Remove ALL HuggingFace models"; then
            rm -rf ~/.cache/huggingface/*
            echo -e "${GREEN}[SUCCESS]${NC} HF Cache cleared."
        fi
    fi
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--infos) MODE_INFOS=true ;;
        -s|--safe) MODE_SAFE=true ;;
        -p|--purge) MODE_PURGE=true ;;
        *|--system) ;; *) usage ;;
    esac
    shift
done

if [ "$MODE_INFOS" = true ]; then show_infos; exit 0; fi
[ "$MODE_SAFE" = true ] && clean_safe
[ "$MODE_PURGE" = true ] && clean_purge

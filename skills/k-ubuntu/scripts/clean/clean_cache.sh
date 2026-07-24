#!/bin/bash
# ==============================================================================
# Script Name: clean_cache.sh
# Description: Global Cache cleanup tool (uv, npm, pnpm, browsers, trash, root)
# API: --infos/-i, --safe/-s, --purge/-p, --system/-y
# Author: Gemini-CLI / KpihX
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[133m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

MODE_SAFE=false
MODE_PURGE=false
MODE_SYSTEM=false
MODE_INFOS=false
PARAMS=("$@")

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Show detailed cache analysis (Read-only)"
    echo "  -s, --safe      Safe cleanup: Trash, Edge static, Home diagnostic logs"
    echo "  -p, --purge     Deep cleanup: UV, NPM, pnpm, HuggingFace, Edge Code Cache"
    echo "  -y, --system    System cleanup: APT, Journal, Root Trash/NPM (Sudo)"
    exit 0
}

confirm() {
    for _p in "${PARAMS[@]}"; do [[ "$_p" == "-y" || "$_p" == "--yes" || "$_p" == "--system" ]] && return 0; done && return 0
    echo -en "${YELLOW}[CONFIRM]${NC} $1 (y/n)? "
    read -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

get_dir_size() {
    [ -d "$1" ] && du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "0B"
}

get_total_usage() {
    local t=$(du -s ~/.cache ~/.npm ~/.local/share/pnpm ~/.local/share/Trash 2>/dev/null | awk '{s+=$1} END {print s}')
    echo $t
}

show_infos() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}===    GLOBAL CACHE SPACE ANALYSIS   ===${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
    printf "${BLUE}%-35s %-15s${NC}\n" "Category" "Size"
    printf "%-35s %-15s\n" "-----------------------------------" "-------"
    printf "%-35s %-15s\n" "Trash (~/.local/share/Trash)" "$(get_dir_size ~/.local/share/Trash)"
    printf "%-35s %-15s\n" "UV Cache (~/.cache/uv)" "$(get_dir_size ~/.cache/uv)"
    printf "%-35s %-15s\n" "NPM Cache (~/.npm)" "$(get_dir_size ~/.npm)"
    printf "%-35s %-15s\n" "pnpm Store (~/.local/share/pnpm)" "$(get_dir_size ~/.local/share/pnpm)"
    printf "%-35s %-15s\n" "Edge Cache (~/.cache/microsoft-edge)" "$(get_dir_size ~/.cache/microsoft-edge)"
    
    echo -e "\n${YELLOW}[SYSTEM/ROOT CACHES (Requires Sudo)]${NC}"
    printf "%-35s %-15s\n" "System Journal (/var/log/journal)" "$(sudo du -sh /var/log/journal 2>/dev/null | awk '{print $1}')"
    printf "%-35s %-15s\n" "Root Trash (/root/.local/share/Trash)" "$(sudo du -sh /root/.local/share/Trash 2>/dev/null | awk '{print $1}')"
    printf "%-35s %-15s\n" "Root NPM Cache (/root/.npm)" "$(sudo du -sh /root/.npm 2>/dev/null | awk '{print $1}')"
}

clean_safe() {
    echo -e "\n${BLUE}>>> STEP: SAFE CACHE CLEANUP${NC}"
    # Trash
    if confirm "Empty Trash (System & trash-cli)"; then
        rm -rf ~/.local/share/Trash/*
        command -v trash-empty >/dev/null 2>&1 && trash-empty -f
        echo -e "${GREEN}[SUCCESS]${NC} Trash emptied."
    fi
    # Edge
    if [ -d ~/.cache/microsoft-edge ]; then
        if confirm "Clean Edge static cache"; then
            rm -rf ~/.cache/microsoft-edge/Default/Cache/*
            echo -e "${GREEN}[SUCCESS]${NC} Edge static cache cleared."
        fi
    fi
    # Home Root Logs
    if confirm "Remove diagnostic logs from Home root (*.log, *.ncdu, *.bak)"; then
        rm -f ~/*.log ~/*.ncdu ~/*.bak
        echo -e "${GREEN}[SUCCESS]${NC} Home root logs cleared."
    fi
}

clean_purge() {
    echo -e "\n${RED}>>> STEP: PURGE CACHE CLEANUP (Dev & Models)${NC}"
    [ -d ~/.cache/uv ] && confirm "Clean UV cache" && uv cache clean
    [ -d ~/.npm ] && confirm "Clean NPM cache" && npm cache clean --force
    [ -d ~/.local/share/pnpm ] && confirm "Prune pnpm store" && npx pnpm store prune
}

clean_system() {
    echo -e "\n${PURPLE}>>> STEP: SYSTEM CACHE CLEANUP (Sudo)${NC}"
    if confirm "Clean APT archives"; then sudo apt-get clean; fi
    if confirm "Vacuum System Journal (2 days)"; then sudo journalctl --vacuum-time=2d; fi
    if confirm "Purge Root user Trash and NPM cache"; then
        sudo rm -rf /root/.local/share/Trash/*
        sudo rm -rf /root/.npm/*
        echo -e "${GREEN}[SUCCESS]${NC} Root maintenance done."
    fi
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--infos) MODE_INFOS=true ;;
        -s|--safe) MODE_SAFE=true ;;
        -p|--purge) MODE_PURGE=true ;;
        -y|--yes) ;;
--system) MODE_SYSTEM=true ;;
        *) usage ;;
    esac
    shift
done

if [ "$MODE_INFOS" = true ]; then show_infos; exit 0; fi
INITIAL_SPACE=$(get_total_usage)
[ "$MODE_SAFE" = true ] && clean_safe
[ "$MODE_PURGE" = true ] && clean_purge
[ "$MODE_SYSTEM" = true ] && clean_system
if [ "$MODE_SAFE" = true ] || [ "$MODE_PURGE" = true ]; then
    FINAL_SPACE=$(get_total_usage)
    echo -e "\n${GREEN}Total User Space Saved: $(((INITIAL_SPACE - FINAL_SPACE)/1024)) MB${NC}"
fi

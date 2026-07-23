#!/bin/bash

# ==============================================================================
# Script Name: clean_snap.sh
# Description: Advanced Snap cleanup tool (Refactored API)
# API: --infos/-i, --safe/-s, --purge/-p, --system/-y, --specific
# Author: Gemini-CLI / KpihX
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MODE_SAFE=false
MODE_PURGE=false
MODE_SYSTEM=false
MODE_INFOS=false
MODE_SPECIFIC=false

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Show detailed Snap distribution and stats"
    echo "  -s, --safe      Safe cleanup: Remove disabled revisions"
    echo "  -p, --purge     Purge cleanup: Remove all cache folders in ~/snap"
    echo "  -y, --system    System cleanup: Delete all Snapshots (sudo)"
    echo "  --specific      Targeted cleanup for KpihX apps (Brave, Discord, etc.)"
    echo "  -h, --help      Display this help"
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
    echo -e "${BLUE}=== SNAP SPACE ANALYSIS ===${NC}"
    echo -e "\n${YELLOW}[USER SPACE]${NC}"
    du -h -d 1 ~/snap 2>/dev/null | sort -hr
    echo -e "\n${YELLOW}[SYSTEM SPACE]${NC}"
    sudo du -h -d 1 /var/lib/snapd 2>/dev/null | sort -hr
    echo -e "\n${YELLOW}[DISABLED REVISIONS]${NC}"
    snap list --all | grep "disabled" || echo "None"
    echo -e "\n${YELLOW}[SNAPSHOTS]${NC}"
    snap saved || echo "None"
}

clean_safe() {
    echo -e "\n${GREEN}--- Executing SAFE Snap Cleanup ---${NC}"
    REVISIONS=$(snap list --all | awk '/disabled/{print $1, $3}')
    if [ -n "$REVISIONS" ]; then
        echo "Found disabled revisions:"
        echo "$REVISIONS"
        if confirm "Remove these revisions"; then
            echo "$REVISIONS" | while read name rev; do sudo snap remove "$name" --revision="$rev"; done
        fi
    else
        echo "No disabled revisions found."
    fi
}

clean_purge() {
    echo -e "\n${RED}--- Executing PURGE Snap Cleanup (Caches) ---${NC}"
    if confirm "Remove ALL .cache folders in ~/snap"; then
        find ~/snap -type d \( -name "Cache" -o -name ".cache" -o -name "GPUCache" -o -name "Code Cache" \) -exec rm -rf {} +
        echo "Caches cleared."
    fi
}

clean_system() {
    echo -e "\n${BLUE}--- Executing SYSTEM Snap Cleanup ---${NC}"
    SNAPSHOTS=$(snap saved | tail -n +2)
    if [ -n "$SNAPSHOTS" ]; then
        echo "Snapshots found:"
        echo "$SNAPSHOTS"
        if confirm "Delete all snapshots"; then
            echo "$SNAPSHOTS" | awk '{print $1}' | while read setid; do sudo snap forget "$setid"; done
        fi
    else
        echo "No snapshots found."
    fi
}

clean_specific() {
    echo -e "\n${YELLOW}--- Executing SPECIFIC App Cleanup ---${NC}"
    if confirm "Clean logs/caches for Brave, Discord, Telegram, OnlyOffice, Gemini"; then
        [ -d ~/snap/discord ] && find ~/snap/discord -type d \( -name "logs" -o -name "crash_reports" \) -exec rm -rf {} +
        [ -d ~/snap/brave ] && find ~/snap/brave -name "Cache" -type d -exec rm -rf {}/* \;
        [ -d ~/snap/telegram-desktop ] && find ~/snap/telegram-desktop -name "cache" -type d -exec rm -rf {}/* \;
        [ -d ~/snap/onlyoffice-desktopeditors ] && find ~/snap/onlyoffice-desktopeditors -name "cache" -type d -exec rm -rf {}/* \;
        [ -d ~/snap/gemini-desktop ] && find ~/snap/gemini-desktop -type d \( -name "Cache" -o -name "GPUCache" \) -exec rm -rf {}/* \;
        echo "Specific targets cleaned."
    fi
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--infos) MODE_INFOS=true ;;
        -s|--safe) MODE_SAFE=true ;;
        -p|--purge) MODE_PURGE=true ;;
        -y|--system) MODE_SYSTEM=true ;;
        --specific) MODE_SPECIFIC=true ;;
        -h|--help) usage ;;
        *) echo "Unknown: $1"; usage ;;
    esac
    shift
done

if [ "$MODE_INFOS" = true ]; then show_infos; exit 0; fi

[ "$MODE_SAFE" = true ] && clean_safe
[ "$MODE_PURGE" = true ] && clean_purge
[ "$MODE_SYSTEM" = true ] && clean_system
[ "$MODE_SPECIFIC" = true ] && clean_specific

if [ "$MODE_SAFE" = false ] && [ "$MODE_PURGE" = false ] && [ "$MODE_SYSTEM" = false ] && [ "$MODE_SPECIFIC" = false ]; then
    echo "No mode selected. Use -s, -p, -y, or --specific."
fi

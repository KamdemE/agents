#!/bin/bash
# ==============================================================================
# Script Name: clean_vscode.sh
# Description: VSCode cache cleanup (~/.config/Code/ — not ~/.cache/)
# API: --infos/-i, --safe/-s, --purge/-p
# Author: Claude / KpihX
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

VSCODE_DIR="$HOME/.config/Code"

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Show VSCode cache space analysis"
    echo "  -s, --safe      Safe cleanup: VSIX cache, HTTP cache, logs"
    echo "  -p, --purge     Deep cleanup: CachedData, WebStorage (extension state)"
    exit 0
}

confirm() {
    [[ "$PARAMS" =~ "-y" || "$PARAMS" =~ "--system" ]] && return 0
    echo -en "${YELLOW}[CONFIRM]${NC} $1 (y/n)? "
    read -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

get_dir_size() {
    [ -d "$1" ] && du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "0B"
}

show_infos() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}===    VSCODE CACHE SPACE ANALYSIS   ===${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
    printf "${BLUE}%-40s %-10s${NC}\n" "Target" "Size"
    printf "%-40s %-10s\n" "----------------------------------------" "------"
    printf "%-40s %-10s\n" "CachedExtensionVSIXs/ (VSIX post-install)" "$(get_dir_size "$VSCODE_DIR/CachedExtensionVSIXs")"
    printf "%-40s %-10s\n" "Cache/ (Electron HTTP cache)"              "$(get_dir_size "$VSCODE_DIR/Cache")"
    printf "%-40s %-10s\n" "logs/ (Session logs)"                      "$(get_dir_size "$VSCODE_DIR/logs")"
    printf "%-40s %-10s\n" "CachedData/ (Compiled extension JS)"       "$(get_dir_size "$VSCODE_DIR/CachedData")"
    printf "%-40s %-10s\n" "WebStorage/ (Extension state, chat hist.)" "$(get_dir_size "$VSCODE_DIR/WebStorage")"
    echo ""
    printf "%-40s %-10s\n" "Extensions (~/.vscode/extensions/)"        "$(get_dir_size "$HOME/.vscode/extensions")"
    printf "%-40s %-10s\n" "workspaceStorage/"                         "$(get_dir_size "$VSCODE_DIR/User/workspaceStorage")"
}

clean_safe() {
    echo -e "\n${BLUE}>>> STEP: SAFE VSCODE CLEANUP${NC}"

    if [ -d "$VSCODE_DIR/CachedExtensionVSIXs" ]; then
        if confirm "Remove VSIX install cache (kept post-install, not needed)"; then
            rm -rf "$VSCODE_DIR/CachedExtensionVSIXs"
            echo -e "${GREEN}[SUCCESS]${NC} CachedExtensionVSIXs cleared."
        fi
    fi

    if [ -d "$VSCODE_DIR/Cache" ]; then
        if confirm "Clear VSCode Electron HTTP cache"; then
            rm -rf "$VSCODE_DIR/Cache"
            echo -e "${GREEN}[SUCCESS]${NC} Cache cleared."
        fi
    fi

    if [ -d "$VSCODE_DIR/logs" ]; then
        if confirm "Remove VSCode session logs"; then
            rm -rf "$VSCODE_DIR/logs"
            echo -e "${GREEN}[SUCCESS]${NC} Logs cleared."
        fi
    fi
}

clean_purge() {
    echo -e "\n${RED}>>> STEP: PURGE VSCODE (Aggressive — extension state)${NC}"

    if [ -d "$VSCODE_DIR/CachedData" ]; then
        if confirm "Remove CachedData (compiled extension JS — slow to regenerate ~1min)"; then
            rm -rf "$VSCODE_DIR/CachedData"
            echo -e "${GREEN}[SUCCESS]${NC} CachedData cleared."
        fi
    fi

    if [ -d "$VSCODE_DIR/WebStorage" ]; then
        echo -e "${RED}[WARNING]${NC} WebStorage contains extension chat histories and session state."
        if confirm "Remove WebStorage (extensions lose their stored state/history)"; then
            rm -rf "$VSCODE_DIR/WebStorage"
            echo -e "${GREEN}[SUCCESS]${NC} WebStorage cleared."
        fi
    fi
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--infos) MODE_INFOS=true ;;
        -s|--safe)  MODE_SAFE=true ;;
        -p|--purge) MODE_PURGE=true ;;
        --system|-y) ;; # accepted silently (passed by clean_all.sh)
        *) ;;
    esac
    shift
done

if [ "$MODE_INFOS" = true ]; then show_infos; exit 0; fi

INITIAL_SPACE=$(du -sk "$VSCODE_DIR" 2>/dev/null | awk '{print $1}' || echo 0)
[ "$MODE_SAFE"  = true ] && clean_safe
[ "$MODE_PURGE" = true ] && clean_purge
FINAL_SPACE=$(du -sk "$VSCODE_DIR" 2>/dev/null | awk '{print $1}' || echo 0)
echo -e "\n${GREEN}VSCode Space Saved: $(((INITIAL_SPACE - FINAL_SPACE)/1024)) MB${NC}"

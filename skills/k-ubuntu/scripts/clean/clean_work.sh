#!/bin/bash

# ==============================================================================
# Script Name: clean_work.sh
# Description: Development workspace cleanup (git, venv, node_modules)
# API: --infos/-i, --safe/-s, --purge/-p, --top N
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
TOP_N=10

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Show project analysis and top folders"
    echo "  -s, --safe      Safe cleanup: Compress Git history, remove pycache & build artifacts"
    echo "  -p, --purge     Purge cleanup: Interactive removal of venv/node_modules"
    echo "  --top N         Set number of top folders for analysis (Default: 10)"
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
    echo -e "${PURPLE}=== WORKSPACE ANALYSIS (Top $TOP_N Projects) ===${NC}
"
    du -h -d 2 $HOME/Work 2>/dev/null | sort -hr | head -n "$TOP_N"

    echo -e "
${YELLOW}[DEPENDENCIES SCAN]${NC}"
    local venvs
    venvs=$(find $HOME/Work -type d \( -name "venv" -o -name ".venv" -o -name "env" \) -prune 2>/dev/null | wc -l)
    local nodes
    nodes=$(find $HOME/Work -type d -name "node_modules" -prune 2>/dev/null | wc -l)
    echo "Environments (venv/env): $venvs found."
    echo "Node Modules (node_modules): $nodes found."

    echo -e "
${YELLOW}[GIT STORAGE]${NC}"
    echo "Total .git size: $(find $HOME/Work -name ".git" -type d -prune -exec du -sh {} + 2>/dev/null | awk '{s+=$1} END {print s/1024 " MB"}')"
}

clean_safe() {
    echo -e "
${BLUE}>>> STEP: SAFE WORK CLEANUP (Optimization)${NC}"

    if confirm "Optimize Git histories (git gc)"; then
        find $HOME/Work -name ".git" -type d -prune 2>/dev/null | while read -r gitdir; do
            repo=$(dirname "$gitdir")
            echo -e "${GREEN}[OPT]${NC} Compressing $(basename "$repo")..."
            (cd "$repo" && git gc --quiet --prune=now)
        done
    fi

    if confirm "Remove Python/Build temp files (__pycache__, .pytest_cache, etc.)"; then
        find $HOME/Work -type d \( -name "__pycache__" -o -name ".pytest_cache" -o -name ".ruff_cache" -o -name ".ipynb_checkpoints" \) -exec rm -rf {} + 2>/dev/null || true
        echo -e "${GREEN}[SUCCESS]${NC} Temp files removed."
    fi

    local artifacts
    artifacts=$(find $HOME/Work -type d \( -name "dist" -o -name "build" -o -name "target" -o -name ".next" \) \
        -not -path "*/node_modules/*" -not -path "*/.git/*" -prune 2>/dev/null)
    if [ -n "$artifacts" ]; then
        echo -e "${YELLOW}[BUILD ARTIFACTS]${NC} Found:"
        du -sh $artifacts 2>/dev/null | sort -hr
        if confirm "Remove build artifacts (dist/, build/, target/, .next/)"; then
            echo "$artifacts" | xargs rm -rf
            echo -e "${GREEN}[SUCCESS]${NC} Build artifacts removed."
        fi
    fi
}

clean_purge() {
    echo -e "
${RED}>>> STEP: PURGE WORK CLEANUP (Dependencies)${NC}"

    local deps
    deps=$(find $HOME/Work -type d \( -name "venv" -o -name ".venv" -o -name "node_modules" \) -prune 2>/dev/null)
    if [ -n "$deps" ]; then
        echo -e "${YELLOW}Found the following dependency folders:${NC}"
        du -sh $deps 2>/dev/null
        if confirm "Remove ALL these dependency folders"; then
            echo "$deps" | xargs rm -rf
            echo -e "${GREEN}[SUCCESS]${NC} Environments and node_modules purged."
        fi
    else
        echo "No dependency folders found."
    fi
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--infos) MODE_INFOS=true ;;
        -s|--safe)  MODE_SAFE=true ;;
        -p|--purge) MODE_PURGE=true ;;
        --top)      shift; TOP_N=$1 ;;
        -h|--help)  usage ;;
        --system|-y) ;; # accepted silently (passed by clean_all.sh)
        *) echo "Unknown option: $1"; usage ;;
    esac
    shift
done

if [ "$MODE_INFOS" = true ]; then show_infos; exit 0; fi

INITIAL_SPACE=$(du -s $HOME/Work 2>/dev/null | awk '{print $1}' || echo 0)
[ "$MODE_SAFE"  = true ] && clean_safe
[ "$MODE_PURGE" = true ] && clean_purge
FINAL_SPACE=$(du -s $HOME/Work 2>/dev/null | awk '{print $1}' || echo 0)
echo -e "
${GREEN}Workspace Saved Space: $(((INITIAL_SPACE - FINAL_SPACE)/1024)) MB${NC}"

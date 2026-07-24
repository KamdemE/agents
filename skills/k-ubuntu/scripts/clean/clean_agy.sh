#!/bin/bash
# ==============================================================================
# Script Name: clean_agy.sh
# Description: Antigravity cache cleanup (~/.config/Antigravity/ — not ~/.cache/)
# API: --infos/-i, --safe/-s, --purge/-p
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
PARAMS=("$@")
MODE_LIVE=false
MODE_REOPEN=false

AGY_DIR="$HOME/.config/Antigravity"
EXTENSIONS_DIR="$HOME/.antigravity/extensions"

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Show Antigravity cache space analysis"
    echo "  -s, --safe      Safe cleanup: VSIX cache, HTTP cache, logs"
    echo "  -p, --purge     Deep cleanup: CachedData, WebStorage (extension state)"
    echo "  -l, --live      Live recovery: close AGY, kill AGY subprocess tree, clean Crashpad/pending"
    echo "  -r, --reopen    Reopen AGY after --live recovery"
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

show_infos() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}===  ANTIGRAVITY CACHE SPACE ANALYSIS ===${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
    printf "${BLUE}%-40s %-10s${NC}\n" "Target" "Size"
    printf "%-40s %-10s\n" "----------------------------------------" "------"
    printf "%-40s %-10s\n" "CachedExtensionVSIXs/" "$(get_dir_size "$AGY_DIR/CachedExtensionVSIXs")"
    printf "%-40s %-10s\n" "Cache/ (Electron HTTP cache)" "$(get_dir_size "$AGY_DIR/Cache")"
    printf "%-40s %-10s\n" "logs/ (Session logs)" "$(get_dir_size "$AGY_DIR/logs")"
    printf "%-40s %-10s\n" "CachedData/ (Compiled extension JS)" "$(get_dir_size "$AGY_DIR/CachedData")"
    printf "%-40s %-10s\n" "WebStorage/ (Extension state)" "$(get_dir_size "$AGY_DIR/WebStorage")"
    echo ""
    printf "%-40s %-10s\n" "Extensions (~/.antigravity/extensions/)" "$(get_dir_size "$EXTENSIONS_DIR")"
    printf "%-40s %-10s\n" "workspaceStorage/" "$(get_dir_size "$AGY_DIR/User/workspaceStorage")"
}

clean_safe() {
    echo -e "\n${BLUE}>>> STEP: SAFE ANTIGRAVITY CLEANUP${NC}"
    if [ -d "$AGY_DIR/CachedExtensionVSIXs" ]; then
        if confirm "Remove VSIX install cache"; then
            rm -rf "$AGY_DIR/CachedExtensionVSIXs"
            echo -e "${GREEN}[SUCCESS]${NC} CachedExtensionVSIXs cleared."
        fi
    fi
    if [ -d "$AGY_DIR/Cache" ]; then
        if confirm "Clear Antigravity Electron HTTP cache"; then
            rm -rf "$AGY_DIR/Cache"
            echo -e "${GREEN}[SUCCESS]${NC} Cache cleared."
        fi
    fi
    if [ -d "$AGY_DIR/logs" ]; then
        if confirm "Remove Antigravity session logs"; then
            rm -rf "$AGY_DIR/logs"
            echo -e "${GREEN}[SUCCESS]${NC} Logs cleared."
        fi
    fi
}

clean_purge() {
    echo -e "\n${RED}>>> STEP: PURGE ANTIGRAVITY (Aggressive — extension state)${NC}"
    if [ -d "$AGY_DIR/CachedData" ]; then
        if confirm "Remove CachedData (compiled JS)"; then
            rm -rf "$AGY_DIR/CachedData"
            echo -e "${GREEN}[SUCCESS]${NC} CachedData cleared."
        fi
    fi
    if [ -d "$AGY_DIR/WebStorage" ]; then
        echo -e "${RED}[WARNING]${NC} WebStorage contains extension states."
        if confirm "Remove WebStorage"; then
            rm -rf "$AGY_DIR/WebStorage"
            echo -e "${GREEN}[SUCCESS]${NC} WebStorage cleared."
        fi
    fi
}

collect_agy_tree_pids() {
    local roots all changed
    roots=$(ps -eo pid=,args= | awk '/\/usr\/share\/antigravity\/antigravity/ {print $1}' | sort -u)
    [ -z "$roots" ] && return 0
    all="$roots"
    changed=1

    while [ "$changed" -eq 1 ]; do
        local new=""
        changed=0
        while read -r pid ppid; do
            for known in $all; do
                if [ "$ppid" = "$known" ]; then
                    case " $all $new " in
                        *" $pid "*) ;;
                        *)
                            new="$new $pid"
                            changed=1
                            ;;
                    esac
                fi
            done
        done < <(ps -eo pid=,ppid=)
        all="$all $new"
    done

    echo "$all" | tr ' ' '\n' | awk 'NF' | sort -u | tr '\n' ' '
}

clean_live() {
    echo -e "\n${BLUE}>>> STEP: LIVE ANTIGRAVITY RECOVERY${NC}"
    local agy_pids pending_count

    agy_pids=$(collect_agy_tree_pids)
    if [ -n "$agy_pids" ]; then
        if confirm "Close Antigravity and terminate AGY subprocess tree"; then
            kill -TERM $agy_pids 2>/dev/null
            sleep 2
            agy_pids=$(collect_agy_tree_pids)
            if [ -n "$agy_pids" ]; then
                kill -KILL $agy_pids 2>/dev/null
            fi
            echo -e "${GREEN}[SUCCESS]${NC} AGY process tree cleanup applied."
        fi
    else
        echo -e "${YELLOW}[INFO]${NC} No running AGY process tree detected."
    fi

    if [ -d "$AGY_DIR/Crashpad/pending" ]; then
        shopt -s nullglob
        local pending_files=("$AGY_DIR/Crashpad/pending/"*)
        pending_count=${#pending_files[@]}
        shopt -u nullglob
        if [ "$pending_count" -gt 0 ]; then
            if confirm "Clean Crashpad/pending ($pending_count files)"; then
                rm -f "$AGY_DIR/Crashpad/pending/"*
                echo -e "${GREEN}[SUCCESS]${NC} Crashpad pending dumps cleared."
            fi
        else
            echo -e "${YELLOW}[INFO]${NC} Crashpad/pending already empty."
        fi
    fi
}

reopen_agy() {
    if command -v antigravity >/dev/null 2>&1; then
        nohup antigravity >/dev/null 2>&1 &
        echo -e "${GREEN}[SUCCESS]${NC} Antigravity reopened."
        return 0
    fi
    if [ -x /usr/share/antigravity/antigravity ]; then
        nohup /usr/share/antigravity/antigravity >/dev/null 2>&1 &
        echo -e "${GREEN}[SUCCESS]${NC} Antigravity reopened."
        return 0
    fi
    echo -e "${YELLOW}[WARNING]${NC} Could not find antigravity binary to reopen."
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--infos) MODE_INFOS=true ;;
        -s|--safe)  MODE_SAFE=true ;;
        -p|--purge) MODE_PURGE=true ;;
        -l|--live) MODE_LIVE=true ;;
        -r|--reopen) MODE_REOPEN=true ;;
        -h|--help) usage ;;
        --system|-y) ;;
        *) ;;
    esac
    shift
done

if [ "$MODE_INFOS" = true ]; then show_infos; exit 0; fi

INITIAL_SPACE=$(du -sk "$AGY_DIR" 2>/dev/null | awk '{print $1}' || echo 0)
[ "$MODE_SAFE"  = true ] && clean_safe
[ "$MODE_PURGE" = true ] && clean_purge
[ "$MODE_LIVE" = true ] && clean_live
[ "$MODE_REOPEN" = true ] && {
    if [ "$MODE_LIVE" = true ]; then
        reopen_agy
    else
        echo -e "${YELLOW}[WARNING]${NC} --reopen ignored because --live was not requested."
    fi
}
FINAL_SPACE=$(du -sk "$AGY_DIR" 2>/dev/null | awk '{print $1}' || echo 0)
echo -e "\n${GREEN}Antigravity Space Saved: $(((INITIAL_SPACE - FINAL_SPACE)/1024)) MB${NC}"

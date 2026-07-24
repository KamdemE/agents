#!/bin/bash
# ==============================================================================
# Script Name: clean_docker.sh
# Description: Advanced Docker cleanup (Images, Volumes, Networks)
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
PARAMS=("$@")

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -i, --infos     Detailed Docker storage analysis"
    echo "  -s, --safe      Safe cleanup: Remove dangling images/containers"
    echo "  -p, --purge     Deep cleanup: Remove all unused images & volumes"
    echo "  -h, --help      Display this help"
    exit 0
}

confirm() {
    for _p in "${PARAMS[@]}"; do [[ "$_p" == "-y" || "$_p" == "--yes" || "$_p" == "--system" ]] && return 0; done && return 0
    echo -en "${YELLOW}[CONFIRM]${NC} $1 (y/n)? "
    read -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

show_infos() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}===      DOCKER STORAGE ANALYSIS     ===${NC}"
    echo -e "${PURPLE}========================================${NC}
"
    sudo docker system df
    echo -e "
${BLUE}[VOLUMES]${NC}"
    sudo du -h -d 1 /var/lib/docker/volumes 2>/dev/null | sort -hr
}

clean_safe() {
    echo -e "
${BLUE}>>> STEP: SAFE DOCKER CLEANUP${NC}"
    if confirm "Prune dangling images and stopped containers"; then
        sudo docker system prune -f
        echo -e "${GREEN}[SUCCESS]${NC} Docker pruned."
    fi
}

clean_purge() {
    echo -e "
${RED}>>> STEP: PURGE DOCKER CLEANUP (Aggressive)${NC}"
    if confirm "Remove ALL unused images, volumes, and networks"; then
        sudo docker system prune -a --volumes -f
        echo -e "${GREEN}[SUCCESS]${NC} Docker fully purged."
    fi
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--infos) MODE_INFOS=true ;;
        -s|--safe) MODE_SAFE=true ;;
        -p|--purge) MODE_PURGE=true ;;
        -h|--help) usage ;;
        -y|--yes) ;;
--system) ;;
        *) usage ;;
    esac
    shift
done

if [ "$MODE_INFOS" = true ]; then show_infos; exit 0; fi
[ "$MODE_SAFE" = true ] && clean_safe
[ "$MODE_PURGE" = true ] && clean_purge

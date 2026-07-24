#!/bin/bash

cd "$(dirname "$0")" || exit 1
# Source the Homelab universal library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/lib/notifier.sh"

# ==============================================================================
# CONFIGURATION
# ==============================================================================
LOG_FILE="/var/log/maintenance.log"

# Proxy (Indispensable pour apt à l'X)
# export http_proxy=http://129.104.201.11:8080
# export https_proxy=http://129.104.201.11:8080

# ==============================================================================
# FONCTIONS
# ==============================================================================
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# ==============================================================================
# DÉBUT DU TRAITEMENT
# ==============================================================================
log "Démarrage de la maintenance..."
homelab_notify "CLEAN" "Début de la maintenance automatique (Mises à jour + Nettoyage)..." "MAINTENANCE"

# 1. MISE À JOUR SYSTÈME (Debian/Proxmox)
log "Update & Upgrade APT..."
apt-get update >> "$LOG_FILE" 2>&1
apt-get upgrade -y >> "$LOG_FILE" 2>&1
apt-get autoremove -y >> "$LOG_FILE" 2>&1
apt-get autoclean >> "$LOG_FILE" 2>&1

# 2. NETTOYAGE DOCKER (Dans le conteneur 100)
# On commande au conteneur docker-host de faire son ménage
log "Nettoyage Docker sur le conteneur 100..."
/usr/sbin/pct exec 100 -- docker system prune -a -f --volumes >> "$LOG_FILE" 2>&1

# 3. NOTIFICATION FINALE ET REBOOT
log "Maintenance terminée. Redémarrage..."
homelab_notify "SUCCESS" "Maintenance terminée.%0A🔄 Le serveur va redémarrer dans 1 minute." "MAINTENANCE"

# On attend un peu pour que le message Telegram parte
sleep 5

# Reboot
/sbin/reboot

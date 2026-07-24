#!/bin/bash

cd "$(dirname "$0")" || exit 1
# Chargement de la configuration
[ -f .env ] && source .env

# ==============================================================================
# 1. CONFIGURATION
# ==============================================================================
LOG_FILE="/var/log/net_switch.log"
INT_DIR="/etc/network"
CURRENT_FILE="$INT_DIR/interfaces"

# Vérification Root
if [[ "$EUID" -ne 0 ]]; then
   echo "❌ Ce script doit être lancé en root."
   exit 1
fi

# ==============================================================================
# 2. FONCTIONS
# ==============================================================================

log() {
    # Affiche à l'écran et écrit dans le fichier log
    local msg="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

send_telegram() {
    local icon="$1"
    local title="$2"
    local message="$3"
    
    local text="$icon **$title** $icon%0A%0A$message"
    
    curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_HOMELAB_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$text" \
        -d parse_mode="Markdown" > /dev/null 2>&1
}

wait_for_internet() {
    log "⏳ Vérification de la connectivité..."
    local max_retries=10
    local count=0
    
    while ! ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; do
        sleep 2
        ((count++))
        if [ $count -ge $max_retries ]; then
            return 1
        fi
    done
    return 0
}

# ==============================================================================
# 3. ANALYSE DES ARGUMENTS
# ==============================================================================

MODE="$1"

case $MODE in
    wifi)
        SOURCE="$INT_DIR/interfaces.wifi"
        ICON="📶"
        TEXT_MODE="WI-FI (wlo1)"
        IFACE="wlo1"
        ;;
    wired)
        SOURCE="$INT_DIR/interfaces.wired"
        ICON="🔌"
        TEXT_MODE="FILAIRE (nic1/vmbr0)"
        IFACE="vmbr0"
        ;;
    *)
        echo "Usage: $0 [wifi|wired]"
        echo "  wifi  : Utilise wlo1 + NAT via wlo1"
        echo "  wired : Utilise nic1 + NAT via vmbr0"
        exit 1
        ;;
esac

if [ ! -f "$SOURCE" ]; then
    log "❌ Erreur : Le fichier source $SOURCE n'existe pas."
    exit 1
fi

# ==============================================================================
# 4. EXÉCUTION DU BASCULEMENT
# ==============================================================================

log "🚀 Début du basculement vers : $TEXT_MODE"

# 1. Backup de sécurité
log "💾 Sauvegarde de la config actuelle..."
cp "$CURRENT_FILE" "$CURRENT_FILE.bak"

# 2. Application de la nouvelle config
log "📝 Copie de la configuration..."
cp "$SOURCE" "$CURRENT_FILE"

# 3. Nettoyage pré-restart (Pour éviter les conflits)
log "🧹 Nettoyage des processus réseau..."
killall wpa_supplicant dhclient 2>/dev/null

# Fix AppArmor préventif (au cas où dhclient serait bloqué)
if [ -f /etc/apparmor.d/sbin.dhclient ]; then
    ln -sf /etc/apparmor.d/sbin.dhclient /etc/apparmor.d/disable/ 2>/dev/null
    apparmor_parser -R /etc/apparmor.d/sbin.dhclient 2>/dev/null || true
fi

# 4. Redémarrage du réseau
log "🔄 Redémarrage des services networking..."

if systemctl restart networking; then
    log "✅ Service networking redémarré."
    
    # Attente active de l'internet pour envoyer la notif
    if wait_for_internet; then
        # Récupération de l'IP pour l'info
        NEW_IP=$(ip -4 addr show "$IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
        
        log "✅ Connectivité OK. IP: $NEW_IP"
        send_telegram "$ICON" "RÉSEAU BASCULÉ" "Le serveur est passé en mode **$MODE** avec succès.%0A%0A📌 Interface : \`$IFACE\`%0A🌐 IP : \`$NEW_IP\`"
    else
        log "⚠️ Service redémarré mais PAS d'internet."
        # On ne rollback pas forcément ici, car c'est peut-être juste un délai DHCP
    fi
    
    # Petit check visuel console
    echo "--- État des interfaces ---"
    ip -br addr show | grep -E "wlo1|vmbr0"

else
    log "❌ Erreur critique lors du redémarrage réseau."
    log "🔙 Restauration de l'ancienne config..."
    cp "$CURRENT_FILE.bak" "$CURRENT_FILE"
    systemctl restart networking
    log "⚠️ Retour à la config précédente."
    exit 1
fi

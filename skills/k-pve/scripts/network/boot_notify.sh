#!/bin/bash

# On se place dans le dossier du script
cd "$(dirname "$0")" || exit 1

[ -f .env ] && source .env

# ==============================================================================
# 1. CONFIGURATION & AUTO-DÉTECTION
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../lib/notifier.sh"

LOG_FILE="/var/log/boot_notify.log"

echo "$(date) - Démarrage du script de notification..." >> "$LOG_FILE"

# Boucle d'attente réseau (Max 60 essais de 5s = 5 minutes)
MAX_RETRIES=60
COUNT=0

# On attend que le réseau se mette en place
sleep 10
while ! ping -c 1 -W 2 google.com > /dev/null 2>&1; do
    echo "$(date) - Pas de réseau, attente..." >> "$LOG_FILE"
    sleep 5
    COUNT=$((COUNT+1))
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo "$(date) - Abandon : Pas de réseau après 5 minutes." >> "$LOG_FILE"
        exit 1
    fi
done

echo "$(date) - Réseau OK. Envoi Telegram..." >> "$LOG_FILE"

# Envoi du message
homelab_notify "SUCCESS" "🚀 **SERVEUR EN LIGNE**%0AJe suis redémarré et connecté !" "SYSTEM"

echo "$(date) - Terminé." >> "$LOG_FILE"

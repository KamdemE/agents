#!/bin/bash

# ==============================================================================
# CONFIGURATION AUTOMATISÉE EDUROAM (X / POLYTECHNIQUE)
# Usage: ./setup_eduroam.sh <chemin_script_python> <email> <password>
# ==============================================================================

PYTHON_SCRIPT="$1"
USER_ID="$2"
USER_PASS="$3"

if [ -z "$PYTHON_SCRIPT" ] || [ -z "$USER_ID" ] || [ -z "$USER_PASS" ]; then
    echo "Usage: $0 <path_to_python_script> <email> <password>"
    exit 1
fi

echo "🚀 Démarrage de la configuration Eduroam..."

# 1. Nettoyage préventif
rm -rf ~/.config/cat_installer
mkdir -p /etc/wpa_supplicant/certs

# 2. Exécution du générateur Python (Mode silencieux)
echo "🐍 Exécution du script Python..."
chmod +x "$PYTHON_SCRIPT"
python3 "$PYTHON_SCRIPT" --silent --wpa_conf -u "$USER_ID" -p "$USER_PASS"

if [ ! -f ~/.config/cat_installer/cat_installer.conf ]; then
    echo "❌ Erreur : Le fichier de config n'a pas été généré."
    exit 1
fi

# 3. Installation des fichiers
echo "📂 Installation des certificats et configs..."

# Copie du certificat CA
cp ~/.config/cat_installer/ca.pem /etc/wpa_supplicant/certs/poly_ca.pem

# Copie de la config WPA
TARGET_CONF="/etc/wpa_supplicant/eduroam.conf"
cp ~/.config/cat_installer/cat_installer.conf "$TARGET_CONF"

# 4. Patch du fichier de configuration (Sed Magic)
# On remplace le chemin du certificat par le bon chemin système
# On s'assure que scan_ssid=1 est présent (vital pour le wifi)

echo "🔧 Ajustement des chemins et paramètres..."

# Remplacement du chemin du certificat
sed -i 's|ca_cert=".*"|ca_cert="/etc/wpa_supplicant/certs/poly_ca.pem"|' "$TARGET_CONF"

# Ajout de scan_ssid=1 juste après ssid="..."
sed -i '/ssid=".*"/a \ \ \ \ \ \ \ \ scan_ssid=1' "$TARGET_CONF"

# Sécurisation des permissions
chmod 600 "$TARGET_CONF"

echo "✅ Configuration Eduroam terminée !"
echo "📄 Fichier généré : $TARGET_CONF"
echo "🔑 Certificat : /etc/wpa_supplicant/certs/poly_ca.pem"

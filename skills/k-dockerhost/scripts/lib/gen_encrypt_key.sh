#!/bin/bash
# gen_vault_key.sh - Deterministic Key Derivation for .vault_secret
# Allows you to derive your GPG passphrase from your Master Password.

# A static salt to ensure the key is unique to your Homelab infrastructure.
SALT="Homelab-Sovereign-Vault-2026-KpihX"

echo "🔐 --- Vaultwarden Key Derivation Tool ---"
echo -n "🔑 Enter your Vault Master Password (hidden): "
read -s MASTER_PASS
echo ""

if [ -z "$MASTER_PASS" ]; then
    echo "❌ Error: Password cannot be empty."
    exit 1
fi

# Deriving a 64-character hex key using SHA-256 + Salt
DERIVED_KEY=$(echo -n "${MASTER_PASS}${SALT}" | openssl dgst -sha256 | awk '{print $NF}')

echo "--------------------------------------------------------"
echo "🛡️  DERIVED GPG KEY :"
echo "--------------------------------------------------------"
echo "$DERIVED_KEY"
echo "--------------------------------------------------------"
echo "📑 Copy the key above and paste it into :"
echo "   docker-host:/root/.vault_secret"
echo "--------------------------------------------------------"
echo "⚠️  Keep your Master Password safe. If you lose it,"
echo "   you can't regenerate this specific GPG key to decrypt backups."

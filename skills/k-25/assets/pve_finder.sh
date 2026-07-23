#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# PVE FINDER — locate Proxmox server when its subnet changes
# Scans subnets around the last known IP using parallel TCP + SSH fingerprint.
# Skill: k-25
# Target: Termux (S25)
# ==============================================================================

set -euo pipefail

# --- Config: import secrets from .env ---
ENV_FILE="${HOME}/.agents/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# SSH
SSH_PORT=2222
SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_EXPECTED_FINGERPRINT="SHA256:rTRwyaqaUtvOW0oEdv8HPYbZ1fS8Ckl2ui+FRZK23og"

# SSH aliases to update
HOST_ALIASES=("homelab" "homelab-ui")
REFERENCE_ALIAS="homelab"

# How many subnets to scan before/after the last known IP
# e.g. IP 10.0.50.x + range 5 → scans 10.0.45.x through 10.0.55.x
SCAN_SUBNET_RANGE=5

# Logging — centralized in ~/.agents/logs/
LOGFILE="$HOME/.agents/logs/pve_finder.log"
FOUND_IP_FILE="/tmp/pve_found_ip"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

log() {
    local level="$1"
    shift
    local msg="$*"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] [$level] $msg" | tee -a "$LOGFILE"
}

send_telegram() {
    local emoji="$1"
    local title="$2"
    local msg="$3"

    if [[ -z "${TELEGRAM_S25_TOKEN:-}" ]]; then
        log "WARN" "TELEGRAM_S25_TOKEN not set — skipping notification"
        return
    fi

    curl -s -X POST \
        "https://api.telegram.org/bot${TELEGRAM_S25_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${emoji} **${title}** ${emoji}%0A%0A${msg}" \
        -d parse_mode="Markdown" > /dev/null 2>&1
}

get_old_ip() {
    if [[ ! -f "$SSH_CONFIG_FILE" ]]; then
        log "ERROR" "SSH config file not found: $SSH_CONFIG_FILE"
        return 1
    fi
    awk -v host="$REFERENCE_ALIAS" '
        $1 == "Host" && $2 == host {found=1; next}
        found && $1 == "HostName" {print $2; exit}
    ' "$SSH_CONFIG_FILE"
}

compute_fingerprint() {
    local ip="$1"
    local key
    key=$(ssh-keyscan -t ed25519 -p "$SSH_PORT" -T 3 "$ip" 2>/dev/null)
    if [[ -z "$key" ]]; then return 1; fi
    echo "$key" | ssh-keygen -lf - 2>/dev/null | awk '{print $2}'
}

update_ssh_config() {
    local alias="$1"
    local new_ip="$2"
    local tmp_file
    tmp_file=$(mktemp)

    awk -v host="$alias" -v newip="$new_ip" '
        $1 == "Host" && $2 == host {in_block=1; print; next}
        $1 == "Host" && $2 != host {in_block=0; print; next}
        in_block && $1 == "HostName" {print "    HostName " newip; next}
        {print}
    ' "$SSH_CONFIG_FILE" > "$tmp_file"

    mv "$tmp_file" "$SSH_CONFIG_FILE"
}

check_ip_worker() {
    local target_ip="$1"

    # Quick TCP ping — skip if port closed
    timeout 0.2 bash -c "echo > /dev/tcp/$target_ip/$SSH_PORT" 2>/dev/null || return

    # Full fingerprint verification
    local fp
    fp=$(compute_fingerprint "$target_ip")
    if [[ "$fp" == "$SSH_EXPECTED_FINGERPRINT" ]]; then
        echo "$target_ip" > "$FOUND_IP_FILE"
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    log "INFO" "--- PVE Finder started ---"
    rm -f "$FOUND_IP_FILE"

    OLD_IP=$(get_old_ip)
    if [[ -z "$OLD_IP" ]]; then
        log "ERROR" "Could not read old IP from SSH config."
        exit 1
    fi

    IFS='.' read -r A B C D <<< "$OLD_IP"

    MIN_C=$((C - SCAN_SUBNET_RANGE))
    MAX_C=$((C + SCAN_SUBNET_RANGE))

    if [[ $MIN_C -lt 0 ]]; then MIN_C=0; fi
    if [[ $MAX_C -gt 255 ]]; then MAX_C=255; fi

    log "INFO" "Target: networks $A.$B.[$MIN_C-$MAX_C].x"

    for (( subnet=MIN_C; subnet<=MAX_C; subnet++ )); do
        if [[ -f "$FOUND_IP_FILE" ]]; then break; fi

        CURRENT_NET="$A.$B.$subnet"
        log "INFO" "Scanning subnet $CURRENT_NET.0/24..."

        for host in {1..254}; do
            if [[ -f "$FOUND_IP_FILE" ]]; then break; fi

            target="$CURRENT_NET.$host"
            check_ip_worker "$target" &

            # Throttle: 50 parallel workers max at a time
            if (( host % 50 == 0 )); then sleep 0.1; fi
        done

        # Wait for this subnet to finish before moving on
        wait
    done

    if [[ -f "$FOUND_IP_FILE" ]]; then
        NEW_IP=$(cat "$FOUND_IP_FILE")
        log "SUCCESS" "Server found: $NEW_IP"

        for alias in "${HOST_ALIASES[@]}"; do
            update_ssh_config "$alias" "$NEW_IP"
        done

        if [[ "$NEW_IP" != "$OLD_IP" ]]; then
            send_telegram "🎉" "IP FOUND" "New IP: \`$NEW_IP\` (old: $OLD_IP)"
        else
            log "INFO" "IP unchanged."
        fi
    else
        log "ERROR" "Server not found in range $A.$B.[$MIN_C-$MAX_C].x"
        send_telegram "❌" "SCAN FAILED" "Server not found in range $A.$B.[$MIN_C-$MAX_C].x"
    fi

    rm -f "$FOUND_IP_FILE"
}

main

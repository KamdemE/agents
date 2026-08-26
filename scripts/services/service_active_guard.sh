#!/usr/bin/env bash
# ============================================================
# service_active_guard.sh — sub-check: unit is-active + recent journal
# ============================================================
# Part of check-services.sh (modular split). For an expect-active service,
# verifies systemctl is-active and prints the recent journal. Handles the
# IPEX-exclusive-switch exclusion (native ollama intentionally stopped when the
# ipex-llm Docker backend is alive). Sets active_ok=1 on success, 0 on failure.
# ============================================================

# IPEX backend liveness (Docker container ipex-llm). The ipex/ollama-ipex CLI is
# an EXCLUSIVE switch between native systemd ollama and the IPEX Docker backend
# on 127.0.0.1:11434 — when IPEX is the active backend, the native ollama.service
# is intentionally stopped. So when ipex-llm is alive, we SKIP the ollama.service
# is-active check (ollama stays expect-active:true in services.jsonc — we handle
# the exclusion here in code, not in the registry, for security/simplicity).
ipex_active() {
  docker ps --format '{{.Names}}' | grep -qx 'ipex-llm'
}

# service_active_guard <unit> <type>  → sets active_ok
service_active_guard() {
  local unit="$1" type="$2"
  active_ok=1
  local scope_flag=""
  [ "$type" = "user" ] && scope_flag="--user"

  if [ "$unit" = "ollama.service" ] && ipex_active; then
    echo "  ✓ is-active: SKIPPED (IPEX backend alive — native ollama intentionally stopped)"
    return
  fi

  local active
  active="$(systemctl $scope_flag is-active "$unit" | tr -d '\n')"
  if [ "$active" = "active" ]; then
    echo "  ✓ is-active: active"
  else
    echo "  ✗ is-active: ${active:-<not active>} (EXPECTED active)"
    active_ok=0
  fi
  echo "  ── recent journal ($unit):"
  journalctl $scope_flag -u "$unit" -n 8 --no-pager | sed 's/^/     /' | tail -8
}

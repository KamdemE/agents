#!/usr/bin/env bash
# ============================================================
# service_asset_guard.sh — sub-check: canonical asset + deployed presence
# ============================================================
# Part of check_services.sh (modular split). Verifies, for one service:
#   1. canonical asset exists (path in $HOME/.agents/...)
#   2. it is deployed in the right systemd dir (user/system) — symlink OR copy
# Returns 0 on success; appends findings to a shared buffer (env var).
# ============================================================

# shellcheck disable=SC1090
source "$SCRIPT_DIR/lib.sh"

# check_service_asset <name> <unit> <type> <path>  → sets asset_ok, deployed_ok
service_asset_guard() {
  local name="$1" unit="$2" type="$3" path="$4"
  asset_ok=1; deployed_ok=1

  # 1. Canonical asset present?
  local target="${path//\$HOME/$HOME}"
  if [ ! -f "$target" ]; then
    echo "  ✗ canonical asset MISSING: $target"
    asset_ok=0
    deployed_ok=0
    return
  fi
  echo "  ✓ canonical: $target"

  # 2. Deployed in the right systemd dir — by REAL unit name
  local unit_dir
  if [ "$type" = "user" ]; then
    unit_dir="$HOME/.config/systemd/user"
  else
    unit_dir="/etc/systemd/system"
  fi
  local deployed="$unit_dir/$unit"
  if [ -L "$deployed" ]; then
    echo "  ✓ deployed (symlink): $deployed -> $(readlink -f "$deployed")"
  elif [ -f "$deployed" ]; then
    echo "  ✓ deployed (copy):    $deployed"
  else
    echo "  ✗ NOT deployed in $unit_dir (expected $deployed)"
    deployed_ok=0
  fi
}

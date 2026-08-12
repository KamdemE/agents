#!/usr/bin/env bash
# ============================================================
# check-systemd — verify deployed .agents-owned systemd units
# ============================================================
# Scans the two systemd unit directories for symlinks whose
# resolved target lives inside $HOME/.agents, then runs
# `systemd-analyze verify` on each DEPLOYED unit path.
#
# Verifying the deployed path (not the bare asset) is the
# deployment truth: systemd applies drop-ins (e.g. the
# exec-override.conf that fixes ExecStart) at that location,
# so units that legitimately rely on drop-ins pass cleanly.
#
# Second pass (informational): lists unit-file assets under
# skills/assets that are NOT deployed (no symlink in the unit
# dirs). These are IGNORED for the exit code — they exist so an
# agent running the check can spot a critical infra service that
# is not linked on the current machine. A VERIFY warning is
# printed: the agent must check whether any of them was supposed
# to be linked for this infra — if so, notify KπX and propose
# the missing symlink before continuing.
#
# Source:  .agents/scripts/check-systemd.sh
# Caller:  make check-systemd   (joined into `make check`)
# ============================================================

set -uo pipefail

AGENTS_DIR="$HOME/.agents"

# System and user unit load directories (deployed symlinks)
UNIT_DIRS=(
  "/etc/systemd/system"
  "$HOME/.config/systemd/user"
)

checked=0
failed=0
not_linked=0
declare -A deployed_targets=()

for dir in "${UNIT_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  # Only symlinks directly in the unit dir (not Wants=/Requires= subdirs)
  while IFS= read -r unit; do
    # Resolve the symlink target; skip anything not owned by .agents
    # (targets may resolve through $HOME/KpihX-Labs/.agents — both match)
    target="$(readlink -f "$unit" 2>/dev/null || true)"
    case "$target" in
      "$AGENTS_DIR"/*|"$HOME/KpihX-Labs/.agents"/*) ;;
      *) continue ;;
    esac

    base="$(basename "$unit")"
    case "$base" in
      *.service|*.timer|*.socket|*.mount|*.path|*.slice) ;;
      *) continue ;;
    esac

    checked=$((checked + 1))
    deployed_targets["$target"]=1
    if output="$(systemd-analyze verify "$unit" 2>&1)"; then
      echo "  ✓ $base"
    else
      failed=$((failed + 1))
      echo "  ✗ $base"
      printf '%s\n' "$output" | sed 's/^/      /'
    fi
  done < <(find "$dir" -maxdepth 1 -type l -print 2>/dev/null)
done

# --- Second pass: unit-file assets under skills that are NOT deployed ---
# Informational only — these do NOT affect the exit code. They exist
# so an agent can spot a critical infra service that is not linked.
not_linked_list=""
while IFS= read -r asset; do
  # Resolve the same way as deployed targets so comparison is apples-to-apples
  resolved="$(readlink -f "$asset" 2>/dev/null || true)"
  [ -n "$resolved" ] || continue
  if [ -z "${deployed_targets["$resolved"]+x}" ]; then
    not_linked=$((not_linked + 1))
    not_linked_list+="    - ${asset#"$AGENTS_DIR"/}\n"
  fi
done < <(find "$AGENTS_DIR/skills" -path '*/assets/*' -type f \
         \( -name '*.service' -o -name '*.timer' -o -name '*.socket' \
            -o -name '*.mount' -o -name '*.path' -o -name '*.slice' \) \
         -print 2>/dev/null | sort)

if [ "$not_linked" -gt 0 ]; then
  echo "  Not-linked unit assets under skills (informational, ignored for exit code):"
  printf '%b' "$not_linked_list"
  echo "  ⚠️ VERIFY: if any of the above was SUPPOSED to be linked for this infra,"
  echo "     stop and notify KπX — propose the missing symlink before continuing."
fi

echo "systemd: $checked .agents-owned unit(s) verified, $failed failure(s), $not_linked not-linked asset(s) (ignored)"
[ "$failed" -eq 0 ]

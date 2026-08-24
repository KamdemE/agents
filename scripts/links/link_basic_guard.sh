#!/usr/bin/env bash
# ============================================================
# link_basic_guard.sh — sub-check: per-link existence/broken/reversed/dead
# ============================================================
# Part of check_links.sh (modular split). For ONE registered link (already
# filtered by infra), verifies:
#   - the registered target exists in .agents (dead check; skipped for
#     allow-reversed links whose target is intentionally outside .agents)
#   - the source exists AND is a symlink (not a regular file)
#   - its resolved target is not dangling (broken)
#   - its resolved target lives inside $HOME/.agents (reversed/outside), unless
#     the entry declares "allow-reversed": true (tolerated but still reported)
# Sets global counters via a passed results-var prefix. Returns 0.
# ============================================================

# shellcheck disable=SC1090
source "$SCRIPT_DIR/lib.sh"

# link_basic_guard <name> <source> <target> <allow_reversed>
#   appends to $CHECKED / $OK / $ALLOWED / $BROKEN / $REVERSED / $DEAD counters
link_basic_guard() {
  local name="$1" source="$2" target="$3" allow_reversed="$4"
  local src tgt resolved

  src="${source//\$HOME/$HOME}"
  CHECKED=$((CHECKED + 1))

  # Registered-target-exists check (mirror check-services canonical-asset):
  # the .agents source this links.jsonc entry points to must exist (file OR dir).
  # EXCEPTION: allow-reversed links (target intentionally OUTSIDE .agents, e.g. a
  # vendored dependency pointing to the runtime install) are skipped here.
  if [ "$allow_reversed" = "true" ]; then
    echo "  ⚠ allow-reversed=true → registered-target-exists check skipped (target outside .agents)"
  else
    tgt="${target//\$HOME/$HOME}"
    if [ ! -e "$tgt" ]; then
      echo "  ✗ DEAD links.jsonc entry: registered target missing in .agents: $tgt"
      DEAD=$((DEAD + 1))
    fi
  fi

  # Source must be a symlink (not a regular file)
  if [ ! -L "$src" ]; then
    if [ -e "$src" ]; then
      echo "  ✗ REGULAR-FILE (not a symlink): $src (expected -> ${target//\$HOME/$HOME})"
      REVERSED=$((REVERSED + 1))
    else
      echo "  ✗ MISSING symlink: $src"
      BROKEN=$((BROKEN + 1))
    fi
    return
  fi

  # Resolved target must not be dangling
  resolved="$(readlink -f "$src" || true)"
  if [ -z "$resolved" ] || [ ! -e "$resolved" ]; then
    echo "  ✗ BROKEN (dangling): $src -> $resolved"
    BROKEN=$((BROKEN + 1))
    return
  fi

  # Reversed check: resolved target must live inside $HOME/.agents.
  # Strict by default (counts as failure). "allow-reversed": true tolerates an
  # outward target but still reports it (informational), not counted as failure.
  case "$resolved" in
    "$AGENTS_DIR"/*|"$HOME/KpihX-Labs/.agents"/*) ;;
    *)
      if [ "$allow_reversed" = "true" ]; then
        echo "  ⚠ ALLOWED-REVERSED (allow-reversed=true): $src -> $resolved"
        ALLOWED=$((ALLOWED + 1))
      else
        echo "  ✗ REVERSED/OUTSIDE: $src -> $resolved"
        REVERSED=$((REVERSED + 1))
      fi
      return
      ;;
  esac

  OK=$((OK + 1))
  echo "  ✓ $src -> $resolved"
}

#!/usr/bin/env bash
# check-dashes — centralized PROSE dash gate (Tier PROSE bloquant)
# Scans git-tracked prose files (*.tex, *.md, *.txt, *.rst, *.adoc) for
# 4 blocked patterns: --- (LaTeX em-dash), — U+2014, " -- " (space--space),
# " – " (spaced en-dash U+2013). Interval form [alnum]–[alnum] collé is allowed.
# Exemptions: full-line TeX comments (^[[:space:]]*%), standalone "---" HR/frontmatter.
# Usage: sh scripts/check-dashes.sh  |  bash scripts/check-dashes.sh  |  ./scripts/check-dashes.sh
# Central source of truth: $HOME/.agents/scripts/check-dashes.sh
# Project copies: k-tex / k-presentation templates copy this file into scripts/check-dashes.sh
# Old canonical: skills/k-tex/scripts/check-dashes.sh (kept for backward compat, do not delete yet)
set -euo pipefail

# --- re-exec under bash if invoked via sh/dash (keeps `sh scripts/check-dashes.sh` working) ---
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

# --- source shared humanize lib (prefer $HOME/.agents, fallback to script dir / git root) ---
_HUMANIZE_LIB="$HOME/.agents/libs/humanize/humanize_lib.sh"
if [ -f "$_HUMANIZE_LIB" ]; then
  # shellcheck disable=SC1090,SC1091
  source "$_HUMANIZE_LIB"
else
  _SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  if [ -f "$_SCRIPT_DIR/../libs/humanize/humanize_lib.sh" ]; then
    # shellcheck disable=SC1090,SC1091
    source "$_SCRIPT_DIR/../libs/humanize/humanize_lib.sh"
  elif [ -f "$_SCRIPT_DIR/../.agents/libs/humanize/humanize_lib.sh" ]; then
    # shellcheck disable=SC1090,SC1091
    source "$_SCRIPT_DIR/../.agents/libs/humanize/humanize_lib.sh"
  else
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
      _GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
      if [ -n "${_GIT_ROOT:-}" ] && [ -f "$_GIT_ROOT/../.agents/libs/humanize/humanize_lib.sh" ]; then
        # shellcheck disable=SC1090,SC1091
        source "$_GIT_ROOT/../.agents/libs/humanize/humanize_lib.sh"
      fi
    fi
  fi
fi

# --- fallback inline definitions if lib not available (project copy without .agents nearby) ---
if ! type contains_blocked_dash >/dev/null 2>&1; then
  HUMANIZE_EM_DASH_TRIPLE="---"
  HUMANIZE_EM_DASH_UNICODE="—"
  HUMANIZE_EN_DASH_SPACED=" – "
  HUMANIZE_DOUBLE_DASH_SPACED=" -- "
  contains_blocked_dash() {
    local text="$1"
    if [[ "$text" == *"$HUMANIZE_EM_DASH_TRIPLE"* ]]; then printf 'EM_DASH_TRIPLE|---\n'; return 0; fi
    if [[ "$text" == *"$HUMANIZE_EM_DASH_UNICODE"* ]]; then printf 'EM_DASH_UNICODE|—\n'; return 0; fi
    if [[ "$text" == *"$HUMANIZE_DOUBLE_DASH_SPACED"* ]]; then printf 'DOUBLE_DASH_SPACED| -- \n'; return 0; fi
    if [[ "$text" == *"$HUMANIZE_EN_DASH_SPACED"* ]]; then printf 'EN_DASH_SPACED| – \n'; return 0; fi
    return 1
  }
fi

fail=0
files=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  files="$(git ls-files '*.tex' '*.md' '*.txt' '*.rst' '*.adoc' 2>/dev/null || true)"
fi

if [ -z "${files:-}" ]; then
  echo "check-dashes OK: no blocked dash in tracked prose files"
  exit 0
fi

# Use while-read over the file list (handles most prose filenames; spaces are rare for these types)
# shellcheck disable=SC2094  # false positive: we read $f line-by-line and print to stdout, never write back to $f
while IFS= read -r f; do
  [ -z "$f" ] && continue
  [ -f "$f" ] || continue
  lineno=0
  # shellcheck disable=SC2162
  while IFS= read -r line || [ -n "${line:-}" ]; do
    lineno=$((lineno + 1))
    # .tex: skip full-line TeX comments (as before)
    case "$f" in
      *.tex)
        if printf '%s' "$line" | grep -q '^[[:space:]]*%'; then
          continue
        fi
        ;;
    esac
    # Exemption: standalone "---" (Markdown HR / YAML frontmatter delimiter)
    trimmed="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    if [ "$trimmed" = "---" ]; then
      continue
    fi
    # Tier PROSE bloquant — delegate to lib (covers 4 patterns, spaced en-dash only blocked)
    if contains_blocked_dash "$line" >/dev/null 2>&1; then
      printf '%s:%d:%s\n' "$f" "$lineno" "$line"
      fail=1
    fi
  done < "$f"
done <<EOF
$files
EOF

if [ "$fail" = 1 ]; then
  echo "check-dashes FAILED: blocked dash found above — replace with , ; : . + logical connector (car, donc, or, puis, en effet)" >&2
  exit 1
else
  echo "check-dashes OK: no blocked dash in tracked prose files"
fi

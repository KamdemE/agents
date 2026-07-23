#!/usr/bin/env bash
# workspace-scan.sh — Scan a workspace for bloat, venvs, node_modules, and secret files
#
# Usage:
#   workspace-scan [OPTIONS] [path]
#
# Options:
#   -s, --sort-size    Sort by size (lines for .env, bytes for dirs/files)
#   -d, --sort-date    Sort by last modification date (default)
#   -r, --reverse      Reverse the sort order
#   -h, --help         Show this help
#
# Default: sorted by most recently used first.
# Author: KpihX [CLAUDE]

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YEL='\033[0;33m'; GRN='\033[0;32m'
BLU='\033[0;34m'; CYN='\033[0;36m'; MAG='\033[0;35m'
BLD='\033[1m'; DIM='\033[2m'; RST='\033[0m'

# ─── Argument parsing ─────────────────────────────────────────────────────────
SORT_BY="date"   # date | size
ASCENDING=0      # 0 = default intuitive direction; 1 = force ascending (low→high)
ROOT=""

usage() {
  cat <<EOF
${BLD}workspace-scan${RST} — Workspace bloat & secrets scanner

${BLD}Usage:${RST}
  workspace-scan [OPTIONS] [path]          (default path: ~/Work)

${BLD}Sort options:${RST}
  -d, --sort-date    Sort by date  ${DIM}(default: oldest first)${RST}
  -s, --sort-size    Sort by size  ${DIM}(default: largest first)${RST}
  -a, --asc          Ascending order  ${DIM}(-d → most recent first / -s → smallest first)${RST}

${BLD}Examples:${RST}
  workspace-scan                     # ~/Work, sorted by date desc
  workspace-scan -s ~/Projects       # ~/Projects, sorted by size desc
  workspace-scan -d -r               # ~/Work, sorted by oldest first
  workspace-scan -s -r .             # current dir, smallest first
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--sort-date)  SORT_BY="date";    shift ;;
    -s|--sort-size)  SORT_BY="size";    shift ;;
    -a|--asc)        ASCENDING=1;       shift ;;
    -h|--help)       usage ;;
    -*) echo -e "${RED}Unknown option: $1${RST}" >&2; usage ;;
    *)  ROOT="$1"; shift ;;
  esac
done

ROOT="${ROOT:-$HOME/Work}"
ROOT="$(realpath "$ROOT")"
[[ -d "$ROOT" ]] || { echo -e "${RED}Error: '$ROOT' is not a directory.${RST}" >&2; exit 1; }

# ─── Sort helpers ─────────────────────────────────────────────────────────────
# Items are stored as TSV: sort_key<TAB>col1<TAB>col2<TAB>...
# sort_key is numeric: epoch seconds (date) or bytes/lines (size)

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Sorts items in $TMP/<file>.tsv by sort_key (field 1), returns sorted lines
sort_items() {
  local file="$TMP/$1.tsv"
  [[ -f "$file" ]] || return 0
  local flag
  if [[ "$SORT_BY" == "date" ]]; then
    # Default: oldest first (low epoch → high epoch)
    flag="-n";  [[ $ASCENDING -eq 1 ]] && flag="-rn"
  else
    # Default: largest first (high bytes → low bytes)
    flag="-rn"; [[ $ASCENDING -eq 1 ]] && flag="-n"
  fi
  sort $flag -k1 "$file"
}

# ─── Stat helpers ─────────────────────────────────────────────────────────────
mtime_epoch() { stat -c "%Y" "$1" 2>/dev/null || echo 0; }
mod_ago() {
  local delta=$(( ( $(date +%s) - $(mtime_epoch "$1") ) / 86400 ))
  if   (( delta == 0 )); then echo "today"
  elif (( delta == 1 )); then echo "yesterday"
  elif (( delta < 30  )); then echo "${delta}d ago"
  elif (( delta < 365 )); then echo "$(( delta / 30 ))mo ago"
  else                        echo "$(( delta / 365 ))y ago"
  fi
}
dir_bytes() { du -sb "$1" 2>/dev/null | cut -f1 || echo 0; }
dir_human() { du -sh  "$1" 2>/dev/null | cut -f1 || echo "?"; }
rel_path()  { echo "${1#"$ROOT"/}"; }

sort_key() {
  if [[ "$SORT_BY" == "date" ]]; then
    mtime_epoch "$1"
  else
    dir_bytes "$1"
  fi
}
sort_key_lines() {
  if [[ "$SORT_BY" == "date" ]]; then
    mtime_epoch "$1"
  else
    wc -l < "$1" 2>/dev/null || echo 0
  fi
}

# ─── Prune dirs for find ──────────────────────────────────────────────────────
PRUNE=( \( -name ".venv" -o -name "venv" -o -name "env" -o -name "node_modules" -o -name ".git" \) -prune -o )

# ─── Header ──────────────────────────────────────────────────────────────────
if [[ "$SORT_BY" == "date" ]]; then
  sort_label="date — oldest first";   [[ $ASCENDING -eq 1 ]] && sort_label="date — most recent first"
else
  sort_label="size — largest first";  [[ $ASCENDING -eq 1 ]] && sort_label="size — smallest first"
fi

echo -e "\n${BLD}${MAG}╔══════════════════════════════════════════════════════╗"
echo -e      "║          🔍  WORKSPACE SCAN — KpihX                 ║"
echo -e      "╚══════════════════════════════════════════════════════╝${RST}"
echo -e "${DIM}  Root   : $ROOT"
echo -e "  Date   : $(date '+%Y-%m-%d %H:%M')"
echo -e "  Sort   : $sort_label${RST}"

# ═════════════════════════════════════════════════════════════════════════════
# 1. SECRET FILES (.env)
# ═════════════════════════════════════════════════════════════════════════════
echo -e "\n${BLD}${BLU}━━━ 🔐 Secret files (.env) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
printf "  ${BLD}%-44s  %6s  %12s  %s${RST}\n" "Path" "Lines" "Last used" "Git status"
printf "  %s\n" "$(printf '─%.0s' {1..80})"

while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  [[ "$base" =~ \.(example|sample|template|test|bak|backup)$ ]] && continue

  lines=$(wc -l < "$f" 2>/dev/null || echo 0)
  key=$(sort_key_lines "$f")
  _repo=$(git -C "$(dirname "$f")" rev-parse --show-toplevel 2>/dev/null || echo "")
  if [[ -z "$_repo" ]]; then
    ignored="${DIM}no git repo${RST}"
  elif git -C "$_repo" ls-files --error-unmatch "$f" &>/dev/null; then
    ignored="${RED}TRACKED IN GIT ⚠⚠⚠${RST}"
  elif ! git -C "$_repo" check-ignore -q "$f" &>/dev/null; then
    ignored="${YEL}NOT gitignored ⚠${RST}"
  else
    ignored="${GRN}gitignored ✓${RST}"
  fi

  printf "%s\t%s\t%s\t%s\t%s\n" \
    "$key" "$(rel_path "$f")" "${lines}L" "$(mod_ago "$f")" "$ignored" \
    >> "$TMP/secrets.tsv"
done < <(find "$ROOT" "${PRUNE[@]}" -type f -name ".env" -print0 2>/dev/null)

count_secrets=0
count_unignored_secrets=0
while IFS=$'\t' read -r _ rpath sz age gitstatus; do
  printf "  ${RED}%-44s${RST}  ${YEL}%6s${RST}  ${DIM}%12s${RST}  %b\n" \
    "$rpath" "$sz" "$age" "$gitstatus"
  (( count_secrets++ )) || true
  if [[ "$gitstatus" == *"TRACKED"* ]] || [[ "$gitstatus" == *"NOT gitignored"* ]]; then
    (( count_unignored_secrets++ )) || true
  fi
done < <(sort_items secrets)
[[ $count_secrets -eq 0 ]] && echo -e "  ${GRN}None found.${RST}"

# ═════════════════════════════════════════════════════════════════════════════
# 2. PYTHON VIRTUAL ENVIRONMENTS
# ═════════════════════════════════════════════════════════════════════════════
echo -e "\n${BLD}${BLU}━━━ 🐍 Python virtual environments (venv / .venv / env) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
printf "  ${BLD}%-44s  %8s  %10s  %s${RST}\n" "Path" "Size" "Python" "Last used"
printf "  %s\n" "$(printf '─%.0s' {1..80})"

while IFS= read -r -d '' d; do
  [[ -f "$d/pyvenv.cfg" ]] || continue
  pyver=$(grep -m1 "^version" "$d/pyvenv.cfg" 2>/dev/null | awk '{print $3}' || echo "?")
  sz_bytes=$(dir_bytes "$d")
  key=$(sort_key "$d")
  printf "%s\t%s\t%s\t%s\t%s\n" \
    "$key" "$(rel_path "$d")" "$(dir_human "$d")" "py${pyver}" "$(mod_ago "$d")" \
    >> "$TMP/venvs.tsv"
done < <(find "$ROOT" -type d \( -name ".venv" -o -name "venv" -o -name "env" \) -print0 2>/dev/null)

count_venvs=0
while IFS=$'\t' read -r _ rpath sz pyver age; do
  sz_bytes=$(du -sb "$ROOT/$rpath" 2>/dev/null | cut -f1 || echo 0)
  if   (( sz_bytes > 5000000000 )); then color=$RED
  elif (( sz_bytes > 500000000  )); then color=$YEL
  else                                   color=$GRN; fi
  printf "  ${color}%-44s${RST}  ${YEL}%8s${RST}  ${DIM}%10s${RST}  ${DIM}%s${RST}\n" \
    "$rpath" "$sz" "$pyver" "$age"
  (( count_venvs++ )) || true
done < <(sort_items venvs)
[[ $count_venvs -eq 0 ]] && echo -e "  ${GRN}None found.${RST}"

# ═════════════════════════════════════════════════════════════════════════════
# 3. NODE_MODULES
# ═════════════════════════════════════════════════════════════════════════════
echo -e "\n${BLD}${BLU}━━━ 📦 node_modules/ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
printf "  ${BLD}%-44s  %8s  %s${RST}\n" "Path" "Size" "Last used"
printf "  %s\n" "$(printf '─%.0s' {1..70})"

while IFS= read -r -d '' d; do
  key=$(sort_key "$d")
  printf "%s\t%s\t%s\t%s\n" \
    "$key" "$(rel_path "$d")" "$(dir_human "$d")" "$(mod_ago "$d")" \
    >> "$TMP/nm.tsv"
done < <(find "$ROOT" -type d -name "node_modules" \
  -not -path "*/node_modules/*/node_modules" -print0 2>/dev/null)

count_nm=0
while IFS=$'\t' read -r _ rpath sz age; do
  printf "  ${YEL}%-44s${RST}  ${YEL}%8s${RST}  ${DIM}%s${RST}\n" "$rpath" "$sz" "$age"
  (( count_nm++ )) || true
done < <(sort_items nm)
[[ $count_nm -eq 0 ]] && echo -e "  ${GRN}None found.${RST}"

# ═════════════════════════════════════════════════════════════════════════════
# 4. BUILD ARTIFACTS
# ═════════════════════════════════════════════════════════════════════════════
echo -e "\n${BLD}${BLU}━━━ 🏗️  Build artifacts (dist / build / target / __pycache__ / .next) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
printf "  ${BLD}%-44s  %8s  %s${RST}\n" "Path" "Size" "Last used"
printf "  %s\n" "$(printf '─%.0s' {1..70})"

while IFS= read -r -d '' d; do
  key=$(sort_key "$d")
  printf "%s\t%s\t%s\t%s\n" \
    "$key" "$(rel_path "$d")" "$(dir_human "$d")" "$(mod_ago "$d")" \
    >> "$TMP/build.tsv"
done < <(find "$ROOT" "${PRUNE[@]}" \
  -type d \( -name "dist" -o -name "build" -o -name "target" -o -name "__pycache__" -o -name ".next" \) \
  -print0 2>/dev/null)

count_build=0
while IFS=$'\t' read -r _ rpath sz age; do
  printf "  ${DIM}%-44s${RST}  ${YEL}%8s${RST}  ${DIM}%s${RST}\n" "$rpath" "$sz" "$age"
  (( count_build++ )) || true
done < <(sort_items build)
[[ $count_build -eq 0 ]] && echo -e "  ${GRN}None found.${RST}"

# ═════════════════════════════════════════════════════════════════════════════
# 5. LARGE FILES > 100 MB
# ═════════════════════════════════════════════════════════════════════════════
echo -e "\n${BLD}${BLU}━━━ 🐘 Large files (> 100 MB) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
printf "  ${BLD}%-54s  %8s  %s${RST}\n" "Path" "Size" "Last used"
printf "  %s\n" "$(printf '─%.0s' {1..80})"

while IFS= read -r -d '' f; do
  sz_bytes=$(stat -c "%s" "$f" 2>/dev/null || echo 0)
  key=$(sort_key "$f")
  [[ "$SORT_BY" == "size" ]] && key=$sz_bytes
  printf "%s\t%s\t%s\t%s\n" \
    "$key" "$(rel_path "$f")" "$(du -sh "$f" 2>/dev/null | cut -f1)" "$(mod_ago "$f")" \
    >> "$TMP/large.tsv"
done < <(find "$ROOT" "${PRUNE[@]}" -type f -size +100M -print0 2>/dev/null)

count_large=0
while IFS=$'\t' read -r _ rpath sz age; do
  printf "  ${RED}%-54s${RST}  ${YEL}%8s${RST}  ${DIM}%s${RST}\n" "$rpath" "$sz" "$age"
  (( count_large++ )) || true
done < <(sort_items large)
[[ $count_large -eq 0 ]] && echo -e "  ${GRN}None found.${RST}"

# ═════════════════════════════════════════════════════════════════════════════
# 6. SUMMARY
# ═════════════════════════════════════════════════════════════════════════════
echo -e "\n${BLD}${MAG}━━━ 📊 Summary ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "  ${BLD}Root  :${RST} $ROOT"
echo -e "  ${BLD}Sort  :${RST} $sort_label"
echo -e "  ${RED}Secret files :${RST}    $count_secrets"
echo -e "  ${YEL}Python venvs :${RST}    $count_venvs"
echo -e "  ${YEL}node_modules :${RST}    $count_nm"
echo -e "  ${DIM}Build artifacts :${RST} $count_build"
echo -e "  ${RED}Large files :${RST}     $count_large"

if (( count_unignored_secrets > 0 )); then
  echo -e "\n${BLD}${RED}🚨 ALERT: $count_unignored_secrets .env file(s) at risk (tracked by git or not gitignored)! Secure them immediately.${RST}"
fi
echo ""

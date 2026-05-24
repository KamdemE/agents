#!/usr/bin/env bash
# check_collections.sh — QMD collection health gate for k-optim / auto_clean / ksh status.
# Detects: missing index paths, empty indexes when docs exist on disk, stale path typos.
#
# Usage:
#   check_collections.sh           # human report, exit 1 on problems
#   check_collections.sh --quiet   # exit code only (no stdout on success)
#   check_collections.sh --json    # machine-readable summary

set -euo pipefail

QMD_BIN="${QMD_BIN:-$HOME/.npm-global/bin/qmd}"
INDEX_YML="${QMD_INDEX_YML:-$HOME/.config/qmd/index.yml}"
QUIET=0
JSON=0

for arg in "$@"; do
    case "$arg" in
        --quiet) QUIET=1 ;;
        --json) JSON=1 ;;
        -h|--help)
            sed -n '2,8p' "$0"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 2
            ;;
    esac
done

if ! command -v "$QMD_BIN" >/dev/null 2>&1; then
    QMD_BIN="$(command -v qmd 2>/dev/null || true)"
fi
if [[ -z "${QMD_BIN:-}" ]] || ! command -v "$QMD_BIN" >/dev/null 2>&1; then
    echo "check_collections: qmd not found in PATH." >&2
    exit 127
fi

if [[ ! -f "$INDEX_YML" ]]; then
    echo "check_collections: missing config $INDEX_YML" >&2
    exit 2
fi

declare -A CONFIG_PATH=()
current=""
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]{2}([a-zA-Z0-9_-]+):[[:space:]]*$ ]]; then
    current="${BASH_REMATCH[1]}"
  elif [[ -n "$current" && "$line" =~ ^[[:space:]]{4}path:[[:space:]]+(.+)$ ]]; then
    path="${BASH_REMATCH[1]}"
    path="${path//\$HOME/$HOME}"
    CONFIG_PATH["$current"]="$path"
    current=""
  fi
done < "$INDEX_YML"

declare -A QMD_FILES=()
list_out="$("$QMD_BIN" collection list 2>/dev/null || true)"
col=""
while IFS= read -r line; do
  if [[ "$line" =~ ^([a-zA-Z0-9_-]+)[[:space:]]+\(qmd:// ]]; then
    col="${BASH_REMATCH[1]}"
  elif [[ -n "$col" && "$line" =~ Files:[[:space:]]+([0-9,]+) ]]; then
    count="${BASH_REMATCH[1]}"
    count="${count//,/}"
    QMD_FILES["$col"]="$count"
    col=""
  fi
done <<< "$list_out"

count_disk_docs() {
    local root="$1"
    find -L "$root" -type f \
        \( -name '*.md' -o -name '*.yml' -o -name '*.yaml' -o -name '*.toml' \) \
        ! -path '*/.git/*' 2>/dev/null | wc -l | tr -d ' '
}

issues=()
ok_lines=()

for name in "${!CONFIG_PATH[@]}"; do
    path="${CONFIG_PATH[$name]}"
    qmd_count="${QMD_FILES[$name]:--1}"
    disk_count=0

    if [[ ! -d "$path" ]]; then
        issues+=("MISSING_PATH|$name|$path|configured root does not exist")
        continue
    fi

    disk_count="$(count_disk_docs "$path")"

    if [[ "$qmd_count" -lt 0 ]]; then
        issues+=("UNKNOWN_QMD|$name|$path|collection missing from 'qmd collection list'")
        continue
    fi

    if [[ "$disk_count" -gt 0 && "$qmd_count" -eq 0 ]]; then
        issues+=("EMPTY_INDEX|$name|$path|$disk_count doc(s) on disk but 0 indexed — check path typo or run: qmd update $name && qmd embed $name")
        continue
    fi

    if [[ "$disk_count" -eq 0 && "$qmd_count" -eq 0 ]]; then
        ok_lines+=("$name: empty (path exists, no indexable docs on disk)")
        continue
    fi

    ok_lines+=("$name: OK ($qmd_count indexed, $disk_count on disk)")
done

if [[ "$JSON" -eq 1 ]]; then
    printf '{"ok":%s,"issues":[' "$([[ ${#issues[@]} -eq 0 ]] && echo true || echo false)"
    first=1
    for issue in "${issues[@]}"; do
        IFS='|' read -r code name path detail <<< "$issue"
        [[ $first -eq 1 ]] || printf ','
        first=0
        printf '{"code":"%s","collection":"%s","path":"%s","detail":"%s"}' \
            "$code" "$name" "$path" "${detail//\"/\\\"}"
    done
    printf '],"collections":%d}\n' "${#CONFIG_PATH[@]}"
    [[ ${#issues[@]} -eq 0 ]] && exit 0 || exit 1
fi

if [[ ${#issues[@]} -eq 0 ]]; then
    [[ "$QUIET" -eq 1 ]] && exit 0
    echo "QMD collections: all configured paths healthy."
    for line in "${ok_lines[@]}"; do
        echo "  - $line"
    done
    exit 0
fi

[[ "$QUIET" -eq 1 ]] && exit 1

echo "QMD collections: ${#issues[@]} problem(s) detected."
for issue in "${issues[@]}"; do
    IFS='|' read -r code name path detail <<< "$issue"
    echo "  [$code] $name"
    echo "    path: $path"
    echo "    $detail"
done
if [[ ${#ok_lines[@]} -gt 0 ]]; then
    echo ""
    echo "Healthy:"
    for line in "${ok_lines[@]}"; do
        echo "  - $line"
    done
fi
exit 1

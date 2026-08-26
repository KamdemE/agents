#!/usr/bin/env bash
# KpihX mnt-sync — shared dirs.txt loader (Linux).
# Source this from every sync-*.sh script: `source "$(dirname "$0")/load_dirs.sh"`
# Populates the SYNC_DIRS bash array from dirs.txt next to this file (or
# $MNT_SYNC_DIRS_FILE if set), ignoring blank lines and # comments.

_dirs_file="${MNT_SYNC_DIRS_FILE:-$(dirname "${BASH_SOURCE[0]}")/dirs.txt}"

if [ ! -f "$_dirs_file" ]; then
  echo "❌ dirs.txt not found at $_dirs_file — copy dirs.txt.example and adjust." >&2
  exit 1
fi

SYNC_DIRS=()
while IFS= read -r _line || [ -n "$_line" ]; do
  _line="${_line%%#*}"                      # strip trailing comment
  _line="$(echo "$_line" | xargs)"           # trim whitespace
  [ -n "$_line" ] && SYNC_DIRS+=("$_line")
done < "$_dirs_file"

if [ "${#SYNC_DIRS[@]}" -eq 0 ]; then
  echo "❌ dirs.txt at $_dirs_file has no entries." >&2
  exit 1
fi

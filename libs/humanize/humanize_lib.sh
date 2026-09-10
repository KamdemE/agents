#!/usr/bin/env bash
# ============================================================
# humanize_lib.sh — shared humanize / PROSE guards for .agents
# ============================================================
# Central place for the Tier PROSE bloquant dash checks and
# related file/payload helpers. The Python and JS twins
# (humanize_lib.py, humanize_lib.js) mirror this file EXACTLY,
# language apart — see libs/AGENTS.md for the mandatory
# "keep the 3 twins in sync" rule.
#
# Validated by the user — 4 PROSE regex (Tier PROSE bloquant):
#   EM_DASH_TRIPLE     = /---/            LaTeX em-dash
#   EM_DASH_UNICODE    = /\u2014/         — U+2014
#   EN_DASH_SPACED     = / \u2013 /       – U+2013 spaced (blocked)
#   DOUBLE_DASH_SPACED = / -- /           markdown substitut
#
# Hardened: also blocks escaped/encoded forms: \\u2014, \\U00002014, \\xE2\\x80\\x94, \\N{EM DASH}, chr(8212)/chr(0x2014)
# Alternative dure for EN DASH: block spaced en-dash ONLY,
# allow interval form [0-9]–[0-9] or [A-Za-z]–[A-Za-z] collé.
#
# Provided here:
#   is_allowed_en_dash <text>             : 0=allowed, 1=blocked (spaced –)
#   contains_blocked_dash <text>          : prints "PATTERN|snippet" if blocked (also blocks escapes)
#   decode_unicode_escapes_for_check <text>: prints decoded text (escapes -> real chars)
#   contains_blocked_dash_with_escapes <text>: alias (compat)
#   is_code_file <path>             : 0=code (whitelisted), 1=prose/other
#   is_prose_file <path>            : 0=prose, 1=not prose
#   strip_tmux_wrapper <cmd>        : strip tmux send-keys wrapper → payload
#   extract_bash_payload <cmd>      : alias of strip_tmux_wrapper
#
# Source:  $HOME/.agents/libs/humanize/humanize_lib.sh
# Caller:  scripts/*/lib.sh (via source), hooks via JS twin
# Reference:  validated — single source of truth for PROSE dash
# ============================================================

# --- Tier PROSE bloquant patterns (literal UTF-8 chars) ---
# U+2014 EM DASH — literal "—"
# U+2013 EN DASH — literal "–"
HUMANIZE_EM_DASH_TRIPLE="---"
HUMANIZE_EM_DASH_UNICODE="—"
HUMANIZE_EN_DASH_SPACED=" – "
HUMANIZE_DOUBLE_DASH_SPACED=" -- "

# --- Escaped / encoded bypasses (hardened, KpiX) ---
# Covers: \u2012..2015, \U00002012..00002015, \xE2\x80\x92..95, \N{EM DASH}, chr(8210..13 / 0x2012..15)
# Use grep -i for case-insensitive hex
HUMANIZE_ESCAPED_U4_REGEX='\\u201[2-5]'
HUMANIZE_ESCAPED_U8_REGEX='\\U0000201[2-5]'
HUMANIZE_ESCAPED_X_REGEX='\\xE2\\x80\\x9[2-5]'
HUMANIZE_ESCAPED_N_REGEX='\\N\{(EM DASH|EN DASH|FIGURE DASH|HORIZONTAL BAR)\}'
HUMANIZE_ESCAPED_CHR_REGEX='chr[[:space:]]*\([[:space:]]*(821[0-3]|0x201[2-5])[[:space:]]*\)'

# SEND_KEYS_REGEX — single source mirrors skills/k-opencode/scripts/plugins/libs/tmux-patterns.js
# Detects: tmux send-keys -t <target> ...
HUMANIZE_SEND_KEYS_REGEX='tmux[[:space:]]+send-keys[[:space:]]+(-l[[:space:]]+|-p[[:space:]]+)?-t[[:space:]]+[%$@a-zA-Z0-9.:_-]+'

# --- Code extensions whitelisted (return 0 = is code, should be skipped) ---
# Prose extensions: md, tex, txt, rst, adoc, mdx, html (partial)
# Everything not in code list is treated as prose-candidate.
_HUMANIZE_CODE_EXTS="py js ts tsx jsx go rs java c cpp h hpp sh bash zsh json yaml yml toml lock svg png jpg jpeg pdf pyc class o so dylib db sqlite"

# --- prose helper: extract lowercased extension ---
_humanize_ext() {
  local path="$1"
  local base
  base="$(basename -- "$path")"
  # no dot → no extension
  if [[ "$base" != *.* ]]; then
    printf ''
    return
  fi
  local ext="${base##*.}"
  printf '%s' "$ext" | tr '[:upper:]' '[:lower:]'
}

# is_code_file <path> → 0 if code (whitelisted), 1 otherwise
is_code_file() {
  local path="$1"
  local ext
  ext="$(_humanize_ext "$path")"
  [ -n "$ext" ] || return 1
  local e
  for e in $_HUMANIZE_CODE_EXTS; do
    if [ "$e" = "$ext" ]; then
      return 0
    fi
  done
  return 1
}

# is_prose_file <path> → 0 if prose extension, 1 otherwise
is_prose_file() {
  local path="$1"
  local ext
  ext="$(_humanize_ext "$path")"
  case "$ext" in
    md|tex|txt|rst|adoc|mdx|html) return 0 ;;
    "") 
      # extensionless prose candidates: AGENTS.md is md, but bare AGENTS etc.
      # Treat extensionless as prose-candidate only if basename looks prose-ish?
      # Keep simple: extensionless → not code → prose candidate
      # But is_code_file already returns 1, so is_prose_file extensionless → 1
      # Caller should use ! is_code_file for prose gating.
      return 1 ;;
    *) return 1 ;;
  esac
}

# is_allowed_en_dash <text> → 0=allowed, 1=blocked
# Logic: spaced en-dash " – " → blocked (return 1)
#        interval [alnum]–[alnum] collé → allowed (return 0)
#        no en-dash → allowed (return 0)
is_allowed_en_dash() {
  local text="$1"
  # Blocked: space–space
  if [[ "$text" == *"$HUMANIZE_EN_DASH_SPACED"* ]]; then
    return 1
  fi
  # No en-dash at all → allowed
  if [[ "$text" != *"–"* ]]; then
    return 0
  fi
  # Has en-dash but not spaced → check if any occurrence is interval form?
  # For shell, crude: if regex [A-Za-z0-9]–[A-Za-z0-9] exists → allowed
  # Otherwise still allowed (since only spaced form is blocked per dure alternative)
  # So if we reached here (no spaced dash), it's allowed.
  return 0
}

# decode_unicode_escapes_for_check <text> → prints decoded text (escapes -> real chars, defense-in-depth)
# Replaces \u2012..\u2015, \U00002012.., \xE2\x80\x92..95, \N{..}, chr(8210..) with literal unicode chars
decode_unicode_escapes_for_check() {
  local s="$1"
  # \u2012..2015 -> literal (use perl for hex decode, fallback to sed mapping)
  # Map via bash replacement for each code (case-insensitive via perl)
  s="$(printf '%s' "$s" | perl -CS -pe 's/\\u201([2-5])/chr(hex("201". $1))/gei')"
  s="$(printf '%s' "$s" | perl -CS -pe 's/\\U0000201([2-5])/chr(hex("201". $1))/gei')"
  # \xE2\x80\x92..95 -> map to unicode
  s="$(printf '%s' "$s" | perl -CS -pe 'BEGIN{%m=("2"=>"\x{2012}","3"=>"\x{2013}","4"=>"\x{2014}","5"=>"\x{2015}")} s/\\xE2\\x80\\x9([2-5])/$m{$1}/gei')"
  # \N{...} -> map
  s="$(printf '%s' "$s" | perl -CS -pe 's/\\N\{(?:EM DASH|HORIZONTAL BAR)\}/\x{2014}/gi; s/\\N\{EN DASH\}/\x{2013}/gi; s/\\N\{FIGURE DASH\}/\x{2012}/gi')"
  # chr(8210..13) and chr(0x2012..15)
  s="$(printf '%s' "$s" | perl -CS -pe 's/chr\s*\(\s*(821[0-3])\s*\)/chr($1)/gei; s/chr\s*\(\s*0x201([2-5])\s*\)/chr(hex("201".$1))/gei')"
  # The above chr() leaves literal chr? need to evaluate: replace chr(8212) with actual char
  # Re-evaluate chr() calls: perl chr
  s="$(printf '%s' "$s" | perl -CS -pe 's/chr\(\s*(\d+)\s*\)/chr($1)/ge; s/chr\(\s*0x([0-9a-fA-F]+)\s*\)/chr(hex($1))/ge')"
  printf '%s' "$s"
}

# helper: check raw escaped regexes (grep -i)
_humanize_check_escaped() {
  local text="$1"
  local snippet
  if printf '%s' "$text" | grep -qiE '\\u201[2-5]'; then
    snippet="$(printf '%s' "$text" | grep -oiE -m1 '\\u201[2-5]' || printf '\\u2014')"
    # normalize hex uppercase for pattern
    local hex
    hex="$(printf '%s' "$snippet" | sed 's/^\\u//' | tr '[:lower:]' '[:upper:]')"
    printf 'ESCAPED_U%s|%s\n' "$hex" "$snippet"
    return 0
  fi
  if printf '%s' "$text" | grep -qiE '\\U0000201[2-5]'; then
    snippet="$(printf '%s' "$text" | grep -oiE -m1 '\\U0000201[2-5]' || printf '\\U00002014')"
    local hex
    hex="$(printf '%s' "$snippet" | sed -E 's/^\\U0*//I' | tr '[:lower:]' '[:upper:]')"
    printf 'ESCAPED_U%s|%s\n' "$hex" "$snippet"
    return 0
  fi
  if printf '%s' "$text" | grep -qiE '\\xE2\\x80\\x9[2-5]'; then
    snippet="$(printf '%s' "$text" | grep -oiE -m1 '\\xE2\\x80\\x9[2-5]' || printf '\\xE2\\x80\\x94')"
    local tail
    tail="$(printf '%s' "$snippet" | tail -c 3 | head -c 2 | tr '[:upper:]' '[:lower:]')"
    case "$tail" in
      92) printf 'ESCAPED_X_2012|%s\n' "$snippet"; return 0 ;;
      93) printf 'ESCAPED_X_2013|%s\n' "$snippet"; return 0 ;;
      94) printf 'ESCAPED_X_2014|%s\n' "$snippet"; return 0 ;;
      95) printf 'ESCAPED_X_2015|%s\n' "$snippet"; return 0 ;;
      *) printf 'ESCAPED_X_2014|%s\n' "$snippet"; return 0 ;;
    esac
  fi
  if printf '%s' "$text" | grep -qiE '\\N\{(EM DASH|EN DASH|FIGURE DASH|HORIZONTAL BAR)\}'; then
    snippet="$(printf '%s' "$text" | grep -oiE -m1 '\\N\{(EM DASH|EN DASH|FIGURE DASH|HORIZONTAL BAR)\}' || printf '\\N{EM DASH}')"
    local up
    up="$(printf '%s' "$snippet" | tr '[:lower:]' '[:upper:]')"
    case "$up" in
      *EM*) printf 'ESCAPED_N_EM_DASH|%s\n' "$snippet"; return 0 ;;
      *EN*) printf 'ESCAPED_N_EN_DASH|%s\n' "$snippet"; return 0 ;;
      *FIGURE*) printf 'ESCAPED_N_FIGURE_DASH|%s\n' "$snippet"; return 0 ;;
      *) printf 'ESCAPED_N_HORIZONTAL_BAR|%s\n' "$snippet"; return 0 ;;
    esac
  fi
  if printf '%s' "$text" | grep -qiE 'chr[[:space:]]*\([[:space:]]*(821[0-3]|0x201[2-5])[[:space:]]*\)'; then
    snippet="$(printf '%s' "$text" | grep -oiE -m1 'chr[[:space:]]*\([[:space:]]*(821[0-3]|0x201[2-5])[[:space:]]*\)' || printf 'chr(8212)')"
    local inner
    inner="$(printf '%s' "$snippet" | sed -E 's/chr[[:space:]]*\([[:space:]]*//I; s/[[:space:]]*\)//')"
    # normalize hex uppercase if needed
    if printf '%s' "$inner" | grep -qi '^0x'; then
      inner="$(printf '%s' "$inner" | tr '[:lower:]' '[:upper:]')"
    fi
    printf 'ESCAPED_CHR_%s|%s\n' "$inner" "$snippet"
    return 0
  fi
  return 1
}

# contains_blocked_dash <text> → 0=blocked, 1=clean
# On blocked: prints "PATTERN|snippet" to stdout
# Priority: ESCAPED_* -> EM_DASH_TRIPLE -> EM_DASH_UNICODE -> DOUBLE_DASH_SPACED -> EN_DASH_SPACED -> decoded second pass
contains_blocked_dash() {
  local text="$1"
  local snippet
  local esc_out
  if esc_out="$(_humanize_check_escaped "$text")"; then
    printf '%s' "$esc_out"
    return 0
  fi

  if [[ "$text" == *"$HUMANIZE_EM_DASH_TRIPLE"* ]]; then
    snippet="$(printf '%s' "$text" | grep -o -m1 -- '---' || printf '---')"
    printf 'EM_DASH_TRIPLE|%s\n' "$snippet"
    return 0
  fi
  if [[ "$text" == *"$HUMANIZE_EM_DASH_UNICODE"* ]]; then
    snippet="$(printf '%s' "$text" | grep -o -m1 -- '—' || printf '—')"
    printf 'EM_DASH_UNICODE|%s\n' "$snippet"
    return 0
  fi
  if [[ "$text" == *"$HUMANIZE_DOUBLE_DASH_SPACED"* ]]; then
    snippet="$(printf '%s' "$text" | grep -o -m1 -- ' -- ' || printf ' -- ')"
    printf 'DOUBLE_DASH_SPACED|%s\n' "$snippet"
    return 0
  fi
  # EN_DASH_SPACED — only spaced form is blocked (dure alternative)
  if [[ "$text" == *"$HUMANIZE_EN_DASH_SPACED"* ]]; then
    snippet="$(printf '%s' "$text" | grep -o -m1 -- ' – ' || printf ' – ')"
    printf 'EN_DASH_SPACED|%s\n' "$snippet"
    return 0
  fi
  # Defense layer 2: decode escapes then re-check literals
  local decoded
  decoded="$(decode_unicode_escapes_for_check "$text")"
  if [[ "$decoded" != "$text" ]]; then
    if [[ "$decoded" == *"$HUMANIZE_EM_DASH_UNICODE"* ]]; then
      snippet="$(printf '%s' "$decoded" | grep -o -m1 -- '—' || printf '—')"
      printf 'ESCAPED_DECODED_EM_DASH|%s\n' "$snippet"
      return 0
    fi
    if [[ "$decoded" == *"$HUMANIZE_EN_DASH_SPACED"* ]]; then
      snippet="$(printf '%s' "$decoded" | grep -o -m1 -- ' – ' || printf ' – ')"
      printf 'ESCAPED_DECODED_EN_DASH_SPACED|%s\n' "$snippet"
      return 0
    fi
    # Check for figure/horizontal bar (U+2012 / U+2015) after decode
    if [[ "$decoded" == *$'\u2012'* ]] || [[ "$decoded" == *$'\u2015'* ]]; then
      local ch
      if [[ "$decoded" == *$'\u2012'* ]]; then
        ch=$'\u2012'
      else
        ch=$'\u2015'
      fi
      printf 'ESCAPED_DECODED_DASH|%s\n' "$ch"
      return 0
    fi
  fi
  return 1
}

# contains_blocked_dash_with_escapes — alias (compat)
contains_blocked_dash_with_escapes() {
  contains_blocked_dash "$1"
}

# strip_tmux_wrapper <cmd> → prints payload if send-keys wrapper, else original
# Crude extraction: detect SEND_KEYS_REGEX, then extract first quoted payload
strip_tmux_wrapper() {
  local cmd="$1"
  if ! printf '%s' "$cmd" | grep -Eq "$HUMANIZE_SEND_KEYS_REGEX"; then
    printf '%s' "$cmd"
    return 0
  fi
  # Try single-quoted payload first, then double-quoted
  local payload
  # Extract content between first pair of single quotes after -t target
  payload="$(printf '%s' "$cmd" | sed -n "s/.*send-keys[^']*'\([^']*\)'.*/\1/p" | head -n1)"
  if [ -n "$payload" ]; then
    printf '%s' "$payload"
    return 0
  fi
  payload="$(printf '%s' "$cmd" | sed -n 's/.*send-keys[^"]*"\([^"]*\)".*/\1/p' | head -n1)"
  if [ -n "$payload" ]; then
    printf '%s' "$payload"
    return 0
  fi
  # Fallback: return original if no quoted payload found
  printf '%s' "$cmd"
}

# extract_bash_payload — alias for strip_tmux_wrapper (keep both names)
extract_bash_payload() {
  strip_tmux_wrapper "$1"
}

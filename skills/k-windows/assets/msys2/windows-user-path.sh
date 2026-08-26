# Add both Windows system AND user PATH to MSYS2 PATH
# Sans cette etape, winget, pwsh, python.exe... ne sont pas trouves.
# Les binaires Windows natifs sont preferes pour l'I/O reseau (SMB O: 2400 MB/s).
#
# Ordre de precedence (comme Windows) : system → user → MSYS2

_read_win_path() {
  # $1 = registry key path (e.g. "HKLM\..." or "HKCU\...")
  reg.exe query "$1" /v PATH 2>/dev/null | \
    tr -d '\0' | \
    awk -F'REG_[A-Z_]+[[:space:]]*' 'NR>1 && $2 {print $2; exit}' | \
    sed 's/[[:space:]]*$//'
}

_convert_to_msys2() {
  # Convertit C:\path\to -> /c/path/to pour MSYS2
  echo "$1" | sed 's/\\/\//g; s/^\([A-Za-z]\):/\/\1/'
}

_append_path() {
  # $1 = raw Windows PATH string (semicolon-separated)
  # Ajoute au PATH MSYS2 les repertoires qui existent
  [ -z "$1" ] && return
  _unix_path=""
  _old_ifs="$IFS"
  IFS=';'
  for _segment in $1; do
    [ -z "$_segment" ] && continue
    _seg=$(echo "$_segment" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    _unix_seg=$(_convert_to_msys2 "$_seg")
    if [ -n "$_unix_seg" ] && [ -d "$_unix_seg" ]; then
      _unix_path="${_unix_path}:${_unix_seg}"
    fi
  done
  IFS="$_old_ifs"
  if [ -n "$_unix_path" ]; then
    _unix_path="${_unix_path#:}"
    export PATH="${_unix_path}${PATH:+:${PATH}}"
  fi
  unset _unix_path _unix_seg _segment _seg
}

# 1) System PATH (HKLM) — priorite haute (git, curl, etc.)
WIN_SYS_PATH=$(_read_win_path "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
_append_path "$WIN_SYS_PATH"
unset WIN_SYS_PATH

# 2) User PATH (HKCU) — priorite moyenne (winget, pip, etc.)
WIN_USER_PATH=$(_read_win_path "HKCU\Environment")
_append_path "$WIN_USER_PATH"
unset WIN_USER_PATH

unset _read_win_path _convert_to_msys2 _append_path _old_ifs

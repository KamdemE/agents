#!/usr/bin/env bash
# ============================================================
# service_internal_paths_guard.sh — sub-check: internal unit paths exist
# ============================================================
# Part of check-services.sh (modular split). Validates the paths referenced by
# a deployed unit file — WorkingDirectory / ExecStart / Environment=...=path —
# and reports any missing file/dir. Catches renames/broken deps (e.g. a service
# pointing to a renamed plugin dir) that would otherwise only fail at runtime.
# Sets internal_paths_ok=1 on success, 0 on any missing path.
# ============================================================

# service_internal_paths_guard <deployed-unit-path>
service_internal_paths_guard() {
  local deployed="$1"
  internal_paths_ok=1

  local unit_src workdir execstart env_paths
  unit_src="$(readlink -f "$deployed" || echo "$deployed")"
  workdir="$(sed -n 's/^[[:space:]]*WorkingDirectory=[[:space:]]*//p' "$unit_src" | head -1)"
  execstart="$(sed -n 's/^[[:space:]]*ExecStart=[[:space:]]*//p' "$unit_src" | head -1)"
  env_paths="$(sed -n 's/^[[:space:]]*Environment=[[:space:]]*//p' "$unit_src" | sed -n 's/^[^=]*=//p')"

  if [ -n "$workdir" ]; then
    workdir="${workdir//\$HOME/$HOME}"
    # strip surrounding double quotes and expand the systemd %h specifier
    workdir="${workdir%\"}"; workdir="${workdir#\"}"
    workdir="${workdir//%h/$HOME}"
    if [ -d "$workdir" ]; then
      echo "  ✓ WorkingDirectory: $workdir"
    else
      echo "  ✗ WorkingDirectory MISSING dir: $workdir"
      internal_paths_ok=0
    fi
  fi

  if [ -n "$execstart" ]; then
    local exe="${execstart%% *}"
    exe="${exe%\"}"; exe="${exe#\"}"
    exe="${exe//\$HOME/$HOME}"
    exe="${exe//%h/$HOME}"
    case "$exe" in
      *"sh -c"*|/bin/sh|/usr/bin/env|node@*/bin/*) : ;;
      *)
        if [ -e "$exe" ]; then
          echo "  ✓ ExecStart: $exe"
        else
          echo "  ✗ ExecStart executable MISSING: $exe"
          internal_paths_ok=0
        fi
        ;;
    esac
  fi

  if [ -n "$env_paths" ]; then
    local ep
    # Split comma-separated path lists (e.g. OPENCODE_WEB_PLUGINS=path1,path2)
    env_paths="${env_paths//,/ }"
    for ep in $env_paths; do
      ep="${ep//\$HOME/$HOME}"
      ep="${ep%\"}"; ep="${ep#\"}"
      ep="${ep//%h/$HOME}"
      case "$ep" in
        */*:*|*:$*) : ;;   # skip path-LIST env vars (PATH=...:/bin) — not file paths
        [/$].*|/*|./*|../*|~/*)
          if [ -e "$ep" ]; then
            echo "  ✓ Environment path: $ep"
          else
            echo "  ✗ Environment path MISSING: $ep"
            internal_paths_ok=0
          fi
          ;;
      esac
    done
  fi
}

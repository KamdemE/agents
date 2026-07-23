#!/usr/bin/env bash
#
# sui — Sudo User Interface (unified privilege gateway)
#
# Purpose:
#   - Give agents and humans ONE predictable GUI flow for local and remote root
#     commands, with full argv preserved (no fragile "$*" reassembly).
#   - Optional Polkit path for desktop users who prefer pkexec over zenity+sudo.
#   - Emit audit records compatible with traditional auth logging (syslog authpriv),
#     which on many distros is merged into /var/log/auth.log alongside sudo(8).
#
# Usage:
#   sui [options] [@ssh-target] <command> [args...]
#
# Options:
#   --polkit     Local only: use pkexec(1) instead of the unified zenity+sudo dialog.
#   --dry-run    Print (and optionally show) what would run; never prompts; no elevation.
#   --reason TXT | -r TXT  Human rationale for the dialog (audit stores present/<none> only).
#   -h, --help Show this summary.
#
# Environment:
#   SUI_LOG=1    Also append audit lines to ${XDG_STATE_HOME:-$HOME/.local/state}/sui/audit.log
#
# Install (example):
#   install -m 0755 sui.sh /usr/local/bin/sui
#
# Develop / verify (from repo clone):
#   make test          # bash -n + optional shellcheck + stub suite
#   make test-stubs    # automated regression without real zenity/sudo
#
# Notes on auditing:
#   - Real sudo(8) invocations are still logged by sudoers defaults (e.g. auth.log lines).
#   - This script adds explicit "sui" syslog entries via logger(1) at authpriv.notice so
#     operators can grep for the wrapper even when Polkit is used (--polkit).
#   - Secrets (passwords) are never written to logs.
#   - The textual --reason / -r value is never written to sui audit (syslog / SUI_LOG file): only present or <none>.
#
# Shell strictness (why not `set -e` here):
#   - `-u` / `nounset`: expanding an unset variable is an error. Catches typos and forgotten
#     defaults instead of silently running with empty values (important for paths and targets).
#   - `-o pipefail`: in `cmd1 | cmd2`, the pipeline fails if any stage fails, not only if the
#     last command fails. Otherwise a failing `printf`/`ssh` producer could be masked.
#   - We omit `errexit` (`-e`) so the script can use explicit `||`, `if`, and user-facing
#     flows (e.g. zenity cancel) without needing `|| true` everywhere.
set -uo pipefail

readonly SUI_VERSION="3.2.1"

# ---------------------------------------------------------------------------
# Globals (shared state for parse_args, audit logging, and execution helpers)
#
# Why globals: bash functions cannot return arrays or structured argv; we stash parsed
# results here so main() and helpers share state without passing many positional parameters.
# ---------------------------------------------------------------------------
# Where elevation runs: "local" (this machine) vs "remote" (via ssh). Set in parse_args().
SUI_SCOPE="local"
# Host label for logs/UI: "local", or the SSH target string after stripping @ (e.g. homelab).
SUI_TARGET="local"
# Username running sui (before sudo). Filled in main(); used in zenity text and sui_audit.
SUI_INVOKER=""
# Numeric uid of the invoker. Filled in main(); distinguishes already-root (0) vs needs elevation.
SUI_UID=""
# Single-line, bash-quoted copy of argv for syslog/file audit (no secrets). Set in main() after parse_args.
SUI_CMD_REPR=""
# Parsed command line: executable path/name plus arguments, after removing flags and optional @target.
# Populated as SUI_CMD=("$@") at end of parse_args(); executed via "${SUI_CMD[@]}" to preserve argv.
SUI_CMD=()
# Parsed from --polkit: local path uses pkexec instead of zenity+sudo (desktop habit). Remote ignores it.
USE_POLKIT=0
# Parsed from --dry-run: show intent only; sui_audit dry-run + zenity info or stdout; no elevation.
DRY_RUN=0
# Sudo password from zenity; kept only between read and first sudo/ssh pipe, then unset -v PASS.
PASS=""
SUDO_CACHE=0
AUTH_MAX_ATTEMPTS=3
EXIT_CANCELLED=130
EXIT_AUTH_FAILED=77
JSON_MODE=0
SUI_REASON=""
REQUIRE_REASON=1
AUTH_COMMENT=""
AUTH_ACTION="RUN"
SHOW_VERSION=0

# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
sui — Sudo User Interface (privileged command gateway)

Usage:
  sui [options] [@ssh-target] <command> [args...]
  sui doctor

Options (must appear before @target and command):
  -p, --polkit     Local elevation via pkexec (Polkit). Ignored for remote targets.
  -d, --dry-run    Show intent only; no password; no execution.
  -D, --doctor     Print runtime diagnostics (zenity/pkexec/sudo/ssh/gui/tty).
  -j, --json       Machine-readable output (use with -D).
  -r, --reason TXT Human rationale shown in the privilege dialog.
  -v, --version    Print sui version and exit (no --reason required).
  -s, --sudo-cache Allow sudo timestamp cache (fewer prompts, less strict).
  -S, --no-sudo-cache Enforce secure mode (default): invalidate timestamp each run.
  -h, --help       This help.

Environment:
  SUI_LOG=1    Also append audit lines to $XDG_STATE_HOME/sui/audit.log (default: ~/.local/state).

Examples:
  sui apt update
  sui --reason "Refresh security indexes" apt update
  sui -r "Short rationale" apt update
  sui @docker-host systemctl restart nginx
  sui --polkit -- gparted
EOF
}

# ---------------------------------------------------------------------------
# Build a single-line, bash-safe representation of argv for logs and dialogs.
# Why: "$*" and string concatenation break on spaces/quotes; %q per argument does not.
# ---------------------------------------------------------------------------
cmd_repr() {
  local out="" a
  for a in "$@"; do
    printf -v out '%s %q' "$out" "$a"
  done
  printf '%s\n' "${out# }"
}

# ---------------------------------------------------------------------------
# Multi-line body for zenity --forms --text=...
# The argv is always shown in a high-visibility block (never concealed): readability and safety first.
# ---------------------------------------------------------------------------
zenity_body() {
  local mode=$1       # LOCAL-ZENITY | REMOTE-ZENITY | DRY-RUN
  local target=$2
  shift 2
  local pretty
  pretty="$(cmd_repr "$@")"
  local scope_u
  scope_u="${SUI_SCOPE^^}"

  cat <<EOF
═══════════════════════════════════════════════════════════
  ${scope_u} ROOT ELEVATION  ·  Sui v${SUI_VERSION}
═══════════════════════════════════════════════════════════

Read the COMMAND block below: it is exactly what will run with privileges.

Context
  Scope:     ${SUI_SCOPE}
  Target:    ${target}
  Invoker:   ${SUI_INVOKER} (uid ${SUI_UID})
  Host:      $(hostname 2>/dev/null || echo unknown)
  CWD:       $(pwd 2>/dev/null || echo unknown)
  Time:      $(date -Iseconds 2>/dev/null || date)
  Channel:   ${mode}
  Rationale: ${SUI_REASON:-<none provided>}

=============================================================
COMMAND (exact argv · bash-quoted · runs as root after OK)
=============================================================

  ${pretty}

=============================================================

Input (single GTK form dialog)
  • Action: RUN (default) or ABORT, then validate with OK.
  • Operator comment (optional): extra shell trace shown at the end if non-empty.
  • Sudo password: your sudo password.

Press Enter in the password field to validate quickly with OK (RUN stays default).
To abort without elevation: set Action=ABORT and press OK.
EOF
}

# ---------------------------------------------------------------------------
# Audit trail: syslog authpriv (often appears in /var/log/auth.log) + optional file.
# Why authpriv: matches sudo/sshd facility conventions on typical rsyslog rulesets.
# phase: invoke | dry-run | cancel | error
# ---------------------------------------------------------------------------
sui_audit() {
  local phase=$1
  local msg
  local reason_audit
  # Do not persist free-text rationale in syslog or audit.log (leak risk to central log stacks).
  if [[ -n "${SUI_REASON// }" ]]; then
    reason_audit="present"
  else
    reason_audit="<none>"
  fi
  msg="phase=${phase} scope=${SUI_SCOPE} target=${SUI_TARGET} invoker=${SUI_INVOKER} uid=${SUI_UID} cmd=${SUI_CMD_REPR} reason=${reason_audit}"

  if command -v logger >/dev/null 2>&1; then
    # dry-run is not a real authentication event — keep it out of authpriv by default
    if [[ "$phase" == "dry-run" ]]; then
      logger -t sui -p user.notice --id=$$ -- "$msg"
    else
      logger -t sui -p authpriv.notice --id=$$ -- "$msg"
    fi
  else
    printf '%s\n' "Sui: logger(1) not found; audit: $msg" >&2
  fi

  if [[ "${SUI_LOG:-0}" == "1" ]]; then
    local statedir="${XDG_STATE_HOME:-$HOME/.local/state}/sui"
    mkdir -p "$statedir"
    printf '%s %s\n' "$(date -Iseconds 2>/dev/null || date)" "$msg" >>"${statedir}/audit.log"
  fi
}

# ---------------------------------------------------------------------------
# GUI / TTY helpers
# ---------------------------------------------------------------------------
have_display() {
  [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]
}

have_zenity_gui() {
  command -v zenity >/dev/null 2>&1 && have_display
}

zenity_run() {
  # Force GTK software/cairo rendering to avoid noisy Vulkan/MESA warnings on some Intel stacks.
  GSK_RENDERER=cairo zenity "$@" 2>/dev/null
}

# TTY fallback when Zenity is unavailable: password (hidden) then optional comment on the next line.
# Keeps a single logical step without extra GUI popups.
tty_collect_auth_inputs() {
  local pwd_prompt=$1
  PASS=""
  AUTH_COMMENT=""
  if [[ ! -t 0 ]]; then
    return 1
  fi
  read -r -s -p "$pwd_prompt" PASS || return 1
  printf '\n' >&2
  read -r -p "Sui: operator comment (optional, empty = skip): " AUTH_COMMENT || AUTH_COMMENT=""
  return 0
}

notify_auth_failure() {
  local msg=$1
  # Always print to shell for traceability, even when a GUI popup is shown.
  printf '%s\n' "Sui: $msg" >&2
  if have_zenity_gui; then
    zenity_run --error --title="Sui — authentication failed" --text="$msg" --width=520 --height=160 || true
  fi
}

emit_sui_rationale_line() {
  :
}

# One line per dialog when the operator comment is non-empty (no cumulative footer).
emit_operator_comment_for_dialog_attempt() {
  local attempt=$1
  local tag=$2
  if [[ -n "${AUTH_COMMENT// }" ]]; then
    printf '%s\n' "Sui: OPERATOR-COMMENT (dialog ${attempt}/${AUTH_MAX_ATTEMPTS}, ${tag}): **${AUTH_COMMENT}**" >&2
  fi
}

emit_empty_password_message() {
  local scope=$1
  local rhost=${2:-}
  if [[ "$scope" == "local" ]]; then
    printf '%s\n' "Sui: authentication aborted — OK pressed with empty password (local)." >&2
  else
    printf '%s\n' "Sui: authentication aborted — OK pressed with empty password (remote @${rhost})." >&2
  fi
}

emit_action_abort_message() {
  local scope=$1
  local rhost=${2:-}
  if [[ "$scope" == "local" ]]; then
    printf '%s\n' "Sui: authentication aborted — Action=ABORT selected (local)." >&2
  else
    printf '%s\n' "Sui: authentication aborted — Action=ABORT selected (remote @${rhost})." >&2
  fi
}

emit_dialog_closed_message() {
  local scope=$1
  local rhost=${2:-}
  if [[ "$scope" == "local" ]]; then
    printf '%s\n' "Sui: authentication cancelled — dialog closed without OK (local)." >&2
  else
    printf '%s\n' "Sui: authentication cancelled — dialog closed without OK (remote @${rhost})." >&2
  fi
}

fail_missing_reason() {
  printf '%s\n' "Sui: blocked — missing required rationale (--reason or -r)." >&2
  printf '%s\n' "Sui: this command was not executed." >&2
  printf '%s\n' "Sui: please relaunch with an explicit reason, then validate in the popup." >&2
  printf 'Sui: retry example: sui --reason "%s" %s\n' "why this privileged action is needed" "${SUI_CMD_REPR}" >&2
}

LOCAL_AUTH_FAILED=0
sudo_execute_local_with_password() {
  local pass=$1
  shift
  local ec
  local kflag=""
  local err_file=""
  local err_text=""
  if [[ "$SUDO_CACHE" -eq 0 ]]; then
    kflag="-k"
  fi
  err_file="$(mktemp)"
  printf '%s\n' "$pass" | sudo -S ${kflag} -p '' -- "$@" 2>"$err_file"
  ec=$?

  LOCAL_AUTH_FAILED=0
  err_text="$(<"$err_file")"
  if [[ "$ec" -ne 0 ]]; then
    if remote_is_auth_error_text "$err_text" || [[ "$err_text" == *"interactive authentication is required"* ]]; then
      LOCAL_AUTH_FAILED=1
    elif [[ -n "$err_text" ]]; then
      printf '%s\n' "$err_text" >&2
    fi
  elif [[ -n "$err_text" ]]; then
    printf '%s\n' "$err_text" >&2
  fi

  rm -f "$err_file"
  if [[ "$SUDO_CACHE" -eq 0 && "$ec" -eq 0 ]]; then
    sudo -k >/dev/null 2>&1 || true
  fi
  return "$ec"
}

REMOTE_AUTH_FAILED=0
remote_is_auth_error_text() {
  local txt=$1
  [[ "$txt" == *"Authentication failed"* ]] || \
  [[ "$txt" == *"a password is required"* ]] || \
  [[ "$txt" == *"incorrect authentication attempts"* ]] || \
  [[ "$txt" == *"try again"* ]]
}

sudo_execute_remote_with_password() {
  local target=$1
  local pass=$2
  shift
  shift
  local ec
  local kflag=""
  local err_file=""

  if [[ "$SUDO_CACHE" -eq 0 ]]; then
    kflag="-k"
  fi
  err_file="$(mktemp)"

  {
    printf '%s\n' "$pass"
    printf 'set -euo pipefail\n'
    printf 'exec'
    local a
    for a in "$@"; do
      printf ' %q' "$a"
    done
    printf '\n'
  } | ssh -o 'BatchMode=no' -- "$target" "sudo -S ${kflag} -p \"\" -- bash -s" 2>"$err_file"
  ec=$?

  REMOTE_AUTH_FAILED=0
  local err_text=""
  err_text="$(<"$err_file")"

  if [[ "$ec" -ne 0 ]]; then
    if remote_is_auth_error_text "$err_text"; then
      REMOTE_AUTH_FAILED=1
    elif [[ -n "$err_text" ]]; then
      # Non-auth remote errors should still be visible to the operator.
      printf '%s\n' "$err_text" >&2
    fi
  elif [[ -n "$err_text" ]]; then
    # Preserve stderr coming from a successful remote command.
    printf '%s\n' "$err_text" >&2
  fi

  rm -f "$err_file"

  if [[ "$SUDO_CACHE" -eq 0 && "$ec" -eq 0 ]]; then
    ssh -o 'BatchMode=no' -- "$target" 'sudo -n -k' >/dev/null 2>&1 || true
  fi
  return "$ec"
}

print_doctor() {
  if [[ "$JSON_MODE" -eq 1 ]]; then
    print_doctor_json
    return 0
  fi
  printf '%s\n' "Sui doctor v${SUI_VERSION}"
  printf '%s\n' "---------------------"
  printf 'user: %s (uid %s)\n' "$(id -un)" "$(id -u)"
  printf 'cwd: %s\n' "$(pwd)"
  printf 'display: DISPLAY=%s WAYLAND_DISPLAY=%s\n' "${DISPLAY:-<unset>}" "${WAYLAND_DISPLAY:-<unset>}"
  printf 'tty-stdin: %s\n' "$([[ -t 0 ]] && echo yes || echo no)"
  printf 'tty-stdout: %s\n' "$([[ -t 1 ]] && echo yes || echo no)"
  printf 'zenity: %s\n' "$({ command -v zenity >/dev/null 2>&1 && echo yes || echo no; })"
  printf 'pkexec: %s\n' "$({ command -v pkexec >/dev/null 2>&1 && echo yes || echo no; })"
  printf 'sudo: %s\n' "$({ command -v sudo >/dev/null 2>&1 && echo yes || echo no; })"
  printf 'ssh: %s\n' "$({ command -v ssh >/dev/null 2>&1 && echo yes || echo no; })"
  printf 'gui-capable-now: %s\n' "$({ have_zenity_gui && echo yes || echo no; })"
  printf '%s\n' ""
  printf '%s\n' "fallback-order-local: zenity -> pkexec -> tty-password+sudo"
  printf '%s\n' "fallback-order-remote: zenity -> tty-password+ssh+sudo"
  printf 'sudo-cache-mode: %s\n' "$([[ "$SUDO_CACHE" -eq 1 ]] && echo enabled || echo secure-disabled)"
}

print_doctor_json() {
  local tty_in tty_out zenity_ok pkexec_ok sudo_ok ssh_ok gui_ok cache_mode
  tty_in="$([[ -t 0 ]] && echo true || echo false)"
  tty_out="$([[ -t 1 ]] && echo true || echo false)"
  zenity_ok="$({ command -v zenity >/dev/null 2>&1 && echo true || echo false; })"
  pkexec_ok="$({ command -v pkexec >/dev/null 2>&1 && echo true || echo false; })"
  sudo_ok="$({ command -v sudo >/dev/null 2>&1 && echo true || echo false; })"
  ssh_ok="$({ command -v ssh >/dev/null 2>&1 && echo true || echo false; })"
  gui_ok="$({ have_zenity_gui && echo true || echo false; })"
  cache_mode="$([[ "$SUDO_CACHE" -eq 1 ]] && echo enabled || echo secure-disabled)"
  printf '{\n'
  printf '  "version": "%s",\n' "$SUI_VERSION"
  printf '  "user": "%s",\n' "$(id -un)"
  printf '  "uid": %s,\n' "$(id -u)"
  printf '  "cwd": "%s",\n' "$(pwd)"
  printf '  "display": "%s",\n' "${DISPLAY:-}"
  printf '  "wayland_display": "%s",\n' "${WAYLAND_DISPLAY:-}"
  printf '  "tty_stdin": %s,\n' "$tty_in"
  printf '  "tty_stdout": %s,\n' "$tty_out"
  printf '  "zenity": %s,\n' "$zenity_ok"
  printf '  "pkexec": %s,\n' "$pkexec_ok"
  printf '  "sudo": %s,\n' "$sudo_ok"
  printf '  "ssh": %s,\n' "$ssh_ok"
  printf '  "gui_capable_now": %s,\n' "$gui_ok"
  printf '  "sudo_cache_mode": "%s",\n' "$cache_mode"
  printf '  "fallback_order_local": ["zenity", "pkexec", "tty-password+sudo"],\n'
  printf '  "fallback_order_remote": ["zenity", "tty-password+ssh+sudo"]\n'
  printf '}\n'
}

zenity_collect_auth_inputs() {
  local title=$1
  local text=$2
  local out zec sep
  if ! have_zenity_gui; then
    return 2
  fi
  sep=$'\x1e'
  out="$(zenity_run --forms \
    --title="$title" \
    --text="$text" \
    --separator="$sep" \
    --add-combo="Action" \
    --combo-values="RUN|ABORT" \
    --add-entry="Operator comment (optional)" \
    --add-password="Sudo password" \
    --ok-label="OK" --cancel-label="Close" \
    --width=780 --height=700)"
  zec=$?
  out="${out//$'\r'/}"
  out="${out%$'\n'}"
  PASS=""
  AUTH_COMMENT=""
  AUTH_ACTION="RUN"
  # Best-effort parse for action/comment even on non-OK exits.
  if [[ "$out" == *"$sep"* ]]; then
    AUTH_ACTION="${out%%"$sep"*}"
    out="${out#*"$sep"}"
    if [[ "$out" == *"$sep"* ]]; then
      AUTH_COMMENT="${out%%"$sep"*}"
      if [[ "$zec" -eq 0 ]]; then
        PASS="${out#*"$sep"}"
      fi
    elif [[ "$zec" -eq 0 ]]; then
      PASS="$out"
    fi
  elif [[ "$zec" -eq 0 ]]; then
    PASS="$out"
  fi
  return "$zec"
}

notify_dry_run() {
  local text
  text="$(zenity_body "DRY-RUN" "$SUI_TARGET" "$@")"
  if have_zenity_gui; then
    zenity_run --info --title="Sui — dry-run" --text="$text" --width=720 --height=480
  else
    printf '%s\n' "$text"
  fi
}

# ---------------------------------------------------------------------------
# Local execution paths
# ---------------------------------------------------------------------------
run_local_as_root() {
  # Already root — no elevation, no password. Still log for accountability.
  sui_audit "invoke"
  exec "$@"
}

run_local_pkexec() {
  if ! command -v pkexec >/dev/null 2>&1; then
    printf '%s\n' "Sui: pkexec not found (install polkit or use default zenity+sudo path)." >&2
    return 1
  fi
  sui_audit "invoke"
  # pkexec does not use GNU-style "--" separator here; passing it makes pkexec
  # try to execute a literal program named "--".
  exec pkexec "$@"
}

run_local_zenity_sudo() {
  if ! command -v sudo >/dev/null 2>&1; then
    printf '%s\n' "Sui: sudo not found." >&2
    return 1
  fi
  local body title zpwd summary attempt
  summary="$(cmd_repr "$@")"
  title="Sui — local sudo [${SUI_INVOKER}] — ${summary}"
  body="$(zenity_body "LOCAL-ZENITY" "local" "$@")"
  for ((attempt=1; attempt<=AUTH_MAX_ATTEMPTS; attempt++)); do
    zpwd=""
    PASS=""
    AUTH_COMMENT=""
    zenity_collect_auth_inputs "${title} [${attempt}/${AUTH_MAX_ATTEMPTS}]" "$body"
    zec=$?
    case $zec in
      0)
        if [[ "${AUTH_ACTION^^}" == "ABORT" ]]; then
          emit_action_abort_message "local"
          emit_operator_comment_for_dialog_attempt "$attempt" "after auth failure"
          sui_audit "cancel"
          return "$EXIT_CANCELLED"
        fi
        zpwd="$PASS"
        if [[ -z "$zpwd" ]]; then
          emit_empty_password_message "local"
          emit_operator_comment_for_dialog_attempt "$attempt" "on empty password"
          sui_audit "cancel"
          return "$EXIT_CANCELLED"
        fi
        ;;
      2)
        tty_collect_auth_inputs "Sui: sudo password for ${SUI_INVOKER}: " || {
          printf '%s\n' "Sui: no GUI available and no interactive TTY password input possible." >&2
          sui_audit "cancel"
          return "$EXIT_CANCELLED"
        }
        zpwd="$PASS"
        ;;
      *)
        emit_dialog_closed_message "local"
        emit_operator_comment_for_dialog_attempt "$attempt" "on dialog closed"
        sui_audit "cancel"
        return "$EXIT_CANCELLED"
        ;;
    esac
    PASS="$zpwd"
    unset -v zpwd
    sudo_execute_local_with_password "$PASS" "$@"
    local local_ec=$?
    unset -v PASS
    if [[ "$local_ec" -eq 0 ]]; then
      sui_audit "invoke"
      emit_operator_comment_for_dialog_attempt "$attempt" "on successful auth"
      return 0
    fi
    if [[ "$LOCAL_AUTH_FAILED" -ne 1 ]]; then
      emit_sui_rationale_line
      emit_operator_comment_for_dialog_attempt "$attempt" "after command error"
      return "$local_ec"
    fi
    if [[ "$attempt" -lt "$AUTH_MAX_ATTEMPTS" ]]; then
      notify_auth_failure "Authentication failed (${attempt}/${AUTH_MAX_ATTEMPTS}). Please try again."
      emit_operator_comment_for_dialog_attempt "$attempt" "after auth failure"
    else
      emit_operator_comment_for_dialog_attempt "$attempt" "after auth failure"
    fi
  done
  notify_auth_failure "Authentication failed ${AUTH_MAX_ATTEMPTS} times. Aborting."
  printf '%s\n' "Sui: local sudo aborted after ${AUTH_MAX_ATTEMPTS} failed attempts." >&2
  emit_sui_rationale_line
  sui_audit "cancel"
  return "$EXIT_AUTH_FAILED"
}

# ---------------------------------------------------------------------------
# Remote execution — robust argv tunnel (never use "$*" over SSH)
#
# Protocol over SSH stdin for non-root→sudo case:
#   Line 1: sudo password (consumed by sudo -S)
#   Rest:   bash script executed as root
#
# Why bash -s: arbitrary argv is re-materialized with %q on the remote shell,
# avoiding one giant quoted string and injection via metacharacters.
# ---------------------------------------------------------------------------
run_remote_root_direct() {
  local target=$1
  shift
  sui_audit "invoke"
  {
    printf 'set -euo pipefail\n'
    printf 'exec'
    local a
    for a in "$@"; do
      printf ' %q' "$a"
    done
    printf '\n'
  } | ssh -o 'BatchMode=no' -- "$target" 'bash -s'
}

run_remote_zenity_sudo() {
  local target=$1
  shift
  # Remote machine must provide sudo(8); we cannot probe it without a session. A missing remote sudo
  # surfaces as a non-zero ssh exit code.
  local body title zpwd summary attempt
  summary="$(cmd_repr "$@")"
  title="Sui — remote sudo [@${target}] — ${summary}"
  body="$(zenity_body "REMOTE-ZENITY" "$target" "$@")"
  for ((attempt=1; attempt<=AUTH_MAX_ATTEMPTS; attempt++)); do
    zpwd=""
    PASS=""
    AUTH_COMMENT=""
    zenity_collect_auth_inputs "${title} [${attempt}/${AUTH_MAX_ATTEMPTS}]" "$body"
    zec=$?
    case $zec in
      0)
        if [[ "${AUTH_ACTION^^}" == "ABORT" ]]; then
          emit_action_abort_message "remote" "$target"
          emit_operator_comment_for_dialog_attempt "$attempt" "after auth failure"
          sui_audit "cancel"
          return "$EXIT_CANCELLED"
        fi
        zpwd="$PASS"
        if [[ -z "$zpwd" ]]; then
          emit_empty_password_message "remote" "$target"
          emit_operator_comment_for_dialog_attempt "$attempt" "on empty password"
          sui_audit "cancel"
          return "$EXIT_CANCELLED"
        fi
        ;;
      2)
        tty_collect_auth_inputs "Sui: remote sudo password for @${target}: " || {
          printf '%s\n' "Sui: no GUI available and no interactive TTY password input possible." >&2
          sui_audit "cancel"
          return "$EXIT_CANCELLED"
        }
        zpwd="$PASS"
        ;;
      *)
        emit_dialog_closed_message "remote" "$target"
        emit_operator_comment_for_dialog_attempt "$attempt" "on dialog closed"
        sui_audit "cancel"
        return "$EXIT_CANCELLED"
        ;;
    esac
    PASS="$zpwd"
    unset -v zpwd
    sudo_execute_remote_with_password "$target" "$PASS" "$@"
    local remote_ec=$?
    unset -v PASS
    if [[ "$remote_ec" -eq 0 ]]; then
      sui_audit "invoke"
      emit_operator_comment_for_dialog_attempt "$attempt" "on successful auth"
      return 0
    fi
    if [[ "$REMOTE_AUTH_FAILED" -ne 1 ]]; then
      emit_sui_rationale_line
      emit_operator_comment_for_dialog_attempt "$attempt" "after command error"
      return "$remote_ec"
    fi
    if [[ "$attempt" -lt "$AUTH_MAX_ATTEMPTS" ]]; then
      notify_auth_failure "Remote authentication failed (${attempt}/${AUTH_MAX_ATTEMPTS}) for @${target}. Please try again."
      emit_operator_comment_for_dialog_attempt "$attempt" "after auth failure"
    else
      emit_operator_comment_for_dialog_attempt "$attempt" "after auth failure"
    fi
  done
  notify_auth_failure "Remote authentication failed ${AUTH_MAX_ATTEMPTS} times for @${target}. Aborting."
  printf '%s\n' "Sui: remote sudo aborted for @${target} after ${AUTH_MAX_ATTEMPTS} failed attempts." >&2
  emit_sui_rationale_line
  sui_audit "cancel"
  return "$EXIT_AUTH_FAILED"
}

# ---------------------------------------------------------------------------
# Parse argv: [options] [@host] command ...
# ---------------------------------------------------------------------------
parse_args() {
  # Initialization
  SUI_TARGET="local"
  SUI_SCOPE="local"
  USE_POLKIT=0
  DRY_RUN=0
  DOCTOR_MODE=0
  SUDO_CACHE=0
  JSON_MODE=0
  SUI_REASON=""
  SHOW_VERSION=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --polkit)    USE_POLKIT=1; shift ;;
      --dry-run)   DRY_RUN=1;    shift ;;
      --doctor)    DOCTOR_MODE=1; shift ;;
      --json)      JSON_MODE=1;   shift ;;
      --sudo-cache) SUDO_CACHE=1; shift ;;
      --no-sudo-cache) SUDO_CACHE=0; shift ;;
      --__require-reason) REQUIRE_REASON=1; shift ;;
      --__no-require-reason) REQUIRE_REASON=0; shift ;;
      --version)   SHOW_VERSION=1; shift ;;
      --help)      usage; exit 0 ;;
      --reason=*)
        SUI_REASON="${1#*=}"
        [[ -z "$SUI_REASON" ]] && { printf 'Sui: --reason requires a value.\n' >&2; exit 2; }
        shift ;;
      --reason)
        shift
        [[ $# -lt 1 || "$1" == -* ]] && { printf 'Sui: --reason requires a value.\n' >&2; exit 2; }
        SUI_REASON="$1"; shift ;;
      -r=*)
        SUI_REASON="${1#-r=}"
        [[ -z "$SUI_REASON" ]] && { printf 'Sui: -r requires a value.\n' >&2; exit 2; }
        shift ;;
      @*)
        if [[ "$SUI_SCOPE" == "local" ]]; then
          SUI_TARGET="${1#@}"
          SUI_SCOPE="remote"
          shift
          if [[ $# -lt 1 ]]; then
            printf 'Sui: missing command after @%s.\n' "$SUI_TARGET" >&2
            exit 2
          fi
        else
          # Already has a target, stop parsing here
          break
        fi
        ;;
      doctor)
        DOCTOR_MODE=1
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        local opt_string="${1#-}"
        shift
        while [[ -n "$opt_string" ]]; do
          local opt="${opt_string:0:1}"
          opt_string="${opt_string:1}"
          case "$opt" in
            p) USE_POLKIT=1 ;;
            d) DRY_RUN=1 ;;
            D) DOCTOR_MODE=1 ;;
            j) JSON_MODE=1 ;;
            s) SUDO_CACHE=1 ;;
            S) SUDO_CACHE=0 ;;
            v) SHOW_VERSION=1 ;;
            h) usage; exit 0 ;;
            r)
              if [[ -n "$opt_string" ]]; then
                SUI_REASON="$opt_string"
                opt_string=""
              elif [[ $# -gt 0 && "$1" != -* ]]; then
                SUI_REASON="$1"
                shift
              else
                printf 'Sui: -r requires a value (cannot start with -).\n' >&2
                exit 2
              fi
              ;;
            *)
              printf 'Sui: unrecognized option -%s\n' "$opt" >&2
              exit 2
              ;;
          esac
        done
        ;;
      *)
        break
        ;;
    esac
  done

  # Process diagnostic modes that don't require a command
  if [[ "$DOCTOR_MODE" -eq 1 && $# -lt 1 ]]; then
    return 0
  fi
  if [[ "$SHOW_VERSION" -eq 1 && $# -lt 1 ]]; then
    return 0
  fi

  if [[ $# -lt 1 ]]; then
    printf 'Sui: missing command (see sui --help).\n' >&2
    exit 2
  fi

  # Remaining positional parameters are exactly what we must exec (preserve argv).
  SUI_CMD=("$@")

  # Detect "shell string" commands: if exactly one command argument is provided
  # and it contains shell metacharacters or spaces, wrap it in 'bash -c' to
  # ensure it is interpreted as a complex command by a high-level shell.
  if [[ ${#SUI_CMD[@]} -eq 1 ]]; then
    local cmd="${SUI_CMD[0]}"
    # If the command contains any character that isn't a safe "filename" character
    # (alphanumerics, dot, underscore, hyphen, plus, or slash), we treat it as 
    # a shell string that requires evaluation.
    if [[ "$cmd" =~ [^a-zA-Z0-9._/+-] ]]; then
      SUI_CMD=("bash" "-c" "$cmd")
    fi
  fi
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
  SUI_INVOKER="$(id -un)"
  SUI_UID="$(id -u)"

  parse_args "$@"

  if [[ "${SHOW_VERSION:-0}" -eq 1 ]]; then
    printf '%s\n' "Sui v${SUI_VERSION}"
    exit 0
  fi

  if [[ "${DOCTOR_MODE:-0}" -eq 1 ]]; then
    print_doctor
    exit 0
  fi

  # Parsed command + argv (flags and @target already stripped).
  SUI_CMD_REPR="$(cmd_repr "${SUI_CMD[@]}")"

  if [[ "$REQUIRE_REASON" -eq 1 ]] && [[ -z "${SUI_REASON// }" ]]; then
    fail_missing_reason
    exit 2
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    sui_audit "dry-run"
    notify_dry_run "${SUI_CMD[@]}"
    exit 0
  fi

  if [[ "$SUI_SCOPE" == "local" ]]; then
    if [[ "$SUI_UID" -eq 0 ]]; then
      run_local_as_root "${SUI_CMD[@]}"
    fi
    if [[ "$USE_POLKIT" -eq 1 ]]; then
      run_local_pkexec "${SUI_CMD[@]}"
    fi
    run_local_zenity_sudo "${SUI_CMD[@]}"
    exit $?
  fi

  # Remote branch
  if [[ "$USE_POLKIT" -eq 1 ]]; then
    printf '%s\n' "Sui: note: --polkit applies to local elevation only; remote still uses SSH + zenity + sudo." >&2
  fi

  local ruid
  ruid="$(ssh -o 'BatchMode=no' -- "$SUI_TARGET" 'id -u' 2>/dev/null)" || {
    printf '%s\n' "Sui: cannot reach ssh target '${SUI_TARGET}' (ssh failed)." >&2
    sui_audit "error"
    exit 1
  }

  if [[ "$ruid" == "0" ]]; then
    run_remote_root_direct "$SUI_TARGET" "${SUI_CMD[@]}"
  else
    run_remote_zenity_sudo "$SUI_TARGET" "${SUI_CMD[@]}"
  fi
  exit $?
}

main "$@"

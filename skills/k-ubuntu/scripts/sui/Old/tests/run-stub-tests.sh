#!/usr/bin/env bash
# Automated stub tests for sui (zenity + sudo + ssh + logger) — no real GUI or privilege.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SUI="$ROOT/sui.sh"
STUBS="$ROOT/tests/stubs"
export DISPLAY="${DISPLAY:-:0}"

fail() {
  printf '%s\n' "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  [[ "$1" == "$2" ]] || fail "expected exit $2, got $1"
}

assert_contains() {
  [[ "$1" == *"$2"* ]] || fail "expected output to contain: $2
---
$1
---"
}

assert_not_contains() {
  [[ "$1" != *"$2"* ]] || fail "expected output NOT to contain: $2"
}

init_state() {
  export SUI_TEST_STATE_DIR
  SUI_TEST_STATE_DIR="$(mktemp -d)"
  printf '0\n' >"$SUI_TEST_STATE_DIR/zenity_count"
  printf '0\n' >"$SUI_TEST_STATE_DIR/sudo_count"
  printf '0\n' >"$SUI_TEST_STATE_DIR/ssh_remote_sudo_count"
  : >"$SUI_TEST_STATE_DIR/logger.log"
  export XDG_STATE_HOME="$SUI_TEST_STATE_DIR/xdg_state"
  mkdir -p "$XDG_STATE_HOME/sui"
}

cleanup() {
  [[ -n "${SUI_TEST_STATE_DIR:-}" ]] && rm -rf "$SUI_TEST_STATE_DIR"
}
trap cleanup EXIT

run_sui() {
  SUI_LOG=1 PATH="$STUBS:$PATH" bash "$SUI" "$@"
}

case_local_abort() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  cat >"$SUI_STUB_ZENITY_RESPONSES" <<'EOF'
0|ABORT|abort-note|ignored
EOF
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 130
  assert_contains "$out" "Action=ABORT selected (local)"
  assert_contains "$out" "OPERATOR-COMMENT (dialog 1/3, after auth failure): **abort-note**"
}

case_local_empty_password() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN|empty-case|' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 130
  assert_contains "$out" "empty password (local)"
  assert_contains "$out" "OPERATOR-COMMENT (dialog 1/3, on empty password): **empty-case**"
}

case_local_dialog_closed() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '1|RUN|closed-note|pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 130
  assert_contains "$out" "dialog closed without OK (local)"
  assert_contains "$out" "OPERATOR-COMMENT (dialog 1/3, on dialog closed): **closed-note**"
}

case_local_success_first() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN|win|s3cr3t' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 0
  assert_contains "$out" "OPERATOR-COMMENT (dialog 1/3, on successful auth): **win**"
}

case_local_reason_r_alias() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN||pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason -r "r-alias-test" true 2>&1)" || ec=$?
  assert_eq "$ec" 0
}

case_local_reason_r_equals_form() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN||pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason -r=r-equals true 2>&1)" || ec=$?
  assert_eq "$ec" 0
}

case_local_retry_then_success() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  cat >"$SUI_STUB_ZENITY_RESPONSES" <<'EOF'
0|RUN|r1|bad
0|RUN|r2|good
EOF
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  cat >"$SUI_STUB_SUDO_MODES" <<'EOF'
auth
ok
EOF
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 0
  assert_contains "$out" "Authentication failed (1/3). Please try again."
  assert_contains "$out" "OPERATOR-COMMENT (dialog 1/3, after auth failure): **r1**"
  assert_contains "$out" "OPERATOR-COMMENT (dialog 2/3, on successful auth): **r2**"
}

case_local_three_auth_failures() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  for _ in 1 2 3; do printf '%s\n' '0|RUN|f|p'; done >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' auth auth auth >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 77
  assert_contains "$out" "Authentication failed (1/3). Please try again."
  assert_contains "$out" "Authentication failed (2/3). Please try again."
  assert_contains "$out" "Authentication failed 3 times. Aborting."
  assert_contains "$out" "local sudo aborted after 3 failed attempts"
  assert_contains "$out" "OPERATOR-COMMENT (dialog 3/3, after auth failure): **f**"
}

case_local_third_dialog_empty_password() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  cat >"$SUI_STUB_ZENITY_RESPONSES" <<'EOF'
0|RUN|a|p1
0|RUN|b|p2
0|RUN|c|
EOF
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  cat >"$SUI_STUB_SUDO_MODES" <<'EOF'
auth
auth
EOF
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 130
  assert_contains "$out" "empty password (local)"
  assert_not_contains "$out" "Authentication failed 3 times"
  assert_contains "$out" "OPERATOR-COMMENT (dialog 3/3, on empty password): **c**"
}

case_local_non_auth_sudo_error() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN|ne|pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "notfound" >"$SUI_STUB_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" true 2>&1)" || ec=$?
  assert_eq "$ec" 127
  assert_contains "$out" "stub: non-auth command error"
  assert_contains "$out" "OPERATOR-COMMENT (dialog 1/3, after command error): **ne**"
}

case_audit_reason_present_not_leaked() {
  local ec=0
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN||x' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  run_sui --__no-require-reason --reason "SECRET_REASON_XYZ" true >/dev/null 2>&1 || ec=$?
  assert_eq "$ec" 0
  logf="$SUI_TEST_STATE_DIR/logger.log"
  auditf="$XDG_STATE_HOME/sui/audit.log"
  [[ -f "$logf" ]] || fail "logger stub log missing"
  [[ -f "$auditf" ]] || fail "audit.log missing"
  assert_contains "$(cat "$logf")" "reason=present"
  assert_not_contains "$(cat "$logf")" "SECRET_REASON_XYZ"
  assert_contains "$(cat "$auditf")" "reason=present"
  assert_not_contains "$(cat "$auditf")" "SECRET_REASON_XYZ"
}

case_missing_reason_blocked() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN||x' >"$SUI_STUB_ZENITY_RESPONSES"
  out="$(run_sui true 2>&1)" || ec=$?
  assert_eq "$ec" 2
  assert_contains "$out" "blocked — missing required rationale"
}

case_version_no_reason() {
  local ec=0 out
  init_state
  out="$(run_sui -v 2>&1)" || ec=$?
  assert_eq "$ec" 0
  assert_contains "$out" "Sui v"
}

case_remote_success() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN|rs|pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_REMOTE_SUDO_MODES="$SUI_TEST_STATE_DIR/rsudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_REMOTE_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" @stubhost true 2>&1)" || ec=$?
  assert_eq "$ec" 0
  assert_contains "$out" "OPERATOR-COMMENT (dialog 1/3, on successful auth): **rs**"
}

case_remote_abort() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|ABORT|ra|x' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_REMOTE_SUDO_MODES="$SUI_TEST_STATE_DIR/rsudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_REMOTE_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" @stubhost true 2>&1)" || ec=$?
  assert_eq "$ec" 130
  assert_contains "$out" "Action=ABORT selected (remote @stubhost)"
}

case_remote_empty_password() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN|re|' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_REMOTE_SUDO_MODES="$SUI_TEST_STATE_DIR/rsudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_REMOTE_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" @stubhost true 2>&1)" || ec=$?
  assert_eq "$ec" 130
  assert_contains "$out" "empty password (remote @stubhost)"
}

case_remote_three_auth_failures() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  for _ in 1 2 3; do printf '%s\n' '0|RUN|rf|p'; done >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_REMOTE_SUDO_MODES="$SUI_TEST_STATE_DIR/rsudo.m"
  printf '%s\n' auth auth auth >"$SUI_STUB_REMOTE_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" @stubhost true 2>&1)" || ec=$?
  assert_eq "$ec" 77
  assert_contains "$out" "Remote authentication failed (1/3) for @stubhost"
  assert_contains "$out" "remote sudo aborted for @stubhost after 3 failed attempts"
}

case_remote_non_auth_error() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN|rne|pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_REMOTE_SUDO_MODES="$SUI_TEST_STATE_DIR/rsudo.m"
  printf '%s\n' "notfound" >"$SUI_STUB_REMOTE_SUDO_MODES"
  out="$(run_sui --__no-require-reason --reason "t" @stubhost true 2>&1)" || ec=$?
  assert_eq "$ec" 127
  assert_contains "$out" "remote non-auth command error"
}

case_local_shell_string() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN||pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_SUDO_MODES="$SUI_TEST_STATE_DIR/sudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_SUDO_MODES"
  # Use --dry-run to check the command representation without real execution.
  # Hide DISPLAY to force stdout dry-run output
  out="$(DISPLAY="" WAYLAND_DISPLAY="" run_sui --__no-require-reason --reason "t" --dry-run "ls -la /root" 2>&1)" || ec=$?
  assert_eq "$ec" 0
  # Representation should show the wrapped bash -c call.
  assert_contains "$out" "COMMAND (exact argv · bash-quoted · runs as root after OK)"
  assert_contains "$out" "bash -c ls\\ -la\\ /root"
}

case_remote_shell_string() {
  local ec=0 out
  init_state
  export SUI_STUB_ZENITY_RESPONSES="$SUI_TEST_STATE_DIR/z.resp"
  printf '%s\n' '0|RUN||pw' >"$SUI_STUB_ZENITY_RESPONSES"
  export SUI_STUB_REMOTE_SUDO_MODES="$SUI_TEST_STATE_DIR/rsudo.m"
  printf '%s\n' "ok" >"$SUI_STUB_REMOTE_SUDO_MODES"
  # Hide DISPLAY to force stdout dry-run output
  out="$(DISPLAY="" WAYLAND_DISPLAY="" run_sui --__no-require-reason --reason "t" --dry-run @stubhost "apt update && apt upgrade" 2>&1)" || ec=$?
  assert_eq "$ec" 0
  assert_contains "$out" "bash -c apt\\ update\\ \\&\\&\\ apt\\ upgrade"
}

main() {
  local failed=0 name fn
  printf '%s\n' "sui stub tests (ROOT=$ROOT)"
  while IFS= read -r name; do
    fn="case_${name}"
    printf '%s\n' "==> $name"
    if "$fn"; then
      printf '%s\n' "    OK"
    else
      failed=$((failed + 1))
      printf '%s\n' "    FAILED"
    fi
  done <<'EOF'
local_abort
local_empty_password
local_dialog_closed
local_success_first
local_reason_r_alias
local_reason_r_equals_form
local_retry_then_success
local_three_auth_failures
local_third_dialog_empty_password
local_non_auth_sudo_error
audit_reason_present_not_leaked
missing_reason_blocked
version_no_reason
remote_success
remote_abort
remote_empty_password
remote_three_auth_failures
remote_non_auth_error
local_shell_string
remote_shell_string
EOF
  if [[ "$failed" -ne 0 ]]; then
    fail "$failed test(s) failed"
  fi
  printf '%s\n' "All stub tests passed."
}

main "$@"

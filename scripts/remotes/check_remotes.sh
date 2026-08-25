#!/usr/bin/env bash
# ============================================================
# check_remotes.sh — verify the kernel git remotes contract
# ============================================================
# Enforces the k-git remotes contract (values in scripts/remotes/lib.sh):
#   1. EXACTLY 2 remotes configured
#   2. names are exactly: github + gitlab (never `origin`)
#   3. each URL matches the exact kpihx-labs/agents SSH mirror
#
# THIN ORCHESTRATOR (scripts/AGENTS.md): sources lib.sh for expected values
# and git helpers; holds only aggregation and reporting.
#
# Source:  .agents/scripts/remotes/check_remotes.sh
# Caller:  make check-remotes   (first gate of `make check`)
# Fix:     make set-remotes
# Depends: .agents/scripts/remotes/lib.sh
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

if ! kernel_repo_exists; then
	echo "  ✗ Kernel repo not found at $KERNEL_REPO_DIR (expected the ~/.agents git clone)"
	exit 1
fi

failed=0
checked=0

names_raw="$(remotes_list)"
count=0
for n in $names_raw; do count=$((count + 1)); done

echo "  ├─ 🛰  1/3 Remote count (contract: exactly 2)"
checked=$((checked + 1))
if [ "$count" -eq 2 ]; then
	echo "  ✓ $count remote(s) configured"
else
	echo "  ✗ Expected exactly 2 remotes, found $count"
	failed=$((failed + 1))
fi

echo "  ├─ 🏷  2/3 Remote names (contract: $EXPECTED_REMOTE_NAMES)"
checked=$((checked + 1))
actual_names="$(printf '%s\n' $names_raw | sort | tr '\n' ' ')"
if [ "$actual_names" = "github gitlab " ]; then
	echo "  ✓ names match the contract exactly"
else
	echo "  ✗ FORBIDDEN remote configuration: names = $(echo "$names_raw" | tr '\n' ' ')"
	for n in $names_raw; do
		case " $EXPECTED_REMOTE_NAMES " in
			*" $n "*) ;;
			*) echo "      unexpected remote '$n' (e.g. 'origin' breaks make push) — run: make set-remotes" ;;
		esac
	done
	for n in $EXPECTED_REMOTE_NAMES; do
		found=""
		for m in $names_raw; do [ "$m" = "$n" ] && found=1; done
		[ -z "$found" ] && echo "      missing required remote '$n' — run: make set-remotes"
	done
	failed=$((failed + 1))
fi

echo "  ├─ 🔗 3/3 Exact SSH mirror URLs"
checked=$((checked + 1))
check_url() {
	name="$1"
	expected="$2"
	if ! actual="$(remotes_get_url "$name" 2>/dev/null)"; then
		echo "  ✗ remote '$name' missing or unreadable — run: make set-remotes"
		failed=$((failed + 1))
		return
	fi
	if [ "$actual" = "$expected" ]; then
		echo "  ✓ $name → $actual"
	else
		echo "  ✗ $name URL mismatch"
		echo "      expected: $expected"
		echo "      actual:   $actual"
		failed=$((failed + 1))
	fi
}
check_url github "$EXPECTED_GITHUB_URL"
check_url gitlab "$EXPECTED_GITLAB_URL"

echo "  └─ 📊 Summary: $checked contract group(s) verified, $failed violation(s)"
[ "$failed" -eq 0 ]

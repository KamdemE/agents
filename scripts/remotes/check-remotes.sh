#!/usr/bin/env bash
# ============================================================
# check-remotes.sh — verify the git remotes contract on the kernel
# repo AND every declared submodule
# ============================================================
# Enforces the k-git remotes contract (values in scripts/remotes/lib.sh):
#   1. EXACTLY 1 remote: `origin` (a read-only `upstream` on submodules is
#      tolerated)
#   2. kernel URL matches the exact fork SSH URL; submodules only need an
#      `origin` remote present (any URL — owner's forks vary)
#   3. `origin` is LIVE-JOINABLE (`git ls-remote`) and the current branch
#      is present on it
#   4. uninitialized submodules are SKIPPED with a note (not a failure) —
#      this machine does not use them
#
# THIN ORCHESTRATOR (scripts/AGENTS.md): sources lib.sh for expected values
# and git helpers; holds only aggregation and reporting.
#
# Source:  .agents/scripts/remotes/check-remotes.sh
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

check_repo() {
	local dir="$1" label="$2" name is_kernel
	name="$(repo_name_for "$dir")"
	is_kernel=0
	[ "$dir" = "$KERNEL_REPO_DIR" ] && is_kernel=1
	echo "  ━━━ $label ━━━"

	local names_raw count=0 n
	names_raw="$(remotes_list "$dir")"
	for n in $names_raw; do count=$((count + 1)); done

	echo "  ├─ 🛰  Remote contract (exactly: origin, upstream tolerated read-only)"
	checked=$((checked + 1))
	local bad=0
	for n in $names_raw; do
		case " $TOLERATED_REMOTE_NAMES " in
			*" $n "*) ;;
			*)
				echo "  ✗ FORBIDDEN remote '$n' ($(remotes_get_url "$dir" "$n")) — only origin (+upstream read-only) allowed. Run: make set-remotes"
				bad=1 ;;
		esac
	done
	if ! printf '%s\n' "$names_raw" | grep -Fxq "$EXPECTED_REMOTE_NAME"; then
		echo "  ✗ missing required remote '$EXPECTED_REMOTE_NAME' — run: make set-remotes"
		bad=1
	fi
	if [ "$bad" -eq 0 ]; then
		echo "  ✓ names match the contract exactly"
	else
		failed=$((failed + 1))
	fi

	echo "  ├─ 🔗 Origin URL"
	checked=$((checked + 1))
	local actual=""
	actual="$(remotes_get_url "$dir" "$EXPECTED_REMOTE_NAME" || true)"
	if [ -z "$actual" ]; then
		echo "  ✗ remote '$EXPECTED_REMOTE_NAME' missing or unreadable — run: make set-remotes"
		failed=$((failed + 1))
	elif [ "$is_kernel" -eq 1 ] && [ "$actual" != "$EXPECTED_KERNEL_URL" ]; then
		echo "  ✗ kernel origin URL mismatch (expected $EXPECTED_KERNEL_URL, got $actual)"
		failed=$((failed + 1))
	else
		echo "  ✓ origin → $actual"
	fi

	echo "  └─ 🌐 Live joinability + branch presence (origin)"
	checked=$((checked + 1))
	local branch out
	branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
	if [ -z "$actual" ]; then
		echo "  ✗ no origin URL to probe — run: make set-remotes"
		failed=$((failed + 1))
	elif ! out="$(git -C "$dir" ls-remote --heads "$EXPECTED_REMOTE_NAME" 2>&1)"; then
		echo "  ✗ origin UNREACHABLE (ls-remote failed): $(printf '%s' "$out" | head -1)"
		failed=$((failed + 1))
	elif ! printf '%s\n' "$out" | grep -q "refs/heads/$branch"; then
		echo "  ✗ branch '$branch' does NOT exist on 'origin' → push it (make push)"
		failed=$((failed + 1))
	else
		echo "  ✓ origin reachable, branch '$branch' present"
	fi
}

check_repo "$KERNEL_REPO_DIR" "$(repo_name_for "$KERNEL_REPO_DIR") (kernel)"

while IFS= read -r sm; do
	[ -n "$sm" ] || continue
	sm_dir="$KERNEL_REPO_DIR/$sm"
	if [ ! -e "$sm_dir/.git" ]; then
		echo "  ━━━ $sm ━━━"
		echo "  ○ $sm: not initialized — skipped (run: make submodule-init to use it)"
		continue
	fi
	check_repo "$sm_dir" "$sm"
done < <(submodule_paths)

echo "  └─ 📊 Summary: $checked contract group(s) verified, $failed violation(s)"
[ "$failed" -eq 0 ]

#!/usr/bin/env bash
# ============================================================
# check-remotes.sh — verify the kpihx git remotes contract on the kernel
# repo AND every declared submodule
# ============================================================
# Enforces the k-git remotes contract (values in scripts/remotes/lib.sh):
#   1. EXACTLY 2 required remotes: github + gitlab (never `origin`) — a
#      read-only `upstream` (Flickwire-Agent/IgorWarzocha forks) is tolerated
#   2. each URL matches the exact kpihx-labs SSH mirror for that repo's name
#      (personal `KpihX`/`kpihx` namespace also accepted, for older tools)
#   3. both `github` and `gitlab` are LIVE-JOINABLE (`git ls-remote`) and the
#      current branch is present on each (absorbed from the blglaptop139-wsl
#      remote-pair contract, 2026-08-26)
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
	local dir="$1" label="$2" name
	name="$(repo_name_for "$dir")"
	echo "  ━━━ $label ━━━"

	local names_raw count=0 n
	names_raw="$(remotes_list "$dir")"
	for n in $names_raw; do count=$((count + 1)); done

	echo "  ├─ 🛰  Remote count (contract: exactly 2 required + optional read-only upstream)"
	checked=$((checked + 1))
	local required=0
	for n in $names_raw; do
		case " $EXPECTED_REMOTE_NAMES " in *" $n "*) required=$((required + 1)) ;; esac
	done
	if [ "$required" -eq 2 ]; then
		echo "  ✓ $count remote(s) configured ($required required + $((count - required)) tolerated)"
	else
		echo "  ✗ Expected exactly the 2 required remotes (github+gitlab), found $required of them ($count total)"
		failed=$((failed + 1))
	fi

	echo "  ├─ 🏷  Remote names (forbidden = anything outside $TOLERATED_REMOTE_NAMES)"
	checked=$((checked + 1))
	local bad=0
	for n in $names_raw; do
		case " $TOLERATED_REMOTE_NAMES " in
			*" $n "*) ;;
			*)
				echo "  ✗ FORBIDDEN remote '$n' ($(remotes_get_url "$dir" "$n")) — only github/gitlab (+upstream read-only) allowed. Run: make set-remotes"
				bad=1 ;;
		esac
	done
	for n in $EXPECTED_REMOTE_NAMES; do
		found=""
		for m in $names_raw; do [ "$m" = "$n" ] && found=1; done
		[ -z "$found" ] && { echo "  ✗ missing required remote '$n' — run: make set-remotes"; bad=1; }
	done
	if [ "$bad" -eq 0 ]; then
		echo "  ✓ names match the contract exactly"
	else
		failed=$((failed + 1))
	fi

	echo "  ├─ 🔗 Exact SSH mirror URLs"
	checked=$((checked + 1))
	check_url() {
		local rname="$1" gh_expected gl_expected actual
		local exp1 exp2
		if [ "$rname" = "github" ]; then
			exp1="$(expected_github_url "$name")"; exp2="git@github.com:KpihX/$name.git"
		else
			exp1="$(expected_gitlab_url "$name")"; exp2="git@gitlab.com:kpihx/$name.git"
		fi
		if ! actual="$(remotes_get_url "$dir" "$rname")" || [ -z "$actual" ]; then
			echo "  ✗ remote '$rname' missing or unreadable — run: make set-remotes"
			failed=$((failed + 1))
			return
		fi
		if [ "$actual" = "$exp1" ] || [ "$actual" = "$exp2" ]; then
			echo "  ✓ $rname → $actual"
		else
			echo "  ✗ $rname URL mismatch (expected $exp1 or personal $exp2, got $actual)"
			failed=$((failed + 1))
		fi
	}
	check_url github
	check_url gitlab

	echo "  └─ 🌐 Live joinability + branch presence (github + gitlab)"
	checked=$((checked + 1))
	local branch out
	branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
	for rname in github gitlab; do
		url="$(remotes_get_url "$dir" "$rname")"
		[ -n "$url" ] || continue
		if ! out="$(git -C "$dir" ls-remote --heads "$rname" 2>&1)"; then
			echo "  ✗ $rname UNREACHABLE (ls-remote failed): $(printf '%s' "$out" | head -1)"
			failed=$((failed + 1))
		elif ! printf '%s\n' "$out" | grep -q "refs/heads/$branch"; then
			echo "  ✗ branch '$branch' does NOT exist on '$rname' → push it (make push)"
			failed=$((failed + 1))
		else
			echo "  ✓ $rname reachable, branch '$branch' present"
		fi
	done
}

check_repo "$KERNEL_REPO_DIR" "$(repo_name_for "$KERNEL_REPO_DIR") (kernel)"

while IFS= read -r sm; do
	[ -n "$sm" ] || continue
	sm_dir="$KERNEL_REPO_DIR/$sm"
	if [ ! -e "$sm_dir/.git" ]; then
		echo "  ━━━ $sm ━━━"
		echo "  ✗ $sm: not initialized (run: make submodule-init)"
		failed=$((failed + 1))
		checked=$((checked + 1))
		continue
	fi
	check_repo "$sm_dir" "$sm"
done < <(submodule_paths)

echo "  └─ 📊 Summary: $checked contract group(s) verified, $failed violation(s)"
[ "$failed" -eq 0 ]

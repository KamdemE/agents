#!/usr/bin/env bash
# ============================================================
# set-remotes.sh — enforce the git remotes contract (fixer) on the
# kernel repo AND every declared submodule
# ============================================================
# Counterpart of check-remotes.sh. Idempotent — safe to run anytime:
#   1. removes any remote outside the contract (a read-only `upstream`
#      is left untouched)
#   2. repoints local-branch tracking that referenced a removed remote
#   3. sets `origin` to the exact contract URL for the kernel; for
#      submodules an existing `origin` URL is kept as-is (owner's forks
#      vary) and only added if missing (caller must fix the URL)
#   4. repeats for every initialized submodule declared in .gitmodules
#
# Source:  .agents/scripts/remotes/set-remotes.sh
# Caller:  make set-remotes
# Verify:  make check-remotes
# Depends: .agents/scripts/remotes/lib.sh
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

if ! kernel_repo_exists; then
	echo "✗ Kernel repo not found at $KERNEL_REPO_DIR (expected the ~/.agents git clone)"
	exit 1
fi

set_repo() {
	local dir="$1" label="$2" name is_kernel
	name="$(repo_name_for "$dir")"
	is_kernel=0
	[ "$dir" = "$KERNEL_REPO_DIR" ] && is_kernel=1
	echo "🛠 [set-remotes] Enforcing contract on $label ($dir)"

	# --- 1. Remove any forbidden remote (upstream tolerated) ---------------
	local removed=0 n
	for n in $(remotes_list "$dir"); do
		case " $TOLERATED_REMOTE_NAMES " in
			*" $n "*) ;;
			*)
				git -C "$dir" remote remove "$n"
				echo "  🗑 removed forbidden remote '$n'"
				removed=$((removed + 1))
				;;
		esac
	done
	[ "$removed" -eq 0 ] && echo "  ✓ no forbidden remote"

	# --- 2. Repoint branch tracking to origin ------------------------------
	local repointed=0
	while IFS='|' read -r branch upstream_remote; do
		[ -z "$upstream_remote" ] && continue
		[ "$upstream_remote" = "$EXPECTED_REMOTE_NAME" ] && continue
		git -C "$dir" config "branch.$branch.remote" "$EXPECTED_REMOTE_NAME"
		echo "  🔁 branch '$branch' tracking repointed: $upstream_remote → $EXPECTED_REMOTE_NAME"
		repointed=$((repointed + 1))
	done < <(git -C "$dir" for-each-ref --format='%(refname:short)|%(upstream:remotename)' refs/heads/)
	[ "$repointed" -eq 0 ] && echo "  ✓ branch tracking already compliant"

	# --- 3. Ensure origin ----------------------------------------------------
	if [ "$is_kernel" -eq 1 ]; then
		if remotes_list "$dir" | grep -Fxq "$EXPECTED_REMOTE_NAME"; then
			actual="$(remotes_get_url "$dir" "$EXPECTED_REMOTE_NAME")"
			if [ "$actual" = "$EXPECTED_KERNEL_URL" ]; then
				echo "  ✓ origin already correct → $actual"
			else
				git -C "$dir" remote set-url "$EXPECTED_REMOTE_NAME" "$EXPECTED_KERNEL_URL"
				echo "  🔁 origin URL updated: $actual → $EXPECTED_KERNEL_URL"
			fi
		else
			git -C "$dir" remote add "$EXPECTED_REMOTE_NAME" "$EXPECTED_KERNEL_URL"
			echo "  ➕ added remote 'origin' → $EXPECTED_KERNEL_URL"
		fi
	else
		if remotes_list "$dir" | grep -Fxq "$EXPECTED_REMOTE_NAME"; then
			echo "  ✓ origin kept as-is → $(remotes_get_url "$dir" "$EXPECTED_REMOTE_NAME") (fix manually if wrong fork)"
		else
			echo "  ⚠️  no origin remote — add it manually: git -C $dir remote add origin <url>"
		fi
	fi

	echo "  — Final remotes:"
	git -C "$dir" remote -v | sed 's/^/      /'
}

set_repo "$KERNEL_REPO_DIR" "$(repo_name_for "$KERNEL_REPO_DIR") (kernel)"

while IFS= read -r sm; do
	[ -n "$sm" ] || continue
	sm_dir="$KERNEL_REPO_DIR/$sm"
	if [ ! -e "$sm_dir/.git" ]; then
		echo "🛠 [set-remotes] $sm: not initialized (run: make submodule-init) — skipped"
		continue
	fi
	set_repo "$sm_dir" "$sm"
done < <(submodule_paths)

echo "✅ Remotes contract enforced — verify with: make check-remotes"

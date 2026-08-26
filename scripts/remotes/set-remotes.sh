#!/usr/bin/env bash
# ============================================================
# set-remotes.sh — enforce the kpihx git remotes contract (fixer) on the
# kernel repo AND every declared submodule
# ============================================================
# Counterpart of check-remotes.sh. Idempotent — safe to run anytime:
#   1. removes any remote outside the contract (e.g. `origin`) — a read-only
#      `upstream` is left untouched (Flickwire-Agent/IgorWarzocha forks)
#   2. repoints local-branch tracking that referenced a removed remote
#   3. adds/sets `github` + `gitlab` to the exact contract URLs (lib.sh)
#   4. repeats for every submodule declared in .gitmodules (absorbed from
#      the blglaptop139-wsl remote-pair contract, 2026-08-26)
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
	local dir="$1" label="$2" name
	name="$(repo_name_for "$dir")"
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

	# --- 2. Repoint branch tracking to a surviving contract remote ---------
	local repointed=0
	while IFS='|' read -r branch upstream_remote; do
		[ -z "$upstream_remote" ] && continue
		case " $EXPECTED_REMOTE_NAMES " in
			*" $upstream_remote "*) ;;
			*)
				git -C "$dir" config "branch.$branch.remote" github
				echo "  🔁 branch '$branch' tracking repointed: $upstream_remote → github"
				repointed=$((repointed + 1))
				;;
		esac
	done < <(git -C "$dir" for-each-ref --format='%(refname:short)|%(upstream:remotename)' refs/heads/)
	[ "$repointed" -eq 0 ] && echo "  ✓ branch tracking already compliant"

	# --- 3. Upsert the two contract remotes ---------------------------------
	upsert_remote() {
		local rname="$1" url="$2" actual=""
		if remotes_list "$dir" | grep -Fxq "$rname"; then
			actual="$(remotes_get_url "$dir" "$rname")"
			if [ "$actual" = "$url" ]; then
				echo "  ✓ $rname already correct → $url"
			else
				git -C "$dir" remote set-url "$rname" "$url"
				echo "  🔁 $rname URL updated: $actual → $url"
			fi
		else
			git -C "$dir" remote add "$rname" "$url"
			echo "  ➕ added remote '$rname' → $url"
		fi
	}
	upsert_remote github "$(expected_github_url "$name")"
	upsert_remote gitlab "$(expected_gitlab_url "$name")"

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

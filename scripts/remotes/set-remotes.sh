#!/usr/bin/env bash
# ============================================================
# set-remotes.sh — enforce the kernel git remotes contract (fixer)
# ============================================================
# Counterpart of check-remotes.sh. Idempotent — safe to run anytime:
#   1. removes ANY remote outside the contract (e.g. `origin`)
#   2. repoints local-branch tracking that referenced a removed remote
#   3. adds/sets `github` + `gitlab` to the exact contract URLs (lib.sh)
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

echo "🛠 [set-remotes] Enforcing contract on $KERNEL_REPO_DIR"

# --- 1. Remove any forbidden remote ---------------------------------------
removed=0
for n in $(remotes_list); do
	case " $EXPECTED_REMOTE_NAMES " in
		*" $n "*) ;;
		*)
			git -C "$KERNEL_REPO_DIR" remote remove "$n"
			echo "  🗑 removed forbidden remote '$n'"
			removed=$((removed + 1))
			;;
	esac
done
[ "$removed" -eq 0 ] && echo "  ✓ no forbidden remote"

# --- 2. Repoint branch tracking to a surviving contract remote -------------
repointed=0
while IFS='|' read -r branch upstream_remote; do
	[ -z "$upstream_remote" ] && continue
	case " $EXPECTED_REMOTE_NAMES " in
		*" $upstream_remote "*) ;;
		*)
			git -C "$KERNEL_REPO_DIR" config "branch.$branch.remote" github
			echo "  🔁 branch '$branch' tracking repointed: $upstream_remote → github"
			repointed=$((repointed + 1))
			;;
	esac
done < <(git -C "$KERNEL_REPO_DIR" for-each-ref --format='%(refname:short)|%(upstream:remotename)' refs/heads/)
[ "$repointed" -eq 0 ] && echo "  ✓ branch tracking already compliant"

# --- 3. Upsert the two contract remotes ------------------------------------
upsert_remote() {
	name="$1"
	url="$2"
	actual=""
	if remotes_list | grep -Fxq "$name"; then
		actual="$(remotes_get_url "$name")"
		if [ "$actual" = "$url" ]; then
			echo "  ✓ $name already correct → $url"
		else
			git -C "$KERNEL_REPO_DIR" remote set-url "$name" "$url"
			echo "  🔁 $name URL updated: $actual → $url"
		fi
	else
		git -C "$KERNEL_REPO_DIR" remote add "$name" "$url"
		echo "  ➕ added remote '$name' → $url"
	fi
}
upsert_remote github "$EXPECTED_GITHUB_URL"
upsert_remote gitlab "$EXPECTED_GITLAB_URL"

# --- 4. Final state ---------------------------------------------------------
echo "— Final remotes:"
git -C "$KERNEL_REPO_DIR" remote -v | sed 's/^/    /'
echo "✅ Remotes contract enforced — verify with: make check-remotes"

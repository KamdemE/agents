# ============================================================
# lib.sh — single source of truth for the kernel git remotes contract
# ============================================================
# Contract (owner skill: k-git): the .agents kernel repo carries EXACTLY two
# remotes, named `github` and `gitlab`, pointing at the SSH mirrors of the
# kpihx-labs/agents repository. Any other remote name (e.g. `origin` left by
# a default clone) violates the contract and breaks `make push`, which pushes
# explicitly to `github` then `gitlab`.
#
# Sourced by check-remotes.sh (verify) and set-remotes.sh (enforce).
#
# Source:  .agents/scripts/remotes/lib.sh
# Used by: scripts/remotes/check-remotes.sh · scripts/remotes/set-remotes.sh
# ============================================================

set -uo pipefail

AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents}"
KERNEL_REPO_DIR="$AGENTS_DIR"

EXPECTED_GITHUB_URL="git@github.com:kpihx-labs/agents.git"
EXPECTED_GITLAB_URL="git@gitlab.com:kpihx-labs/agents.git"
EXPECTED_REMOTE_NAMES="github gitlab"

remotes_list() {
	git -C "$KERNEL_REPO_DIR" remote
}

remotes_get_url() {
	git -C "$KERNEL_REPO_DIR" remote get-url "$1"
}

kernel_repo_exists() {
	[ -d "$KERNEL_REPO_DIR/.git" ]
}

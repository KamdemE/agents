# ============================================================
# lib.sh — single source of truth for the git remotes contract
# ============================================================
# Contract (owner skill: k-git): the kernel repo (~/.agents) AND every one of
# its submodules carry EXACTLY ONE remote, named `origin`, pointing at the
# owner's fork (single-remote workflow — no github/gitlab pair, no upstream
# pushes). A read-only `upstream` is tolerated on submodules — never pushed.
# `make push` pushes explicitly to `origin`.
#
# Sourced by check-remotes.sh (verify) and set-remotes.sh (enforce).
#
# Source:  .agents/scripts/remotes/lib.sh
# Used by: scripts/remotes/check-remotes.sh · scripts/remotes/set-remotes.sh
# ============================================================

set -uo pipefail

AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents}"
KERNEL_REPO_DIR="$AGENTS_DIR"

EXPECTED_REMOTE_NAME="origin"
EXPECTED_KERNEL_URL="git@github.com:KamdemE/agents.git"
TOLERATED_REMOTE_NAMES="origin upstream"

remotes_list() {
	git -C "$1" remote
}

remotes_get_url() {
	git -C "$1" remote get-url "$2" 2>/dev/null
}

kernel_repo_exists() {
	[ -d "$KERNEL_REPO_DIR/.git" ]
}

# repo_name_for DIR — basename of the repo, with the `.agents` → `agents`
# mapping (the kernel directory hosts the `agents` repo under a different
# local name).
repo_name_for() {
	local dir="$1" name
	name="$(basename "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")")"
	[ "$name" = ".agents" ] && name="agents"
	printf '%s\n' "$name"
}

# submodule_paths — every path declared in .gitmodules at the repo root.
submodule_paths() {
	git config -f "$KERNEL_REPO_DIR/.gitmodules" --get-regexp '^submodule\..*\.path$' 2>/dev/null \
		| cut -d' ' -f2
}

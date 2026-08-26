# ============================================================
# lib.sh — single source of truth for the kpihx git remotes contract
# ============================================================
# Contract (owner skill: k-git): the kernel repo (~/.agents) AND every one of
# its submodules carry EXACTLY two remotes, named `github` and `gitlab`,
# pointing at the SSH mirrors of the matching kpihx-labs (or personal kpihx)
# repository. A read-only `upstream` (Flickwire-Agent/IgorWarzocha forks on
# submodules) is explicitly tolerated — never enforced, never pushed. Any
# other remote name (e.g. `origin` left by a default clone) violates the
# contract and breaks `make push`, which pushes explicitly to `github` then
# `gitlab`.
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
TOLERATED_REMOTE_NAMES="github gitlab upstream"

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

# expected_github_url NAME / expected_gitlab_url NAME — kpihx-labs namespace
# by default; a personal KpihX/kpihx namespace is also accepted (see the
# case-match in check-remotes.sh) for personal tools that predate the
# kpihx-labs org convention.
expected_github_url() { printf 'git@github.com:kpihx-labs/%s.git\n' "$1"; }
expected_gitlab_url() { printf 'git@gitlab.com:kpihx-labs/%s.git\n' "$1"; }

# submodule_paths — every path declared in .gitmodules at the repo root.
submodule_paths() {
	git config -f "$KERNEL_REPO_DIR/.gitmodules" --get-regexp '^submodule\..*\.path$' 2>/dev/null \
		| cut -d' ' -f2
}

# $HOME/.agents/Makefile — agent memory repo lifecycle
# Required commands: make, git, zsh, awk, find, bash, python3, ruff, pyright, shellcheck, oxlint, node.
#
# 🔴🔴🔴 ABSOLUTE RULE — NEVER USE « 2>/dev/null || true »
# 🔴🔴🔴 EVERY ERROR MUST BE FIXED, INCLUDING PRE-EXISTING ONES.
# 🔴🔴🔴 NEVER SILENCE AN ERROR WITH 2>/dev/null || true.
# 🔴🔴🔴 « make check » MUST BE 100% CLEAN BEFORE COMMIT/PUSH.
#
# If you are tempted to add 2>/dev/null || true: DON'T. Fix the error.
# Pre-existing errors are not an excuse — fix them one-by-one with Edit calls.

BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
SHELL = /bin/zsh

.PHONY: push push-sub push-tags log status check-skills check check-remotes set-remotes pr check-py check-sh check-js check-services check-links check-tailscale check-exec check-env check-jsonc reload-services set-tailscale chmod install-hooks set-links help submodule-init submodule-update

help: ## Show available targets
	@awk 'BEGIN {FS = ": ## "}; /^[a-zA-Z0-9_.-]+: ## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

push: ## Push to all configured remotes
	git push github $(BRANCH) && git push gitlab $(BRANCH)

push-sub: ## Commit (if dirty) + push EVERY submodule to ALL its remotes (rebase on remote-ahead, loud failures)
	@bash $(HOME)/.agents/scripts/git/push-submodules.sh

pr: ## Open PR (github) + MR (gitlab) for the current branch against master [override: make pr BASE=dev]
	@bash $(HOME)/.agents/scripts/git/create-pr.sh $(BASE)

check-skills: ## Run .agents structural skills audit
	@echo "🔍 [check-skills] Structural skill audit"
	@python3 $(HOME)/.agents/scripts/check_skills/check_skills.py

check-py: ## Auto-fix and lint Python files using ruff and pyright
	@echo "🔍 [check-py] Python quality"
	@echo "  ├─ 🛠 Ruff format + safe fixes"
	@ruff format scripts/ libs/ skills/
	@ruff check --fix scripts/ libs/ skills/
	@echo "  ├─ 🔎 Ruff diagnostics"
	@ruff check scripts/ libs/ skills/
	@echo "  ├─ 🧠 Pyright type analysis"
	@pyright scripts/ libs/
	@echo "  └─ ✅ Summary: Python checks passed"

check-sh: ## Lint Shell scripts using shellcheck (ignore known false positives)
	@echo "🔍 [check-sh] Shell quality"
	@echo "  ├─ 🔎 ShellCheck"
	@find . -type f -name "*.sh" -not -path "*/.venv/*" \
		-exec shellcheck --shell=bash \
		-e SC1090,SC1091,SC2034,SC2154,SC2086,SC2012,SC2004,SC2015,SC2014,SC2129,SC2181,SC2035,SC2029,SC2155,SC2291,SC2024,SC2317,SC2162,SC1010,SC2016 \
		{} + # SC1090-91:non-constant source (modular .kshrc). SC2034:exported vars. SC2154:sourced vars. SC2086:word-split intentional. SC2012:ls readable. SC2004:style. SC2015:A&&B||C intended. SC2014:find expansion needed. SC2129:style. SC2181:style. SC2035:no dashes. SC2029:client-side expansion. SC2155:export VAR="$(cmd)" idiomatic. SC2291:ASCII art spaces. SC2024:sudo context safe. SC2317:indirect calls. SC2162:backslash edge-case
	@echo "  └─ ✅ Summary: Shell checks passed"

check-js: ## Lint JS/TS files in hooks, scripts, libs, and skill scripts
	@echo "🔍 [check-js] JavaScript and TypeScript quality"
	@echo "  ├─ 🔎 OXLint"
	@oxlint scripts/ libs/ skills/ --deny-warnings
	@echo "  ├─ 🧩 Node syntax"
	@for f in $$(find scripts/ libs/ skills/ -name "*.js" -type f -not -path "*/node_modules/*" -not -path "*/vendor/*"); do node -c "$$f" || exit $$?; done
	@echo "  └─ ✅ Summary: JS/TS checks passed"

check-services: ## Verify .agents-owned systemd services (from assets/services.jsonc) — deployed + functional
	@echo "🔍 [check-services] Systemd service contract"
	@bash $(HOME)/.agents/scripts/services/check-services.sh

check-tailscale: ## Verify Tailscale is up (--accept-dns --accept-routes) + local node online + operator (no sudo)
	@echo "🔍 [check-tailscale] Tailscale backbone"
	@bash $(HOME)/.agents/scripts/tailscale/check-tailscale.sh

set-tailscale: ## Converge Tailscale to desired state (--accept-dns --accept-routes --operator=$$USER) — use via tmux ops pane if sudo prompts
	@bash $(HOME)/.agents/scripts/tailscale/set-tailscale.sh

reload-services: ## Reload .agents-owned services of the current infra (from assets/services.jsonc)
	@echo "🔁 Reloading .agents-owned services..."
	@bash $(HOME)/.agents/scripts/services/reload-services.sh

check-links: ## Verify .agents-owned symlinks (from assets/links.jsonc) are not broken/reversed
	@echo "🔍 [check-links] Symlink registry contract"
	@bash $(HOME)/.agents/scripts/links/check-links.sh

check-exec: ## Verify script executability (shebang entrypoints executable, library modules not)
	@echo "🔍 [check-exec] Script executability"
	@bash $(HOME)/.agents/scripts/exec/check-exec.sh

check-env: ## Verify .env/.env.example governance (one each, perms 600, format, mirror, filled)
	@echo "🔍 [check-env] Environment-file governance"
	@bash $(HOME)/.agents/scripts/env/check-env.sh

check-jsonc: ## Verify .agents JSONC config assets parse cleanly (via libs/jsonc)
	@echo "🔍 [check-jsonc] JSONC configuration"
	@bash $(HOME)/.agents/scripts/jsonc/check-jsonc.sh

check-remotes: ## Verify kernel repo + EVERY submodule have EXACTLY github+gitlab (exact URLs, live joinable, branch present)
	@echo "🔍 [check-remotes] Git remotes contract (kernel + submodules)"
	@bash $(HOME)/.agents/scripts/remotes/check-remotes.sh

set-remotes: ## Enforce github+gitlab remotes on kernel repo + EVERY submodule (kpihx-labs namespace, remove e.g. origin)
	@bash $(HOME)/.agents/scripts/remotes/set-remotes.sh

check: check-remotes check-py check-sh check-js check-services check-links check-exec check-tailscale check-skills check-env check-jsonc ## Run all validations (Remotes, Ruff, Pyright, Shellcheck, JS, Services, Symlinks, Executability, Tailscale, Skills, Env, JSONC)
	@echo "✅ [make check] All grouped subchecks passed"

install-hooks: ## Install git hooks from scripts/git/hooks/
	bash $(HOME)/.agents/scripts/git/install-hooks.sh

set-links: ## Create/recreate .agents-owned symlinks (uses scripts/links/set-links.sh + assets/links.jsonc)
	@bash $(HOME)/.agents/scripts/links/set-links.sh
	@echo "✅ Symlinks updated for all agent runtimes."

chmod: ## Normalize execute permissions on all kernel scripts (scripts/exec/chmod.sh, default 755)
	@bash $(HOME)/.agents/scripts/exec/chmod.sh 755

submodule-init: ## Init + checkout the plugin submodules (opencode-context, opencode-lens, opencode-web-voice)
	git submodule init && git submodule update --init --recursive

submodule-update: ## Fetch latest from the plugin submodule remotes (github+gitlab)
	git submodule foreach 'git remote get-url github >/dev/null 2>&1 && git pull github main || echo "SKIP: no github remote"'
	git submodule foreach 'git remote get-url gitlab >/dev/null 2>&1 && git pull gitlab main || echo "SKIP: no gitlab remote"'

submodule-upstream: ## Fetch latest from the upstream origin repos (Flickwire/IgorWarzocha) and merge into main
	git submodule foreach 'git remote get-url upstream >/dev/null 2>&1 && git fetch upstream && git merge upstream/main || echo "SKIP: no upstream remote"'

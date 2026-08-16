# $HOME/.agents/Makefile — agent memory repo lifecycle
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

.PHONY: push push-tags log status check-skills check check-py check-sh check-js check-services check-links check-tailscale check-exec check-env check-jsonc reload-services set-links chmod install-hooks link help submodule-init submodule-update

help: ## Show available targets
	@awk 'BEGIN {FS = ": ## "}; /^[a-zA-Z0-9_.-]+: ## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

push: ## Push to all configured remotes
	git push github $(BRANCH) && git push gitlab $(BRANCH)

check-skills: ## Run .agents structural skills audit
	python3 $(HOME)/.agents/scripts/check_skills/check_skills.py

check-py: ## Auto-fix and lint Python files using ruff and pyright
	@echo "🔍 Auto-fixing Python (ruff format + ruff check --fix)..."
	@ruff format scripts/ libs/ skills/
	@ruff check --fix scripts/ libs/ skills/
	@echo "🔍 Checking Python scripts..."
	@ruff check scripts/ libs/ skills/
	@pyright scripts/ libs/

check-sh: ## Lint Shell scripts using shellcheck (ignore known false positives)
	@echo "🔍 Checking Shell scripts..."
	@find . -type f -name "*.sh" -not -path "*/.venv/*" \
		-exec shellcheck --shell=bash \
		-e SC1090,SC1091,SC2034,SC2154,SC2086,SC2012,SC2004,SC2015,SC2014,SC2129,SC2181,SC2035,SC2029,SC2155,SC2291,SC2024,SC2317,SC2162 \
		{} + # SC1090-91:non-constant source (modular .kshrc). SC2034:exported vars. SC2154:sourced vars. SC2086:word-split intentional. SC2012:ls readable. SC2004:style. SC2015:A&&B||C intended. SC2014:find expansion needed. SC2129:style. SC2181:style. SC2035:no dashes. SC2029:client-side expansion. SC2155:export VAR="$(cmd)" idiomatic. SC2291:ASCII art spaces. SC2024:sudo context safe. SC2317:indirect calls. SC2162:backslash edge-case

check-js: ## Lint JS/TS files in hooks, scripts, libs, and skill scripts
	@echo "🔍 Checking JS/TS scripts..."
	@oxlint scripts/ libs/ skills/ --deny-warnings
	@for f in $$(find scripts/ libs/ skills/ -name "*.js" -type f); do node -c "$$f" || exit $$?; done

check-services: ## Verify .agents-owned systemd services (from assets/services.jsonc) — deployed + functional
	@echo "🔍 Checking .agents-owned services (assets/services.jsonc)..."
	@bash $(HOME)/.agents/scripts/services/check_services.sh

check-tailscale: ## Verify Tailscale is up (--accept-dns --accept-routes) + user is a Tailscale operator (no sudo)
	@echo "🔍 Checking Tailscale backbone..."
	@bash $(HOME)/.agents/scripts/check_tailscale.sh

reload-services: ## Reload .agents-owned services of the current infra (from assets/services.jsonc)
	@echo "🔁 Reloading .agents-owned services..."
	@bash $(HOME)/.agents/scripts/services/reload_services.sh

check-links: ## Verify .agents-owned symlinks (from assets/links.jsonc) are not broken/reversed
	@echo "🔗 Checking .agents-owned symlinks (assets/links.jsonc)..."
	@bash $(HOME)/.agents/scripts/links/check_links.sh

check-exec: ## Verify script executability (shebang entrypoints executable, library modules not)
	@echo "🔧 Checking script executability (shebang entrypoints vs library modules)..."
	@bash $(HOME)/.agents/scripts/exec/check_exec.sh

check-env: ## Verify .env/.env.example governance (one each, perms 600, format, mirror, filled)
	@echo "🔍 Checking .env/.env.example governance..."
	@bash $(HOME)/.agents/scripts/env/check_env.sh

check-jsonc: ## Verify .agents JSONC config assets parse cleanly (via libs/jsonc)
	@echo "🔍 Checking JSONC config assets (assets/*.jsonc)..."
	@bash $(HOME)/.agents/scripts/jsonc/check_jsonc.sh

check: check-py check-sh check-js check-services check-links check-exec check-tailscale check-skills check-env check-jsonc ## Run all validations (Ruff, Pyright, Shellcheck, JS, Services, Symlinks, Executability, Tailscale, Skills, Env, JSONC)

tools: ## Required global tools: ruff (uv tool install ruff), pyright (uv tool install pyright), oxlint (npm install -g oxlint)

install-hooks: ## Install git hooks from scripts/git/assets/
	bash $(HOME)/.agents/scripts/git/install-hooks.sh

link: ## Create/recreate .agents-owned symlinks (uses scripts/links/set_links.sh + assets/links.jsonc)
	@bash $(HOME)/.agents/scripts/links/set_links.sh
	@echo "✅ Symlinks updated for all agent runtimes."

set-links: ## Alias for `link` — (re)create .agents-owned symlinks from assets/links.jsonc
	@bash $(HOME)/.agents/scripts/links/set_links.sh
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

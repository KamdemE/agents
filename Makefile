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

.PHONY: push push-tags log status audit check check-py check-sh check-js install-hooks link help

help: ## Show available targets
	@awk 'BEGIN {FS = ": ## "}; /^[a-zA-Z0-9_.-]+: ## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

push: ## Push to all configured remotes
	git push github $(BRANCH) && git push gitlab $(BRANCH)

push-tags: ## Push all tags to all remotes
	git push github --tags && git push gitlab --tags

audit: ## Run .agents structural audit
	python3 $(HOME)/.agents/hooks/audit.py

check-py: ## Auto-fix and lint Python files using ruff and pyright
	@echo "🔍 Auto-fixing Python (ruff format + ruff check --fix)..."
	@ruff format hooks/ scripts/ skills/
	@ruff check --fix hooks/ scripts/ skills/
	@echo "🔍 Checking Python scripts..."
	@ruff check hooks/ scripts/ skills/
	@pyright hooks/ scripts/

check-sh: ## Lint Shell scripts using shellcheck (ignore known false positives)
	@echo "🔍 Checking Shell scripts..."
	@find . -type f -name "*.sh" -not -path "*/.venv/*" \
		-exec shellcheck --shell=bash \
		-e SC1090,SC1091,SC2034,SC2154,SC2086,SC2012,SC2004,SC2015,SC2014,SC2129,SC2181,SC2035,SC2029,SC2155,SC2291,SC2024,SC2317,SC2162 \
		{} + # SC1090-91:non-constant source (modular .kshrc). SC2034:exported vars. SC2154:sourced vars. SC2086:word-split intentional. SC2012:ls readable. SC2004:style. SC2015:A&&B||C intended. SC2014:find expansion needed. SC2129:style. SC2181:style. SC2035:no dashes. SC2029:client-side expansion. SC2155:export VAR="$(cmd)" idiomatic. SC2291:ASCII art spaces. SC2024:sudo context safe. SC2317:indirect calls. SC2162:backslash edge-case

check-js: ## Lint JS/TS files in hooks, scripts, and skill scripts
	@echo "🔍 Checking JS/TS scripts..."
	@oxlint hooks/ scripts/ skills/ --deny-warnings
	@for f in $$(find hooks/ scripts/ skills/ \( -name "*.js" -o -name "*.ts" \) -type f); do node -c "$$f" || exit $$?; done

check: check-py check-sh check-js audit ## Run all  evalidations (Ruff, Pyright, Shellcheck, JS, and Audit)

tools: ## Required global tools: ruff (uv tool install ruff), pyright (uv tool install pyright), oxlint (npm install -g oxlint)

install-hooks: ## Install git hooks from scripts/git/assets/
	bash $(HOME)/.agents/scripts/git/install-hooks.sh

link: ## Symlink .agents/ into all agent runtimes
	ln -sfn $(HOME)/.agents/AGENTS.md $(HOME)/.config/opencode/AGENTS.md
	ln -sfn $(HOME)/.agents/skills $(HOME)/.config/opencode/skills
	ln -sfn $(HOME)/.agents/agents $(HOME)/.config/opencode/agents
	ln -sfn $(HOME)/.agents/profiles $(HOME)/.config/opencode/profiles
	ln -sfn $(HOME)/.agents/skills/k-opencode/assets/opencode.jsonc $(HOME)/.config/opencode/opencode.jsonc
	ln -sfn $(HOME)/.agents/skills/k-opencode/assets/tui.json $(HOME)/.config/opencode/tui.json
	ln -sfn $(HOME)/.agents/AGENTS.md $(HOME)/.codex/AGENTS.md
	ln -sfn $(HOME)/.agents/AGENTS.md $(HOME)/.copilot/copilot-instructions.md
	ln -sfn $(HOME)/.agents/AGENTS.md $(HOME)/.gemini/GEMINI.md
	ln -sfn $(HOME)/.agents/AGENTS.md $(HOME)/.vibe/prompts/global.md
	ln -sfn $(HOME)/.agents/AGENTS.md $(HOME)/.k-ai/AGENTS.md
	@echo "✅ Symlinks updated for all agent runtimes."

log: ## Last 10 commits
	git log --oneline -10

status: ## Git status
	git status

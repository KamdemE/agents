# $HOME/.agents/Makefile — agent memory repo lifecycle

BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)

.PHONY: push push-tags log status audit link help

help: ## Show available targets
	@awk 'BEGIN {FS = ": ## "}; /^[a-zA-Z0-9_.-]+: ## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

push: ## Push to all configured remotes
	git push github $(BRANCH) && git push gitlab $(BRANCH)

push-tags: ## Push all tags to all remotes
	git push github --tags && git push gitlab --tags

audit: ## Run .agents structural audit
	python3 $(HOME)/.agents/hooks/audit.py

link: ## Symlink .agents/ into all agent runtimes
	ln -sfn $(HOME)/.agents/AGENTS.md $(HOME)/.config/opencode/AGENTS.md
	ln -sfn $(HOME)/.agents/skills $(HOME)/.config/opencode/skills
	ln -sfn $(HOME)/.agents/agents $(HOME)/.config/opencode/agents
	ln -sfn $(HOME)/.agents/profiles $(HOME)/.config/opencode/profiles
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

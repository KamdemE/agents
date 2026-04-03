# $HOME/.agents/Makefile — agent memory repo lifecycle

BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)

.PHONY: push push-tags log status audit help

help: ## Show available targets
	@awk 'BEGIN {FS = ": ## "}; /^[a-zA-Z0-9_.-]+: ## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

push: ## Push to all configured remotes
	git push github $(BRANCH) && git push gitlab $(BRANCH)

push-tags: ## Push all tags to all remotes
	git push github --tags && git push gitlab --tags

audit: ## Run .agents structural audit
	python3 $(HOME)/.agents/hooks/core/audit.py

log: ## Last 10 commits
	git log --oneline -10

status: ## Git status
	git status

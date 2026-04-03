# $HOME/.agents/Makefile — agent memory repo lifecycle

BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)

.PHONY: push push-tags log status

push: ## Push to all configured remotes
	git push github $(BRANCH) && git push gitlab $(BRANCH)

push-tags: ## Push all tags to all remotes
	git push github --tags && git push gitlab --tags

log: ## Last 10 commits
	git log --oneline -10

status: ## Git status
	git status

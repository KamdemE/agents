.DEFAULT_GOAL := help
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

help:  ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install:  ## Install sui to /usr/local/bin (root-owned)
	sudo install -o root -g root -m 0755 sui.sh "$(BINDIR)/sui"

uninstall:  ## Remove sui from the install directory
	sudo rm -f "$(BINDIR)/sui"

push:  ## Push current branch to all remotes (github + gitlab)
	@branch="$$(git branch --show-current)"; \
	for remote in $$(git remote); do \
		echo "==> pushing $$branch to $$remote"; \
		git push "$$remote" "$$branch"; \
	done

git-status:  ## git status --short
	@git status --short

lint:  ## Syntax check (bash -n); shellcheck if installed
	@bash -n sui.sh
	@bash -n tests/run-stub-tests.sh
	@command -v shellcheck >/dev/null 2>&1 && shellcheck sui.sh tests/run-stub-tests.sh tests/stubs/* || true

test-stubs:  ## Automated stub tests (zenity/sudo/ssh/logger fakes; no GUI)
	@tests/run-stub-tests.sh

test: lint test-stubs  ## Lint + stub tests (local CI-equivalent)

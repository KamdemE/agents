.DEFAULT_GOAL := help
# NOTE: no top-level $(shell ...) variables — they would run as root when
# 'sudo make install' is used and pollute .git/ ownership. Use inline $$(...) in recipes.

help:  ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

push:  ## Push current branch to all remotes
	@branch="$$(git branch --show-current)"; \
	for remote in $$(git remote); do \
		echo "==> pushing $$branch to $$remote"; \
		git push "$$remote" "$$branch"; \
	done

push-tags:  ## Push all tags to all remotes
	@for remote in $$(git remote); do git push "$$remote" --tags; done

status:  ## Show clean-system service + timer status (systemd)
	@systemctl status clean-system.service clean-system.timer --no-pager 2>/dev/null || true

git-status:  ## git status --short
	@git status --short

log:  ## Show recent service logs via journald
	@journalctl -u clean-system -n 50 --no-pager

log-scan:  ## Show last workspace scan log
	@tail -n 60 /var/log/clean-system/workspace_scan.log 2>/dev/null || echo "No scan log yet — run the service first."

log-all:  ## Show full workspace scan log
	@cat /var/log/clean-system/workspace_scan.log 2>/dev/null || echo "No scan log yet."

install:  ## Install systemd units and enable timer — requires sudo
	@sudo bash install.sh

purge:  ## Disable timer and remove unit files — requires sudo
	@sudo bash purge.sh

run:  ## Simulate the weekly service run (reads USER from .env)
	@_user="$$(grep '^USER=' .env 2>/dev/null | cut -d= -f2)"; \
	if [ -z "$$_user" ]; then echo "❌ USER not set in .env"; exit 1; fi; \
	echo "→ Running as root with HOME=/home/$$_user"; \
	sudo -n /usr/bin/bash /home/kpihx/.agents/skills/k-ubuntu/scripts/clean/auto_clean.sh

lint:  ## Shellcheck on all .sh files
	@shellcheck --shell=bash *.sh

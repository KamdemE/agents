.DEFAULT_GOAL := help

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

status:  ## Show backup-restore service + timer status (systemd)
	@systemctl status backup-restore.service backup-restore.timer --no-pager 2>/dev/null || true

git-status:  ## git status --short
	@git status --short

install:  ## Install systemd units and enable timer — requires sudo
	@sudo bash install.sh

purge:  ## Disable timer and remove unit files — requires sudo
	@sudo bash purge.sh

log:  ## Show recent backup service logs via journald
	@journalctl -u backup-restore -n 50 --no-pager

run:  ## Run a backup immediately (requires sudo)
	@sudo bash "$(CURDIR)/backup_workstation.sh"

preview:  ## Estimate backup size without compression (requires sudo)
	@sudo PREVIEW=1 bash backup_workstation.sh

lint:  ## Shellcheck on all .sh files
	@shellcheck --shell=bash *.sh

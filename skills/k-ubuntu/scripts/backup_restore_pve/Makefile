.DEFAULT_GOAL := help

help:   ## Show targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## Symlink systemd units + enable timer (sudo)
	@sudo bash install.sh

purge:  ## Remove symlinks, disable timer (sudo)
	@sudo bash purge.sh

log:    ## Last 50 journal lines
	@journalctl -u pve-backup -n 50 --no-pager

check:  ## Shellcheck
	@shellcheck --shell=bash *.sh || true

.DEFAULT_GOAL := help
# NOTE: no top-level $(shell ...) variables — they would run as root when
# 'sudo make install' is used and pollute .git/ ownership. Use inline $$(...) in recipes.

help:  ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

status:  ## Show clean-system service + timer status (systemd)
	@systemctl status clean-system.service clean-system.timer --no-pager 2>/dev/null || true

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

run:  ## Run cleanup now (requires sudo)
	@sudo bash "$(CURDIR)/auto_clean.sh"

lint:  ## Shellcheck on all .sh files
	@shellcheck --shell=bash *.sh

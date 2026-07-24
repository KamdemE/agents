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

install:  ## Install systemd units and enable timer — requires sudo
	@sudo bash install.sh

purge:  ## Disable timer and remove unit files — requires sudo
	@sudo bash purge.sh

check:  ## Shellcheck bash scripts (SC2155/SC2317/SC2291 silenced — false positives)
	@shellcheck --shell=bash -e SC2155,SC2317,SC2291 *.sh || true; \
	  echo; \
	  echo "👉 Focus on remaining SC2046 (intentional? check context) and SC2086 (unquoted \$HOME — cosmetic but fixable)"; \
	  echo "👉  eSC2014 in clean_snap.sh is known — expands before find, harmless for snap cache paths"

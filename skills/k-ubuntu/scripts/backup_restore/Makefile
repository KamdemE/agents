.DEFAULT_GOAL := help

help:  ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

status:  ## Show backup-restore service + timer status (systemd)
	@systemctl status backup-restore.service backup-restore.timer --no-pager 2>/dev/null || true

install:  ## Symlink systemd units from .agents/ + enable timer + test run (sudo)
	@sudo bash install.sh

purge:  ## Remove symlinks, disable timer (sudo)
	@sudo bash purge.sh

log:  ## Show recent backup service logs via journald
	@journalctl -u backup-restore -n 50 --no-pager

check:  ## Shellcheck all scripts (known false positives silenced)
	@shellcheck --shell=bash -e SC2024,SC2155,SC2317,SC2291 *.sh || true; \
	  echo; \
	  echo "👉 SC2024 silenced: sudo > redirect is intentional (script runs as root, owns all files)."

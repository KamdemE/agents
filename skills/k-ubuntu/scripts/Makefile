.DEFAULT_GOAL := help

MODULES := clean backup_restore
SHELL   := /bin/bash

# ── Help ──────────────────────────────────────────────────────────────────────
help: ## Show this help
	@echo "🏢 KpihX Workstation Orchestrator"
	@echo ""
	@echo "Usage: make [module]-[target]"
	@echo "Modules: [clean], [backup]"
	@echo ""
	@echo "Examples: make clean-run, make backup-log"
	@echo ""
	@grep -E '^[a-z_A-Z-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ── Operational Guard ─────────────────────────────────────────────────────────
status: ## Show global operational status (ksh status)
	@ksh status

# ── Installation ──────────────────────────────────────────────────────────────
install: ## Install ksh dispatcher + Telegram bot service
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(CURDIR)/ksh.sh $(HOME)/.local/bin/ksh
	@mkdir -p $(HOME)/.config/systemd/user
	@cp $(CURDIR)/tg-ubuntu.service $(HOME)/.config/systemd/user/
	@systemctl --user daemon-reload
	@systemctl --user enable tg-ubuntu.service
	@systemctl --user restart tg-ubuntu.service
	@echo "✅ Installed ksh and Ubuntu Bot service."

# ── Smart Proxies (Magic Dispatch) ───────────────────────────────────────────
clean-%:
	@$(MAKE) -s -C clean $(subst clean-,,$@)

backup-%:
	@$(MAKE) -s -C backup_restore $(subst backup-,,$@)

# Global Aliases
clean: clean-run

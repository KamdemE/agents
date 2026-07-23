.DEFAULT_GOAL := help

# ── Variables ─────────────────────────────────────────────────────────────────
MODULES := clean backup_restore
SHELL   := /bin/bash

# ── Help ──────────────────────────────────────────────────────────────────────
help: ## Show this help
	@echo "🏢 KpihX Workstation Orchestrator (v2.1.4)"
	@echo ""
	@echo "Usage: make [module]-[target]"
	@echo "Modules: [clean], [backup]"
	@echo ""
	@echo "Examples: make clean-run, make backup-log"
	@echo ""
	@grep -E '^[a-z_A-Z-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ── Operational Guard ─────────────────────────────────────────────────────────
status: ## Show global operational status (Audit)
	@ksh status

git-status: ## Show git status (Root + Submodules)
	@git status -s
	@git submodule status

# ── Global Git (Multi-Remote) ──────────────────────────────────────────────────
push: ## Push everything to both GitHub and GitLab
	@git submodule foreach 'branch=$$(git branch --show-current); \
echo "==> pushing $$branch to github..."; git push github $$branch || :; \
echo "==> pushing $$branch to gitlab..."; git push gitlab $$branch || :;'
	@branch=$$(git branch --show-current); \
		echo "==> pushing Root to github..."; git push github $$branch || :; \
		echo "==> pushing Root to gitlab..."; git push gitlab $$branch || :;

# ── Installation ──────────────────────────────────────────────────────────────
install: ## Install ksh and bot-service
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

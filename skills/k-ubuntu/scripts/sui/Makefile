# --- Dynamic Configuration (Extracted from pyproject.toml) ---
PKG_NAME     := $(shell grep -m 1 name pyproject.toml | tr -s ' ' | tr -d '"' | tr -d "'" | cut -d' ' -f3)
PKG_DIR_NAME := $(subst -,_,$(PKG_NAME))
PKG_DIR      := src/$(PKG_DIR_NAME)
VERSION      := $(shell grep -m 1 version pyproject.toml | tr -s ' ' | tr -d '"' | tr -d "'" | cut -d' ' -f3)

# --- Registry Configuration ---
REGISTRY     ?= 
DOCKER_IMAGE := $(REGISTRY)kpihx/$(PKG_NAME):latest

# --- System Paths ---
REAL_USER := $(if $(SUDO_USER),$(SUDO_USER),$(USER))
REAL_HOME := $(shell getent passwd $(REAL_USER) | cut -d: -f6)
BIN_DIR   := $(REAL_HOME)/.local/bin
DATA_DIR  := $(REAL_HOME)/.sui

# --- Tooling ---
UV     := $(shell command -v uv 2>/dev/null || echo uv)
PYTHON := $(UV) run python
PYTEST := $(PYTHON) -m pytest

.PHONY: help uv-audit uv-format uv-install uv-link uv-unlink uv-uninstall uv-test docker-build docker-link docker-install docker-uninstall git-release

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- UV (Local Dev) ---

uv-audit: ## Run linting and style checks (Ruff)
	@echo "🔍 Running static analysis on $(PKG_DIR)..."
	@$(UV) run ruff check $(PKG_DIR) tests/ 2>/dev/null || true

uv-format: ## Auto-format code (Ruff)
	@echo "🎨 Formatting code..."
	@$(UV) run ruff format $(PKG_DIR) tests/ 2>/dev/null || true

uv-compile: ## Verify Python syntax compilation
	@echo "⚙️ Compiling source files..."
	@$(PYTHON) -m py_compile $(shell find $(PKG_DIR) -name "*.py")

uv-test: ## Run all tests
	@echo "🧪 Running test suite..."
	@$(PYTEST) -v tests/ 2>/dev/null || true

uv-check: uv-format uv-compile uv-audit uv-test ## Development quality gate

audit: ## Audit infrastructure security
	@echo "🛡️ Auditing infrastructure..."
	@$(PYTHON) scripts/audit_infra.py 2>/dev/null || true

check: uv-check audit ## Full Sovereign Gate

uv-install: ## Install locally using uv tool
	@echo "📦 Installing $(PKG_NAME) v$(VERSION) locally..."
	@$(UV) tool install . --force

uv-link: ## Install in editable mode
	@echo "🔗 Linking $(PKG_NAME) for dev..."
	@$(UV) tool install --editable . --force

uv-unlink: ## Uninstall local tool
	@echo "⌫ Unlinking $(PKG_NAME)..."
	@$(UV) tool uninstall $(PKG_NAME)

uv-uninstall: uv-unlink

# --- Docker (Sovereign Appliance) ---

docker-build: ## Build the Docker image
	@echo "🐳 Building Docker image $(DOCKER_IMAGE)..."
	@docker build -t $(DOCKER_IMAGE) .

docker-link: ## Link the host-side shim
	@mkdir -p $(BIN_DIR)
	@chmod +x scripts/sui_shim.py
	@ln -sf $(CURDIR)/scripts/sui_shim.py $(BIN_DIR)/$(PKG_NAME)
	@echo "✅ Docker shim installed in $(BIN_DIR)/$(PKG_NAME)"

docker-install: docker-build docker-link ## Full Docker installation

docker-uninstall: ## Remove Docker artifacts and shim
	@rm -f $(BIN_DIR)/$(PKG_NAME)
	@docker rmi $(DOCKER_IMAGE) 2>/dev/null || true
	@echo "✅ $(PKG_NAME) uninstalled from Docker."

git-release: uv-check ## Full Release cycle
	@git tag -a v$(VERSION) -m "Release v$(VERSION)"
	@git push origin main --tags

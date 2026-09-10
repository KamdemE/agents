SHELL := /bin/zsh

.PHONY: help check build push

help:  ## Show this help
	@grep -E '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

check:  ## Dashes gate (must pass before build)
	sh scripts/check-dashes.sh

build: check  ## Build (runs dashes check first) → build/main.pdf
	latexmk -pdf -f -interaction=nonstopmode -output-directory=build main.tex || true

push:  ## Push to remotes
	git push origin main

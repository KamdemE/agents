SOURCE   = main
BUILDDIR = build

.DEFAULT_GOAL := help

.PHONY: help build

help:  ## Show this help
	@grep -E '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

build:  ## Compile — always rebuilds, double pdflatex pass into build/
	mkdir -p $(BUILDDIR)
	pdflatex -interaction=nonstopmode -output-directory=$(BUILDDIR) $(SOURCE).tex || true
	pdflatex -interaction=nonstopmode -output-directory=$(BUILDDIR) $(SOURCE).tex || true
	cp $(BUILDDIR)/$(SOURCE).pdf .

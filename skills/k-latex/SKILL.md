---
name: k-latex
description: LaTeX revision templates and compilation workflows for KpihX.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: templates-workflow
  target-agent: all
allowed-tools: Bash, Read, Write, Edit
---

# KπX LaTeX Skills & Templates

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Core Templates

The master LaTeX templates for revisions and specific layouts live in:
`$HOME/KpihX-Labs/LaTeX/Templates/`

### Revision Template
- **Path**: `$HOME/KpihX-Labs/LaTeX/Templates/Revision/`
- **Features**: Ultra-compact margins (0.5cm), 3 columns (`multicols*`), stripped-down lists and titles, landscape A4. Optimized for maximizing content on a single page for open-book exams.
- **Compilation**: Driven by a standard Makefile. It handles multiple pdflatex passes and automatic cleanups. Use the `OUT` argument to rename the final PDF.
  `make OUT=my_output.pdf`
- **Workflow for Markdown Integration**:
  1. Copy the template folder (`main.tex` and `Makefile`) to a temporary working directory.
  2. Convert your Markdown to raw LaTeX body using Pandoc: `pandoc content.md -o 1.tex`
  3. Compile using: `make OUT=final_sheet.pdf`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-06 | [ANTIGRAVITY] | v1.0.0 — Initialized k-latex skill. Documented ultra-compact revision template and Makefile-based compilation. |
| [SUMMARY] | — | Initialization of k-latex |

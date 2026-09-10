---
name: k-classification
description: >
  Sovereign Classification Framework — General patterns and integrity models for 
  organizing Drive, files, images, bookmarks, and knowledge bases. Semantic-first 
  identity, structural nesting, and deterministic control.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: architecture-governance
---

#  Classification — Sovereign Framework

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Core Philosophy

Classification is an **interface cognitive** between the architect and his data. It must be 0% magic, 100% deterministic, and 100% loss-proof.

## Pillars of Classification

### 1. Semantic Identity (The "What")
- **Core Naming:** Use identifiers, not descriptions. Short, unique, and noise-free.
- **Intent Domains:** Group by life pillars (e.g., `Labs`, `X`, `Fr`, `E-Tools`).
- **Semantic Merging:** Collapse items with identical intents even if their physical addresses (URLs/Paths) differ.

### 2. Structural Topology (The "Where")
- **The 3-Level Rule:** Aim for `Context -> Function -> Specialization`. Minimize depth to reduce cognitive friction.
- **Non-Monolithic Hierarchy:** Avoid burying information. Use subfolders only when functional clarity requires it.
- **The "Others" Sink:** A flat directory for items awaiting classification. If "Others" grows too dense, it triggers the creation of a new semantic category.

### 3. Integrity Control (The "Safety Net")
- **Deterministic Reconciliation:** Use scripts to compare Source vs. Target. Guarantee `Total_Input == Total_Output + Total_Merged`.
- **Health Audits:** Automated verification of item validity (e.g., 404 checks for links, file hash checks for duplicates).
- **Provenance Preservation:** Always map and migrate original metadata (dates, icons, tags) to the new structure. No reorganization should degrade history.

## Standard Workflow

1. **Mapping:** Parse source data into a metadata map (URL/Path -> Metadata).
2. **Brainstorming:** Define the 3-level Markdown hierarchy based on intuition.
3. **Drafting:** Place items in the Markdown structure (Shortened names).
4. **Auditing:** Run reconciliation scripts to detect lost or forgotten items.
5. **Finalizing:** Generate the high-fidelity target (HTML, Folder structure, etc.) with metadata injection.

## Insights

- **Manual vs. Auto:** Always let the human intuition drive the placement, and use the machine to verify the integrity.
- **Lexical Control:** Standardize naming conventions early to avoid structural drift.
- **Reference:** Read `references/insights.md` for durable classification lessons.


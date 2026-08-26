---
name: k-confluence
description: Create, repair, enrich, and review high-quality Confluence documentation with a visual-first, evidence-first workflow. Use this skill when working on Confluence pages that require precise structure, strong narrative quality, rendered formulas, image-heavy R&D storytelling, attachment hygiene, safe incremental edits, or a mix of MCP and direct Atlassian API operations.
metadata:
  author: KpihX
  version: "1.1.0"
  scope: tool-integration
---

# KπX — Confluence

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

This skill is for building or repairing Confluence pages with the same level of care as production code: cautious reads first, incremental updates, strong visuals, rendered math, attachment deduplication, and page-by-page coherence checks.

## When To Use

Use this skill when the task involves any of the following:

- Creating or restructuring Confluence pages.
- Repairing broken Confluence markup, images, attachments, or formulas.
- Turning technical R&D material into rich visual documentation.
- Auditing multiple related pages for coherence, depth, and missing evidence.
- Publishing local images or rendered formulas to Confluence safely.
- Mixing Atlassian MCP operations with direct API fallback when MCP is insufficient.

## Core Rules

Follow this sequence strictly because Confluence edits are fragile:

1. Read the target page exactly as it exists now before proposing changes.
2. Identify the page role in the larger narrative: landing page, dataset page, R&D page, results page, appendix, or archaeology page.
3. Inspect what already exists before uploading anything: attachments, image links, formulas, tables, and sections.
4. Prefer surgical updates over rewrites. Preserve validated content and enrich it.
5. Never leave raw ASCII formulas when a rendered formula or stable image can be used.
6. Prefer stable absolute attachment URLs over brittle relative HTML snippets.
7. Treat every visual as evidence: each image should support a claim, comparison, failure mode, or process explanation.

## Workflow

### 1. Read and classify

Read the page fully, then classify it:

- Landing page: global framing, navigation, representative visuals, scope.
- Dataset page: sources, protocol, examples, distributions, edge cases, annotation policy.
- R&D page: intuition, formulas, variants tested, analysis path, why decisions were made.
- Results page: metrics, plots, error analysis, failure galleries, interpretation.

### 2. Audit gaps

Look for these common failures:

- Broken images or preview-only links.
- Raw `<img src="/wiki/...">` HTML that depends on fragile paths.
- ASCII formulas instead of rendered math.
- Claims without figures, tables, or examples.
- Dataset pages without representative samples.
- Results pages without failure cases, per-class analysis, or narrative interpretation.
- R&D pages that jump to conclusions without explaining the construction path.

### 3. Choose the transport

Prefer the highest-safety path available:

- Atlassian MCP / Rovo for page discovery, current body retrieval, and page updates.
- Direct Atlassian API only as a fallback or for attachment upload when explicitly allowed and operationally simpler.

If direct API is needed:

- Read credentials from the local environment only if the user explicitly authorized it.
- Check whether the attachment is already online before uploading.
- Reuse existing attachments when they already solve the need.

### 4. Repair and enrich

Apply the minimum-risk transformation that fully fixes the issue:

- Replace ASCII formulas with rendered formula images.
- Replace brittle relative image tags with stable absolute attachment URLs.
- Add representative visual grids, plots, confusion matrices, galleries, and commentary.
- Expand thin sections with narrative context, comparisons, and interpretation.
- Keep the page visually dense but semantically organized.

### 5. Re-read after editing

After each substantial page update, read the page again and verify:

- formulas render,
- images load,
- sections remain coherent,
- no regressions were introduced,
- the page is richer, not noisier.

## References

Read only what is needed:

- For the surgical page-edit sequence: [references/page-surgery.md](references/page-surgery.md)
- For visual storytelling, formulas, and attachments: [references/visual-publishing.md](references/visual-publishing.md)
- For cross-page audits and narrative consistency: [references/page-audit.md](references/page-audit.md)

## Output Standard

A successful result is not just "page updated". It means the page is now robust, visually convincing, technically faithful, and aligned with the user's intent at the level of section logic, imagery, formulas, and commentary.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-confluence/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-confluence/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [CLAUDE] | v1.1.0 — Restored after the `.agents` restructure wiped the skill (recovered verbatim from a Codex session log, 2026-07-12 creation, confirmed unchanged as of its last known use on 2026-08-21). Conformed to the KπX structural contract: `metadata.version`, edit reminder, Insights Discipline section, `references/insights.md`, this Changelog. Dropped `agents/openai.yaml` (Codex-only UI metadata, unreferenced anywhere and without a KπX equivalent). |
| [SUMMARY] | — | v1.0.0 — Original creation: visual-first, evidence-first Confluence workflow (safe incremental edits, rendered formulas, attachment hygiene, MCP-first with API fallback) plus `references/page-surgery.md`, `references/visual-publishing.md`, `references/page-audit.md`. |

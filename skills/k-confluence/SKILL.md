---
name: k-confluence
description: Create, repair, enrich, and review high-quality Confluence documentation with a visual-first, evidence-first workflow. Use this skill when working on Confluence pages that require precise structure, strong narrative quality, rendered formulas, image-heavy R&D storytelling, figures adapted from an existing source artefact, attachment hygiene, uniform page chrome and traceability across a tree, safe incremental edits, or a mix of MCP and direct Atlassian API operations.
metadata:
  author: KpihX
  version: "2.0.0"
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
- **Adapting an existing artefact** — a deck, a report, a paper — into a documentation tree.
- Auditing multiple related pages for coherence, depth, and missing evidence.
- Publishing local images or rendered formulas to Confluence safely.
- **Unifying a whole tree**: header, footer, navigation, traceability metadata.
- Mixing Atlassian MCP operations with direct API fallback when MCP is insufficient.

## Core Rules

Follow this sequence strictly because Confluence edits are fragile:

1. Read the target page exactly as it exists now before proposing changes.
2. Identify the page role in the larger narrative: landing page, dataset page, R&D page, results page, appendix, or archaeology page.
3. Inspect what already exists before uploading anything: attachments, image links, formulas, tables, and sections.
4. Prefer surgical updates over rewrites. Preserve validated content and enrich it.
5. Never leave raw ASCII formulas when a rendered formula or stable image can be used.
6. Prefer stable absolute attachment URLs over brittle relative HTML snippets, and **resolve every attachment id by name at patch time** — never carry one over from a previous run.
7. Treat every visual as evidence: each image should support a claim, comparison, failure mode, or process explanation.
8. **Write one continuous thread, never bolted-on chunks.** A page is an argument that runs from its first line to its last, not a container of independent sections.
9. **One figure per argument, at the argument** — never a composite under a heading that wants one of its lanes, and never a figure the canonical source does not actually ship. See [references/figure-discipline.md](references/figure-discipline.md).
10. **Adapt, never transcribe.** A page is a documentation form of the source, not a copy of it. Drop the source's own coordinates — step numbers, slide numbers, section letters — and name the argument or link the page instead. The reader does not have the source open.
11. **A tree is a unit.** Every page in it gets the same header, the same footer, and the same traceability block, so any claim anywhere can be followed back to the ticket, the code and the artefacts. See [references/page-chrome.md](references/page-chrome.md).
12. **Finish with a scripted sweep over every page**, and report what it found — including what it found and you did not fix. See [references/verification.md](references/verification.md).

## Narrative Continuity (mandatory)

The single most common way a good page is spoiled is by appending a correct,
well-evidenced section that does not connect to what surrounds it. The reader
loses the reasoning chain, which is the actual value of the documentation.

Every section follows the same movement, which is the one a talk uses:

1. **The problem first** — what question is open, and why the previous section
   did not close it.
2. **The intuition** — in plain language, before any notation.
3. **The formal or measured form** — the formula, the protocol, the table.
4. **What it does _not_ prove** — stated in the same breath as the result.
5. **The hand-off** — a closing line that opens the next section.

Before inserting anything, read the section *before* and the section *after*
the insertion point. Write an opening line that picks up the previous thread
and a closing line that hands to the next one. A section that could be moved
anywhere on the page without anything reading oddly is not yet integrated.

Two rules that follow from this and are worth stating separately:

- **Never contract.** Add or correct; do not delete, summarise or flatten
  existing content to make room. A page grows; it does not get tidied.
- **Detail is the point.** Where a claim rests on a number, give the number,
  its source, and the precondition that makes it valid.

When the project already has a voice — speaker notes, a README that argues
well — reuse its phrasing rather than inventing a parallel register.

## Adapting an existing artefact

When the tree is the documentation form of something that already exists, the
source is the authority on **three** things and on nothing else:

| the source decides | you decide |
|---|---|
| which figures are legal | where each one is placed |
| the order of the argument | how far each step is expanded |
| the wording of a claim it already makes well | the page boundaries |

Two failure modes, both of which look like fidelity:

- **Transcription.** Copying the source's numbering, its section titles, its
  slide-by-slide granularity. The result reads as a document with a missing
  companion. Name things, link pages, drop the coordinates.
- **Invention.** Building a figure the source does not have, because the section
  needs one. That figure has never been reviewed by anyone. A section with no
  legal figure gets no figure.

**Split a long part into subpages** rather than letting one page carry six
arguments. Page boundaries are a documentation decision; the source's section
boundaries are a presentation decision, and they are not the same thing.

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
- **Captions with no figure above them**, and pointers into panels that are not on the page.
- **Composite figures** dropped under a heading that needed one of their lanes.
- Claims without figures, tables, or examples.
- Dataset pages without representative samples.
- Results pages without failure cases, per-class analysis, or narrative interpretation.
- R&D pages that jump to conclusions without explaining the construction path.
- **Hand-written navigation sections** and per-page "where this lives" tables that no two pages agree on.

### 3. Choose the transport

Prefer the highest-safety path available:

- Atlassian MCP / Rovo for page discovery, current body retrieval, and page updates.
- Direct Atlassian API only as a fallback or for attachment upload when explicitly allowed and operationally simpler.

If direct API is needed:

- Read credentials from the local environment only if the user explicitly authorized it.
- Check whether the attachment is already online before uploading.
- Reuse existing attachments when they already solve the need.
- **Re-assert the parent on every write** — a content update must not be able to move a page.

### 4. Repair and enrich

Apply the minimum-risk transformation that fully fixes the issue:

- Replace ASCII formulas with rendered formula images.
- Replace brittle relative image tags with stable absolute attachment URLs.
- Add representative visual grids, plots, confusion matrices, galleries, and commentary.
- Expand thin sections with narrative context, comparisons, and interpretation.
- Keep the page visually dense but semantically organized.

**Retire, never delete.** When a page is superseded, move it to an archive branch
and prefix its title so nobody lands on it by search. The substance stays
reachable; the live tree stops pointing at it.

### 5. Re-read after editing

After each substantial page update, read the page again and verify:

- formulas render,
- images load,
- sections remain coherent,
- no regressions were introduced,
- the page is richer, not noisier.

### 6. Close the tree

Once every content edit is done, and only then:

1. Set the sibling order deliberately, so the sidebar reads in argument order.
2. Apply header, provenance and footer to every page — **replacing** whatever
   each page had of its own, never appending to it.
3. Run the verification sweep, and report it.

## References

Read only what is needed:

- For the surgical page-edit sequence: [references/page-surgery.md](references/page-surgery.md)
- For visual storytelling, formulas, and attachments: [references/visual-publishing.md](references/visual-publishing.md)
- For figures adapted from another artefact: [references/figure-discipline.md](references/figure-discipline.md)
- For header, footer, navigation and traceability across a tree: [references/page-chrome.md](references/page-chrome.md)
- For the closing sweep and its traps: [references/verification.md](references/verification.md)
- For cross-page audits and narrative consistency: [references/page-audit.md](references/page-audit.md)

## Output Standard

A successful result is not just "page updated". It means the page is now robust, visually convincing, technically faithful, and aligned with the user's intent at the level of section logic, imagery, formulas, and commentary — and that a reader landing on it cold can see where they are, where to go next, and where every claim on it came from.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-confluence/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-confluence/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [CLAUDE] | v2.0.0 — **Generalised from a full tree rebuild**, on the operator's instruction to keep the lessons project-agnostic. Four new core rules: one figure per argument and only figures the canonical source ships (9), adapt rather than transcribe — drop the source's coordinates (10), a tree is a unit with uniform chrome and traceability (11), and finish with a scripted sweep that reports what it did *not* fix (12). Rule 6 extended: resolve attachment ids by name at patch time. New section **Adapting an existing artefact** — what the source decides against what you decide, transcription and invention as the two failure modes that look like fidelity, and split a long part into subpages. New workflow step **Close the tree**, plus «retire, never delete». Three new references: `figure-discipline.md`, `page-chrome.md`, `verification.md`. |
| 2026-08-26 | [CLAUDE] | v1.2.0 — **Narrative Continuity made a mandatory rule** (KπX directive, mid-task): a page is one continuous argument, never a container of independent sections. Adds core rule 8 and a section giving the five-beat movement every section must follow (problem → intuition → formal/measured → what it does not prove → hand-off), the "read the section before and after before inserting" check, and the two corollaries the operator stated directly: **never contract** (add or correct, never delete/summarise to make room) and **detail is the point** (a number always comes with its source and its precondition). Also: reuse the project's existing voice — speaker notes, a README that already argues well — rather than inventing a parallel register. |
| 2026-08-26 | [CLAUDE] | v1.1.0 — Restored after the `.agents` restructure wiped the skill (recovered verbatim from a Codex session log, 2026-07-12 creation, confirmed unchanged as of its last known use on 2026-08-21). Conformed to the KπX structural contract: `metadata.version`, edit reminder, Insights Discipline section, `references/insights.md`, this Changelog. Dropped `agents/openai.yaml` (Codex-only UI metadata, unreferenced anywhere and without a KπX equivalent). |
| [SUMMARY] | — | v1.0.0 — Original creation: visual-first, evidence-first Confluence workflow (safe incremental edits, rendered formulas, attachment hygiene, MCP-first with API fallback) plus `references/page-surgery.md`, `references/visual-publishing.md`, `references/page-audit.md`. |

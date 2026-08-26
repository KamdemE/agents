# Page Surgery

Use this playbook when editing an existing Confluence page that may already contain valuable content.

## Safe Sequence

1. Retrieve the exact current page body and title.
2. Read the full page, not only the section mentioned by the user.
3. Infer the page function in the documentation tree.
4. Make a concrete gap list before editing.
5. Prepare the smallest update that closes all important gaps in one pass.
6. Update the page with version awareness.
7. Read the resulting page again to verify rendering and coherence.

## What To Preserve

Preserve and extend:

- valid narrative structure,
- working attachment references,
- good tables,
- already strong analysis text,
- stable page anchors and expected section names.

Do not flatten a rich page into a generic summary. When content is thin, add depth; when content is rich, organize it without stripping meaning.

## Typical Repair Patterns

| Problem | Preferred fix |
|---|---|
| Thin R&D section | Add intuition, design path, formulas, intermediate plots, and why the final choice won |
| Thin results section | Add key metrics, per-class breakdowns, failure cases, and interpretation |
| Broken image references | Replace with stable absolute download URLs to attachments |
| Raw formula text | Render as image and embed it |
| Dataset page too abstract | Add concrete dataset samples, distributions, and annotation examples |

## Update Philosophy

The edit should feel like a careful restoration, not a blind regeneration. The user often values continuity, accumulated nuance, and traceability of thought.

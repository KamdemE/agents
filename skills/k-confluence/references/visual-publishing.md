# Visual Publishing

Use this reference when the page depends on images, plots, grids, or rendered formulas.

## Visual-First Standard

In image-centric R&D documentation, visuals are not decorative. They carry evidence, intuition, and comparison. A strong page usually mixes:

- representative samples,
- diagnostic plots,
- process illustrations,
- failure galleries,
- rendered formulas,
- commentary that explains what the reader should notice.

## Formula Rule

Never leave formulas as plain ASCII when presentation quality matters.

Prefer this order:

1. A correctly rendered native Confluence math block if it is known to render reliably.
2. A rendered formula image uploaded as an attachment.
3. Duplicate-safe reuse of an existing formula image already online.

Avoid:

- inline ASCII equations,
- brittle HTML image tags with relative `/wiki/...` paths,
- ambiguous notation without legend or variable explanation.

## Attachment Hygiene

Before uploading:

1. Check whether the asset already exists on the page or nearby pages.
2. Reuse existing attachments when possible.
3. Upload only what is missing.
4. Prefer stable absolute download URLs after upload.

For direct API fallback:

- use the local environment credential only when authorized,
- keep attachment naming deterministic,
- avoid duplicate uploads caused by timestamp noise when a file is already sufficient.

## Minimum Illustration Expectations

| Page type | Minimum visual payload |
|---|---|
| Landing page | Overview visuals plus examples from each major dataset or result family |
| Dataset page | Samples, distributions, edge cases, annotation examples |
| R&D page | Formulas, intermediate diagrams, alternative variants, decision evidence |
| Results page | Core plots, matrices, previews, success cases, failure cases |

## Commentary Rule

Do not dump images without interpretation. Every visual block should answer at least one of these:

- What is being shown?
- Why does it matter?
- What comparison or decision does it support?
- What should the reader notice?

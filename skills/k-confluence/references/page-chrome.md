# Page Chrome — header, footer, traceability

Use this reference when the unit of work is a **tree** rather than a page: a space,
a section, or any set a reader is expected to walk from a landing page to the last
leaf.

A reader arriving from search on a leaf page has no idea what it hangs off. A
reader who finishes it has no idea what comes next. The sidebar answers the first
question and nothing answers the second — so both go on the page.

## The three blocks, in this order

**Header — a breadcrumb.** Ancestors as links, the page itself as plain text, then
a rule. Nothing else: this is orientation, not a summary.

**Provenance — one uniform table**, immediately above the footer. See below.

**Footer — a rule, then movement, then the standing links.**
`← previous · ↑ up · next →` among siblings *in tree order*, then the handful of
links every page carries: the root, the main sections, the conclusion, the
references.

## Rules that make it survive

**Refonte, never append.** Pages accumulate their own hand-written «Navigation»
sections, their own «Where this lives» tables, and a leading `<h1>` repeating the
title the platform already prints. **Read what is there and remove it** before
inserting. Appending on top produces a page that lists its own contents twice, and
that is worse than having no chrome at all.

**Idempotent by construction.** Delimit each block with invisible `anchor` macros
(`nav-top`, `nav-meta`, `nav-end`). A re-run finds the previous block between its
anchors and *replaces* it. This matters because the pass gets re-run every time the
tree changes, and it must never stack.

**Run it last.** Any content edit made afterwards rewrites the body and drops the
chrome. Chrome is the final pass, always.

**Derive from the live tree, never from a hard-coded list.** Walk the parent-child
API, in the order it returns children, and skip the archive branch and everything
under it — a retired page with live navigation on it looks current.

**Order the siblings explicitly.** Most platforms keep whatever position a page was
last given, which means "the order the pages happened to be created in". Set the
reading order deliberately, once, with the move endpoint, so the sidebar and the
`previous/next` chain agree with the argument.

## Traceability: one uniform table

Every page must let a reader follow any claim on it back to where it was produced.
Four coordinates, the same four on every page, in the same order:

| row | what it holds |
|---|---|
| Tracker | the ticket(s) this work sits under, as links |
| Code | the module(s), as **deep links into the host at the pinned branch**, plus the path as text |
| Artefacts — repo | the output directory, as a link |
| Artefacts — share | the same directory **in every view a reader might use it in** |
| Re-run | the command that regenerates it, when there is one |

**Give the share path in all three views.** The same folder is a drive letter to
the people who will open it, a UNC path to anybody scripting it, and a mount point
on the machine that produced it. Printing only one of them means two audiences have
to translate.

**Read the paths off the machine, never from memory.** `mount`, the sync script,
the Makefile target. A path that is one directory out is worse than no path.

**Only publish share paths that are actually synced.** Mirroring is usually
*selective* — a subset of directories, not the whole tree. A path published for a
directory that never reaches the share sends a reader to a folder that does not
exist. Check the sync scope, list only what it covers, and omit the share rows
entirely for pages whose material is not mirrored.

**Scope the block by tree position.** A literature write-up has no artefacts of its
own; four share paths under one are four paths to somebody else's folder. Give it
the ticket and the code and stop. Derive the default from where the page sits.

## Do not let a content write move a page

Some content APIs treat `ancestors` as optional and *mostly* leave the position
alone. Over a sweep of dozens of pages, "mostly" is not enough — pages drift into
unrelated parents, and the drift is silent.

**Re-assert the parent on every write**: read it, then send it back.

```python
parent = parent_of(page_id)  # read now
payload["ancestors"] = [{"id": parent}]
```

**And beware the stale read.** A move followed immediately by a write can read the
*pre-move* parent and pin the page straight back where it came from — the guard
working perfectly on a wrong answer. After any move, **poll until the API agrees**
before anything writes to that page.

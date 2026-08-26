# Verification

Use this reference for the pass that closes the work. It is not optional and it is
not a spot check: on a tree of any size, **every class of defect below has been
shipped at least once by someone who was being careful.**

Write it as a script, run it over every page, and make it print a count.

## The sweep

| check | why it exists |
|---|---|
| **Well-formed** | a page that fails renders as raw markup |
| **Body survived** | strippers that cut spans by index can eat more than they were aimed at — flag any page that came back tiny or lost its headings |
| **Chrome exactly once** | append-instead-of-replace, and archive pages that must have none |
| **Every image resolves** | ids written from a previous run, or attachments removed |
| **Figures are legal** | every figure traces to the canonical source's manifest |
| **Every link resolves** | including after any rename |
| **Display maths rendered** | no `<p><code>…</code></p>` holding an expression |
| **No caption without a figure** | the pattern of a removed image |
| **No pointer at an absent panel** | «top-left», «the figure below» |
| **No source coordinates in the prose** | «section II.C» is a reference to a document the reader does not have |
| **Tree shape** | compare the live parent→children lists against what you intend |
| **Numbers agree** | quantities quoted on more than one page must match, and superseded values must appear nowhere |

## Two traps that make a clean tree look broken

Both of these produced dozens of false failures before being caught. **A checker
that cries wolf is worse than no checker** — it trains you to skim the output.

**Entities.** Storage format is XHTML and uses the HTML entity set. Bare XML
defines none of it, so parsing a body directly reports «undefined entity» on every
page containing an em dash — which is nearly all of them. Resolve named entities to
numeric references before parsing.

**Link scope.** Pages legitimately link outside the subtree being swept. Checking
targets against the local tree alone reports perfectly good links as dead. Look the
title up in the space before calling it broken.

## Reading the output

Sort the survivors into three piles and say which is which:

- **real defects** — fix them;
- **out of scope** — pages you were told not to touch. Report what is on them
  rather than silently fixing or silently ignoring;
- **deliberate** — the hub-previews-then-argues repeats, a definition restated
  where it is used. State the intent so the next reader does not "fix" it.

## What you cannot fix, say plainly

Some things fail on permissions rather than on judgement — attachment deletion in
particular is often refused (`403`) even for a token that can write pages freely.

**Test it rather than assuming, then report it.** Never report a loop counter as a
result: "64 attachments removed" when the loop ran 64 times and the server refused
all 64 is a false statement about the state of the system, and it is the kind that
gets discovered by somebody else.

## Report structure

Say, in this order: what changed, what was found and fixed, **what was found and
not fixed and why**, and what was deliberate. A verification pass that reports only
successes has not been run.

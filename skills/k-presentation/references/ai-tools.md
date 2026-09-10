# Generative deck tools — when, and how to stay in control

**Default: build with this stack.** It is versioned, diffable, reproducible,
respects the template, enforces the rules, and the words stay in files you own.
No hosted generator gives you that.

There are still three situations where reaching outside is the right call, and
one artifact in this skill proves the quality is real:
`assets/exs/Presentation_Mother_Mirror.pdf` was generated with Google NotebookLM and is the best
looking deck in the repo. Study it (`visual-systems.md`), and be honest about
what produced it.

## When it is the right call

**A visual register we cannot draw.** Charcoal, watercolour, engraving,
painterly illustration. matplotlib draws diagrams, not drawings. If the deck
needs that register, generate the images — then subjugate them to one style
prompt and one treatment.

**A first draft of a narrative arc** on a subject you are still finding. Ask for
the arc, keep the two good moves, throw the rest away, and write the markdown
yourself.

**Throwaway internal material** with no template obligation and no audience
beyond a meeting.

## When it is the wrong call

- Anything graded, contractual or archived. A rule that says "the plan must
  differ from the written report" is not something a generator can be trusted
  with, and the grader is reading for exactly that.
- Anything with a house template to respect. Generators impose their own.
- Anything whose facts must be traceable. A generated figure with plausible
  numbers is the worst possible outcome.
- Anything you will maintain. There is no diff, no `check`, no history.

## The tools, and what each is actually for

Names and capabilities move fast — verify before relying on any of this.

| Tool | What it is really good at | Watch out for |
|---|---|---|
| **Google NotebookLM** | turning *your own sources* into a grounded deck or audio overview; strong at coherent illustration in one register | output is a finished artifact, not a source you can maintain |
| **Gamma** (gamma.app) | fast, genuinely well-composed web-first decks from an outline; good export | its house style is recognisable; template fidelity is weak |
| **Google Slides / Gemini**, **Microsoft 365 Copilot in PowerPoint** | living inside the suite, respecting an existing corporate theme | generic layouts; verify every claim |
| **Canva Magic Design** | non-technical users, lots of assets, brand kits | asset-driven rather than argument-driven |
| **Beautiful.ai**, **Tome**, **Pitch**, **Presentations.AI** | opinionated layout engines that keep a deck tidy | vendor lock-in; the opinion may not be yours |
| **Midjourney / DALL·E / Imagen / Stable Diffusion** | the illustration register itself | one style prompt reused verbatim, or coherence collapses |

The tell of ordinary generated imagery is not quality, it is **incoherence**:
each image was produced in isolation and carries its own aesthetic. The fix is
process, not prompt quality — see below.

## If an agent has browser access

An agent with Chrome tools can drive these products, and should do it like a
careful human:

1. **Ask first.** Sending the user's content to a third-party service is their
   decision, not the agent's. Say which service and what leaves the machine.
2. **Never paste confidential material.** Internal metrics, unpublished
   results, client names, personal data. This is the default answer, not an
   edge case.
3. **Prefer export over screenshots.** A `.pptx` export can be re-opened, mapped
   with `inspect_template.py` and rebuilt properly. A PNG is a dead end.
4. **Re-verify every fact.** Treat generated content as a draft by a confident
   stranger.
5. **Record provenance.** Which tool, which date, which prompt — in the deck's
   README.

## The hybrid that actually works

This is the recommended pattern when a deck needs a register we cannot draw:

1. **Structure and words: ours.** The spine, the argument, the wording, the
   speaker notes — markdown in `slides/`, under version control.
2. **Illustrations: generated, with one style prompt reused verbatim.** Medium,
   paper colour by hex, line weight, palette, framing, level of abstraction. One
   prompt, N subjects. Never one prompt per image.
3. **Then treat everything anyway.** `figkit.treated_photo` with a single
   `IMAGE_TREATMENT` dict from `theme.py`. The treatment is what rescues
   coherence when the generator drifts, and it is what makes a sourced image a
   member of the family.
4. **Assembly: ours.** So the template is respected, the rules are checked, the
   page furniture is right, and the thing is rebuildable next year.
5. **Credit it.** One line. An uncredited generated image in academic or
   professional work is a real problem.

## The line not to cross

Treating a real portrait so it matches the palette is design. Generating a
plausible face and letting it pass for the person is not. Same for a chart:
drawing a measured result beautifully is design; generating a plausible-looking
result is fabrication. If a number appears on a slide, it came from a file you
can point at.

Make that a pass, not a hope: before the narrative is written, list every
number the deck will claim and verify each against its source — a results
CSV, a citation count, a measured log — and correct the deck (or the source)
on any mismatch. A number nobody re-checked is a number nobody can defend
under a question.

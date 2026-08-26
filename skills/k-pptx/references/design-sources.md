# Where to find good design

Our own stack first, always. This file is for the three things the stack cannot
invent: a palette worth having, a type pair worth having, and a sense of what
"good" looks like this year. Everything here is a place to *look*, not a
dependency to add.

## Judgement before sources

Before browsing anything, know what you are shopping for. A deck needs exactly
four decisions, and no gallery will make them for you:

1. a ground (light, dark, or paper)
2. two colours and one accent
3. one type pair, contrasted
4. four to six slide archetypes

Everything below serves those four. If a source cannot answer one of them,
close the tab.

## Palettes

- **The template's own theme.** `inspect_template.py` prints it. If a template
  exists, this is not a choice you get to make — and that is a relief.
- **Adobe Color**, **Coolors**, **Color Hunt** — for generating and checking
  harmonies quickly.
- **ColorBrewer** — the serious one for data: sequential, diverging and
  qualitative scales built for perceptual uniformity and colour-blind safety.
  Use it for anything with a legend.
- **Viz Palette** — pastes your palette and simulates colour-vision
  deficiencies plus small-area rendering. Run every data palette through it.
- **WebAIM Contrast Checker** — a projector is a bad screen in a bright room.
  Aim well above the 4.5:1 web minimum for body text.

Steal a palette from a painting, a book jacket or a film still rather than from
another deck. It will be better and it will be yours.

## Type

- **Google Fonts** — free, licence-clean, and the practical default. Reliable
  display serifs: Playfair Display, Fraunces, Source Serif, Lora, Libre
  Baskerville. Reliable neutral sans: Inter, Source Sans, Work Sans, IBM Plex
  Sans, Manrope.
- **Fontsource / Fontshare** — well-made free families beyond Google's.
- **Font pairing:** do not overthink it. Display serif + neutral sans, or
  neutral sans + monospace for technical decks. Never two serifs, never two
  display faces.
- **Practical constraint:** a font not installed on the presenting machine is
  substituted, and substitution changes line breaks and sometimes drops glyphs
  (`pitfalls.md`). Either use what the template declares, or embed, or ship the
  files next to the deck and say so in the README.

## Icons and pictograms

- **Lucide**, **Feather**, **Phosphor**, **Tabler** — coherent line families,
  permissive licences. Take icons from **one** family only.
- Rules often require pictograms to be "univocal and not open to
  interpretation". A monogram or a numbered disc with the role written under it
  cannot be misread; a hand-drawn metaphor can. `figkit.disc` exists for that.

## Images

- **Unsplash**, **Pexels** — permissive, but everyone uses the same twenty
  photos; treat them (`visual-systems.md`) or avoid them.
- **Public-domain archives** — Rijksmuseum, Met Open Access, Library of
  Congress, Wikimedia Commons, Internet Archive, Biodiversity Heritage Library,
  Old Book Illustrations. Engravings and plates carry gravity that stock
  photography cannot, and they duotone beautifully.
- **Always record the source and check the licence.** Some datasets forbid
  public display of recognisable faces; a treatment does not launder a licence.

## Looking at good decks

- Read `assets/Mother_Mirror.pdf` in this skill first — it is dissected in
  `visual-systems.md`.
- Conference talk decks from people who present for a living, published slide
  archives from research groups, and investor-deck teardowns are more useful
  than "presentation inspiration" galleries, which optimise for screenshots
  rather than for a room.
- **Information Is Beautiful**, **Flowing Data**, **The Pudding** — for how to
  make a figure carry an argument.

## Books worth the evening

- Robin Williams, *The Non-Designer's Design Book* — proximity, alignment,
  repetition, contrast. Four ideas, and they fix most decks.
- Edward Tufte, *The Visual Display of Quantitative Information* — for figures.
- Garr Reynolds, *Presentation Zen* — for restraint.
- Ellen Lupton, *Thinking with Type* — for the type pair.

## The honest caveat

Products, prices and URLs change. If a name here matters to a decision, search
for it and confirm before relying on it; do not trust this file as current.

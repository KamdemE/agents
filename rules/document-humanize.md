# Document Humanize (GRAVE)

**Status:** Kernel sovereignty for authored deliverables.  
**Applies to:** ALL agents, ALL profiles, whenever producing or editing documents **for KpihX**.  
**Engraved:** KpihX 2026-09-10 (ALTEN cover-letter pass) + prior prose dash gate 2026-09-09.  
**Related tooling:** `libs/humanize/humanize_lib.{sh,py,js}`, `scripts/check-dashes.sh` (automated subset; this rule is stricter for deliverables).

---

## Scope (when this rule applies)

Any agent-authored or agent-edited **deliverable** meant for KpihX to read, send, print, present, or submit:

| Kind | Examples |
|------|----------|
| Letters / CV blurbs | cover letters (md/pdf/docx), motivation letters, experience descriptions |
| Markdown docs | `offers.md`, notes, registries, READMEs written for him |
| PDF / LaTeX | reports, revision sheets, one-pagers via pandoc/xelatex/`k-tex` |
| Presentations | `k-presentation` decks, slide markdown, speaker notes |
| Form / portal copy | JobTeaser, LinkedIn, Welcome to the Jungle, AX text fields |
| Chat drafts for him | text he will paste elsewhere (mail body, LinkedIn Easy Apply message) |

**Does NOT rewrite** historical kernel prose already committed (e.g. old `AGENTS.md` lines) unless KpihX asks. **Does apply** to every **new** sentence you write in those files and every **new** deliverable.

---

## The keyboard test (source of truth)

> Before shipping a character, ask: **can KpihX type this instinctively on his keyboard (AZERTY FR / common US layout) without Compose, AltGr gymnastics, or copy-paste from Unicode tables?**

If no -> replace with a keyboard-native equivalent or rephrase with words.

**Allowed (human, keyboard-native):**

- ASCII letters, digits, space
- FR letters with accents he types on AZERTY (acute, grave, circumflex, diaeresis, cedilla): allowed in FR prose
- Punctuation: `. , ; : ! ? ' " ( ) [ ] { } / \ @ # % & * + = < > | _`
- ASCII hyphen `-` only when a real hyphen is needed (compound words, `June-August`, `06/2026 - 08/2026`)
- Currency in words or `EUR` / `euro`; the euro sign is OK only if he already uses it in that file's style
- Code / math **inside proper markup** (LaTeX math mode, fenced code) follows that markup's rules, not this prose keyboard test

---

## Hard bans (non-human Unicode / AI typography)

Never introduce these in deliverable prose (source md, rendered pdf text, slide text, portal drafts):

| Ban | Codepoint / form | Replace with |
|-----|------------------|--------------|
| Em dash / tiret cadratin | `U+2014`; also LaTeX `---` used as em-dash in prose | comma, colon, parenthesis, or a conjunction (`and`, `so`, `because`, `while`, `et`, `puis`, `donc`, `car`) |
| En dash | `U+2013` (including numeric intervals) | ASCII `-` (`2024-2025`, `June-August`) |
| Spaced double hyphen | ` -- ` | conjunction or colon |
| Ellipsis glyph | `U+2026` | three ASCII dots `...` or rephrase |
| Smart / curly quotes | `U+201C` `U+201D` `U+2018` `U+2019` | straight `"` and `'` |
| Fancy bullets | `U+2022` `U+25C6` `U+25AA` | `-` or `*` markdown / numbered lists |
| Arrows in prose | `U+2192` and fancy double arrows | ASCII `->`, `=>`, or words (`to`, `then`, `yields`) |
| Subscripts / superscripts in plain text | e.g. `U+2081` in `F`+subscript-1; unicode squared | ASCII `F1`, `m^2`, or real LaTeX math |
| Multiplication / comparison glyphs | `U+00D7` `U+2264` `U+2265` `U+2260` | `x` or `*`, `<=`, `>=`, `!=` |
| Thin / nbsp / exotic spaces | `U+00A0`, `U+202F`, `U+2009`, ZWSP, BOM mid-file | normal space |
| Horizontal bar / figure dash | `U+2015`, `U+2012` | ASCII `-` or rephrase |

**Priority:** prefer **semantic connectors** over any dash-separated fragment. Dashes are not a style; they are a failure mode when they replace grammar.

---

## Extra failure modes (seen or likely)

These are not "unicode bans" but they produce **non-human / broken deliverables**. Treat them as part of humanize:

1. **Pandoc definition-list trap:** a line like `Term: rest` can become a definition list (huge white gap). For `Re:` / titles, avoid a second bare `Title: subtitle` pattern; prefer `Re: Application for X (Y, id)` or escape deliberately.
2. **PDF page spill:** a cover letter that should be 1 page must be verified (`pdfinfo` Pages=1, optional `pdftoppm` visual). Tighten margins/font or shorten; never ship a lonely orphan line on page 2 by accident.
3. **docx vs pdf:** when KpihX asks for a document to send, default to **PDF** unless he asked for editable Word. Keep `.md` as source of truth; do not leave stale `.docx` beside a PDF you just produced.
4. **Fake typography in metrics:** write ASCII `macro-F1` (never unicode subscript digits); write `0.93` not glamorous fraction glyphs.
5. **Invisible characters:** strip ZWSP/BOM; they break search, git diffs, and ATS parsers.
6. **Over-bold / over-emoji in formal letters:** letters and CV-adjacent prose stay sober (no emoji, minimal bold).
7. **Language mix:** follow `file-governance.md` (file language) + response language; never mix FR/EN inside one letter unless he asked bilingual.
8. **Copied third-party text:** quoting an offer may keep original glyphs; **your** surrounding prose must still be humanized.
9. **Slide decks:** same keyboard rule on titles and bullets; avoid smart quotes pasted from Keynote/PowerPoint samples.
10. **Pre-ship scan (mandatory on every deliverable):**

```bash
# example scan (adjust path); any hit = fix before delivery
python3 - <<'PY'
from pathlib import Path
p = Path("PATH/TO/FILE.md")
t = p.read_text(encoding="utf-8")
banned = (
    "\u2014\u2013\u2012\u2015\u2026"
    "\u201c\u201d\u2018\u2019\u2022\u2192"
    "\u00a0\u202f\u2009\u200b\ufeff"
    "\u00d7\u2264\u2265\u2260\u2081\u00b2\u25c6\u25aa"
)
hits = [(i, hex(ord(c))) for i, c in enumerate(t) if c in banned]
print(hits[:50], "count=", len(hits))
PY
```

FR accented letters stay allowed. Typography glyphs above do not. Prefer `EUR`/`euro` wording when unsure about money signs.

---

## Relation to `check-dashes` / `humanize_lib`

| Layer | What it does |
|-------|----------------|
| **This rule** | Full human keyboard standard for **deliverables** (stricter: even interval en-dashes become ASCII `-`; also quotes, ellipsis, subscripts, arrows, PDF hygiene). |
| **`scripts/check-dashes.sh` + `libs/humanize/`** | Automated gate on git-tracked prose for a **subset** (triple `-`, `U+2014`, spaced `--`, spaced en-dash). Interval en-dash may still pass the script today. |

If deliverable rule and script diverge, **the deliverable rule wins for anything you ship to KpihX**. Propose tightening `humanize_lib` / `check-dashes` when convenient (Propose != Act unless he asks).

---

## Workflow (every document pass)

1. Write / edit in the file language (`file-governance.md`).
2. Humanize while writing (do not "beautify" with Word-style punctuation).
3. Pre-ship scan for banned codepoints.
4. If PDF: build, check page count + extract text (`pdftotext`) for leftover bans.
5. Remove superseded sidecars (e.g. trash `.docx` when PDF is the requested artifact).
6. Log non-trivial humanize lessons in `k-context` session log when relevant.

---

## Changelog

| Date | Note |
|------|------|
| 2026-09-10 | Created. Keyboard-human deliverable standard after ALTEN letter (no em/en dashes, ASCII F1, PDF 1-page). Broader bans: smart quotes, ellipsis, arrows, subscripts, nbsp, pandoc `Re:` trap, docx/pdf hygiene. |

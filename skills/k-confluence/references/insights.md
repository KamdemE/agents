# k-confluence Insights

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Reading the platform

- **Never judge a page from the `markdown` rendering.** `getConfluencePage` with
  `contentFormat: "markdown"` silently drops `ac:structured-macro` nodes — a
  `multimedia` macro (an embedded MP4) renders as *nothing*, so a correctly
  embedded video looks exactly like an orphan caption with a missing image.
  Cost, once: nearly "repairing" two videos that were already correctly placed.
  Read `html` or `storage` before concluding anything is missing.
- **Storage format is the safe transport for surgical edits.**
  `GET /rest/api/content/<id>?expand=body.storage` returns clean XHTML that
  round-trips byte-for-byte through a `PUT`. Fetch → exact-string patch → PUT,
  with every anchor asserted to occur **exactly once**, so a stale anchor aborts
  before the page is touched instead of half-patching it.
- **The server rewrites what you send.** It stamps `ri:version-at-save` into every
  page link on save, so an anchor built from markup you wrote a moment ago will
  not match on the next read. Anchor on the *link body* or on plain text, and
  make "already applied?" checks compare tag-stripped text rather than markup.
- **Confluence storage is XHTML with the HTML entity set.** Parsing a body as bare
  XML reports «undefined entity» on every page containing an em dash. Resolve
  named entities to numeric references before any well-formedness check —
  otherwise the checker flags the whole tree and trains you to skim its output.

## Writing to the platform

- **Update an attachment in place, never as a new upload.**
  `POST /content/<id>/child/attachment/<attId>/data` creates a new *version* of
  the same attachment, so the `attXXXX` id — and every `<img src>` already in the
  body — stays valid. Posting to `/child/attachment` instead creates a duplicate
  and the page keeps showing the stale image. Compare byte size first and skip
  when unchanged.
- **Never hard-code an attachment id.** Ids are assigned at upload. Writing one
  into a patch script from a previous run's output produces dead references the
  first time an upload is repeated — three broken images, once, caught only by
  the verification pass. Resolve by name, at patch time, every time.
- **A content write can move a page.** Some APIs treat `ancestors` as optional and
  *mostly* leave the position alone; over a sweep of dozens of pages, two drifted
  into unrelated parents, silently. Re-assert the parent on every write: read it,
  then send it back.
- **After a move, poll before you write.** A move followed immediately by a write
  can read the *pre-move* parent and pin the page straight back — the guard above
  working perfectly on a stale answer. Confirm the API agrees before writing.
- **Attachment deletion is often refused** (`403`) even for a token that can write
  pages freely. Test it rather than assuming, and never report a loop counter as a
  result: "N attachments removed" when the server refused all N is a false
  statement about the state of the system.
- **Check inline comments before any body rewrite**
  (`/child/comment?location=inline`): a destructive replacement can leave
  reviewer anchors dangling.

## Figures

- **A build directory is not a manifest.** It also holds unregistered exploratory
  panels and stale output from sections that no longer exist. Using one puts a
  never-reviewed figure on a page with the authority of the source it appears to
  come from. Derive the legal set from the source's own manifest, and encode it as
  a `PROVENANCE` dict the patch script consults on every insertion — care does not
  survive a long task, a dict does.
- **Cropping at a guessed fraction is the wrong tool**, and it looks like work. Use
  the source's own layout constants and the plotting library's own transforms, or
  re-run the drawing code of the single lane. Both are exact; a fraction is not,
  and it breaks on any re-render.
- **Strip the chrome, then re-fit the layout.** A lane spaced to fill a tall canvas
  beside a panel that is no longer there arrives with inches of white in it, and
  that white reads as a missing panel.
- **Look at every figure you generate.** Every figure defect worth catching was
  caught by opening a contact sheet, and none by reading the code that made it:
  sliced type, clipped legends, a formula colliding with a marker, an interceptor
  that also caught the colour-bar label.

## Working with an operator who reviews closely

- **A caption for a figure that is not there is the loudest defect on a page.** It
  is the first thing a reviewer sees and it is trivially detectable by script.
  Sweep for it before handing anything over.
- **Prose describing a different figure than the one placed is worse than a missing
  figure.** It happens when the text is written for one source artefact and the
  image comes from another. If the text says "a motorcycle" and the image is four
  landscapes, the page is actively misleading. Re-read every caption against its
  image.
- **Numbering carried over from the source is a tell.** "See section II.C" on a page
  whose reader does not have the source open is transcription, not adaptation.
  Sweep for it.
- **Uniform chrome must be a refonte, not an append.** Pages carry their own
  hand-written navigation and their own "where this lives" table; adding yours on
  top makes the page list its contents twice, which is worse than no chrome. Read
  what is there and remove it first.
- **Escape once.** Writing `&mdash;` as a literal in a link title and then escaping
  it produces `&amp;mdash;` — a link to a page that does not exist. Two of five
  standing footer links were dead on every page of a tree because of this. Keep
  real characters in the data and let the escaper do its job.
- **Only publish share paths that are actually mirrored.** Sync is usually
  selective; a path published for a directory that never reaches the share sends
  the reader to a folder that does not exist. Read the sync scope, do not infer it.

## Project memory

- Project-specific writing style belongs in a **linked memory**, not in this file,
  so it stays scoped to the project that needs it rather than every Confluence
  task. Reference it as `[[feedback-confluence-narrative-style]]`.
- This skill was wiped once by an `.agents` re-clone because it had never been
  committed. If you materially improve it mid-task, **commit it before moving on**.

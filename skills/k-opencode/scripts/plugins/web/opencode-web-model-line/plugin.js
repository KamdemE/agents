// Lens plugin: keep the OpenCode Web model selector on its own full-width line.
//
// The model selector is the button with `data-action="prompt-model"` (it shows
// the current model name). It ships with `max-w-[220px]`, so a long model name
// pushes the other controls and visually covers the submit button
// (`data-action="prompt-submit"`) sitting at the right of the same bar. We force
// the selector (and its flex ancestors) to take the full row width and enable
// wrapping on the controls row, so the selector always sits on its own line and
// the submit button stays visible.
//
// We also let the bottom bar grow (`h-11` -> auto) so the wrapped controls and
// their dropdown menus are not clipped by the form's `overflow: clip`.

function lensFixModelSelectorLine() {
  const modelBtn = document.querySelector('[data-action="prompt-model"]');
  if (!modelBtn) return;

  const setFull = (el) => {
    el.style.setProperty("flex", "0 0 100%", "important");
    el.style.setProperty("max-width", "100%", "important");
    el.style.setProperty("width", "100%", "important");
  };

  setFull(modelBtn);

  // The controls row that holds the voice / attach / agent / model buttons.
  const controlsRow = modelBtn.closest(
    "div.flex.min-w-0.flex-1.items-center.gap-1",
  );
  if (controlsRow) {
    controlsRow.style.setProperty("flex-wrap", "wrap", "important");
  }

  // Make the model button's flex ancestors (up to the controls row) full width
  // so the button truly occupies its own line.
  let el = modelBtn.parentElement;
  while (el && el !== controlsRow && el !== document.body) {
    setFull(el);
    const parent = el.parentElement;
    const pcs = parent ? getComputedStyle(parent) : null;
    if (pcs && (pcs.display === "flex" || pcs.display === "inline-flex")) {
      parent.style.setProperty("flex-wrap", "wrap", "important");
    }
    el = parent;
  }

  // Let the bottom bar grow so the wrapped line(s) and any dropdown menus are
  // not clipped by the form's `overflow: clip`.
  const bar = modelBtn.closest("div.flex.h-11.items-center.px-2");
  if (bar) {
    bar.style.setProperty("height", "auto", "important");
    bar.style.setProperty("min-height", "44px", "important");
    bar.style.setProperty("align-items", "flex-start", "important");
    bar.style.setProperty("flex-wrap", "wrap", "important");
  }

  // Fallback for markup variations: wrap any flex ancestor up to the submit
  // button so the model selector never shares a line with it.
  const submitBtn = document.querySelector('[data-action="prompt-submit"]');
  if (submitBtn) {
    let n = modelBtn;
    while (n && !n.contains(submitBtn) && n !== document.body) {
      const pcs = getComputedStyle(n);
      if (pcs.display === "flex" || pcs.display === "inline-flex") {
        n.style.setProperty("flex-wrap", "wrap", "important");
      }
      n = n.parentElement;
    }
  }
}

// Debounced re-apply: OpenCode Web re-renders the composer dynamically.
function lensScheduleModelFix() {
  if (window.__lensModelLineScheduled) return;
  window.__lensModelLineScheduled = true;
  setTimeout(() => {
    window.__lensModelLineScheduled = false;
    try {
      lensFixModelSelectorLine();
    } catch {
      /* ignore */
    }
  }, 150);
}

lensFixModelSelectorLine();
window.addEventListener("load", lensFixModelSelectorLine);
const lensModelObserver = new MutationObserver(lensScheduleModelFix);
lensModelObserver.observe(document.documentElement, {
  childList: true,
  subtree: true,
});

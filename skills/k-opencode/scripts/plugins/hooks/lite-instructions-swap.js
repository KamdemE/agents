import { appendFileSync } from "node:fs";

const _TARGET_AGENTS = ["Lite"];

// Fingerprint of the big kernel AGENTS.md injected natively by OpenCode.
// Must match the real file so we remove only that entry, never the Lite prompt.
const BIG_FINGERPRINTS = ["kpihx-agents", "K\u03c0X \u2014 Sovereign Agent Kernel"];
const LITE_MARKER = "You are Lite";

export default async function () {
  return {
    // Strips the big kernel AGENTS.md for Lite only — Lite now uses its own
    // standard prompt.txt (like Colab/Live) via opencode.jsonc {file:...}.
    // No replacement: just remove the general AGENTS.md entry.
    // Detection: output.system already contains the Lite prompt ("You are Lite")
    // when the session's agent is Lite — self-contained, no cross-hook state.
    "experimental.chat.system.transform": async (_input, output) => {
      const system = output.system || [];
      try {
        const dump = system.map((s,i)=>`[${i}] len=${typeof s==='string'?s.length:0} head="${String(s).slice(0,250).replace(/\n/g,'\\n')}"`).join("\n");
        appendFileSync("/tmp/lite-swap.log", `[${new Date().toISOString()}] DUMP n=${system.length}\n${dump}\n---\n`);
      } catch {}
      const isLite = system.some((s) => typeof s === "string" && s.includes(LITE_MARKER));
      try { appendFileSync("/tmp/lite-swap.log", `[${new Date().toISOString()}] HOOK isLite=${isLite} n=${system.length}\n`); } catch {}
      if (!isLite) return output;
      const idx = system.findIndex((s) => typeof s === "string" && BIG_FINGERPRINTS.some((fp) => s.includes(fp)));
      if (idx === -1) return output;
      const entry = system[idx];
      if (entry.includes(LITE_MARKER)) {
        // Merged entry contains both Lite prompt and big AGENTS.md — strip the big part only
        const bigPos = BIG_FINGERPRINTS.map(fp => entry.indexOf(fp)).filter(p=>p!==-1).sort((a,b)=>a-b)[0] ?? -1;
        const litePos = entry.indexOf(LITE_MARKER);
        if (bigPos !== -1 && litePos !== -1) {
          // Two orderings: Lite first (litePos < bigPos) or Big first (bigPos < litePos)
          let kept;
          if (litePos < bigPos) {
            kept = entry.slice(0, bigPos).trimEnd();
            try { appendFileSync("/tmp/lite-swap.log", `[${new Date().toISOString()}] MERGED Lite-first: keep 0..${bigPos} new_len=${kept.length}\n`); } catch {}
          } else {
            kept = entry.slice(litePos).trimStart();
            // if big was before lite, there may be trailing big content after lite? remove it if found after litePos
            const bigAfterLite = BIG_FINGERPRINTS.map(fp => kept.indexOf(fp)).filter(p=>p!==-1).sort((a,b)=>a-b)[0] ?? -1;
            if (bigAfterLite !== -1) kept = kept.slice(0, bigAfterLite).trimEnd();
            try { appendFileSync("/tmp/lite-swap.log", `[${new Date().toISOString()}] MERGED Big-first: keep from ${litePos} new_len=${kept.length}\n`); } catch {}
          }
          output.system[idx] = kept;
          return output;
        }
      }
      output.system.splice(idx, 1);
      try { appendFileSync("/tmp/lite-swap.log", `[${new Date().toISOString()}] STRIP idx=${idx} new_len=${system.length}\n`); } catch {}
      return output;
    },
  };
}

// Guard: enforce the GRAVÉ rule (AGENTS.md → ABSOLUTE RULE — make check).
// `make check` must run EXACTLY as `make check` — only these 2 tokens, nothing
// around (no pipe, no redirect, no &&, no ;, no extra args).
//
// Mechanism: `tool.execute.before` is the ONLY blockable event in OpenCode.
// Mutating `output.args` does NOT propagate (upstream bug — see opencode
// issue #31680), so the reliable block is `throw new Error(...)`, which aborts
// the tool before it runs (same pattern as DefenseClaw/Cisco).
//
// NOTE — `TARGET_AGENTS` is intentionally ABSENT (deviation from
// `hooks-standard.md` §2, documented here): `tool.execute.before` does NOT
// receive `messages` in its input, so the `currentAgentIs` helper (which needs
// messages) cannot scope it. The rule is GLOBAL (GRAVÉ, in AGENTS.md) and must
// apply to ALL agents — a hard kernel rule, not agent-specific. Declaring an
// unused `TARGET_AGENTS` would trip eslint `no-unused-vars` and fail `make
// check`'s `check-js` step. The standard's mandatory `TARGET_AGENTS` applies
// to `messages.transform` hooks, not to tool-level blocking hooks.

// Strip nothing — the ultra-simple logic searches `make check` ANYWHERE in the
// command (no anchoring at start), so shell wrappers (`bash -c '...'`,
// `zsh -c '...'`, multi-line `cd X\nmake check`) are caught naturally: we only
// need to look at what FOLLOWS the first `make check`.
export default async function () {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;
      const command = (output.args?.command || "").trim();
      if (!command) return;

      // Find the FIRST occurrence of `make check` anywhere in the command.
      const m = command.match(/make check/);
      if (!m) return; // no `make check` → allow

      // Look at what follows the first `make check`.
      const after = command.slice(m.index + m[0].length);
      // If a blank (whitespace) appears before the end → block. This catches
      // every case where `make check` is followed by a pipe, redirect, &&, ;,
      // or any argument. `make check-skills`/`make check-jsonc` are allowed
      // because what follows (`-skills`, `-jsonc`) contains NO blank.
      if (!/\s/.test(after)) return; // no blank after → allow

      throw new Error(
        "🛑 GRAVÉ rule (AGENTS.md): `make check` must run EXACTLY as `make check` " +
          "(only these 2 tokens — no pipe, no redirect, no &&, no ;, no extra args).\n" +
          `Blocked command: ${command}`,
      );
    },
  };
}

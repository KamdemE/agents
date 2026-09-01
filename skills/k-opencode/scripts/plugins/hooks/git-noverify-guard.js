// Guard: block git commands that bypass verification gates.
// Detects --no-verify, -n (commit shorthand), and equivalent bypass flags
// in git commit, git push, and git merge commands.
//
// Same pattern as make-check-guard.js: throw-only, no TARGET_AGENTS (global rule).

const BYPASS_FLAGS = [
  "--no-verify",
  "--no-verify-signatures",
  "-n", // git commit -n is shorthand for --no-verify
];

// Patterns that indicate a git command attempting to bypass checks
const BLOCKED_COMMANDS = /^(git\s+(commit|push|merge|rebase)\b|\/usr\/bin\/git\s+(commit|push|merge|rebase)\b)/;

function hasBypassFlag(args) {
  for (const arg of args) {
    const parts = arg.split(/\s+/);
    for (const part of parts) {
      if (BYPASS_FLAGS.includes(part)) return true;
    }
  }
  return false;
}

export default async function () {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;
      const command = (output.args?.command || "").trim();
      if (!command) return;

      // Only check git commit/push/merge/rebase commands
      if (!BLOCKED_COMMANDS.test(command)) return;

      // Split command into args for flag detection
      const args = command.split(/\s+/);

      if (hasBypassFlag(args)) {
        throw new Error(
          "🛑 BLOCKED: git command with --no-verify / -n bypass flag.\n\n" +
          "You MUST run `make check` BEFORE committing. The pre-commit hook enforces " +
          "kernel quality rules (AGENTS.md → ABSOLUTE RULE — make check).\n\n" +
          "Banned flags: --no-verify, --no-verify-signatures, -n\n\n" +
          "Correct flow:\n" +
          "  1. Run `make check` (and fix ALL findings)\n" +
          "  2. Then run `git commit` (without --no-verify)\n" +
          "  3. Then `make push` (not raw git push)\n\n" +
          `Blocked command: ${command}`,
        );
      }
    },
  };
}

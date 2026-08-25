// src/config.ts — Canonical KpihX configuration skeleton
// =========================================================
// Minimal, dependency-light config. No YAML loader, no ConfigManager
// singleton — runtime values are plain constants declared directly here.
// Add layering only if the project genuinely needs it (most don't).
//
// IMPORTANT:
//   - Keep this module runtime-focused.
//   - Never store package/app metadata here (name, version, contract schema/version).
//     Metadata belongs to package.json (or pyproject.toml for Python).
//
// HOW TO USE:
//   1. Copy to: src/config.ts
//   2. Copy .env.example to: src/.env (fill real values for local dev)
//   3. Replace ALL_CAPS placeholders below with your project's specifics
//   4. Update REQUIRED_SECRETS with your secret names as they appear in Vaultwarden
//
// PLACEHOLDERS TO REPLACE:
//   - SECRET_ONE          → first required secret name (e.g., "OPENAI_API_KEY")
//   - SECRET_TWO          → second required secret (remove if not needed)
//   - DEFAULT_HOST        → sensible default host (e.g., "localhost")
//   - DEFAULT_PORT        → sensible default port (e.g., 8080)

import path from "path";
import dotenv from "dotenv";

// ---------------------------------------------------------------------------
// Secrets — .env for local dev, process.env / Vaultwarden login shell for prod
// ---------------------------------------------------------------------------
const _PKG_DIR = path.dirname(__filename);
const _DOT_ENV = path.join(_PKG_DIR, ".env");
dotenv.config({ path: _DOT_ENV, override: false }); // process.env always wins over .env

export const REQUIRED_SECRETS: string[] = ["SECRET_ONE", "SECRET_TWO"];

/** Raised when a required secret cannot be resolved from any source. */
export class SecretsUnavailableError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "SecretsUnavailableError";
  }
}

/** Resolve a secret from process.env (populated by .env or the shell). */
export function getSecret(name: string, { required = true }: { required?: boolean } = {}): string {
  const value = process.env[name];
  if (value) return value;
  if (required) {
    throw new SecretsUnavailableError(
      `Secret '${name}' is not available. Ensure Vaultwarden is unlocked or set it in ${_DOT_ENV}.`
    );
  }
  return "";
}

// ---------------------------------------------------------------------------
// Runtime config — plain readonly object, edit defaults directly
// ---------------------------------------------------------------------------

export interface Config {
  readonly host: string;
  readonly port: number;
  readonly logLevel: string;
  readonly debug: boolean;
}

export const CONFIG: Config = {
  host: "DEFAULT_HOST",
  port: 8080,
  logLevel: "INFO",
  debug: false,
};

// Override at runtime only when a real need appears (tests, CLI flags):
//   const testCfg: Config = { ...CONFIG, port: 9999 };

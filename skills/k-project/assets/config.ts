// src/config.ts — Canonical KpihX configuration skeleton
// =========================================================
// Template for any TypeScript project that needs:
//   - YAML-based non-sensitive settings
//   - .env-based secrets (local dev override)
//   - Login-shell secret resolution (production, via bw-env)
//   - Cached singleton + runtime override support
//
// HOW TO USE:
//   1. Copy to: src/config.ts
//   2. Copy config.yaml.example to: src/config.yaml
//   3. Copy .env.example to: src/.env (fill real values for local dev)
//   4. Replace ALL_CAPS placeholders below with your project's specifics
//   5. Update REQUIRED_SECRETS with your secret names as they appear in bw-env
//
// PLACEHOLDERS TO REPLACE:
//   - YOUR_PACKAGE        → your package/module name (e.g., "my-mcp")
//   - SECRET_ONE          → first required secret name (e.g., "OPENAI_API_KEY")
//   - SECRET_TWO          → second required secret (remove if not needed)
//   - DEFAULT_HOST        → sensible default host (e.g., "localhost")
//   - DEFAULT_PORT        → sensible default port (e.g., 8080)

import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import dotenv from "dotenv";
import { execSync } from "child_process";

// ---------------------------------------------------------------------------
// Paths
// ---------------------------------------------------------------------------

const _PKG_DIR = path.dirname(__filename);
const _CONFIG_YAML = path.join(_PKG_DIR, "config.yaml");
const _DOT_ENV = path.join(_PKG_DIR, ".env");

// Load .env into process.env (override=false — existing env vars win)
dotenv.config({ path: _DOT_ENV, override: false });

// ---------------------------------------------------------------------------
// Required secrets — names must match bw-env / GLOBAL_ENV_VARS vault entries
// ---------------------------------------------------------------------------

export const REQUIRED_SECRETS: string[] = [
  "SECRET_ONE",
  "SECRET_TWO",
];

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/** Raised when a required secret cannot be resolved from any source. */
export class SecretsUnavailableError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "SecretsUnavailableError";
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

type ConfigData = Record<string, unknown>;

/** Simple Map-based YAML cache — equivalent to @lru_cache in Python. */
const _yamlCache = new Map<string, ConfigData>();

/**
 * Load a YAML file; return empty object if absent.
 * Result is cached by file path.
 */
function _loadYaml(filePath: string): ConfigData {
  if (_yamlCache.has(filePath)) return _yamlCache.get(filePath)!;
  if (!fs.existsSync(filePath)) return {};
  const raw = fs.readFileSync(filePath, "utf8");
  const data = yaml.load(raw) as ConfigData;
  if (typeof data !== "object" || Array.isArray(data) || data === null) {
    throw new TypeError(`Config at ${filePath} must be a YAML mapping.`);
  }
  _yamlCache.set(filePath, data);
  return data;
}

/**
 * Recursively merge `overlay` into a deep copy of `base`.
 * Nested objects are merged; all other types are replaced.
 */
function _deepMerge(base: ConfigData, overlay: ConfigData): ConfigData {
  const result = structuredClone(base);
  for (const [k, v] of Object.entries(overlay)) {
    if (
      v !== null &&
      typeof v === "object" &&
      !Array.isArray(v) &&
      typeof result[k] === "object" &&
      result[k] !== null &&
      !Array.isArray(result[k])
    ) {
      result[k] = _deepMerge(result[k] as ConfigData, v as ConfigData);
    } else {
      result[k] = structuredClone(v as ConfigData);
    }
  }
  return result;
}

/**
 * Two-tier secret resolution:
 *   1. process.env  (already set — terminal session, explicit export, or .env loaded)
 *   2. zsh -l -c   (login shell — bw-env secrets injected via $HOME/.kshrc)
 *
 * Returns null if the secret is absent in both tiers.
 */
function _resolveEnv(name: string): string | null {
  // Tier 1: current process env (covers: terminal session, .env load, explicit export)
  const fromEnv = process.env[name];
  if (fromEnv) return fromEnv;

  // Tier 2: login shell — bw-env injects secrets at login time via $HOME/.kshrc
  try {
    const value = execSync(`zsh -l -c 'printf "%s" "\${${name}}"'`, {
      timeout: 10_000,
      stdio: ["pipe", "pipe", "pipe"],
    })
      .toString()
      .trim();
    if (value) return value;
  } catch {
    // Shell unavailable or timeout — fall through
  }

  return null;
}

// ---------------------------------------------------------------------------
// Config class
// ---------------------------------------------------------------------------

export class ConfigManager {
  /**
   * Layered configuration singleton.
   *
   * Load order (later layers override earlier ones):
   *   1. Hardcoded defaults (in this class)
   *   2. config.yaml (non-sensitive settings)
   *   3. .env file    (local dev secret overrides — dotenv)
   *   4. process.env  (explicit exports always win)
   *
   * Secrets are resolved lazily on first access via `getSecret()`.
   * Use `updateConfig(overrides)` for runtime patching (e.g., in tests).
   */
  private _data: ConfigData;

  /** Hardcoded defaults — override in config.yaml. */
  private static readonly _defaults: ConfigData = {
    server: {
      host: "DEFAULT_HOST",
      port: "DEFAULT_PORT",
    },
    log: {
      level: "INFO",
    },
    debug: false,
  };

  constructor(overridePath?: string, extras?: Partial<ConfigData>) {
    // Merge: defaults → yaml → override file → inline extras
    let data = structuredClone(ConfigManager._defaults);
    data = _deepMerge(data, _loadYaml(_CONFIG_YAML));

    const resolvedPath = overridePath ?? process.env["CONFIG_PATH"];
    if (resolvedPath) {
      const abs = path.resolve(
        resolvedPath.replace(/^\x7E/, process.env["HOME"] ?? "")
      );
      if (fs.existsSync(abs)) {
        data = _deepMerge(data, _loadYaml(abs));
      }
    }

    if (extras) data = _deepMerge(data, extras as ConfigData);
    this._data = data;
  }

  // ------------------------------------------------------------------
  // Generic accessor — supports dotted-path navigation
  // ------------------------------------------------------------------

  /**
   * Access config by dotted path.
   *
   * @example
   *   cfg.get("server.host")         // → "localhost"
   *   cfg.get("server.port", 9000)   // → 8080 (from yaml) or 9000 (if missing)
   *   cfg.get("debug")               // → false
   */
  get<T = unknown>(dottedPath: string, defaultValue?: T): T {
    const keys = dottedPath.split(".");
    let node: unknown = this._data;
    for (const k of keys) {
      if (typeof node !== "object" || node === null || !(k in (node as object))) {
        return defaultValue as T;
      }
      node = (node as ConfigData)[k];
    }
    return node as T;
  }

  /** Return a deep copy of the merged config dict. */
  toDict(): ConfigData {
    return structuredClone(this._data);
  }

  set(key: string, value: unknown): void {
    this._data[key] = value;
  }

  // ------------------------------------------------------------------
  // Typed property shortcuts — add one per top-level config group
  // ------------------------------------------------------------------

  get host(): string {
    return String(this.get("server.host", "DEFAULT_HOST"));
  }

  get port(): number {
    return Number(this.get("server.port", "DEFAULT_PORT"));
  }

  get logLevel(): string {
    return String(this.get("log.level", "INFO"));
  }

  get debug(): boolean {
    return Boolean(this.get("debug", false));
  }

  // ------------------------------------------------------------------
  // Secret accessors — lazy two-tier resolution
  // ------------------------------------------------------------------

  /**
   * Resolve a secret by name via the two-tier strategy:
   *   process.env → zsh -l -c login shell
   *
   * @param name     Secret name (e.g., "SECRET_ONE").
   * @param required If true, throw SecretsUnavailableError when absent.
   * @returns        The secret value as a string.
   * @throws         SecretsUnavailableError if required=true and the secret is absent.
   */
  getSecret(name: string, { required = true }: { required?: boolean } = {}): string {
    const value = _resolveEnv(name);
    if (value) return value;
    if (required) {
      throw new SecretsUnavailableError(
        `Secret '${name}' is not available. ` +
          `Ensure bw-env is unlocked or set it in ${_DOT_ENV}.`
      );
    }
    return "";
  }

  // Convenience getters per required secret
  get secretOne(): string {
    return this.getSecret("SECRET_ONE");
  }

  // Add more as needed:
  // get secretTwo(): string {
  //   return this.getSecret("SECRET_TWO");
  // }

  // ------------------------------------------------------------------
  // Reload
  // ------------------------------------------------------------------

  /**
   * Clear the YAML cache and reload config with new overrides.
   * Mirrors Python's update_config() — clears lru_cache, re-reads files.
   */
  reload(overridePath?: string, extras?: Partial<ConfigData>): void {
    _yamlCache.clear();
    const fresh = new ConfigManager(overridePath, extras);
    this._data = fresh._data;
  }
}

// ---------------------------------------------------------------------------
// Cached singleton
// ---------------------------------------------------------------------------

/** Cached ConfigManager instance — created once on first import. */
let _instance: ConfigManager | null = null;

/**
 * Return (or create) the cached ConfigManager singleton.
 *
 * On first call: reads config.yaml + .env, merges layers.
 * Subsequent calls: return the same instance.
 *
 * Use `updateConfig(overrides)` to patch and reload.
 */
export function loadConfig(overridePath?: string, extras?: Partial<ConfigData>): ConfigManager {
  if (!_instance) {
    _instance = new ConfigManager(overridePath, extras);
  }
  return _instance;
}

/**
 * Clear the cache and reload config with runtime overrides.
 *
 * Typical use-cases:
 *   - Tests: patch specific values without touching files
 *   - CLI: override host/port from flags
 *   - Hot-reload: re-read config.yaml after file change
 *
 * @example
 *   const cfg = updateConfig(undefined, { server: { port: 9999 } });
 *   console.log(cfg.port); // 9999
 */
export function updateConfig(
  overridePath?: string,
  extras?: Partial<ConfigData>
): ConfigManager {
  _yamlCache.clear();
  _instance = new ConfigManager(overridePath, extras);
  return _instance;
}

// ---------------------------------------------------------------------------
// Module-level convenience — import this directly in other modules
// ---------------------------------------------------------------------------

/**
 * Shorthand: `import { getConfig } from "./config"; const cfg = getConfig();`
 */
export function getConfig(): ConfigManager {
  return loadConfig();
}

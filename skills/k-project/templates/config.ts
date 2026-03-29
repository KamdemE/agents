// src/config.ts
// Config management — override hierarchy:
//   1. Built-in defaults  (config.yaml alongside this file)
//   2. User config file   (overridePath or CONFIG_PATH env var)
//   3. Inline extras object
import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import dotenv from "dotenv";

dotenv.config();

type ConfigData = Record<string, unknown>;

const DEFAULT_CONFIG_PATH = path.join(__dirname, "config.yaml");

// Simple Map-based cache (equivalent to @lru_cache in Python)
const _cache = new Map<string, ConfigData>();

function loadYaml(filePath: string): ConfigData {
  if (_cache.has(filePath)) return _cache.get(filePath)!;
  const raw = fs.readFileSync(filePath, "utf8");
  const data = yaml.load(raw) as ConfigData;
  if (typeof data !== "object" || Array.isArray(data) || data === null) {
    throw new TypeError(`Config at ${filePath} must be a YAML mapping.`);
  }
  _cache.set(filePath, data);
  return data;
}

function deepMerge(base: ConfigData, overlay: ConfigData): ConfigData {
  for (const [k, v] of Object.entries(overlay)) {
    if (
      v !== null &&
      typeof v === "object" &&
      !Array.isArray(v) &&
      typeof base[k] === "object" &&
      base[k] !== null &&
      !Array.isArray(base[k])
    ) {
      base[k] = deepMerge(base[k] as ConfigData, v as ConfigData);
    } else {
      base[k] = v;
    }
  }
  return base;
}

export class ConfigManager {
  private data: ConfigData;

  constructor(overridePath?: string, extras?: Partial<ConfigData>) {
    this.data = structuredClone(loadYaml(DEFAULT_CONFIG_PATH));

    const resolvedPath = overridePath ?? process.env.CONFIG_PATH;
    if (resolvedPath) {
      const abs = path.resolve(
        resolvedPath.replace(/^~/, process.env.HOME ?? "")
      );
      if (fs.existsSync(abs)) {
        deepMerge(this.data, structuredClone(loadYaml(abs)));
      }
    }

    if (extras) Object.assign(this.data, extras);
  }

  get<T = unknown>(key: string, defaultValue?: T): T {
    return (key in this.data ? this.data[key] : defaultValue) as T;
  }

  /** Navigate nested keys safely. Returns defaultValue if any key is missing. */
  getNested<T = unknown>(keys: string[], defaultValue?: T): T {
    let node: unknown = this.data;
    for (const k of keys) {
      if (typeof node !== "object" || node === null || !(k in (node as object))) {
        return defaultValue as T;
      }
      node = (node as ConfigData)[k];
    }
    return node as T;
  }

  set(key: string, value: unknown): void {
    this.data[key] = value;
  }

  get debug(): boolean {
    return Boolean(this.data["debug"] ?? false);
  }

  reload(overridePath?: string, extras?: Partial<ConfigData>): void {
    _cache.clear();
    const fresh = new ConfigManager(overridePath, extras);
    this.data = fresh.data;
  }
}

export const config = new ConfigManager();

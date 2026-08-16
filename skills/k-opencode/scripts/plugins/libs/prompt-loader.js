import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const promptsDirectory = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..", "..", "assets", "plugins", "hooks");
const cache = new Map();

export function loadPrompt(name) {
  if (!cache.has(name)) {
    cache.set(name, readFileSync(resolve(promptsDirectory, `${name}.txt`), "utf8").trim());
  }
  return cache.get(name);
}

export function renderPrompt(name, variables = {}) {
  return Object.entries(variables).reduce(
    (text, [key, value]) => text.replaceAll(`{{${key}}}`, value),
    loadPrompt(name),
  );
}

export function promptMarker(name) {
  return loadPrompt(name).split("\n", 1)[0];
}

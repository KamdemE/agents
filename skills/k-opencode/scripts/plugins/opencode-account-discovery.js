// opencode-account-discovery.js — auto-discovery for any extra OpenCode
// Zen/Go account (2nd, 3rd, …), WITHOUT opencode-models-discovery and WITHOUT
// a localhost proxy.
//
// Opt-in: provider.<id>.options.opencodeAccountDiscovery = true
// Requires: options.baseURL (e.g. https://opencode.ai/zen/v1 or …/zen/go/v1)
// Auth: auth.json[providerId].key (opencode auth login → Other → that id)
//
// Why not models-discovery + a follow-up enricher:
// 1) models-discovery config hook races a timeout / parallel plugins
//    → enricher often sees empty models → muse stays on @ai-sdk/openai-compatible
// 2) openai-compatible → /v1/chat/completions ; muse/luna need @ai-sdk/openai
//    → /v1/responses (Internal server error — same trap as the old :4999 proxy)
// 3) modelInfoFormat=models.dev uses fuzzy prefix match → free renamed as paid
//
// This plugin: GET {baseURL}/models + EXACT models.dev match for name/cost/npm.
// No hardcoded model list. Works for any Nth OpenCode account provider id.

import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const MODELS_DEV_URL = "https://models.dev/api.json";
const CACHE_TTL_MS = 60 * 60 * 1000;
const UA = "opencode-account-discovery";
const ACRONYMS = new Set(["gpt", "oss", "api", "gguf", "ggml", "nomic", "vl", "it", "mlx"]);

let modelsDevCache = null;
let modelsDevAt = 0;

function authFile() {
  return path.join(os.homedir(), ".local/share/opencode/auth.json");
}

function readApiKey(providerId) {
  try {
    const auth = JSON.parse(fs.readFileSync(authFile(), "utf8"));
    const entry = auth?.[providerId];
    if (entry?.type === "api" && typeof entry.key === "string") return entry.key;
  } catch {
    /* ignore */
  }
  return "";
}

async function loadModelsDev() {
  const now = Date.now();
  if (modelsDevCache && now - modelsDevAt < CACHE_TTL_MS) return modelsDevCache;
  const res = await fetch(MODELS_DEV_URL, { headers: { "User-Agent": UA } });
  if (!res.ok) throw new Error(`models.dev HTTP ${res.status}`);
  modelsDevCache = await res.json();
  modelsDevAt = now;
  return modelsDevCache;
}

function preferredProviders(baseURL) {
  const u = String(baseURL || "");
  if (u.includes("/zen/go")) return ["opencode-go", "opencode"];
  if (u.includes("/zen")) return ["opencode", "opencode-go"];
  return ["opencode", "opencode-go"];
}

function lookupExact(data, modelId, prefs) {
  for (const pid of prefs) {
    const m = data?.[pid]?.models?.[modelId];
    if (m && typeof m === "object") return m;
  }
  return undefined;
}

function humanizeFromId(modelId) {
  const part = modelId.includes("/") ? modelId.split("/").pop() : modelId;
  return String(part)
    .split(/[-_]/)
    .filter(Boolean)
    .map((token) => {
      const lower = token.toLowerCase();
      if (ACRONYMS.has(lower)) return token.toUpperCase();
      if (/^\d+[bkmg]$/i.test(token)) return token.toUpperCase();
      if (/^q\d+$/i.test(token)) return token.toUpperCase();
      if (/^\d+\.\d+/.test(token)) return token;
      if (/^[a-z]\d+[a-z]$/i.test(token) || /^\d+[a-z]$/i.test(token)) return token.toUpperCase();
      return token.charAt(0).toUpperCase() + token.slice(1).toLowerCase();
    })
    .join(" ");
}

function ensureFreeLabel(modelId, name) {
  if (!modelId.includes("free")) return name;
  if (typeof name !== "string" || name.length === 0) return name;
  if (/\bfree\b/i.test(name)) return name;
  return `${name} Free`;
}

function modelsUrl(baseURL) {
  return `${String(baseURL || "").replace(/\/+$/, "")}/models`;
}

async function fetchProviderModels(baseURL, apiKey) {
  const url = modelsUrl(baseURL);
  const headers = { "User-Agent": UA };
  if (apiKey) headers.Authorization = `Bearer ${apiKey}`;
  const res = await fetch(url, { headers });
  if (!res.ok) throw new Error(`${url} → HTTP ${res.status}`);
  const body = await res.json();
  const list = Array.isArray(body?.data) ? body.data : Array.isArray(body) ? body : [];
  return list.map((m) => (typeof m?.id === "string" ? m.id : null)).filter(Boolean);
}

function buildModel(modelId, info) {
  const name = ensureFreeLabel(
    modelId,
    typeof info?.name === "string" && info.name.length > 0 ? info.name : humanizeFromId(modelId),
  );
  const out = {
    id: modelId,
    name,
    modalities: { input: ["text"], output: ["text"] },
  };
  if (info?.modalities?.input || info?.modalities?.output) {
    out.modalities = {
      ...(info.modalities.input ? { input: info.modalities.input } : { input: ["text"] }),
      ...(info.modalities.output ? { output: info.modalities.output } : { output: ["text"] }),
    };
  }
  if (typeof info?.attachment === "boolean") out.attachment = info.attachment;
  if (typeof info?.reasoning === "boolean") out.reasoning = info.reasoning;
  if (typeof info?.tool_call === "boolean") out.tool_call = info.tool_call;
  if (typeof info?.provider?.npm === "string" && info.provider.npm.length > 0) {
    out.provider = { npm: info.provider.npm };
  }
  const c = info?.cost;
  if (c && typeof c === "object" && typeof c.input === "number") {
    out.cost = {
      input: c.input,
      output: typeof c.output === "number" ? c.output : 0,
      cache_read: typeof c.cache_read === "number" ? c.cache_read : 0,
      cache_write: typeof c.cache_write === "number" ? c.cache_write : 0,
    };
  }
  const ctx = info?.limit?.context ?? info?.limit?.input;
  if (typeof ctx === "number" && Number.isFinite(ctx) && ctx > 0) {
    out.limit = {
      context: ctx,
      ...(typeof info.limit?.input === "number" ? { input: info.limit.input } : {}),
      output: typeof info.limit?.output === "number" ? info.limit.output : 0,
    };
  }
  return out;
}

function wantsDiscovery(prov) {
  const o = prov?.options || {};
  // Primary flag + legacy alias from earlier Labs pass
  return o.opencodeAccountDiscovery === true || o.enrichNpmFromModelsDev === true;
}

async function discoverProvider(providerId, prov, data) {
  const baseURL = prov?.options?.baseURL;
  if (!baseURL) return;
  if (prov.options.modelsDiscovery) {
    prov.options.modelsDiscovery = { ...prov.options.modelsDiscovery, enabled: false };
  }
  const prefs = preferredProviders(baseURL);
  const apiKey = readApiKey(providerId);
  let ids;
  try {
    ids = await fetchProviderModels(baseURL, apiKey);
  } catch {
    return;
  }
  if (!ids.length) return;
  const models = {};
  for (const id of ids) {
    models[id] = buildModel(id, lookupExact(data, id, prefs));
  }
  prov.models = models;
}

export default async function OpencodeAccountDiscovery() {
  return {
    config: async (config) => {
      const providers = config?.provider;
      if (!providers || typeof providers !== "object") return;

      const targets = Object.entries(providers).filter(([, p]) => wantsDiscovery(p));
      if (targets.length === 0) return;

      let data = {};
      try {
        data = await loadModelsDev();
      } catch {
        data = {};
      }

      await Promise.all(targets.map(([id, prov]) => discoverProvider(id, prov, data)));
    },
  };
}

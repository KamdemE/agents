// opencode-copilot-picker-fix.js — restore github-copilot models when GitHub
// returns model_picker_enabled:false for every model (upstream #42083).
// OpenCode 1.18.x filters pickerEnabled → empty → "Provider not found".
// Workaround: re-fetch /models and keep usable (policy≠disabled + limits + tools).

const PROVIDER_ID = "github-copilot";
const UA = "opencode/1.18.16";

function baseUrl(auth) {
  if (auth?.enterpriseUrl) {
    const host = String(auth.enterpriseUrl).replace(/^https?:\/\//, "").replace(/\/$/, "");
    return `https://copilot-api.${host}`;
  }
  return "https://api.githubcopilot.com";
}

function authToken(auth) {
  // Live probe: access works for /models; issue #42083 used refresh — try both.
  return auth?.access || auth?.refresh || "";
}

function usable(m) {
  // Student/Free: policy=None legacy + internals (copilot-search-*, exec-agent-*)
  // still pass a soft "not disabled" check and then 400 "model is not supported".
  // Keep only explicitly enabled models (KπX 2026-09-09 option A).
  if (m?.policy?.state !== "enabled") return false;
  const lim = m?.capabilities?.limits;
  if (!lim?.max_output_tokens || !lim?.max_prompt_tokens) return false;
  if (m?.capabilities?.supports?.tool_calls === undefined) return false;
  return true;
}

function toOpencodeModel(m, base) {
  const lim = m.capabilities.limits;
  const isMsg = Array.isArray(m.supported_endpoints) && m.supported_endpoints.includes("/v1/messages");
  const version = typeof m.version === "string" ? m.version : "";
  return {
    id: m.id,
    providerID: PROVIDER_ID,
    api: {
      id: m.id,
      url: isMsg ? `${base}/v1` : base,
      npm: isMsg ? "@ai-sdk/anthropic" : "@ai-sdk/github-copilot",
    },
    status: "active",
    limit: {
      context: lim.max_context_window_tokens ?? lim.max_prompt_tokens,
      input: lim.max_prompt_tokens,
      output: lim.max_output_tokens,
    },
    capabilities: {
      temperature: true,
      reasoning: true,
      attachment: true,
      toolcall: !!m.capabilities?.supports?.tool_calls,
      input: {
        text: true,
        audio: false,
        image: !!m.capabilities?.supports?.vision,
        video: false,
        pdf: false,
      },
      output: { text: true, audio: false, image: false, video: false, pdf: false },
      interleaved: false,
    },
    family: m.capabilities?.family,
    name: m.name || m.id,
    cost: { input: 0, output: 0, cache: { read: 0, write: 0 } },
    options: {},
    headers: {},
    release_date: version.startsWith(`${m.id}-`) ? version.slice(m.id.length + 1) : version,
  };
}

export default async function OpencodeCopilotPickerFix() {
  return {
    provider: {
      id: PROVIDER_ID,
      async models(provider, ctx) {
        if (ctx?.auth?.type !== "oauth") return provider.models;
        const base = baseUrl(ctx.auth);
        const token = authToken(ctx.auth);
        if (!token) return provider.models;
        try {
          const r = await fetch(`${base}/models`, {
            headers: {
              Authorization: `Bearer ${token}`,
              "User-Agent": UA,
              "Editor-Version": UA,
              "Copilot-Integration-Id": "vscode-chat",
              "X-GitHub-Api-Version": "2026-06-01",
            },
            signal: AbortSignal.timeout(8000),
          });
          if (!r.ok) return provider.models;
          const j = await r.json();
          const models = {};
          for (const m of j.data || []) {
            if (!usable(m)) continue;
            models[m.id] = toOpencodeModel(m, base);
          }
          return Object.keys(models).length > 0 ? models : provider.models;
        } catch {
          return provider.models;
        }
      },
    },
  };
}

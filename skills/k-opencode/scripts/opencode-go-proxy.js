#!/usr/bin/env node
/**
 * opencode-go-proxy — minimal reverse proxy for OpenCode Go 2nd account.
 *
 * Problem: opencode-models-discovery plugin strips the path from baseURL
 * via `new URL(endpoint, new URL(baseURL).origin)`, so a custom provider
 * with baseURL "https://opencode.ai/zen/go/v1" getsDiscovery hit
 * "https://opencode.ai/v1/models" (missing /zen/go/ prefix).
 *
 * Solution: this proxy listens on localhost:4999, rewrites /v1/* →
 * https://opencode.ai/zen/go/v1/*, and forwards the auth header.
 * The plugin sees "http://localhost:4999/v1" as baseURL, which resolves
 * correctly to "http://localhost:4999/v1/models".
 *
 * Usage: node opencode-go-proxy.js [port]
 * Auth: reads API key from ~/.local/share/opencode/auth.json["opencode-go-2"]
 */

import http from "node:http";
import https from "node:https";
import fs from "node:fs";
import path from "node:path";

const PORT = parseInt(process.argv[2] || "4999", 10);
const UPSTREAM = "https://opencode.ai/zen/go";
const AUTH_FILE = path.join(
  process.env.HOME || "/home/kpihx",
  ".local/share/opencode/auth.json"
);

function getApiKey() {
  try {
    const auth = JSON.parse(fs.readFileSync(AUTH_FILE, "utf8"));
    return auth["opencode-go-2"]?.key || "";
  } catch {
    return "";
  }
}

const server = http.createServer((req, res) => {
  // Rewrite: /v1/anything → /zen/go/v1/anything
  const upstreamPath = `/zen/go${req.url}`;
  const apiKey = getApiKey();

  const headers = { ...req.headers };
  delete headers["host"];
  headers["host"] = "opencode.ai";
  if (apiKey) {
    headers["authorization"] = `Bearer ${apiKey}`;
  }

  const proxyReq = https.request(
    `https://opencode.ai${upstreamPath}`,
    {
      method: req.method,
      headers,
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    }
  );

  proxyReq.on("error", (err) => {
    console.error(`[proxy] ${req.method} ${req.url} → ERROR: ${err.message}`);
    res.writeHead(502);
    res.end(`Proxy error: ${err.message}`);
  });

  req.pipe(proxyReq);
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`[opencode-go-proxy] listening on http://127.0.0.1:${PORT}`);
  console.log(`[opencode-go-proxy] rewriting /v1/* → ${UPSTREAM}/v1/*`);
});

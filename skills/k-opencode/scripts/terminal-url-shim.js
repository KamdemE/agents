#!/usr/bin/env bun
// KπX terminal-url-shim (k-opencode) — 2026-08-16
//
// Fixes opencode web's known upstream bug #5844
// (github.com/anomalyco/opencode/issues/5844): when reached via a hostname
// that is neither "localhost" nor "opencode.ai" (e.g. any Tailscale
// hostname), the frontend's sdk.url falls back to "/", producing a
// malformed WebSocket URL ("//pty/<id>/connect") — the browser misinterprets
// it as protocol-relative with host "pty", the terminal loads indefinitely.
//
// SOLUTION (Option A — script injection, NO redirects):
//   Instead of redirecting to add ?url= (which breaks SPAs, API calls,
//   and causes cascading issues), the shim injects a tiny <script> tag
//   into HTML responses that overrides URLSearchParams.prototype.get("url")
//   to always return the correct origin. This way the frontend reads the
//   correct sdk.url without any redirect, URL change, or page reload.
//
// DUAL-PORT architecture: one script, two Bun.serve instances:
//   - Port 4097 → transparent proxy to opencode-web on 40977
//   - Port 3000 → transparent proxy to opencode-lens on 30001
// Tailscale Serve is NEVER touched — it still points to 4097 and 3000.

const BACKENDS = {
  4097: { http: "http://127.0.0.1:40977", ws: "ws://127.0.0.1:40977" },
  3000: { http: "http://127.0.0.1:30001", ws: "ws://127.0.0.1:30001" },
};

function createHandler(backend) {
  return {
    async fetch(req, server) {
      const url = new URL(req.url);
      // CRITICAL FIX (found 2026-08-17): the injected script MUST use the
      // EXTERNAL origin (the Tailscale hostname the browser actually used —
      // computed from the request's Host header + x-forwarded-proto), NEVER
      // backend.http (the internal 127.0.0.1:<port> URL). An earlier version
      // of this file injected backend.http directly, causing the frontend's
      // sdk.url to become "http://127.0.0.1:40977" — unreachable from the
      // browser's machine — which broke ALL API calls (sessions, workspace
      // folders never loading) and the terminal WebSocket.
      const host = req.headers.get("host") || `127.0.0.1:${server.port}`;
      const proto = req.headers.get("x-forwarded-proto") || "https";
      const externalOrigin = `${proto}://${host}`;

      // WebSocket upgrade — bridge to the real backend WS endpoint (internal,
      // backend.ws is correct here since this connection is server-to-server,
      // not from the browser).
      if (req.headers.get("upgrade")?.toLowerCase() === "websocket") {
        const upstreamUrl = backend.ws + url.pathname + url.search;
        const upgraded = server.upgrade(req, { data: { upstreamUrl, buffer: [] } });
        if (upgraded) return undefined;
        return new Response("WebSocket upgrade failed", { status: 500 });
      }

      // Transparent proxy: forward EVERYTHING to the backend unchanged
      // (internal URL — this is a server-to-server hop, correct to use
      // backend.http here).
      const target = new URL(backend.http + url.pathname + url.search);
      const headers = new Headers(req.headers);

      // HOST HEADER FIX (found 2026-08-17, a THIRD independent symptom of
      // the same upstream hostname-detection bug class as #5844 — and the
      // reason the ticket-header fix below still wasn't enough on its
      // own): this line used to unconditionally do
      // `headers.set("host", new URL(backend.http).host)` — rewriting the
      // Host header to the internal backend address
      // ("127.0.0.1:40977") on EVERY proxied request. That is NOT needed
      // for routing: `fetch(target, ...)` already connects to the correct
      // internal address via `target` itself (the URL, not the Host
      // header) — confirmed by curling `127.0.0.1:40977` directly with an
      // explicit `Host: kpihx-ubuntu.tail2527bd.ts.net:1443` header and
      // getting a normal, correct response. But opencode's own
      // `connect-token` handler does an Origin/Host same-origin check
      // (`iI(origin, host, corsConfig)` in the compiled binary) — with
      // Origin left untouched as the real Tailscale hostname but Host
      // rewritten to the internal loopback address, the two never match
      // and ANY known-safe pattern (localhost/127.0.0.1 origin, or
      // origin.host === host) fails, so the backend returns 403
      // "Invalid PTY connect token request" — reproduced exactly via
      // curl (Origin=tailscale hostname + Host=127.0.0.1:40977 → 403;
      // same Origin + Host=tailscale hostname → 200, real ticket
      // returned). Fix: simply do NOT override Host — let the original
      // client-facing Host header (already copied via
      // `new Headers(req.headers)` above) pass through unchanged, so
      // Origin and Host naturally match for real browser requests.
      // Verified this does not break routing (target URL still
      // determines the actual TCP destination) nor any other previously
      // fixed endpoint (`/`, `/session`, `/event` HTML injection and
      // buffering logic below are unaffected — they never depended on
      // this header).

      // TICKET HEADER FIX (found 2026-08-17, a SECOND independent symptom
      // of the same upstream hostname-detection bug class as #5844):
      // opencode's backend requires a custom `x-opencode-ticket: 1` header
      // on every `POST /pty/{id}/connect-token` (and `/api/pty/{id}/...`)
      // request — verified directly in the compiled opencode binary
      // (`bin/opencode`, extracted via `strings`): the handler does
      // `if (headers["x-opencode-ticket"] !== "1" || !originHostOk)
      // return 403 PtyForbiddenError("Invalid PTY connect token
      // request")`. Reproduced the EXACT 403 the browser console showed
      // by curling the real Tailscale hostname with no such header, then
      // confirmed a real ticket (`{"ticket":...,"expires_in":60}`) once
      // the header was added — at all 3 layers (backend 40977 direct,
      // shim 4097, and the real Tailscale hostname). The official web
      // frontend evidently only attaches this header conditionally on
      // hostname (mirroring the exact `sdk.url` bug above), so it never
      // reaches the backend when opencode-web is accessed via a Tailscale
      // hostname. Fix: the shim injects the header itself, transparently
      // working around the frontend gap — same "inject to fix
      // hostname-conditional logic" philosophy already used for sdk.url.
      if (/\/(api\/)?pty\/[^/]+\/connect-token$/.test(url.pathname)) {
        headers.set("x-opencode-ticket", "1");
      }

      const resp = await fetch(target, {
        method: req.method,
        headers,
        body: req.method === "GET" || req.method === "HEAD" ? undefined : req.body,
        redirect: "manual",
        // A streamed SSE response outlives ordinary requests. Without tying
        // the backend fetch to the downstream request lifecycle, closing a
        // browser tab leaves its shim→backend socket established forever.
        // Enough abandoned streams eventually exhaust Bun's connection pool
        // and make both public routes time out despite healthy backends.
        signal: req.signal,
      });

      // CRITICAL FIX (found 2026-08-17, via verbose curl on the /session API
      // call): returning `resp` directly (a streamed/chunked fetch() Response
      // with NO explicit Content-Length) breaks Tailscale Serve's HTTP/2
      // proxy layer for larger payloads — confirmed with `curl -v`:
      // "HTTP/2 stream 1 was not closed cleanly: INTERNAL_ERROR (err 2)".
      // Small HTML pages (~3KB) slipped by unnoticed, but the /session API
      // response (52KB of session/project JSON) reset the stream before any
      // body arrived — this is WHY sessions/workspace folders never loaded,
      // in EVERY browser and even in private/incognito mode (it's a
      // server-side HTTP/2 framing bug, not a client-side cache/state issue —
      // an earlier localStorage theory was disproven by this same evidence).
      // Fix: buffer the ENTIRE response body for EVERY response (not just
      // HTML) and always set an explicit Content-Length header.
      const ct = resp.headers.get("content-type") || "";

      // STREAMING FIX (found 2026-08-17, root-caused via a LIVE OUTAGE: the
      // shim became unresponsive on ALL routes — even previously-working
      // "/" and "/session" — after accumulating 257 stuck outbound
      // connections to the backends over ~25h of uptime, eventually
      // starving Bun's fetch connection pool so every NEW request hung
      // indefinitely with 0 bytes received). Root cause: opencode exposes
      // a Server-Sent-Events stream at `/event` (content-type:
      // text/event-stream) for real-time session/log updates — this
      // response NEVER closes for the lifetime of the browser tab. The
      // buffering fix above (`await resp.arrayBuffer()`) was applied
      // UNCONDITIONALLY to every proxied response, including this one —
      // for a stream that never ends, arrayBuffer() never resolves,
      // permanently pinning one shim->backend fetch-pool connection AND
      // one browser->shim connection per SSE session, forever. Reproduced
      // directly: `curl --max-time 6 http://127.0.0.1:4097/event` returned
      // ZERO bytes (not even headers) after the full 6s window, while the
      // same request straight to the backend (127.0.0.1:40977) returned
      // headers instantly with `Transfer-Encoding: chunked`. This is ALSO
      // why the browser's console showed a 403 on `/pty/{id}/connect-token`
      // during the original terminal-loading investigation: by the time
      // that request ran, the pool was already exhausted from prior /event
      // connections piling up across earlier sessions/reloads.
      // Fix: detect `text/event-stream` and pass the ReadableStream body
      // straight through with NO buffering and NO Content-Length (length
      // is inherently unknown/unbounded for a live stream — this is
      // normal, valid HTTP for SSE over both HTTP/1.1 chunked and HTTP/2
      // DATA framing, so it does NOT re-trigger the earlier HTTP/2
      // stream-reset bug, which only ever affected fully-buffered
      // small/medium JSON payloads declaring no Content-Length).
      if (ct.includes("text/event-stream")) {
        const sh = new Headers(resp.headers);
        sh.delete("content-encoding");
        sh.delete("content-length");
        sh.delete("transfer-encoding");
        return new Response(resp.body, { status: resp.status, headers: sh });
      }

      const buf = await resp.arrayBuffer();
      const h = new Headers(resp.headers);
      // SECOND FIX (found immediately after the first, same investigation):
      // Bun's fetch() transparently decompresses gzip/br responses into
      // arrayBuffer() — but the backend's original "content-encoding: gzip"
      // header was still being copied via `new Headers(resp.headers)`,
      // declaring the body is gzip-compressed when it's actually plain bytes
      // by the time we return it. This header/body mismatch is invalid HTTP
      // and is the most likely reason Tailscale Serve's HTTP/2 proxy reset
      // the stream (INTERNAL_ERROR) even after Content-Length was fixed —
      // curl's local test didn't catch this because it wasn't strict about
      // the mismatch, but a real HTTP/2 proxy validating frames would be.
      h.delete("content-encoding");
      h.delete("transfer-encoding");

      if (resp.status >= 200 && resp.status < 300 && ct.includes("text/html")) {
        // HTML response injection: inject a tiny <script> that overrides
        // URLSearchParams.prototype.get("url") to return the EXTERNAL origin
        // (externalOrigin, NOT backend.http). This makes the frontend
        // resolve sdk.url correctly without any redirect, URL change, or
        // page reload.
        const body = Buffer.from(buf).toString("utf8");
        const script = `<script>(function(){var o="${externalOrigin}";var g=URLSearchParams.prototype.get;URLSearchParams.prototype.get=function(k){return k==="url"?o:g.call(this,k)};})();</script>`;
        const injected = body.replace("<head>", `<head>${script}`);
        h.set("content-length", String(Buffer.byteLength(injected)));
        return new Response(injected, { status: resp.status, headers: h });
      }

      // Every other response (JSON API calls, static assets, etc.): return
      // the buffered body with an explicit Content-Length — this is the
      // fix for the HTTP/2 stream reset described above.
      h.set("content-length", String(buf.byteLength));
      return new Response(buf, { status: resp.status, headers: h });
    },
    websocket: {
      open(ws) {
        const { upstreamUrl } = ws.data;
        const upstream = new WebSocket(upstreamUrl);
        ws.data.upstream = upstream;
        upstream.addEventListener("open", () => {
          for (const msg of ws.data.buffer) upstream.send(msg);
          ws.data.buffer = [];
        });
        upstream.addEventListener("message", (ev) => {
          try { ws.send(ev.data); } catch {}
        });
        upstream.addEventListener("close", () => {
          try { ws.close(); } catch {}
        });
        upstream.addEventListener("error", () => {
          try { ws.close(); } catch {}
        });
      },
      message(ws, message) {
        const upstream = ws.data.upstream;
        if (upstream && upstream.readyState === WebSocket.OPEN) {
          upstream.send(message);
        } else if (upstream) {
          ws.data.buffer.push(message);
        }
      },
      close(ws) {
        const upstream = ws.data.upstream;
        if (upstream) {
          try { upstream.close(); } catch {}
        }
      },
    },
  };
}

for (const [portStr, backend] of Object.entries(BACKENDS)) {
  const port = parseInt(portStr, 10);
  const name = port === 4097 ? "opencode-web" : "opencode-lens";
  Bun.serve({
    port,
    hostname: "127.0.0.1",
    // The default 10-second idle timeout terminates valid long-lived SSE
    // traffic. Keep the server-side connection alive while req.signal above
    // still guarantees prompt cleanup when the client disconnects.
    idleTimeout: 255,
    ...createHandler(backend),
  });
  console.log(`terminal-url-shim: ${name} on http://127.0.0.1:${port} -> ${backend.http}`);
}

console.log("terminal-url-shim: all backends up (script injection, no redirects — fixes #5844)");

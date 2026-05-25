import { DEFAULT_DESTINATIONS, ROUTES } from "./routes.mjs";

function normalizeRecipient(message) {
  const raw = `${message.to || ""} ${message.headers?.get?.("to") || ""}`.toLowerCase();
  for (const address of Object.keys(ROUTES)) {
    if (raw.includes(address)) return address;
  }
  return null;
}

async function forwardSequential(message, destinations) {
  const results = [];
  for (const addr of destinations) {
    try {
      await message.forward(addr);
      console.log(`forward ok: ${addr}`);
      results.push({ addr, ok: true });
    } catch (err) {
      const msg = err?.message || String(err);
      console.error(`forward failed ${addr}: ${msg}`);
      results.push({ addr, ok: false, error: msg });
    }
  }
  const failed = results.filter((r) => !r.ok);
  if (failed.length === results.length && results.length > 0) {
    message.setReject(`All forwards failed: ${failed.map((f) => f.error).join("; ")}`);
  }
}

export default {
  async email(message) {
    const recipient = normalizeRecipient(message);
    const destinations = recipient ? ROUTES[recipient] : DEFAULT_DESTINATIONS;
    console.log(`route ${recipient || "default"} -> ${destinations.join(", ")}`);
    await forwardSequential(message, destinations);
  },
};

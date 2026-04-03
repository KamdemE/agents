# Mac Studio — Business Model & Service Capacity

> Status: REFERENCE · Last updated: 2026-04-02 · [CLAUDE + GEMINI]
> Config: M4 Max 128GB | ~4 331€ total (+ SSD)

---

## Core Differentiator

**Do NOT compete with ChatGPT on B2C.** Win on:
1. **GDPR / data sovereignty** — cabinets avocats, médecins, comptables, RH cannot send data to US cloud
2. **Fixed cost** — zero per-token, predictable billing
3. **Integration** — connect to client's own tools (email, CRM, drive)
4. **Custom fine-tuning** — model adapted to client domain

---

## Service Capacity (honest numbers)

### 3 metrics to distinguish:

| Metric | Value (70B Q4) | Meaning |
|--------|---------------|---------|
| KV sessions (4k ctx) | **176** | Simultaneous session contexts in RAM |
| Live simultaneous users | **2-4 fluent, 8 slow** | People actively generating at same ms |
| Users/hour (throughput) | **~72** | Distinct users served per hour |
| Total population (async) | **300-500** | Realistic subscriber base |

### Router pattern (80/20 model split)

```
Incoming request
  → router (fast classif)
      ├─ 80% simple tasks → 8B Q4 (~87 tok/s) → 20-30 simultaneous OK
      └─ 20% complex tasks → 70B Q4 (~13 tok/s) → 2-4 simultaneous OK
```
→ Effective throughput: 4-6× higher than single-model approach.

### Async queue pattern (unlimited scale)

```
Clients send jobs via API → queue (RabbitMQ / Celery)
→ Mac processes 24/7 at max speed
→ Client gets result when ready (seconds to minutes)
```
→ Handles **hundreds of clients** for non-interactive tasks (email triage, doc analysis, SEO copy).

---

## Business Models

### Tier 1 — Launch (1-5 clients, solo)

| Model | Target | Price | ROI |
|-------|--------|-------|-----|
| **Private GPT B2B** | Law firms, accountants, medical | 200-500€/month/company | ~3-6 months (3 clients) |
| RGPD pitch | "Your data never leaves your machine" | same | |

Setup: Open-WebUI + Ollama + RAG (ChromaDB) + Tailscale access. 2-3 weeks work.

### Tier 2 — Scale (5-20 clients)

| Model | Target | Price | Notes |
|-------|--------|-------|-------|
| **Callbot** | Restaurants, artisans, SMEs | 100-150€/month | Twilio + Whisper + 8B + TTS |
| **SEO batch** | E-commerce, agencies | 0.15€/fiche | 5000 fiches = 750€, overnight |
| **Email/CRM agent** | Any business | 200-400€/month | n8n + LLM + CRM API |

Requires: n8n/Dify routing + Celery queue.

### Scale limit & growth path

```
<5 clients     → Mac alone, comfortable
5-50 clients   → Mac + queue + router pattern
>500 clients   → Add 2nd identical Mac Studio (load balance, not upgrade)
>1000 clients  → Migrate heavy load to cloud GPU, Mac = R&D + personal
```

**Why 2nd Mac vs upgrade:** No single point of failure + linear cost scaling.

---

## Financial Model (3-year TCO)

| Item | Cost |
|------|------|
| Mac Studio M4 Max 128GB | 3 982€ |
| External SSD 4TB TB4 | 350€ |
| Total upfront | **4 332€** |
| Electricity (40W avg × 8760h × 0.20€) | ~70€/year |
| 3-year TCO | ~4 542€ |
| Amortized monthly | **~126€/month** |

**Cloud equivalent (A6000 × 2 for ~96GB VRAM): ~1 000-1 500€/month.**
→ ROI vs cloud: **3-4 months** of equivalent usage.

**API comparison (amortized 126€/month):**

| API | Frontier | Users served/month (200 msg/mo) |
|-----|---------|--------------------------------|
| GPT-4o (10€/M tok) | ✅ | ~63 users |
| Gemini 2.5 Pro (14€/M tok) | ✅ | ~44 users |
| Mac local (126€/mo amortized) | ~GPT-4 | **unlimited** |

---

## X24 Shareholding Model (revised)

**Recommendation (Gemini-validated):** Buy the Mac yourself. Do NOT pool funds.

Why: physical asset co-ownership between students → conflict risk.

Options for involving camarades:
- **Bounty model:** "Build WhatsApp integration → 30% revenue share on that feature"
- **Slicing Pie:** Dynamic equity based on actual contributions (time × rate + capital)
- **Vesting (if formal co-founding):** 4-year cliff 1 year — protects against early dropouts

**Pricing for X24 access:**
- Internal access (camarades): free or ~20-30€/month cost-sharing
- External professionals: 100-500€/month depending on features

**Math: 3 981€ / 10 parts = 398€/part — BUT 10 × 16 GB = 160 GB > 128 GB physical.**
Corrected quota: max 10 GB/user simultaneously (KV cache share when 70B loaded).

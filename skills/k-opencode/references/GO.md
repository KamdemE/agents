# OpenCode Go — Complete Model Reference

**Subscription:** $5 first month → $10/month  
**Usage Limits:** $12 / 5h (rolling) · $30 / week (rolling) · $60 / month (rolling)  
**Source:** `https://opencode.ai/go` · `https://opencode.ai/docs/go/`  
**Live Catalog:** `https://opencode.ai/zen/go/v1/models`  

---

## 🔑 Column Legend

| Column | Description |
|--------|-------------|
| **#** | Rank in current classification |
| **Model** | Model name |
| **Provider** | AI lab / company |
| **ID Config** | Full model ID for config (`opencode-go/<id>`) |
| **Context** | Context window (tokens) |
| **Output Max** | Maximum output tokens |
| **Multimodal** | Input modalities supported |
| **Req / 5h** | Estimated requests per 5-hour rolling window |
| **Req / week** | Estimated requests per week |
| **Req / month** | Estimated requests per month |
| **SWE-V** | SWE-Bench Verified (%) — real GitHub issues |
| **SWE-P** | SWE-Bench Pro (%) — complex engineering |
| **TB 2.0** | Terminal-Bench 2.0 (%) — shell/CLI tasks |
| **LCB** | LiveCodeBench (%) — coding without training contamination |
| **GPQA** | GPQA Diamond (%) — graduate-level science reasoning |
| **AIME** | AIME 2026 (%) — math olympiad |
| **GDPval** | GDPval-AA (Elo) — general agent tasks |
| **BrowseC** | BrowseComp (%) — web research/synthesis |
| **Tool %** | Tool calling success rate |
| **Notes** | Key strengths, weaknesses, and usage recommendations |

---

## 🏠 Table 1 — Daily Driver (Volume + Quality + Cost Efficiency)

**Criteria:** Best balance of request volume, coding quality, and cost efficiency for everyday use.

| # | Model | Provider | ID Config | Context | Output Max | Multimodal | Req / 5h | Req / week | Req / month | SWE-V | SWE-P | TB 2.0 | LCB | GPQA | AIME | GDPval | BrowseC | Tool % | Notes |
|---|--------|----------|-----------|---------|------------|------------|----------|-----------|------------|-------|-------|--------|-----|------|------|--------|---------|--------|-------|
| 1 | **MiniMax M2.5** | MiniMax | `minimax-m2.5` | 1M | 131K | ❌ Text | 6,300 | 15,900 | **31,800** | 80.2 | ~56 | ~65 | ~89 | ~89 | ~93 | 1495 | ~75 | 96% | 🏆 Best overall: 80.2% SWE-V, 31K req/month, 37% faster than M2.1. SOTA coding at unbeatable value. |
| 2 | **DeepSeek V4 Flash** | DeepSeek | `deepseek-v4-flash` | 1M | 131K | ❌ Text | **31,650** | **79,050** | **158,150** | 79.0 | ~57 | ~65 | 91.6 | 88.1 | 76.8 | ~88 | ~78 | 95% | ⚡ Volume king: 158K req/month, Flash Max ≈ Pro Max reasoning. Perfect for exploration, quick fixes, RAG. |
| 3 | **MiniMax M2.7** | MiniMax | `minimax-m2.7` | 1M | 131K | ❌ Text | 3,400 | 8,500 | 17,000 | ~81 | ~56 | ~66 | ~90 | ~90 | ~94 | 1520 | ~76 | 97% | 🧠 Next-gen M2.5: self-evolution, Agent Teams, SRE recovery <3min. Use for complex debugging. |
| 4 | **Qwen3.5 Plus** | Alibaba | `qwen3.5-plus` | 1M | 66K | ❌ Text | 10,200 | 25,200 | **50,500** | ~78 | ~54 | ~63 | ~88 | ~87 | ~92 | 1480 | ~74 | 95% | 💰 Best value after Flash/MiMo: 50K req/month, excellent general coding. Daily workhorse. |
| 5 | **Kimi K2.5** | Moonshot | `kimi-k2.5` | 262K | 66K | ✅ Text+Image | 1,850 | 4,630 | 9,250 | 76.8 | 50.7 | 50.8 | 85.0 | 87.6 | 96.1 | 1470 | 74.9 | 96% | 🐝 Agent Swarm (100 agents), vision, frontend dev. 256K ctx. Use for multi-agent workflows. |
| 6 | **MiMo-V2.5** | Xiaomi | `mimo-v2.5` | 1M | 131K | ✅ **Text+Img+Audio+Video** | 30,100 | 75,200 | **150,400** | ~78 | ~55 | ~62 | ~74 | ~88 | ~93 | 1485 | ~72 | 95% | 🌐 Full multimodal (audio/video!), 150K req/month. Use for image/video analysis tasks. |
| 7 | **Qwen3.6 Plus** | Alibaba | `qwen3.6-plus` | 1M | 66K | ✅ Text+Image+Video | 3,300 | 8,200 | 16,300 | ~79 | ~56 | ~65 | ~89 | ~88 | ~93 | 1490 | ~75 | 96% | 📦 Multimodal + 1M ctx. Better than 3.5 Plus for vision tasks. Solid all-rounder. |
| 8 | **DeepSeek V4 Pro** | DeepSeek | `deepseek-v4-pro` | 1M | 131K | ❌ Text | 3,450 | 8,550 | 17,150 | 80.6 | ~58 | 67.9 | **93.5** | 90.1 | 85.6 | ~90 | ~80 | 97% | 🎯 Knowledge leader (GPQA 90.1), SWE-V 80.6%. Use for deep debugging, complex architecture. |
| 9 | **MiMo-V2.5-Pro** | Xiaomi | `mimo-v2.5-pro` | 1M | 131K | ✅ **Text+Img+Audio+Video** | 3,250 | 8,150 | 16,300 | 78.9 | 57.2 | **68.4** | ~74 | ~90 | ~95 | **1581** | ~76 | 97% | 🏗️ Engineering beast: compiler in 4.3h (672 tool calls), 40-60% fewer tokens than Opus. |
| 10 | **Kimi K2.6** | Moonshot | `kimi-k2.6` | 262K | 66K | ✅ Text+Image | 1,150 | 2,880 | 5,750 | 80.2 | **58.6** | 66.7 | 89.6 | 90.5 | **96.4** | 1510 | **83.2** | **96.6%** | 🛠️ Tool calling elite (96.6%), 13h autonomy (4000+ calls). Use for intensive agent workflows. |
| 11 | **Qwen3.7 Max** | Alibaba | `qwen3.7-max` | 1M | 64K | ❌ Text | 950 | 2,390 | 4,770 | 80.4 | **60.6** | **69.7** | 91.6 | **92.4** | ~96 | **1546** | ~86 | 97% | 🔥 New king: 35h autonomy (1158 calls), 10x speed, TB 2.0 leader. Expensive — use strategically. |
| 12 | **GLM-5** | Zhipu | `glm-5` | 200K | 131K | ❌ Text | 1,150 | 2,880 | 5,750 | ~76 | ~52 | ~60 | ~86 | ~85 | ~90 | 1450 | ~70 | 94% | 📉 Lighter GLM-5.1, more requests. Solid reasoning, use when GLM-5.1 too expensive. |
| 13 | **GLM-5.1** | Zhipu | `glm-5.1` | 200K | 131K | ❌ Text | 880 | 2,150 | 4,300 | ~76 | ~52 | ~60 | ~86 | **86.2** | ~95 | 1470 | ~70 | 94% | 🧮 Math/science specialist (GPQA 86.2). Use only for pure reasoning tasks. |
| 14 | **Big Pickle** | OpenCode | `big-pickle` | 200K | 128K | ❌ Text | ~200* | ~500* | ~1000* | ~75 | ~50 | ~58 | ~85 | ~84 | ~92 | 1440 | ~68 | 93% | 🆓 FREE tier fallback. GLM-4.6 based. Use when Go credit exhausted. *free tier limits. |

---

## 🧠 Table 2 — Reasoning / Math / Science

**Criteria:** GPQA Diamond, AIME, MATH-500, SciCode, reasoning depth, scientific knowledge.

| # | Model | Provider | ID Config | Context | Output Max | Multimodal | Req / 5h | Req / week | Req / month | SWE-V | SWE-P | TB 2.0 | LCB | GPQA | AIME | GDPval | BrowseC | Tool % | Notes |
|---|--------|----------|-----------|---------|------------|------------|----------|-----------|------------|-------|-------|--------|-----|------|------|--------|---------|--------|-------|
| 1 | **Qwen3.7 Max** | Alibaba | `qwen3.7-max` | 1M | 64K | ❌ Text | 950 | 2,390 | 4,770 | 80.4 | 60.6 | 69.7 | 91.6 | **92.4** | ~96 | **1546** | ~86 | 97% | 🏆 GPQA leader (92.4), AIME ~96%, 35h autonomy. Best overall reasoning + coding combo. 10x speed vs prior gen. |
| 2 | **Kimi K2.6** | Moonshot | `kimi-k2.6` | 262K | 66K | ✅ Text+Image | 1,150 | 2,880 | 5,750 | 80.2 | 58.6 | 66.7 | 89.6 | 90.5 | **96.4** | 1510 | 83.2 | 96.6% | 🥈 Math olympiad king (AIME 96.4), GPQA 90.5. Tool calling 96.6%. Best for math + agent tasks. |
| 3 | **DeepSeek V4 Pro** | DeepSeek | `deepseek-v4-pro` | 1M | 131K | ❌ Text | 3,450 | 8,550 | 17,150 | 80.6 | ~58 | 67.9 | 93.5 | 90.1 | 85.6 | ~90 | ~80 | 97% | 🥉 Knowledge leader open-source (GPQA 90.1, LCB 93.5). 49B active params. Best for science-heavy tasks. |
| 4 | **MiMo-V2.5-Pro** | Xiaomi | `mimo-v2.5-pro` | 1M | 131K | ✅ Text+Img+Audio+Video | 3,250 | 8,150 | 16,300 | 78.9 | 57.2 | 68.4 | ~74 | ~90 | ~95 | 1581 | ~76 | 97% | 🧠 GDPval 1581 (highest), GPQA ~90. Compiler in 4.3h. Strong reasoning + engineering. |
| 5 | **MiniMax M2.7** | MiniMax | `minimax-m2.7` | 1M | 131K | ❌ Text | 3,400 | 8,500 | 17,000 | ~81 | ~56 | ~66 | ~90 | ~90 | ~94 | 1520 | ~76 | 97% | 📊 MLE Bench 66.6% medal, self-evolution. Strong across all reasoning benchmarks. |
| 6 | **DeepSeek V4 Flash** | DeepSeek | `deepseek-v4-flash` | 1M | 131K | ❌ Text | 31,650 | 79,050 | 158,150 | 79.0 | ~57 | ~65 | 91.6 | 88.1 | 76.8 | ~88 | ~78 | 95% | ⚡ Flash Max ≈ Pro Max on reasoning (AIME 76.8). 12x cheaper. Best volume/quality ratio. |
| 7 | **MiniMax M2.5** | MiniMax | `minimax-m2.5` | 1M | 131K | ❌ Text | 6,300 | 15,900 | 31,800 | 80.2 | ~56 | ~65 | ~89 | ~89 | ~93 | 1495 | ~75 | 96% | 📈 Balanced reasoning (GPQA ~89, AIME ~93). Best daily driver with strong reasoning. |
| 8 | **GLM-5.1** | Zhipu | `glm-5.1` | 200K | 131K | ❌ Text | 880 | 2,150 | 4,300 | ~76 | ~52 | ~60 | ~86 | 86.2 | ~95 | 1470 | ~70 | 94% | 🧮 Pure math specialist. GPQA 86.2, AIME ~95. Use only for math/science — too expensive for daily. |
| 9 | **Qwen3.6 Plus** | Alibaba | `qwen3.6-plus` | 1M | 66K | ✅ Text+Image+Video | 3,300 | 8,200 | 16,300 | ~79 | ~56 | ~65 | ~89 | ~88 | ~93 | 1490 | ~75 | 96% | 📦 Solid reasoning (GPQA ~88), multimodal. Good balance for science + vision tasks. |
| 10 | **Kimi K2.5** | Moonshot | `kimi-k2.5` | 262K | 66K | ✅ Text+Image | 1,850 | 4,630 | 9,250 | 76.8 | 50.7 | 50.8 | 85.0 | 87.6 | 96.1 | 1470 | 74.9 | 96% | 🔬 AIME 96.1, GPQA 87.6. Agent Swarm for research tasks. 256K ctx for long papers. |
| 11 | **GLM-5** | Zhipu | `glm-5` | 200K | 131K | ❌ Text | 1,150 | 2,880 | 5,750 | ~76 | ~52 | ~60 | ~86 | ~85 | ~90 | 1450 | ~70 | 94% | 📉 Lighter GLM-5.1. GPQA ~85. Use when GLM-5.1 too expensive but need reasoning. |
| 12 | **MiMo-V2.5** | Xiaomi | `mimo-v2.5` | 1M | 131K | ✅ Text+Img+Audio+Video | 30,100 | 75,200 | 150,400 | ~78 | ~55 | ~62 | ~74 | ~88 | ~93 | 1485 | ~72 | 95% | 🌐 Multimodal reasoning (audio/video). GPQA ~88. Use for multimodal science tasks. |
| 13 | **Qwen3.5 Plus** | Alibaba | `qwen3.5-plus` | 1M | 66K | ❌ Text | 10,200 | 25,200 | 50,500 | ~78 | ~54 | ~63 | ~88 | ~87 | ~92 | 1480 | ~74 | 95% | 💰 Volume reasoning (50K req/month). GPQA ~87. Best for high-volume science exploration. |
| 14 | **Big Pickle** | OpenCode | `big-pickle` | 200K | 128K | ❌ Text | ~200* | ~500* | ~1000* | ~75 | ~50 | ~58 | ~85 | ~84 | ~92 | 1440 | ~68 | 93% | 🆓 FREE fallback. GPQA ~84. Use when Go credit exhausted. *free tier limits. |

---

## 💻 Table 3 — Coding / SWE-Bench / Shell / AIOps

**Criteria:** SWE-Bench Verified, SWE-Pro, Terminal-Bench 2.0, LiveCodeBench, shell proficiency, AIOps capabilities.

| # | Model | Provider | ID Config | Context | Output Max | Multimodal | Req / 5h | Req / week | Req / month | SWE-V | SWE-P | TB 2.0 | LCB | GPQA | AIME | GDPval | BrowseC | Tool % | Notes |
|---|--------|----------|-----------|---------|------------|------------|----------|-----------|------------|-------|-------|--------|-----|------|------|--------|---------|--------|-------|
| 1 | **Qwen3.7 Max** | Alibaba | `qwen3.7-max` | 1M | 64K | ❌ Text | 950 | 2,390 | 4,770 | 80.4 | **60.6** | **69.7** | 91.6 | 92.4 | ~96 | 1546 | ~86 | 97% | 👑 Coding king: SWE-P 60.6, TB 2.0 69.7, 35h autonomy (1158 tool calls). Kernel optimization 10x speed. Best for AIOps/shell. |
| 2 | **MiniMax M2.5** | MiniMax | `minimax-m2.5` | 1M | 131K | ❌ Text | 6,300 | 15,900 | 31,800 | 80.2 | ~56 | ~65 | ~89 | ~89 | ~93 | 1495 | ~75 | 96% | 🏆 Best value: 80.2% SWE-V, 31K req/month. Full-stack (Web/iOS/Android/Server). Daily coding champion. |
| 3 | **DeepSeek V4 Pro** | DeepSeek | `deepseek-v4-pro` | 1M | 131K | ❌ Text | 3,450 | 8,550 | 17,150 | **80.6** | ~58 | 67.9 | **93.5** | 90.1 | 85.6 | ~90 | ~80 | 97% | 🎯 SWE-V leader (80.6), LCB 93.5. Knowledge + coding. Best for complex architecture, debugging. |
| 4 | **Kimi K2.6** | Moonshot | `kimi-k2.6` | 262K | 66K | ✅ Text+Image | 1,150 | 2,880 | 5,750 | 80.2 | 58.6 | 66.7 | 89.6 | 90.5 | 96.4 | 1510 | 83.2 | 96.6% | 🛠️ Tool calling 96.6%, 13h autonomy (4000+ calls). Financial engine optimization (185% throughput gain). |
| 5 | **MiniMax M2.7** | MiniMax | `minimax-m2.7` | 1M | 131K | ❌ Text | 3,400 | 8,500 | 17,000 | ~81 | ~56 | ~66 | ~90 | ~90 | ~94 | 1520 | ~76 | 97% | 🧠 Self-evolution, Agent Teams. Production incident recovery <3min. SRE-level decisions. |
| 6 | **MiMo-V2.5-Pro** | Xiaomi | `mimo-v2.5-pro` | 1M | 131K | ✅ Text+Img+Audio+Video | 3,250 | 8,150 | 16,300 | 78.9 | 57.2 | 68.4 | ~74 | ~90 | ~95 | 1581 | ~76 | 97% | 🏗️ Compiler (SysY, Rust) in 4.3h (672 calls), video editor 11.5h (1868 calls). Engineering systems beast. |
| 7 | **DeepSeek V4 Flash** | DeepSeek | `deepseek-v4-flash` | 1M | 131K | ❌ Text | 31,650 | 79,050 | 158,150 | 79.0 | ~57 | ~65 | 91.6 | 88.1 | 76.8 | ~88 | ~78 | 95% | ⚡ Volume coding: 158K req/month, LCB 91.6. Flash Max ≈ Pro Max. Best for exploration, quick fixes. |
| 8 | **Qwen3.6 Plus** | Alibaba | `qwen3.6-plus` | 1M | 66K | ✅ Text+Image+Video | 3,300 | 8,200 | 16,300 | ~79 | ~56 | ~65 | ~89 | ~88 | ~93 | 1490 | ~75 | 96% | 📦 Solid coding (SWE-V ~79), multimodal. 1M ctx for large repos. Good all-rounder. |
| 9 | **Kimi K2.5** | Moonshot | `kimi-k2.5` | 262K | 66K | ✅ Text+Image | 1,850 | 4,630 | 9,250 | 76.8 | 50.7 | 50.8 | 85.0 | 87.6 | 96.1 | 1470 | 74.9 | 96% | 🐝 Agent Swarm (100 agents), frontend dev, vision. Reconstruct website from video. 256K ctx. |
| 10 | **MiMo-V2.5** | Xiaomi | `mimo-v2.5` | 1M | 131K | ✅ Text+Img+Audio+Video | 30,100 | 75,200 | 150,400 | ~78 | ~55 | ~62 | ~74 | ~88 | ~93 | 1485 | ~72 | 95% | 🌐 Multimodal coding (150K req/month). Claw-Eval 62.3. Use for vision+code tasks. |
| 11 | **Qwen3.5 Plus** | Alibaba | `qwen3.5-plus` | 1M | 66K | ❌ Text | 10,200 | 25,200 | 50,500 | ~78 | ~54 | ~63 | ~88 | ~87 | ~92 | 1480 | ~74 | 95% | 💰 Volume coding (50K req/month). Solid general coding. Best for high-volume daily work. |
| 12 | **GLM-5** | Zhipu | `glm-5` | 200K | 131K | ❌ Text | 1,150 | 2,880 | 5,750 | ~76 | ~52 | ~60 | ~86 | ~85 | ~90 | 1450 | ~70 | 94% | 📉 Solid coding (SWE-V ~76). Use when better models too expensive. |
| 13 | **GLM-5.1** | Zhipu | `glm-5.1` | 200K | 131K | ❌ Text | 880 | 2,150 | 4,300 | ~76 | ~52 | ~60 | ~86 | 86.2 | ~95 | 1470 | ~70 | 94% | 🧮 Math-focused. Coding ~76%. Use only when math + coding needed together. |
| 14 | **Big Pickle** | OpenCode | `big-pickle` | 200K | 128K | ❌ Text | ~200* | ~500* | ~1000* | ~75 | ~50 | ~58 | ~85 | ~84 | ~92 | 1440 | ~68 | 93% | 🆓 FREE fallback. GLM-4.6 based. SWE-V ~75%. Use when Go credit exhausted. *free tier limits. |

---

## 📊 Quick Reference — Best by Category

| Category | #1 Pick | Model ID | Why |
|----------|---------|----------|-----|
| **Daily Driver** | MiniMax M2.5 | `opencode-go/minimax-m2.5` | 80.2% SWE-V, 31K req/month, best value |
| **Volume King** | DeepSeek V4 Flash | `opencode-go/deepseek-v4-flash` | 158K req/month, Flash Max ≈ Pro Max |
| **Reasoning / Math** | Qwen3.7 Max | `opencode-go/qwen3.7-max` | GPQA 92.4, AIME ~96%, 35h autonomy |
| **Coding / SWE** | Qwen3.7 Max | `opencode-go/qwen3.7-max` | SWE-P 60.6, TB 2.0 69.7, shell king |
| **AIOps / Shell** | Qwen3.7 Max | `opencode-go/qwen3.7-max` | 35h, 1158 tool calls, kernel opt 10x |
| **Tool Calling** | Kimi K2.6 | `opencode-go/kimi-k2.6` | 96.6% success, 13h, 4000+ calls |
| **Multimodal** | MiMo-V2.5 | `opencode-go/mimo-v2.5` | Text+Image+Audio+Video, 150K req/month |
| **Engineering Systems** | MiMo-V2.5-Pro | `opencode-go/mimo-v2.5-pro` | Compiler 4.3h, video editor 11.5h |
| **Multi-Agent** | Kimi K2.5 | `opencode-go/kimi-k2.5` | Agent Swarm (100 agents), vision |
| **SRE / Production** | MiniMax M2.7 | `opencode-go/minimax-m2.7` | Incident recovery <3min, Agent Teams |
| **Science / Knowledge** | DeepSeek V4 Pro | `opencode-go/deepseek-v4-pro` | GPQA 90.1, LCB 93.5, 49B active |
| **Budget Math** | GLM-5.1 | `opencode-go/glm-5.1` | GPQA 86.2, AIME ~95% (expensive) |
| **Free Fallback** | Big Pickle | `opencode/big-pickle` | FREE, GLM-4.6 based, 200K ctx |

---

## ⚠️ Critical Notes

### Documentation Discrepancies
- `dev.opencode.ai/docs/go/` is **OUTDATED** — shows old MiMo-V2.5 numbers (2,150 req/5h vs actual 30,100) and missing Qwen3.7 Max
- **Source of truth:** `opencode.ai/go` and `opencode.ai/docs/go/` (live version)
- **Live catalog:** `https://opencode.ai/zen/go/v1/models`

### Credit Mechanics
- **Three rolling windows:** $12/5h · $30/week · $60/month
- **Shared bucket:** Using one model reduces credit available for ALL others
- **Cheapest models:** DeepSeek V4 Flash, MiMo-V2.5, Qwen3.5 Plus (use for 80% of work)
- **Most expensive:** Qwen3.7 Max, GLM-5.1, Kimi K2.6 (use strategically)
- **Fallback:** When Go credit exhausted → free models (Big Pickle, etc.) or Zen balance

### Multimodal Summary
| Model | Text | Image | Audio | Video |
|-------|------|-------|-------|-------|
| MiMo-V2.5 | ✅ | ✅ | ✅ | ✅ |
| MiMo-V2.5-Pro | ✅ | ✅ | ✅ | ✅ |
| Qwen3.6 Plus | ✅ | ✅ | ❌ | ✅ |
| Kimi K2.5 | ✅ | ✅ | ❌ | ❌ |
| Kimi K2.6 | ✅ | ✅ | ❌ | ❌ |
| All others | ✅ | ❌ | ❌ | ❌ |

---

## 🔗 Related

- **OpenCode Go Official:** `https://opencode.ai/go`
- **Go Docs:** `https://opencode.ai/docs/go/`
- **Zen (pay-per-use):** `https://opencode.ai/docs/zen/`
- **Console (usage tracking):** `https://opencode.ai/console`
- **Live Model Catalog:** `https://opencode.ai/zen/go/v1/models`

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-28 | [OPENCODE] | v1.0.0 — Initial creation: 3 classification tables (Daily, Reasoning, Coding), all 14 models, complete benchmark data, multimodal matrix, credit mechanics explained |

---

**File:** `$HOME/.agents/skills/k-opencode/references/GO.md`  
**Symlink:** `~/KpihX-Labs/G0.md` → `~/.agents/skills/k-opencode/references/GO.md`

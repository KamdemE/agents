# GPU Inference Backend Benchmark — Intel Arc iGPU

Comparison shared by the user (original source document not located in this filesystem at time of writing — re-link if found) of three local LLM serving backends on the same Intel Arc iGPU hardware (this workstation, Intel Core Ultra 7 155H):

| Backend | Install | tok/s | Wall time | Load time |
|---------|---------|-------|-----------|-----------|
| IPEX-LLM (SYCL) — existing, port 11434 | already present | 30.73 | 13.72s | 3.02s |
| Vulkan (Ollama official 0.33.1) — new, port 11435 | `~/.local/ollama-vulkan/` | 13.57 | 27.47s | 5.19s |
| **OpenVINO GenAI 2026.3.1 (GPU)** — new, `/tmp/openvino-test/` | `uv venv + optimum-intel[openvino]` | **🏆 81.50** | **3.68s** | **2.33s** |

**OpenVINO wins decisively — 2.65x faster than IPEX-LLM, 6x faster than Vulkan.** Matches independent web research findings at the time ("OpenVINO increasingly recommended... outperforming Vulkan").

## Context

This benchmark predates/motivated the decision to build the sovereign `k_openvino` FastAPI server (see `k-openvino/SKILL.md`) instead of continuing to route local inference through Ollama (`k-ollama`) on this hardware. The performance advantage did NOT come at the cost of control or transparency — quite the opposite: building a custom OpenAI-compatible server on top of OpenVINO gave full visibility into the tool-calling/reasoning protocol (see `references/tool-calling-protocol.md`), which a black-box runtime (Ollama) never exposed, and which was the actual root cause of tool-calling failures previously misattributed to "model too small."

See also `k-ollama` (generic Ollama operations, comparison baseline) and `k-ubuntu` → `references/ollama-igpu.md` (Intel Arc iGPU tuning for Ollama specifically).
</content>

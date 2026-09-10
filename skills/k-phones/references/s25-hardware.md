# Samsung Galaxy S25 — Hardware & Compute Profile (`kpihx-s25`)

> **Device:** Samsung **SM-S938B** (Galaxy S25 line, international variant)  
> **Tailscale:** `kpihx-s25` · `100.125.54.1` · MagicDNS `kpihx-s25.tail2527bd.ts.net`  
> **Last inventory:** 2026-05-26 (ADB + Termux SSH on workstation)

Source of truth for agents deciding what the phone can run locally vs what must stay on **workstation** or homelab.

---

## Identity & software

| Field | Value |
|-------|--------|
| Retail model | `SM-S938B` |
| Internal device | `pa3q` |
| Board / platform | `sun` (Qualcomm) |
| SoC | **Snapdragon 8 Elite** — `SM8750` (QTI) |
| Android | **16** (API **36**) |
| Security patch | 2026-05-05 |
| Build | `BP4A.251205.006` |
| ABI | `arm64-v8a` |
| Termux (Play) | `googleplay.2026.02.11` · targetSdk 36 |
| Root | **No** (retail) — no `/data/data/<app>/` via ADB without `run-as` |

---

## CPU

| Spec | Detail |
|------|--------|
| Logical CPUs (OS) | **8** (ARM64, Qualcomm implementer `0x51`) |
| Max frequency (cpu0) | **~3.53 GHz** (3 532 800 kHz) |
| ISA highlights | AES, SHA3, **bf16**, **i8mm** — useful for ML kernels on ARM |
| **Termux `nproc`** | **4** — Android often caps the Termux app to a subset of cores |

**Implication:** batch jobs in Termux see **4 threads**, not the full 8-core SoC.

---

## GPU & AI accelerators

| Block | Detail |
|-------|--------|
| GPU | **Qualcomm Adreno 830** (freq tiers up to ~1.1 GHz) |
| Hexagon / NPU | Present on SoC — used by **system apps** (Galaxy AI, camera, etc.) |
| Termux access | **No** stable public NPU API from Termux — not comparable to Intel Arc + Ollama on PC |

---

## Memory & swap

| Layer | Total | Notes (2026-05-26) |
|-------|-------|----------------------|
| Android RAM | **~11.0 GiB** (`MemTotal` 11 379 972 kB) | ~5.0 GiB `MemAvailable` (system-wide) |
| Termux view (`free -h`) | **10 Gi** total | ~5.0 Gi available · **swap 11 Gi** (often **4–5 Gi used**) |
| Heap (Dalvik) | `dalvik.vm.heapsize` **512m** | app JVM limit, not Termux RAM |

**Implication:** heavy workloads + LLM weights → **swap churn**, heat, and battery drain. Prefer **short** jobs on device.

---

## Storage

| Mount | Size | Used | Free | Use % |
|-------|------|------|------|-------|
| `/data` (user) | **456 GiB** | ~149 GiB | ~307 GiB | ~33% |

Shared storage path for agents: **`/sdcard`** → Termux `~/storage/` after `termux-setup-storage`.

**Telegram (app data, public tree):**  
`/sdcard/Android/data/org.telegram.messenger/files/Telegram/`  
(Images / Video / Documents / Files / cache — purge/backup via ADB; see session 2026-05-26 backup under `$HOME/Downloads/tmp/telegram-s25-backup-20260526/` on workstation.)

---

## Display

| Spec | Value |
|------|--------|
| Logical size (`wm size`) | **1080 × 2340** |
| Density | **450 dpi** |

Panel may be higher resolution physically; Android reports a scaled logical size.

---

## Battery (typical snapshot)

| Field | Value |
|-------|--------|
| Technology | Li-ion |
| Health | Good (`health: 2`) |
| Level | varies (e.g. ~83% when sampled) |
| Temperature | ~30–35 °C under light ADB/SSH load |

Long compute sessions on battery → expect **fast drain** and thermal throttling.

---

## Remote access ( stack)

| Channel | Endpoint | Role |
|---------|----------|------|
| **SSH** | `ssh s25` → Termux `:8022` | Full Linux userland (Python, git, tmux, scripts) |
| **ADB** | `adb connect 100.125.54.1:<DEBUG_PORT>` | Apps, `/sdcard`, logcat, maintenance — **not** Termux home |
| **Tailscale** | Android app `com.tailscale.ipn` | Mesh IP; Termux has **no** `tailscale` CLI package |

Runbooks: `adb.md`, `s25-adb-vs-ssh.md`, `s25-termux-sshd.md`, `termux-tmux.md`, `phone-to-ubuntu.md`.

---

## Termux toolchain (deployed)

| Tool | Status |
|------|--------|
| **tmux** | **3.6b** (Ctrl-a, resurrect / continuum — see `termux-tmux.md`) |
| **Python** | 3.12 + pip |
| **clang** | installed |
| **git** | installed |
| **openssh** | client + `sshd` |
| **Packages** | ~114 (`pkg list-installed`) |
| **proot-distro** | not in use (no guest distro listed) |
| **llama.cpp / Ollama** | not installed by default |

**Phone → PC:** Termux alias `ubuntu` → `tmux attach -t default` on **workstation** (PC session, not Termux server).

---

## What the S25 is good for (agent routing)

| Workload | On S25? | Preferred path |
|----------|---------|----------------|
| tmux sessions (local) | ✅ Yes | `ssh s25` → `tmux` |
| Shell / Python automation | ✅ Yes | Termux; keep jobs **&lt; ~30 min** |
| Sync, bots, capture relays | ✅ Yes | `k-tg`, Termux, Tailscale |
| ADB file pull/push | ✅ Yes | raw `adb push` / `adb pull` |
| Numeric / data crunch (medium) | ⚠️ Limited | 4 threads, swap, thermals |
| **LLM inference (comfortable)** | 🔴 No | **workstation** Ollama IPEX (`127.0.0.1:11434`) or homelab |
| **LLM inference (experimental)** | ⚠️ Tiny only | llama.cpp + **1–3B** Q4 GGUF; high latency |
| NPU / Hexagon ML | 🔴 Not from Termux | System apps / Qualcomm SDK only |
| Heavy training / large models | 🔴 No | Workstation or cloud |

**Recommended pattern:**

```
S25 (Termux/ADB)  ──Tailscale──►  workstation
  sensors · bots · light scripts      Ollama · agents · big compute
```

Call Ollama on PC from Termux when IPEX is up:

```bash
curl -s http://100.82.95.70:11434/api/tags   # example; verify IP + firewall
```

---

## Comparison vs workstation (orientation)

| | **S25** | **workstation** |
|---|---------|------------------------------|
| SoC | Snapdragon 8 Elite | Intel Core Ultra 7 **155H** |
| RAM | ~11 GiB | **30 GiB** |
| GPU / ML | Adreno 830; NPU closed to Termux | Intel **Arc** + **NPU** (`/dev/accel0`); **Ollama IPEX** |
| Architecture | **arm64** | **x86_64** |
| Best for | Mobile node, capture, light compute | Primary dev + inference |

---

## Refreshing this document

Re-run inventory from workstation when hardware or Termux stack changes:

```bash
adb devices -l
adb -s 100.125.54.1:<DEBUG_PORT> shell getprop ro.product.model ro.soc.model ro.build.version.release
adb -s 100.125.54.1:<DEBUG_PORT> shell "nproc; cat /proc/meminfo | head -3; cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
ssh s25 'uname -m; nproc; free -h; tmux -V; pkg list-installed | wc -l'
```

Update **Last inventory** date and bump `k-phones` `SKILL.md` changelog if facts changed.

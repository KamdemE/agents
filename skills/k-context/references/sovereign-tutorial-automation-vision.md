# Sovereign tutorial automation — vision (phone → PC → agents)

Status: **BRAINSTORM** (2026-05-25)  
Owner stack: Termux · Tailscale · `ssh s25` / `ubuntu` · tmux · CLI (`gws`, `m365`, `tg`, homelab MCPs) · local agents (`agent`, Codex, etc.)

## Problem

KπX builds a **sovereign control plane** (phone drives the PC, CLIs beat narrow MCPs, no Cloud-dispatch-style subscriptions). Explaining it on camera (face + live clicks) is high friction; evolution work should stay primary.

Goal: **repeatable, high-quality tutorials** — articles *and especially video* — generated or assembled by agents with minimal human screen time.

## What is already extraordinary (message)

| Layer | What we proved |
|-------|----------------|
| **Phone → PC** | Termux + Tailscale + `ubuntu` → PC tmux `default` + full shell |
| **Agents** | Same CLIs as desktop, launched from phone, no vendor UI lock-in |
| **Integrations** | Meta, LinkedIn, WhatsApp, X, mail, TickTick — homelab + `gws` / `m365` / custom MCPs |
| **Cost model** | Tailscale + Termux + self-hosted — not per-seat cloud agent dispatch |

MCPs remain useful but **narrow** (general-public scope, provider subscriptions). **CLIs + SSH** are the tutorial hero.

## Automation tiers

| Tier | Output | Human time | Automatability |
|------|--------|------------|----------------|
| **A — Article** | Docsify / techskills / GitHub Pages | Low | **High** — agent writes MD from session log + QMD |
| **B — Visual static** | Napkin SVG, PPTX (`k-pptx`) | Low | **High** — text → diagram |
| **C — Terminal cinema** | MP4/GIF of real commands | Medium | **High** — scripted terminal (no facecam) |
| **D — Composed video** | Branded explainer (voice + motion) | Medium | **Medium** — Remotion + TTS + clips |
| **E — Publish** | YouTube / X / LinkedIn | Low | **Medium** — `k-media`, APIs |

**Do not start with E.** Prove **C → A → D** on one story (e.g. `ssh s25` → `ubuntu` → `agent -p`).

## Video without “KπX in front of the screen”

Avoid primary reliance on OBS + manual clicks.

| Technique | Tool | Best for |
|-----------|------|----------|
| **Scripted terminal recording** | [VHS](https://github.com/charmbracelet/vhs) (`.tape` files), asciinema | SSH, tmux, CLI demos — reproducible, stylable |
| **Programmatic motion** | Remotion (React) | Intros, diagrams, captions, chapter cards |
| **Voice** | `edge-tts` (already in masterclass notes), or cloud TTS if allowed | Narration without recording mic |
| **Diagrams** | `k-napkin` | Architecture slides inserted between terminal acts |
| **Optional B-roll** | Homelab WebTop / Edge CDP headless | Only when DOM demo is required — not default |

**Pipeline shape:**

```text
Storyboard (MD/YAML, agent-authored)
    → vhs tape run (terminal truth)
    → Remotion compose (brand, chapters, napkin assets, TTS)
    → ffmpeg finalize (1080p60, captions)
    → k-media publish (optional)
```

Human role: **approve storyboard + voice script**, not operate the UI per frame.

## Repo / skill anchors (existing)

| Asset | Path / skill |
|-------|----------------|
| Code-first video experiment | `linux-file-masterclass` (k-context Active Projects) — Remotion + D3 + edge-tts |
| Visual AI brainstorm | `k-context/references/vision/visual-ai-vision.md` |
| Homelab written tutos | `$HOME/Work/KpihX-Labs/Homelab/presentation/tutos_live/` |
| Ubuntu articles | `$HOME/Work/techskills/` |
| Docs sites | `k-git-pages` |
| Infographics | `k-napkin` |
| Social publish | `k-media`, `k-x`, `k-meta` |

New work should **extend** `linux-file-masterclass` or a sibling repo `sovereign-tutorials/` — not duplicate Remotion setup.

## First canonical tutorial (MVP)

**Title:** *Control your PC agents from your phone (no subscription dispatch)*  

**Acts (60–90 s):**

1. Phone Termux — Tailscale connected (static diagram, not face).
2. `vhs`: `ssh s25` → shell on phone user.
3. `vhs`: `ubuntu` → PC tmux attach (split pane optional).
4. `vhs`: `agent -p "summarize inbox"` or `gws`/`m365` one-liner (pick one CLI we own).
5. Napkin: stack diagram (phone → TS → PC → CLI).
6. Outro card: links to homelab docs.

**Artifacts:** `article.md` (Docsify), `demo.tape`, `out.mp4`, optional Short.

## Agent roles (division of labor)

| Agent task | Input | Output |
|------------|-------|--------|
| **Architect** | Brainstorm + k-phones / k-workspace facts | `storyboard.md` |
| **Scripter** | storyboard | `*.tape` (VHS), test commands in tmux |
| **Renderer** | tape + assets | terminal MP4 |
| **Composer** | Remotion project | final MP4 |
| **Publisher** | final + metadata | techskills article + YouTube draft (`k-media`) |

KπX: **review script**, **approve export**, no live recording.

## Quality bar

- 1080p, readable font (JetBrains Mono), dark theme aligned with KπX IDE palette.
- Captions burned-in (FR/EN) from script, not whisper-of-random-audio.
- Commands must be **copy-paste true** (run in CI or `make demo-verify` where possible).
- No real secrets in tapes (placeholders, `bw-env` mentioned not shown).

## Risks

| Risk | Mitigation |
|------|------------|
| VHS/terminal fonts differ phone vs PC | Record **PC side** in tape; phone segment = diagram only |
| Stale ports (ADB, wireless debug) | Storyboard uses **stable** paths: `ssh s25`, Tailscale IPs |
| MCP-only demos break | Prefer **CLI** in tutorials |
| Over-production before story | Ship **one** 60 s VHS clip before full Remotion |

## Phases

| Phase | Deliverable | When |
|-------|-------------|------|
| **0** | This vision + 1 storyboard | Now |
| **1** | `demo.tape` + raw terminal MP4 | 1 session |
| **2** | Article in `techskills` + homelab presentation link | Same week |
| **3** | Remotion wrapper + TTS | After MVP clip validated |
| **4** | Catalog: mail, WhatsApp, X, homelab MCP vs CLI series | Ongoing |

## Open decisions (KπX)

1. **Language:** FR narration, EN captions, or bilingual series?
2. **Channel:** YouTube `@KPIHX7` first vs homelab-only unlisted?
3. **Repo:** extend `linux-file-masterclass` vs new `sovereign-tutorials`?
4. **Face/voice:** TTS-only vs occasional real voice for brand?

## Next action (on `go`)

1. Install `vhs` on Ubuntu (`brew`/`go install` per upstream).
2. Add `tutorials/phone-to-pc-agents/demo.tape` under chosen repo.
3. Agent generates article from same `storyboard.md` → `techskills` + QMD index.

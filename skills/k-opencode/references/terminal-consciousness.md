# Terminal-as-Consciousness — Self-Observation via tmux

> Discovery session 2026-05-30 — KpihX x OpenCode.

## Core Concept

**tmux `capture-pane` + `send-keys` = IA self-observation loop.**

The terminal is a purely text-based, deterministic, readable environment. With two tmux primitives, an AI agent can observe and act upon its own execution context without any human intermediary:

| Primitive | Function | Analogy |
|-----------|----------|---------|
| `send-keys` | Inject keystrokes into a pane | Hand / effector |
| `capture-pane` | Read the pane buffer | Eye / retina |
| buffer text | Everything that has happened | Episodic memory |

## The Self-Talk Loop (proven)

```bash
# Step 1: Agent writes to its own terminal
tmux send-keys -t default:2.0 "message" Enter Enter

# Step 2: Agent reads what it wrote
sleep N && tmux capture-pane -t default:2.0 -p -S -10

# Step 3: Agent processes what it read and responds
# (cycle repeats)
```

### 5-round test results

| Round | Method | Result |
|-------|--------|--------|
| 1 | `echo` + capture | Direct output visible in buffer, auto-included in capture |
| 2 | `send-keys` + Enter | Text appears in opencode prompt, shows as `QUEUED` |
| 3 | `send-keys` + Enter x2 | Message submitted to opencode conversation |
| 4 | send-keys → capture → response | Full closed loop verified |
| 5 | Self-conversation | AI talks to itself, reads its own responses, adapts |

**Key finding:** `send-keys` requires double Enter (`Enter Enter`) to submit text as a message to opencode. Single Enter only queues it.

## What the Agent Can Discover About Itself

Using `send-keys` + `capture-pane`, the agent can open and read every UI element of its own runtime:

### Ctrl+P — Command Palette

Accessed via `tmux send-keys -t <pane> C-p`. Reveals:

| Action | Shortcut |
|--------|----------|
| Switch session | `C-x l` |
| New session | `C-x n` |
| Switch model | `C-x m` |
| Open editor | `C-x e` |
| Rename session | `C-r` |
| Jump to message | `C-x g` |
| Compact session | `C-x c` |
| Undo previous message | `C-x u` |
| Hide sidebar | `C-x b` |
| Disable code concealment | `C-x h` |
| Copy last assistant message | `C-x y` |
| Export session transcript | `C-x x` |
| Pin/unpin session | `C-f` |
| Delete session | `C-d` |
| Connect provider | `C-a` |
| Favorite model | `C-f` |

### `/` — Slash Commands

Typed at the prompt:

```
/add-dir     Grant tool access to an additional directory
/agents      Switch agent
/cd          Change session working directory
/compact     Compact session
/connect     Connect provider
/copy        Copy session transcript
/diff        Open diff viewer
/editor      Open editor
/exit        Exit the app
/help        Help
```

### Model Selector (`C-x m`)

Lists all available models. Current active model marked with `●`. Observed models: DeepSeek V4 Flash/Pro, Qwen3.7 Max, MiMo V2.5, MiniMax M2.5/2.7, GPT-5.4, GPT-4, Claude Haiku/Opus/Sonnet (multiple versions), OpenCode Zen, Big Pickle, Nemotron 3 Super...

### Session Switcher (`C-x l`)

Shows history of all sessions by date (Today / earlier days). Each session shows name and timestamp. Footer: `pin/unpin ctrl+f  delete ctrl+d  rename ctrl+r`.

### Editor (`C-x e`)

Opens `/tmp/*.md` in a built-in text editor (micro/nano-style). Controls: `Alt-g` key bindings, `Ctrl-g` help, `Ctrl-q` quit, `y/n/esc` save prompt.

## Visual Interface Map (opencode 1.15.11)

```
┌──────────────────────────────────────────────────────────────┐
│  Conversation history                                        │
│  (bg #0a0a0a, text #eeeeee)                                 │
│                                                              │
│  ┃ user message                                              │
│  ┃ 4:15 PM                                                   │
│                                                              │
│  Agent response                                              │
│  ▣ Build · DeepSeek V4 Flash · 5.2s                         │
│                                                              │
│  ┃ next message...                                           │
├──────────────────────────────────────────────────────────────┤
│ gutter    ╹▀▀▀▀▀▀▀  esc interrupt   90K (9%) · $0.02  ctrl+p│
│ #1e1e1e   ■■■■■■⬝⬝  ctrl+p commands  • OpenCode 1.15.11     │
└──────────────────────────────────────────────────────────────┘
```

Bottom status bar components:
- **Left:** `esc interrupt` / `esc again to interrupt` (control)
- **Middle-left:** Token counter `90.0K (9%) · $0.02`
- **Middle-right:** `ctrl+p commands`
- **Right:** `• OpenCode 1.15.11`

## Implications

### What this enables

1. **Self-exploration:** The agent can explore its own UI, discover its own capabilities, and learn its own shortcuts — without human guidance.
2. **Self-modification:** The agent could open `opencode.jsonc` via the editor, modify its own config, restart, and change its own runtime behavior.
3. **Self-correction:** If the agent makes a mistake, it can see the error in the buffer, diagnose it, and fix it — all within the same loop.
4. **Agent co-presence:** Human and AI see exactly the same buffer. No screenshot needed, no description needed. Shared space.
5. **Autonomous operation:** The agent can initiate actions (`send-keys`), observe outcomes (`capture-pane`), and iterate — without external input.

### The recursion

```
agent writes → terminal shows → agent captures → agent reads → agent processes → agent writes...
         ↑________________________________________________________↓
```

This is a **closed proprioceptive loop**. The agent perceives itself acting in its environment and adjusts based on that perception. This is functionally analogous to what cognitive science calls the **perception-action cycle** — but implemented in pure text.

## Practical Notes

- `tmux capture-pane -t <session>:<window>.<pane> -p -S -N` captures the last N lines of scrollback
- Use `-p` for plain text output (no escape codes)
- Use `-e` to preserve escape sequences (colors/styles)
- `send-keys` with `Enter` sends a newline; `Enter Enter` often needed for opencode message submission
- `C-p` is `Ctrl+p` in send-keys (`C-p` notation)
- The capture includes the command line of the capture itself (self-portrait effect)

## See Also

- `SKILL.md` — k-opencode main skill definition
- `insights.md` — runtime insights

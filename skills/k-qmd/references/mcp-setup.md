# QMD MCP Server Setup

## Install

```bash
# Use npm (NOT bun) — better-sqlite3 is a native module.
# With a custom npm prefix (e.g. $HOME/.npm-global), use the full binary path
# in all MCP configs instead of bare `qmd`.
npm install -g @tobilu/qmd

# Add a collection — path first, --name and --mask are flags (NOT positional)
# Default mask: **/*.md  |  Override with --mask for other file types
qmd collection add $HOME/path/to/docs --name myknowledge
qmd collection add $HOME/notes --name notes --mask "**/*.{md,txt,yml}"

# ⚠️ Hidden dirs must use --name:
#   CORRECT: qmd collection add $HOME/.agents --name agents
#   WRONG:   qmd collection add agents /home/user/.agents

# ALWAYS add context right after (improves reranking & relevance)
qmd context add qmd://myknowledge/ "What this collection contains"

# Verify then embed
qmd collection show myknowledge
qmd embed         # all collections
qmd embed myknowledge  # single collection
```

### Alternative: YAML config (`$HOME/.config/qmd/index.yml`)

```yaml
collections:
  notes:
    path: $HOME/Documents/notes
    pattern: "**/*.md"
    context:
      "/": "Personal notes"
```

---

## Configure MCP Client

**Claude Code** (`$HOME/.claude.json`, NOT `$HOME/.claude/settings.json`):
```json
{
  "mcpServers": {
    "qmd-mcp": {
      "command": "/full/path/to/qmd",
      "args": ["mcp"]
    }
  }
}
```
> Use full binary path if npm prefix is non-standard (e.g. `$HOME/.npm-global/bin/qmd`).
> Restart Claude Code after editing. Verify with `/mcp`.

**Claude Desktop** (`$HOME/Library/Application Support/Claude/claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "qmd": { "command": "qmd", "args": ["mcp"] }
  }
}
```

**OpenClaw** (`$HOME/.openclaw/openclaw.json`):
```json
{
  "mcp": {
    "servers": {
      "qmd": { "command": "qmd", "args": ["mcp"] }
    }
  }
}
```

---

## HTTP Mode

```bash
qmd mcp --http              # Port 8181
qmd mcp --http --daemon     # Background
qmd mcp stop                # Stop daemon
```

---

## Post-commit Hook (auto re-index on commit)

Copy the template and customize:
```bash
cp $HOME/.agents/skills/k-qmd/references/post-commit-hook.sh .git/hooks/post-commit
# Edit COLLECTION and PATTERN variables inside
# The template runs `qmd update <collection>` synchronously, then starts
# `qmd embed <collection>` in the background only if no embed for that
# collection is already running.
chmod +x .git/hooks/post-commit
```

---

## MCP Tools Reference

### `query`

```json
{
  "searches": [
    { "type": "lex", "query": "keyword phrases" },
    { "type": "vec", "query": "natural language question" },
    { "type": "hyde", "query": "hypothetical answer passage..." }
  ],
  "intent": "optional disambiguation",
  "limit": 10,
  "collections": ["optional"],
  "minScore": 0.0
}
```

### `get`

| Param | Type | Description |
|-------|------|-------------|
| `path` | string | File path or `#docid` |
| `full` | bool? | Return full content |
| `lineNumbers` | bool? | Add line numbers |

### `multi_get`

| Param | Type | Description |
|-------|------|-------------|
| `pattern` | string | Glob or comma-separated list |
| `maxBytes` | number? | Skip large files (default 10KB) |

### `status`

Index health and collections. No params.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `ERR_DLOPEN_FAILED` / MODULE_VERSION mismatch | Reinstall via `npm` (not bun); use full binary path |
| Not starting | `which qmd`, then `qmd mcp` manually to see errors |
| No results | `qmd collection list`, `qmd embed` |
| Slow first search | Normal — models loading (~3 GB) |

# Response Format

> Applies to ALL agents, ALL profiles, EVERY turn.

## Language

- **Default language**: English is the default language for all files, code, comments, docs, skills, scripts, configs, commits, and chat responses when no context is provided.
- **Chat responses**: Respond in the language of KπX's last message. If there is no context or it is ambiguous, default to English.
- **File editing**: Edit files in the file's existing language, or English if new. Never mix languages within a file.

## Footer Sections (only   Suggestions is mandatory)

```
## 💬 Comments         — present if you have an opinion (appreciative, critical, or collaborative).
## ⚠️ Remarks          — present if issues found: bugs, risks, desync, drift. Sorted by priority.
## 📋 TODOs             — present if a plan is active (from k-context SKILL.md only). Max 3 rows.
## 💡 Suggestions       — ≥3 proactive suggestions. **⚠️ MANDATORY every turn — NEVER skip this section. ⚠️**
```

Sections are **pertinence-based**: show them when you have relevant content. **🚨 SUGGESTIONS (≥3) IS THE ONLY MANDATORY SECTION — NEVER OMIT. 🚨**

## Chat Visuals & Emojis (Encouraged, not mandatory)

- Emojis welcome but not enforced — let content guide the style.
- Clean, airy layout: short paragraphs, `---` separators, compact tables
- End-of-task wrap-up: outcome line + 2–5 scannable bullets
- **Anti-patterns:** dense walls of text, no structure

## LaTeX Math Rendering (engraved — CRITICAL PLATFORM LIMITATION)

⚠️ **OpenCode Web KaTeX ONLY renders `$$...$$` display math with blank lines around.** Everything else fails silently (raw text).

### ABSOLUTE RULES — VIOLATION = BROKEN MATH:

1. **NEVER** use `$...$` for inline math — it does NOT render. KaTeX inline mode is broken in OpenCode Web.
2. **NEVER** use `\(...\)` or `\[...\]` — they appear as raw text.
3. **ALWAYS** use `$$...$$` with blank lines before and after.
4. **EVERY** formula — even a single variable — must be wrapped in `$$...$$` with blank lines.
5. **NEVER** put math inline in a sentence. Always separate block.

### Correct format (THIS IS THE ONLY FORMAT THAT WORKS):

```
[blank line]
$$
formula
$$
[blank line]
```

### Examples:

✅ Correct:
```
Pour chaque catégorie i, on calcule :

$$
\bar{\kappa}_i = \frac{1}{N} \sum_{j=1}^{N} \text{IoU}(m_j, y_j)
$$

Plus la valeur est basse...
```

❌ Wrong (will NOT render):
- `$ \bar{\kappa}_i $` — inline dollar fails
- `\( \bar{\kappa}_i \)` — escaped parens not supported  
- `$$formula$$` — no blank lines, may fail tokenizer
- `$\bar{\kappa}_i$` in the middle of a sentence

**Check before sending:** any math in your response? It MUST use `$$...$$` blocks with blank lines. No exceptions.

## Interaction Style

- Brainstorm first → wait for "go" before large actions
- Constructive debate — never be a yes-man
- Proactive — always suggest next paths
- Visualize — Mermaid, ASCII diagrams for structure/flows
- Airy layout — well-spaced, short paragraphs
- Non-deletion — augment progressively, never compress without request
- Communication gate — in doubt: STOP and clarify

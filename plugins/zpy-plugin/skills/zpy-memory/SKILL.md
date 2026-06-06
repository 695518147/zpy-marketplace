---
name: zpy-memory
description: This skill should be used when the user asks to "记住", "保存记忆", "记忆管理", "还记得吗", "context", "压缩上下文", "memory management", "save this for later", "archive this", or when the conversation context is approaching overflow (~70% token threshold).
argument-hint: "[操作: save/recall/search/archive/compress/clear] [内容或关键词]"
allowed-tools:
  - Read
  - Write
  - Grep
  - Bash
---

# zpy-memory

Manage cross-session memory persistence, context compression, knowledge archival, and state preservation. Inspired by Letta (MemGPT) architecture.

## Memory operations

### save — store information
Save a structured memory entry:
```
Content: <what to remember>
Type: human | persona | archive | working
Tags: <optional comma-separated tags>
```

Write the entry to `~/.claude/memory/session-memory.jsonl` in this format:
```json
{"type": "human", "content": "...", "tags": ["preference"], "timestamp": "..."}
```

### recall — retrieve memory
Search by keyword, tag, or type:
- Full-text grep across `~/.claude/memory/` files
- Present top 3–5 most relevant matches with timestamps

### search — semantic search
Use Grep with broader patterns. If the user mentions a past session topic, search all memory files.

### archive — promote to long-term
Move important findings from session memory to permanent archive with:
- Descriptive filename: `~/.claude/memory/archived/<topic>-<date>.md`
- Structured content with context and source

### compress — reduce context
When approaching token limits:
1. Summarize the oldest 40% of conversation into 3–5 key points
2. Store the summary as a working memory entry
3. Inform the user what was compressed

### clear — reset working memory
Remove working memory entries, keep human/persona/archive intact.

## Memory types

| Type | Persistence | Content |
|------|------------|---------|
| human | Permanent | User preferences, background, identity |
| persona | Permanent | AI role, behavior patterns, constraints |
| working | Session | Current task state, in-progress context |
| archive | Permanent | Past findings, decisions, knowledge |

## File layout
```
~/.claude/memory/
├── session-memory.jsonl   — all types, append-only log
├── archived/              — promoted knowledge artifacts
│   └── <topic>-<date>.md
└── index.json             — quick lookup index (auto-generated)
```

## Trigger conditions

- User says "记住", "保存", "记下来", "存档"
- User asks about past conversations or decisions
- Context approaching 70% token threshold (check with rough estimation)
- End of a significant discussion or decision point

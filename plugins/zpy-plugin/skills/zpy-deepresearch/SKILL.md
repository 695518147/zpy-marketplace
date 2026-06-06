---
name: zpy-deepresearch
description: This skill should be used when the user asks to "deep research", "深度研究", "深入分析", "调研", "写研究报告", "research this topic", "全面分析", or wants a multi-source, verified report on a complex topic.
argument-hint: "[研究主题] [可选: 深度级别(基础/深入/全面)] [可选: 输出格式(report/markdown/html)]"
allowed-tools:
  - WebSearch
  - WebFetch
  - Bash
  - Read
  - Write
  - Edit
  - Agent
---

# zpy-deepresearch

Execute end-to-end deep research with multi-source information retrieval, parallel sub-agent investigation, sandbox verification, and structured report generation.

## Research workflow

### Step 1: Understand the request

Parse the user's research topic, clarify scope, depth level, and output format. If ambiguous, ask 1–2 targeted questions to narrow scope before proceeding.

### Step 2: Design research plan

Output a structured plan covering:
- Research dimensions (3–6 orthogonal angles)
- Sources to search per dimension
- Sub-agent assignment (one per dimension)
- Report structure outline

### Step 3: Parallel sub-agent research

Dispatch one sub-agent per dimension using the Agent tool. Each sub-agent:
- Searches multiple sources via WebSearch
- Fetches and extracts key content from top results
- Produces a structured finding with source citations

Use Agent with `schema` for structured output to get consistent results across dimensions.

### Step 4: Cross-validate findings

- Compare findings across dimensions for consistency
- Run code verification in Bash sandbox for data-driven claims
- Flag conflicting information for resolution

### Step 5: Synthesize report

Generate the final report with this structure:
1. **Executive summary** — key findings in 3–5 bullet points
2. **Methodology** — how research was conducted
3. **Analysis by dimension** — one section per dimension with citations
4. **Conclusions** — actionable takeaways
5. **References** — numbered citations with URLs

Save important findings using `zpy-plugin:memory save` for future reference.

## Output formats

| Format | When to use |
|--------|------------|
| report | Full structured report (default) |
| markdown | Clean markdown for pasting into docs |
| html | Rendered HTML with styling |

## Related skills

- **`zpy-memory`** — save research conclusions for cross-session recall
- **`zpy-agents`** — if more than 4 sub-agents needed for complex research

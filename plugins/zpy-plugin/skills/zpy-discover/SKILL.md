---
name: zpy-discover
description: This skill should be used when the user asks to "发现工具", "discover", "推荐技能", "趋势", "trending", "有什么好用的", "推荐插件", "GitHub 趋势", "explore tools", "find plugins", or wants to explore and evaluate Claude Code ecosystem tools.
argument-hint: "[可选: 搜索关键词/类别] [可选: 平台(claude-code/codex/all)]"
allowed-tools:
  - WebSearch
  - WebFetch
  - Bash
  - Read
---

# zpy-discover

Discover, evaluate, and recommend Claude Code ecosystem tools, plugins, skills, and frameworks.

## Operations

### discover trending tools

1. Search GitHub trending for Claude Code related projects in the past week
2. Group results by category: plugins, skills, frameworks, utilities
3. For each result, extract: purpose, stars, last update, key features
4. Present a ranked summary with brief evaluation

### discover by category

When the user specifies a category (e.g., "代码审查工具", "test frameworks"):
1. Search specifically for tools in that category
2. Compare top 3-5 tools side by side
3. Recommend the best fit with rationale

### discover what's new

1. Check recently updated plugins and tools the user might have missed
2. Cross-reference with the user's existing toolset
3. Highlight complementary additions

### evaluate a specific tool

Given a GitHub repo URL or tool name:
1. Fetch the README and key documentation
2. Analyze: maturity, activity, compatibility with user's stack
3. Determine integration effort (easy / moderate / complex)
4. Provide installation instructions if recommended

## Evaluation criteria

Score each tool on (1-10):
| Criterion | What to check |
|-----------|---------------|
| Maturity | Stars, last commit date, release count |
| Compatibility | Works with current Claude Code version |
| Documentation | README quality, examples, API docs |
| Community | Issue response time, PR activity, contributors |
| Integration effort | Setup complexity, dependency chain |

---
name: harness-entry
description: 会话启动入口 — 输出纪律基线、声明 6 项能力、加载知识索引、检查流水线状态
allowed-tools: Read, Skill, Bash
---

## Usage
`/harness-entry`

## Behavior
1. 读取 `${CLAUDE_PLUGIN_ROOT}/knowledge/core/knowledge-index.yaml` 加载错误沉淀
2. 声明 Harness Engineering 6 项能力（brainstorming / doc-generation / systematic-debugging / code-review / implementation / testing）
3. 检查是否存在 `pipeline-state.json`，定位用户当前阶段
4. 输出标准移交链：
   - 开发：entry → brainstorming → implementation → testing → code-review
   - 文档：entry → brainstorming → doc-generation
   - 调试：entry → systematic-debugging

## HARD GATE
- 每个会话必须先调 `Skill: harness-entry`，再接其他 skill
- 跳过纪律基线 = 流程违规

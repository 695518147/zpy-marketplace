---
name: harness-doc
description: 文档生成 — 调 harness-document-generation；type ∈ {prd, system-design, api-spec, db-model, test-case, test-report}
allowed-tools: Read, Write, Edit, Bash
---

## Usage
`/harness-doc <type>`

`<type>` 取值：
- `prd` — 产品需求文档（`templates/PRD标准模板_v2.0.md`）
- `system-design` — 系统设计文档（`templates/系统设计文档模板.md`）
- `api-spec` — 系统接口设计（`templates/系统接口设计文档模版.md`）
- `db-model` — 物理模型设计（`templates/系统物理模型设计文档模版.md`）
- `test-case` — 测试用例（`templates/测试用例文档模板.md`）
- `test-report` — 测试报告（`templates/测试报告文档模板.md`）

## Behavior
1. 调 `Skill: harness-document-generation`
2. 确认 brainstorming 已完成（如未完成，提示先跑 `/harness-brainstorm`）
3. 读取对应模板，路径解析优先级：`<project>/.harness/templates/` > `~/.claude/harness.local/templates/` > `${CLAUDE_PLUGIN_ROOT}/templates/`
4. 逐节生成 → mermaid 图表 → 用户审阅 → `bash ${CLAUDE_PLUGIN_ROOT}/scripts/doc-pipeline.sh` 转 docx

## HARD GATE
- 必须先有 brainstormed spec
- 必须按模板逐节匹配
- 必须用户审阅通过
- 必须生成 .docx 副本

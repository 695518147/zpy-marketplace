---
name: harness-document-generation
description: Use when user says 生成文档, 写方案, 出文档, 写设计文档, 写PRD, 写接口文档, 写物理模型, 产出文档 — ensures brainstorming → template compliance → diagrams → md draft → user review → docx pipeline.
allowed-tools: Read, Write, Edit, Bash
---

# Harness — Document Generation Agent

<HARD-GATE>
生成任何文档前必须：
1. 触发 brainstorming → 用户确认方案
2. Read 对应模板 → 逐节匹配
3. 生成 MD 草稿 → 用户审阅
4. 图表嵌入 + 所有 .md 转 .docx
跳过任意一步 = 违规。
</HARD-GATE>

## 文档生成流程

### Phase 1: 前置确认
- 确认是否已完成 brainstorming
- 确认用户需要的文档类型（PRD/系统设计/接口设计/物理模型）

### Phase 2: 读取模板
根据文档类型读取对应模板：
- PRD标准模板_v2.0.md
- 系统设计文档模板.md
- 系统接口设计文档模版.md
- 系统物理模型设计文档模版.md

### Phase 3: 逐节生成
按模板章节逐节生成内容：
1. 背景与目标
2. 功能需求
3. 非功能需求
4. 数据模型
5. API 设计
6. 错误处理
7. 验收标准

### Phase 4: 图表生成
- 询问用户选择图表工具（mermaid / fireworks）
- 生成 Mermaid 代码块或 PNG
- 嵌入文档

### Phase 5: 用户审阅
- 展示 MD 草稿
- 收集用户反馈
- 根据反馈迭代

### Phase 6: 批量转换
使用 doc-pipeline.sh 转换所有 .md 为 .docx：
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/doc-pipeline.sh
```

---

## 链式移交

| 下一 Skill | 触发条件 |
|-----------|----------|
| — | 交付完成（无下一步 Skill） |

---

## 模板优先级（按路径解析规则）

1. `<project>/.harness/templates/` ← 项目覆盖（最高优先级）
2. `~/.claude/harness.local/templates/` ← 公司覆盖
3. `${CLAUDE_PLUGIN_ROOT}/templates/` ← 默认（兜底）
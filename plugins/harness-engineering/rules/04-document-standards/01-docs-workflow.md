# Document Workflow — 文档生成全流程

本文档定义文档生成的完整流程。

---

## 流程概览

```
用户请求 → Brainstorming 确认范围 → 读取模板 → 逐节生成 → 图表嵌入 → 用户审阅 → MD 转 DOCX
```

---

## Phase 1: 前置确认
- 确认 brainstorming 已完成
- 确认文档类型

## Phase 2: 读取模板
按文档类型选择：
- PRD: PRD标准模板_v2.0.md
- 系统设计: 系统设计文档模板.md
- 接口设计: 系统接口设计文档模版.md
- 物理模型: 系统物理模型设计文档模版.md

## Phase 3: 逐节生成
按模板章节逐节生成。

## Phase 4: 图表生成
1. 询问用户选择图表工具
2. 生成 Mermaid 代码块或 PNG
3. 嵌入文档

## Phase 5: 用户审阅
- 展示 MD 草稿
- 收集反馈
- 迭代

## Phase 6: 批量转换
```bash
bash scripts/doc-pipeline.sh
```

---

## 模板优先级

1. `<project>/.harness/templates/` ← 项目覆盖
2. `~/.claude/harness.local/templates/` ← 公司覆盖
3. `~/.claude/plugins/harness-engineering/templates/` ← 默认
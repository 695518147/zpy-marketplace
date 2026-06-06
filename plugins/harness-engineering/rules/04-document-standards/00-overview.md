# Document Standards — 文档规范总览

本文档定义文档生成的规范。

---

## 文档类型

| 类型 | 用途 | 模板 |
|------|------|------|
| PRD | 产品需求文档 | PRD标准模板_v2.0.md |
| 系统设计 | 系统架构设计 | 系统设计文档模板.md |
| 接口设计 | API 接口文档 | 系统接口设计文档模版.md |
| 物理模型 | 数据库物理模型 | 系统物理模型设计文档模版.md |

---

## 文档生成流程

1. **前置确认** → brainstorming 已完成
2. **读取模板** → 按文档类型选择模板
3. **逐节生成** → 按模板章节逐节生成
4. **图表嵌入** → mermaid 或 fireworks
5. **用户审阅** → 收集反馈
6. **批量转换** → md → docx

---

## 模板优先级

1. `<project>/.harness/templates/` ← 项目覆盖（最高优先级）
2. `~/.claude/harness.local/templates/` ← 公司覆盖
3. `~/.claude/plugins/harness-engineering/templates/` ← 默认（兜底）
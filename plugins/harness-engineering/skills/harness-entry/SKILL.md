---
name: harness-entry
description: Use when session starts or user says 会话启动, 初始化, setup, start session — establishes discipline baseline, declares all capabilities, loads knowledge index.
allowed-tools: Read, Skill, Bash
---

# Harness — Entry Agent

<HARD-GATE>
When this skill is invoked, the following baseline must be established before any other action:
1. Read knowledge-index.yaml to load error沉淀 knowledge
2. Declare all available Harness capabilities to user
3. Set discipline expectations
This applies to EVERY session regardless of task.
</HARD-GATE>

## Core Responsibilities

### 1. 纪律基线建立
会话开始时，声明 Harness Engineering 的核心纪律：

- **AI 编程缺的不是智力，是纪律**
- 所有能力通过自然语言触发，无需记忆命令
- 关键步骤不可跳过（HARD GATE 机制）
- 错误会沉淀到知识索引，避免同类问题反复出现

### 2. 能力声明
声明所有可用能力：

| 能力 | 触发词示例 |
|------|-----------|
| brainstorming | 帮我设计...、分析一下...、架构... |
| 文档生成 | 帮我写方案...、生成文档...、写PRD... |
| 系统调试 | 帮我修bug...、调试一下...、报错了... |
| 代码审查 | 帮我review...、审查代码... |
| 实现开发 | 帮我实现...、开发这个...、写代码... |
| 测试工程 | 帮我写测试...、跑单测...、压测... |

### 3. 知识索引加载
读取 `knowledge/core/knowledge-index.yaml` 并注入上下文，供所有 Skill 查询错误沉淀。

### 4. 流水线状态检查
检查是否存在 `pipeline-state.json`，确定用户从哪个阶段进入。

---

## 链式移交规则

- **标准流程**：harness-entry → 用户选择能力 → 对应 Skill
- **开发流程**：harness-entry → harness-brainstorming → harness-implementation → harness-testing → harness-code-review
- **文档流程**：harness-entry → harness-brainstorming → harness-document-generation

---

## 错误沉淀机制

根据 `knowledge-index.yaml` 中的沉淀规则：

| 类型 | 严重度 | 沉淀位置 |
|------|--------|----------|
| process | high | SKILL.md 中的 HARD GATE |
| rule | high/medium | rules/ 目录 |
| anti-pattern | high/medium | knowledge/patterns/anti-patterns.md |
| knowledge | medium/low | knowledge/ 知识库 |

修复错误时，AI 判断是否值得沉淀：
- 隐含约束/架构盲区/流程违规/重复犯错/修复成本>5min → 询问用户确认沉淀
- 拼写语法小错/工具失误/已有规则未遵守 → 静默跳过
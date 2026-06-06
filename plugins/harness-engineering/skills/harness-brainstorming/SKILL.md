---
name: harness-brainstorming
description: Use when user says 设计, 方案, 分析需求, 架构, 选型, 技术方案 — ensures 9-step design process, produces committed spec, enforces HARD GATE before implementation.
allowed-tools: Read, Write, Bash, AskUserQuestion
---

# Harness — Brainstorming Agent

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project,
or take any implementation action until:
1. Brainstorming is complete
2. Design spec is written and committed
3. User has approved the spec

This applies to EVERY task regardless of perceived simplicity.
</HARD-GATE>

## 9步方案设计流程

### Step 1: 探索项目现状
- 读取项目文件结构和最近的 git commits
- 了解现有技术栈、架构模式
- 识别相关方（stakeholders）

### Step 2: 澄清问题
逐条询问关键问题：
- 功能需求范围是什么？
- 用户是谁？核心使用场景？
- 数据模型有哪些？
- 外部依赖（API、数据库、缓存）？
- 非功能性需求（性能、安全、兼容性）？

### Step 3: 提出方案选项
提出 2-3 个可行方案，每个方案包含：
- **架构概述**
- **数据模型**
- **API 设计**
- **优缺点分析**
- **风险评估**

### Step 4: 分节展示设计
按以下章节组织：
1. 背景与目标
2. 架构设计
3. 数据模型
4. API 设计
5. 错误处理
6. 验收标准

### Step 5: 写入 Spec 文件
将设计写入 `spec/<timestamp>-<feature>-design.md`

### Step 6: 自检
对照以下清单检查：
- [ ] 所有关键问题已澄清
- [ ] 方案选项已展示
- [ ] 用户已知悉各方案优缺点
- [ ] 验收标准已定义

### Step 7: 用户审阅
- 展示 Spec 摘要
- 询问用户确认或反馈
- 根据反馈迭代设计

### Step 8: Commit Spec
用户确认后，将 Spec 提交到仓库

### Step 9: 链式移交
根据任务类型移交：
- **开发任务** → harness-implementation
- **文档任务** → harness-document-generation

---

## Spec 文件模板

```markdown
# <功能名称> 设计文档

## 1. 背景与目标
### 背景
### 目标
### 成功标准

## 2. 架构设计
### 整体架构
### 核心组件

## 3. 数据模型
### Entity 设计
### 关系图

## 4. API 设计
### 接口列表
### 请求/响应格式

## 5. 错误处理
### 错误码定义
### 异常场景

## 6. 验收标准
- [ ]
```

---

## 链式移交

| 下一 Skill | 触发条件 |
|-----------|----------|
| harness-implementation | 用户确认设计，要求实现 |
| harness-document-generation | 用户确认设计，要求生成文档 |
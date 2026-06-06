---
name: harness-brainstorm
description: 启动 9 步设计流程，强制 HARD GATE（无 spec 不写代码）
allowed-tools: Read, Write, Bash, AskUserQuestion
---

## Usage
`/harness-brainstorm <feature-name>`

`<feature-name>`：待设计的功能名（kebab-case）

## Behavior
1. 调 `Skill: harness-brainstorming`
2. 按 9 步流程执行：探索现状 → 澄清问题 → 提出 2-3 个方案 → 分节展示设计 → 写入 `spec/<timestamp>-<feature>-design.md` → 自检 → 用户审阅 → commit spec → 链式移交
3. 每步向用户输出阶段性产出
4. 完成后询问是否移交到 `harness-implementation`（开发）或 `harness-doc`（文档）

## HARD GATE
- 不允许跳过任何步骤
- 不允许未提交 spec 就开始实现
- 不允许未获得用户确认就结束流程

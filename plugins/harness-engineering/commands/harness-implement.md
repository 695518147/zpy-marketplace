---
name: harness-implement
description: TDD + 8 层架构实施 — 要求 spec 已 approved；按技术栈自动加载编码规范
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

## Usage
`/harness-implement <spec-path>`

`<spec-path>`：brainstorm 阶段已 commit 的 spec 路径（相对 repo 根或绝对路径）

## Behavior
1. 调 `Skill: harness-implementation`
2. 验证 spec 存在且已 git commit
3. 自动检测技术栈（Java/Spring / Python / Go / TypeScript / .NET / Android / iOS）
4. 加载对应栈的编码规范（`${CLAUDE_PLUGIN_ROOT}/knowledge/coding-standards/<stack>/`）
5. TDD 红绿重构循环：先写测试 → 最小实现 → 重构
6. 按 8 层模板组织代码：Entity → Repository → Service → API → Validator → Error → Logger → Metrics
7. 完成后列出测试文件路径，移交到 `/harness-test`

## HARD GATE
- spec 未 approved → 拒绝实现
- 简单配置变更可跳过 TDD；其他必须测试先行
- 8 层模板任一层缺失需在 commit message 注明

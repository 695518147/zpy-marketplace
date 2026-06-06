---
name: harness-review
description: 4 阶段独立代码审查 — Phase 0 diff / Phase 1 plan / Phase 2 code / Phase 3 test；三态 verdict
allowed-tools: Read, Bash, Grep, Glob, Skill
---

## Usage
`/harness-review`

## Behavior
1. 调 `Skill: harness-code-review`
2. 调起 `Agent: harness-reviewer` 独立审查（角色分离）
3. 顺序执行 4 阶段，跳过任一阶段 = 违规：
   - **Phase 0**：`git diff --name-only` 展示改动
   - **Phase 1**：检查 spec 完整性、范围对齐
   - **Phase 2**：按 4 维度（规范/安全/性能/可维护性）独立评审
   - **Phase 3**：覆盖率（stmt≥80% / branch≥70%）、边界条件、异常路径
4. 输出三态 verdict：
   - `APPROVED` — 可合并
   - `CHANGES_REQUESTED` — 需修改
   - `REJECTED` — 需重大重构

## HARD GATE
- 4 阶段顺序不可跳、不可并行
- verdict 必须基于全部 4 阶段
- 不修改代码（仅评审）

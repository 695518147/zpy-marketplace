---
name: harness-debug
description: 4 阶段系统调试 + 3-failure 强制停 — 调 harness-systematic-debugging
allowed-tools: Read, Bash, Grep, Glob, Edit
---

## Usage
`/harness-debug <error-summary>`

`<error-summary>`：错误信息关键字或堆栈摘要

## Behavior
1. 调 `Skill: harness-systematic-debugging`
2. 调起 `Agent: harness-debugger` 隔离根因
3. 顺序执行 4 阶段：
   - **Phase 1**：完整读日志（服务端/客户端/网络） + 稳定复现 + `git log/diff/blame`
   - **Phase 2**：找类似代码 + 逐项对比差异
   - **Phase 3**：单假设验证（一次只改一处）
   - **Phase 4**：先写复现测试 → 最小修复 → 验证 → commit
4. 3-failure 规则：连续 3 次假设未中 → 停止调试，触发架构讨论

## HARD GATE
- 必须读完整错误日志（不可只读一行）
- 必须有稳定复现步骤
- 必须找到根因（非表象）
- 必须先写复现测试再改代码
- 3 次失败强制停止 + 讨论架构

---
name: harness-test
description: 单元/E2E/压测自动判 — 三条测试路径；coverage ≥ 80% stmt / 70% branch
allowed-tools: Read, Write, Edit, Bash, Grep, mcp__playwright__*
---

## Usage
`/harness-test <path>`

`<path>`：被测代码文件或目录（默认 `./src`）

## Behavior
1. 调 `Skill: harness-testing`
2. 自动判定测试路径：
   - **Path A**（写单测/跑单测/测覆盖率）→ 单元测试
   - **Path B**（端到端/UI测试）→ Playwright E2E（仅前端/全栈项目）
   - **Path C**（压测/性能测试）→ StressTest，触发 `AskUserQuestion` 选择压测目标
3. 单元测试：分析依赖 → mock 外部层 → Given/When/Then → 执行 `npm test -- --coverage` 或 `pytest --cov`
4. E2E 测试：运行 `npx playwright install` → 调 `mcp__playwright__*` 工具 → 截图存档
5. 压测：生成 StressTest 文件 → 多轮执行 → 输出 GC/耗时/动态门禁

## HARD GATE
- 必须分析被测代码的依赖
- 必须符合项目测试框架
- 覆盖率不达标（stmt<80% 或 branch<70%）需标注未覆盖路径
- 压测必须从 `git diff --name-only` 中选目标

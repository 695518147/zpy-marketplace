---
name: harness-testing
description: Use when user says 写测试, 跑测试, 单测, E2E, 测覆盖率, 压测, 性能测试 — ensures backend unit test + E2E + stress test with interactive configuration.
allowed-tools: Read, Write, Edit, Bash, Grep, mcp__playwright__*
---

# Harness — Testing Agent

<HARD-GATE>
测试前必须：
1. 分析被测代码，识别依赖
2. 生成符合项目测试框架的测试用例
3. 执行后报告覆盖率（statement ≥ 80%, branch ≥ 70%）
压测必须从改动清单中选择目标模块。
</HARD-GATE>

## 三条测试路径

### Path A: 后端单测
触发词：写单测、跑单测、测覆盖率

#### Step 1: 分析被测代码
- 读取源码
- 识别依赖（数据库 DAO、外部 API）
- 确定需要 mock 的层

#### Step 2: 识别测试场景
- Happy Path：正常流程
- 边界条件：空值、超长、null
- 异常路径：连接失败、超时

#### Step 3: 生成测试文件
- 自动检测项目测试框架（Jest / pytest / Go testing / JUnit）
- Given/When/Then 结构
- 写入 __tests__/ 目录

#### Step 4: 执行测试
```bash
npm test -- --coverage
# 或
pytest --cov
# 或
go test -coverprofile=coverage.out
```

#### Step 5: 报告
- 通过/失败/跳过数量
- 覆盖率数据
- 失败分类

---

### Path B: E2E 测试
触发词：端到端测试、页面测试、UI测试

**仅适用于前端/全栈 Web 项目**

#### Step 1: 项目类型判定
- 检测 package.json 含 react/vue/next → 继续
- Java 后端/CLI 工具 → 自动跳过

#### Step 2: 浏览器预检
- 运行 `npx playwright install`（首次）安装浏览器
- 通过 `${CLAUDE_PLUGIN_ROOT}/scripts/check-dependencies.sh` 检测 playwright 可执行性
- 浏览器二进制实际路径由 npx cache 决定（macOS/Linux/Windows 跨平台），不硬编码

#### Step 3: 分析页面操作流
- 读取前端代码
- 识别 selector
- 识别操作步骤

#### Step 4: 启动服务
- invoke Skill: webapp-testing
- 管理前后端服务生命周期

#### Step 5: 执行 Playwright 测试
使用 MCP 工具（mcp__playwright__navigate/click/fill/screenshot）

#### Step 6: 验证与报告
- 每个关键步骤截图（宽度 ≥ 1200px）
- 失败时保留页面状态截图

---

### Path C: 压测
触发词：压测、压力测试、性能测试、benchmark

#### Step C1: 展示改动清单
- 读取 `git diff --name-only`
- 按代码角色标注描述
- AskUserQuestion 让用户勾选压测目标

#### Step C2: 压测配置
第一轮交互：
- 数据规模
- 并发度
- Mock 哪些依赖
- 轮次

第二轮交互：
- 每个被选中依赖独立配置 Mock 耗时

#### Step C3: 执行压测
生成 StressTest 文件并执行

#### Step C4: 压测报告
- 单轮明细：耗时 + 核心指标
- 汇总：均值 + 动态门禁
- GC 次数/耗时

#### Step C5: 链式移交
- 全部门禁通过 → harness-code-review
- 性能劣化 → harness-implementation 修复

---

## 链式移交

| 下一 Skill | 触发条件 |
|-----------|----------|
| harness-code-review | 全部测试通过 |
| harness-implementation | 测试失败（代码 bug）|
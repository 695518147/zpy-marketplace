# Testing Standards — 测试标准

本文档定义后端单测、E2E 测试和压测的标准。

---

## Path A: 后端单测标准

### 核心要求

1. **Mock 外部依赖**
   - 必须 mock：数据库 DAO、外部 API 调用、文件系统
   - 禁止 mock：被测代码本身

2. **覆盖三大路径**
   - Happy Path：正常业务流程
   - 边界条件：空值、超长字符串、null 参数
   - 异常路径：连接失败、超时、数据不存在

3. **Given/When/Then 结构**
   ```
   Given: 设置测试数据和 mock
   When:  调用被测方法
   Then:  验证返回结果或异常
   ```

4. **覆盖率门禁**
   - statement coverage ≥ 80%
   - branch coverage ≥ 70%

---

## Path B: E2E 测试标准

### 适用场景
仅适用于前端/全栈 Web 项目（Java 后端/CLI 工具自动跳过）

### 浏览器预检
每次调用 MCP 前检查 `~/Library/Caches/ms-playwright/`，有浏览器才继续，不自动触发下载。

### 测试执行
使用 Playwright MCP 工具（mcp__playwright__navigate/click/fill/screenshot），不手写 Python 脚本。

### 截图要求
- 每个关键步骤截图（宽度 ≥ 1200px）
- 失败时保留页面状态截图

---

## Path C: 压测标准

### 交互式配置流程

**Step 1: 改动清单展示**
- 读取 `git diff --name-only`
- 过滤出实现类
- 按代码角色标注描述
- AskUserQuestion 让用户勾选压测目标（超4个拆多次调用）

**Step 2: 配置（分两轮交互）**
第一轮：
- 数据规模
- 并发度
- Mock 哪些依赖（从 import 中动态提取）
- 轮次

第二轮：
- 每个被选中依赖独立问 Mock 耗时（用 Other 自由输入 ms）

### Mock 规则
- 默认不 mock（走真实路径）
- 从 import 中动态提取可 mock 依赖
- 每个依赖独立配置耗时

### 全维度指标
- 耗时
- 核心指标（Reader → 吞吐, API → QPS）
- CPU%
- 堆内存增量
- GC 次数/耗时

### 动态门禁
阈值按数据规模自动计算：
| 数据规模 | 堆内存阈值 |
|---------|-----------|
| 1万行 | 10MB |
| 10万行 | 100MB |
| 50万行 | 500MB |

### 链式移交
- 全部门禁通过 → harness-code-review
- 性能劣化 → 返回 harness-implementation 修复
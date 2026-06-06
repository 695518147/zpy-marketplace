---
name: harness-implementation
description: Use when user says 实现, 开发, 写代码, 编码, implement, develop — ensures TDD + 8-layer template + subagent dispatching.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Harness — Implementation Agent

<HARD-GATE>
实现任何功能前必须：
1. 确认 Spec 已 approved
2. 先写测试（除非是简单配置变更）
3. 遵循 8 层编码模板
4. 按技术栈加载编码规范
</HARD-GATE>

## TDD 红绿重构

### Red: 写失败的测试
- 明确要实现的功能
- 写出会失败的测试
- Given/When/Then 结构

### Green: 让测试通过
- 写最小实现
- 不追求完美
- 确保测试变绿

### Refactor: 重构
- 改善代码质量
- 保持测试通过
- 逐步演进

---

## 8 层编码模板

### Layer 1: Entity/Model
数据结构定义

### Layer 2: Repository/DAO
数据访问层

### Layer 3: Service/Business Logic
业务逻辑层

### Layer 4: API/Controller
接口层

### Layer 5: Validator
参数校验

### Layer 6: Error Handler
异常处理

### Layer 7: Logger
日志记录

### Layer 8: Metrics
监控指标

---

## 技术栈自动检测

| 技术栈 | 检测信号 | 规范文件数 |
|--------|---------|-----------|
| Java/Spring | pom.xml, build.gradle | 7 |
| Python | pyproject.toml, requirements.txt | 7 |
| Go | go.mod | 7 |
| TypeScript/React | package.json + tsconfig.json | 7 |
| .NET/C# | .csproj, .sln | 8 |
| Android/Kotlin | build.gradle.kts + AndroidManifest.xml | 9 |
| iOS/Swift | *.xcodeproj, *.xcworkspace | 10 |

自动加载对应技术栈的编码规范（如 Go 项目自动加载 Go 并发规范）。

---

## 链式移交

| 下一 Skill | 触发条件 |
|-----------|----------|
| harness-testing | 编码完成，列出测试文件路径 |
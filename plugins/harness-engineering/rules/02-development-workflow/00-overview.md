# Development Workflow — TDD + 8层编码模板

本文档定义开发流程的编码模板。

---

## TDD 红绿重构循环

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

| 技术栈 | 检测信号 |
|--------|---------|
| Java/Spring | pom.xml, build.gradle |
| Python | pyproject.toml, requirements.txt |
| Go | go.mod |
| TypeScript/React | package.json + tsconfig.json |
| .NET/C# | .csproj, .sln |
| Android/Kotlin | build.gradle.kts + AndroidManifest.xml |
| iOS/Swift | *.xcodeproj, *.xcworkspace |

自动加载对应技术栈的编码规范。
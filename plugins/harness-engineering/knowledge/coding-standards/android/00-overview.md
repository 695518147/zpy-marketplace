# Android 编码规范总览

本文档定义了 Android/Kotlin 开发的标准规范，旨在提高代码质量和一致性。

## 核心原则

1. **Kotlin 优先** - 使用 Kotlin 进行开发
2. **架构清晰** - 遵循 MVVM/Clean Architecture
3. **协程安全** - 正确使用协程处理异步
4. **UI 规范** - 遵循 Material Design
5. **安全优先** - 防止常见安全漏洞
6. **测试覆盖** - 确保关键逻辑测试覆盖

## 技术栈要求

- Kotlin: 1.9.x
- Android SDK: 34
- Jetpack Compose / View 系统
- Hilt / Koin 依赖注入
- Coroutines + Flow

## 代码风格

遵循 Kotlin 官方风格指南，使用 Gradle Kotlin DSL。

## 文档索引

- [命名规范](./01-naming.md)
- [架构规范](./02-architecture.md)
- [组件规范](./03-components.md)
- [协程规范](./04-coroutines.md)
- [日志规范](./05-logging.md)
- [安全规范](./06-security.md)
- [测试规范](./07-testing.md)
- [性能规范](./08-performance.md)
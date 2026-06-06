# .NET 编码规范总览

本文档定义了 .NET/C# 开发的标准规范，旨在提高代码质量和一致性。

## 核心原则

1. **类型安全** - 充分利用 .NET 类型系统
2. **异步编程** - 合理使用 async/await
3. **异常处理** - 正确处理异常，保持程序健壮
4. **日志规范** - 合理记录日志，便于问题排查
5. **安全优先** - 防止常见安全漏洞
6. **测试覆盖** - 确保关键逻辑测试覆盖

## 技术栈要求

- .NET: 8.0
- C#: 12
- ASP.NET Core
- Entity Framework Core 8

## 代码风格

遵循 .NET 设计规范，使用 EditorConfig 统一格式。

## 文档索引

- [命名规范](./01-naming.md)
- [类结构规范](./02-class-structure.md)
- [异常处理规范](./03-exception-handling.md)
- [异步编程规范](./04-async.md)
- [日志规范](./05-logging.md)
- [安全规范](./06-security.md)
- [测试规范](./07-testing.md)
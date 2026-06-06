# Go 编码规范总览

本文档定义了 Go 开发的标准规范，旨在提高代码质量和一致性。

## 核心原则

1. **简洁清晰** - Go 以简洁著称，避免过度设计
2. **面向错误** - 错误是值，妥善处理每个错误
3. **并发安全** - 合理使用 goroutine 和 channel
4. **性能优先** - 关注内存分配和执行效率
5. **测试驱动** - 重视单元测试和覆盖率

## 技术栈要求

- Go: 1.21+
- 常用框架：Gin、Echo、Fiber
- 常用工具：gofmt、golangci-lint、go test

## 代码风格

遵循 Go 官方格式化规范，使用 `gofmt` 格式化代码。

## 文档索引

- [命名规范](./01-naming.md)
- [错误处理规范](./02-error-handling.md)
- [并发规范](./03-concurrency.md)
- [日志规范](./04-logging.md)
- [测试规范](./05-testing.md)
- [最佳实践](./06-best-practices.md)
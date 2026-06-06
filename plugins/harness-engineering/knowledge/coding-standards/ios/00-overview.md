# iOS 编码规范总览

本文档定义了 iOS/Swift 开发的标准规范，旨在提高代码质量和一致性。

## 核心原则

1. **Swift 优先** - 使用 Swift 进行开发
2. **协议导向** - 合理使用协议和泛型
3. **值类型** - 优先使用 struct 和值类型
4. **安全第一** - 避免常见安全漏洞
5. **性能优化** - 关注内存和性能
6. **测试覆盖** - 确保关键逻辑测试覆盖

## 技术栈要求

- Swift: 5.9+
- iOS: 16.0+
- UIKit / SwiftUI
- Combine / async-await

## 代码风格

遵循 Swift 官方风格指南，使用 SwiftLint 确保一致性。

## 文档索引

- [命名规范](./01-naming.md)
- [架构规范](./02-architecture.md)
- [ViewController 规范](./03-viewcontrollers.md)
- [自动布局规范](./04-auto-layout.md)
- [网络规范](./05-networking.md)
- [日志规范](./06-logging.md)
- [安全规范](./07-security.md)
- [测试规范](./08-testing.md)
- [性能规范](./09-performance.md)
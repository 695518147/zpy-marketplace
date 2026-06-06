# Java 编码规范总览

本文档定义了 Java/Spring 开发的标准规范，旨在提高代码质量和一致性。

## 核心原则

1. **清晰优于简洁** - 代码应易于阅读和理解
2. **命名有意义** - 变量、方法、类名应能表达其用途
3. **单一职责** - 每个类和方法只做一件事
4. **异常处理** - 正确处理异常，避免吞掉错误
5. **事务安全** - 数据库操作需正确管理事务
6. **日志规范** - 合理记录日志，便于问题排查
7. **安全优先** - 防止常见安全漏洞

## 技术栈版本要求

- Java: 17+
- Spring Boot: 3.x
- Spring Framework: 6.x

## 目录结构

```
src/
├── main/java/
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── entity/
│   ├── dto/
│   ├── config/
│   └── exception/
└── test/java/
```

## 文档索引

- [命名规范](./01-naming.md)
- [类结构规范](./02-class-structure.md)
- [异常处理规范](./03-exception-handling.md)
- [事务规范](./04-transaction.md)
- [日志规范](./05-logging.md)
- [安全规范](./06-security.md)
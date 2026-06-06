# Coding Standards Index — 编码规范索引

本文档是编码规范知识库的入口，按技术栈组织。

---

## 技术栈目录

| 技术栈 | 目录 | 文件数 |
|--------|------|--------|
| Java/Spring | docs/coding-standards/java/ | 7 |
| Python | docs/coding-standards/python/ | 7 |
| Go | docs/coding-standards/go/ | 7 |
| TypeScript/React | docs/coding-standards/typescript/ | 7 |
| .NET/C# | docs/coding-standards/dotnet/ | 8 |
| Android/Kotlin | docs/coding-standards/android/ | 9 |
| iOS/Swift | docs/coding-standards/ios/ | 10 |

---

## 检测信号

项目自动检测技术栈的信号：

| 技术栈 | 检测信号 |
|--------|---------|
| Java/Spring | pom.xml, build.gradle, build.gradle.kts |
| Python | pyproject.toml, requirements.txt, setup.py |
| Go | go.mod |
| TypeScript/React | package.json + tsconfig.json |
| .NET/C# | .csproj, .sln |
| Android/Kotlin | build.gradle.kts + AndroidManifest.xml |
| iOS/Swift | *.xcodeproj, *.xcworkspace |

---

## 自动加载

harness-implementation 执行时自动：
1. 检测项目技术栈
2. 加载对应编码规范
3. 在生成代码时遵循规范
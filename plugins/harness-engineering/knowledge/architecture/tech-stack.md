# Tech Stack — 技术栈说明

本文档定义各技术栈的编码规范索引。

---

## 技术栈列表

| 技术栈 | 规范目录 | 检测信号 |
|--------|---------|----------|
| Java/Spring | docs/coding-standards/java/ | pom.xml, build.gradle |
| Python | docs/coding-standards/python/ | pyproject.toml, requirements.txt |
| Go | docs/coding-standards/go/ | go.mod |
| TypeScript/React | docs/coding-standards/typescript/ | package.json + tsconfig.json |
| .NET/C# | docs/coding-standards/dotnet/ | .csproj, .sln |
| Android/Kotlin | docs/coding-standards/android/ | build.gradle.kts + AndroidManifest.xml |
| iOS/Swift | docs/coding-standards/ios/ | *.xcodeproj, *.xcworkspace |

---

## 自动检测机制

harness-implementation 执行时自动检测项目技术栈，按栈加载对应规范。

详见各技术栈目录下的 `README.md`。
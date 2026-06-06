# iOS 日志规范

## 1. 日志框架

使用 OSLog 或自定义日志封装。

```swift
import os.log

// Logger
enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "App"

    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let database = OSLog(subsystem: subsystem, category: "Database")
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let business = OSLog(subsystem: subsystem, category: "Business")

    static let general = OSLog(subsystem: subsystem, category: "General")
}

// 使用
os_log(.debug, log: Logger.network, "Fetching users from API")
os_log(.info, log: Logger.business, "User created: %{public}@", userId)
os_log(.error, log: Logger.general, "Failed to load data: %{public}@", error.localizedDescription)
```

## 2. 日志级别

| 级别 | 使用场景 | OSLog type |
|------|----------|------------|
| Debug | 调试信息，开发环境 | `.debug` |
| Info | 重要业务节点 | `.info` |
| Error | 错误，需要关注 | `.error` |
| Fault | 系统故障 | `.fault` |

```swift
// Debug 日志 - 开发环境
os_log(.debug, log: Logger.network, "Request: %{public}@", request.url)

// Info 日志 - 业务节点
os_log(.info, log: Logger.business, "User logged in: userId=%{public}d", userId)

// Error 日志 - 错误
os_log(.error, log: Logger.general, "Network error: %{public}@", error.localizedDescription)

// Fault 日志 - 系统故障
os_log(.fault, log: Logger.general, "Database corruption detected")
```

## 3. 日志格式

```swift
// 结构化日志
os_log(.info, log: Logger.business,
       "Order created: orderId=%{public}d, amount=%.2f, userId=%{public}d",
       orderId, amount, userId)

// 复杂对象
os_log(.debug, log: Logger.network,
       "Response: %{public}@",
       String(data: jsonData, encoding: .utf8) ?? "invalid data")
```

## 4. 性能日志

```swift
// 使用 os_signpost
import os.log

let signpostLog = OSLog(subsystem: "App", category: "Performance")

func loadData() {
    let signpostID = OSSignpostID(log: signpostLog)
    os_signpost(.begin, log: signpostLog, name: "LoadData", signpostID: signpostID)

    // 执行操作

    os_signpost(.end, log: signpostLog, name: "LoadData", signpostID: signpostID)
}

// Instruments 测量
import os.signpost

let tracingHandle = OSSignpostTracer(log: signpostLog)

tracingHandle.beginTracing(name: "NetworkRequest")
// 网络请求
tracingHandle.endTracing()
```

## 5. 日志脱敏

```swift
// 不要记录敏感信息
os_log(.info, log: Logger.business, "User login: username=%{public}@", username)  // OK
os_log(.info, log: Logger.business, "User login: password=%{public}@", password)  // 禁止

// 审计日志
os_log(.info, log: Logger.business,
       "Security event: action=%{public}@, userId=%{public}d, result=%{public}@",
       "PASSWORD_CHANGE", userId, "SUCCESS")
```

## 6. 条件日志

```swift
// 调试时记录
#if DEBUG
func logVerbose(_ message: String) {
    os_log(.debug, log: Logger.general, "%{public}@", message)
}
#else
func logVerbose(_ message: String) {
    // 发布版本不记录
}
#endif

// 使用 LogLevel
enum LogLevel {
    case debug
    case info
    case warning
    case error

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}
```

## 7. 日志文件

```swift
// 将日志写入文件
import os.log

class FileLogger {
    private let fileHandle: FileHandle?
    private let logQueue = DispatchQueue(label: "FileLogger")

    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logFile = documentsPath.appendingPathComponent("app.log")

        FileManager.default.createFile(atPath: logFile.path, contents: nil)
        fileHandle = try? FileHandle(forWritingTo: logFile)
    }

    func log(_ message: String) {
        logQueue.async { [weak self] in
            let timestamp = ISO8601DateFormatter().string(from: Date())
            let logLine = "\(timestamp) - \(message)\n"

            if let data = logLine.data(using: .utf8) {
                self?.fileHandle?.write(data)
            }
        }
    }
}
```

## 8. Crash 报告

```swift
// 设置 UncaughtExceptionHandler
func setupCrashReporting() {
    NSSetUncaughtExceptionHandler { exception in
        let stackTrace = exception.callStackSymbols.joined(separator: "\n")
        os_log(.fault, log: Logger.general,
               "Uncaught exception: %{public}@\n%{public}@",
               exception.reason ?? "Unknown",
               stackTrace)

        // 上报到 Crash 服务
        CrashReportingService.shared.report(exception)
    }
}
```

## 9. 禁止事项

- 不要在日志中记录密码、密钥等敏感信息
- 不要在生产环境记录 Debug 日志
- 不要在循环中记录大量日志
- 不要记录用户输入（可能有恶意代码）
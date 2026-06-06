# Go 日志规范

## 1. 日志库选择

推荐使用 `slog`（标准库）或 `zap`/`logrus`。

```go
// 标准库 slog (Go 1.21+)
import "log/slog"

slog.Info("user created", "userID", 123, "email", "test@example.com")

// zap
import "go.uber.org/zap"
logger, _ := zap.NewProduction()
logger.Info("user created",
    zap.Int("userID", 123),
    zap.String("email", "test@example.com"),
)
```

## 2. 日志级别

| 级别 | 使用场景 |
|------|----------|
| `Debug` | 调试信息，开发环境 |
| `Info` | 重要业务节点，正常流程 |
| `Warn` | 警告信息，可能有问题 |
| `Error` | 错误，需要关注 |
| `Critical` | 严重错误，系统故障 |

```go
slog.Debug("debug info", "key", "value")
slog.Info("info message", "key", "value")
slog.Warn("warning message", "key", "value")
slog.Error("error occurred", "err", err)
slog.Log(context.Background(), slog.LevelCritical, "system failure", "err", err)
```

## 3. 结构化日志

```go
// 使用键值对
slog.Info("order created",
    "orderID", order.ID,
    "amount", order.Amount,
    "userID", user.ID,
)

// 嵌套结构
slog.Info("request processed",
    "requestID", reqID,
    "user", slog.Group("user",
        "id", user.ID,
        "name", user.Name,
    ),
)
```

## 4. 日志上下文

```go
// 使用 context 传递日志
func withLogger(ctx context.Context, logger *slog.Logger) context.Context {
    return context.WithValue(ctx, "logger", logger)
}

func getLogger(ctx context.Context) *slog.Logger {
    return ctx.Value("logger").(*slog.Logger)
}

// 在日志中包含 context 信息
func processRequest(ctx context.Context) {
    logger := getLogger(ctx)
    logger.Info("processing request")
}
```

## 5. 错误日志

```go
// 记录错误并附加上下文
if err != nil {
    slog.Error("failed to process request",
        "error", err,
        "requestID", requestID,
        "userID", userID,
    )
}

// 使用 Error 级别记录业务错误
if err == ErrInvalidInput {
    slog.Warn("invalid input",
        "field", "email",
        "value", email,
    )
}
```

## 6. 日志配置

```go
// slog 配置
import "log/slog"
import "os"

func init() {
    // JSON 格式输出
    handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    })
    slog.SetDefault(slog.New(handler))
}

// zap 配置
import "go.uber.org/zap"

func init() {
    cfg := zap.NewProductionConfig()
    cfg.Level = zap.NewAtomicLevelAt(zap.InfoLevel)
    logger, _ := cfg.Build()
    zap.ReplaceGlobals(logger)
}
```

## 7. 日志文件

```go
import (
    "log/slog"
    "os"
    "path/filepath"
)

func setupFileLogger(dir string) error {
    f, err := os.OpenFile(
        filepath.Join(dir, "app.log"),
        os.O_CREATE|os.O_WRONLY|os.O_APPEND,
        0666,
    )
    if err != nil {
        return err
    }

    handler := slog.NewJSONHandler(f, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    })
    slog.SetDefault(slog.New(handler))
    return nil
}
```

## 8. 审计日志

```go
// 记录安全相关事件
slog.Info("security event",
    "event", "USER_LOGIN",
    "userID", userID,
    "ip", ipAddress,
    "result", "SUCCESS",
    "timestamp", time.Now().Format(time.RFC3339),
)
```

## 9. 敏感信息处理

```go
// 不要记录敏感信息
// 错误
slog.Info("user login", "password", password)

// 正确
slog.Info("user login", "username", username)

// 使用日志级别控制
if slog.Default().Enabled(context.Background(), slog.LevelDebug) {
    slog.Debug("detailed info", "debugData", debugData)
}
```
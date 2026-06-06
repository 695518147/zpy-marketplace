# .NET 日志规范

## 1. 日志框架

使用 Microsoft.Extensions.Logging，支持多种日志提供者。

```csharp
// 注册日志服务
builder.Services.AddLogging(options =>
{
    options.AddConsole();
    options.AddDebug();
    options.SetMinimumLevel(LogLevel.Debug);
});

// Serilog 配置
builder.Services.AddSerilog((services, configuration) =>
{
    configuration
        .MinimumLevel.Information()
        .MinimumLevel.Override("Microsoft", LogLevel.Warning)
        .MinimumLevel.Override("System", LogLevel.Warning)
        .Enrich.FromLogContext()
        .WriteTo.Console();
});
```

## 2. 日志级别

| 级别 | 使用场景 |
|------|----------|
| `Trace` | 详细跟踪信息 |
| `Debug` | 调试信息，开发环境 |
| `Information` | 重要业务节点 |
| `Warning` | 警告信息，可能有问题 |
| `Error` | 错误，需要关注 |
| `Critical` | 系统故障，需要立即处理 |

## 3. 结构化日志

```csharp
// 使用结构化日志
_logger.LogInformation("User created: UserId={UserId}, Email={Email}", user.Id, user.Email);
_logger.LogDebug("Processing request: RequestId={RequestId}, Path={Path}", requestId, path);

// 嵌套对象
_logger.LogInformation("Order placed: {Order}", new
{
    OrderId = order.Id,
    Amount = order.Amount,
    UserId = order.UserId
});

// 场景日志
_logger.LogWarning("Retry attempt {Attempt} failed for user: {UserId}", attempt, userId);
_logger.LogError(ex, "Failed to process order: OrderId={OrderId}", orderId);
```

## 4. 日志消息模板

```csharp
// 模板化日志消息
_logger.LogInformation("Processing {ItemCount} items from queue", items.Count);
_logger.LogDebug("Cache miss for key: {CacheKey}", cacheKey);

// 避免字符串拼接
// 错误
_logger.LogInformation($"User {userId} logged in");

// 正确
_logger.LogInformation("User logged in: {UserId}", userId);
```

## 5. 异常日志

```csharp
// 记录异常及上下文
try
{
    await processAsync();
}
catch (Exception ex)
{
    _logger.LogError(ex, "Process failed: {RequestId}, {UserId}", requestId, userId);
    throw;
}

// 记录异常详细信息
_logger.LogError(ex, "Database error: {ConnectionId}", connectionId);

// 警告场景
_logger.LogWarning(ex, "Operation partially failed: {FailedCount}/{TotalCount}", failedCount, totalCount);
```

## 6. 日志分类

```csharp
// 使用 ILogger<T> 获取分类日志
public class UserService : IUserService
{
    private readonly ILogger<UserService> _logger;

    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;
    }

    // _logger 日志的分类名为 "Company.Project.Services.UserService"
}
```

## 7. 禁用日志

```csharp
// 在生产环境禁用 Debug 日志
if (_logger.IsEnabled(LogLevel.Debug))
{
    _logger.LogDebug("Detailed info: {Data}", expensiveData);
}

// 或使用 LogInformation
_logger.LogInformation("Processing item: {ItemId}", itemId);
```

## 8. 审计日志

```csharp
// 安全相关事件
_logger.LogWarning(
    "Security event: Action={Action}, UserId={UserId}, IP={IpAddress}, Result={Result}",
    "PASSWORD_CHANGE",
    userId,
    ipAddress,
    "SUCCESS");

// 业务审计
_logger.LogInformation(
    "Audit: Entity={EntityType}, EntityId={EntityId}, Action={Action}, UserId={UserId}, Timestamp={Timestamp}",
    "Order",
    orderId,
    "CREATE",
    userId,
    DateTime.UtcNow);
```

## 9. 日志配置

```json
// appsettings.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information",
      "Company.Project": "Debug"
    },
    "Console": {
      "FormatterName": "json",
      "FormatterOptions": {
        "SingleLine": true,
        "IncludeScopes": true,
        "TimestampFormat": "yyyy-MM-dd HH:mm:ss "
      }
    }
  }
}
```

## 10. 禁止事项

- 不要记录密码、密钥等敏感信息
- 不要在日志中记录大对象（使用摘要）
- 不要在日志中记录用户输入（可能有恶意代码）
- 不要在热路径中记录大量日志
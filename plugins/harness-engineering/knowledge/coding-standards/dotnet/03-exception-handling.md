# .NET 异常处理规范

## 1. 异常分类

| 异常类型 | 用途 | 示例 |
|----------|------|------|
| `ArgumentNullException` | 参数为 null | 参数传入 null |
| `ArgumentException` | 参数非法 | 参数值不符合要求 |
| `InvalidOperationException` | 状态异常 | 当前状态不允许操作 |
| `NotFoundException` | 资源不存在 | 找不到对应数据 |
| `BusinessException` | 业务逻辑异常 | 业务规则不满足 |

## 2. 自定义异常

```csharp
// 自定义异常定义
public class UserNotFoundException : Exception
{
    public int UserId { get; }

    public UserNotFoundException(int userId)
        : base($"User not found with id: {userId}")
    {
        UserId = userId;
    }

    public UserNotFoundException(int userId, Exception innerException)
        : base($"User not found with id: {userId}", innerException)
    {
        UserId = userId;
    }
}

// 业务异常
public class BusinessException : Exception
{
    public string Code { get; }
    public Dictionary<string, object> Details { get; }

    public BusinessException(string code, string message)
        : base(message)
    {
        Code = code;
        Details = new Dictionary<string, object>();
    }

    public BusinessException(string code, string message, Dictionary<string, object> details)
        : base(message)
    {
        Code = code;
        Details = details;
    }
}
```

## 3. 异常抛出

```csharp
// 抛出异常
public async Task<User> GetUserByIdAsync(int id)
{
    var user = await _userRepository.GetByIdAsync(id);
    if (user is null)
        throw new UserNotFoundException(id);
    return user;
}

// 不返回 null，使用空集合或异常
public async Task<IEnumerable<User>> GetUsersAsync()
{
    var users = await _userRepository.GetAllAsync();
    return users ?? Enumerable.Empty<User>();  // 不返回 null
}
```

## 4. 全局异常处理

```csharp
// ASP.NET Core 全局异常处理
public class GlobalExceptionHandler : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;

    public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
    {
        _logger = logger;
    }

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        _logger.LogError(exception, "An unhandled exception occurred");

        var (statusCode, message) = exception switch
        {
            UserNotFoundException => (StatusCodes.Status404NotFound, exception.Message),
            ArgumentNullException => (StatusCodes.Status400BadRequest, exception.Message),
            BusinessException businessEx => (StatusCodes.Status400BadRequest, businessEx.Message),
            _ => (StatusCodes.Status500InternalServerError, "An error occurred")
        };

        httpContext.Response.StatusCode = statusCode;
        await httpContext.Response.WriteAsJsonAsync(new { error = message }, cancellationToken);

        return true;
    }
}

// 注册
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
```

## 5. 异常日志

```csharp
// 记录异常日志
try
{
    await processAsync();
}
catch (Exception ex)
{
    _logger.LogError(ex, "Failed to process request: {RequestId}", requestId);
    throw;
}

// 使用 LogLevel
_logger.LogWarning("Retry attempt {Attempt} failed for user: {UserId}", attempt, userId);
_logger.LogDebug("User not found: {UserId}", userId);
```

## 6. 异常过滤

```csharp
// 异常过滤器
public class HttpExceptionFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        if (context.Exception is UserNotFoundException)
        {
            context.Result = new NotFoundObjectResult(new
            {
                error = context.Exception.Message
            });
        }
    }
}

// 使用
[TypeFilter(typeof(HttpExceptionFilter))]
public class UsersController : ControllerBase { }
```

## 7. Result 模式

```csharp
// 使用 Result 避免异常
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }

    public static Result<T> Success(T value) => new(true, value, null);
    public static Result<T> Failure(string error) => new(false, default, error);
}

public async Task<Result<User>> GetUserByIdAsync(int id)
{
    var user = await _repository.GetByIdAsync(id);
    if (user is null)
        return Result<User>.Failure($"User not found: {id}");
    return Result<User>.Success(user);
}

// 使用
var result = await _userService.GetUserByIdAsync(id);
if (!result.IsSuccess)
{
    return BadRequest(result.Error);
}
return Ok(result.Value);
```
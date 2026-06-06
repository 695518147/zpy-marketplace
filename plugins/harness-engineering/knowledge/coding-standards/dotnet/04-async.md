# .NET 异步编程规范

## 1. 异步基础

```csharp
// 异步方法命名 - 以 Async 结尾
public async Task<User> GetUserByIdAsync(int id) { ... }
public async Task CreateUserAsync(User user) { ... }
public async Task<IEnumerable<User>> GetAllUsersAsync() { ... }

// 避免 async void（事件处理程序除外）
public async void ProcessData(Data data)  // 错误
public async Task ProcessDataAsync(Data data)  // 正确
```

## 2. async/await 模式

```csharp
// 正确使用 async/await
public async Task<User> GetUserByIdAsync(int id)
{
    return await _userRepository.GetByIdAsync(id)
        ?? throw new UserNotFoundException(id);
}

// 避免过度包装
public async Task<string> GetDataAsync()
{
    var result = await _httpClient.GetStringAsync("url");
    return result;  // 不要 return await 简单表达式
}

// 使用 ValueTask
public async ValueTask<User?> GetUserAsync(int id)
{
    return await _cache.GetOrCreateAsync(id, async () =>
        await _repository.GetByIdAsync(id));
}
```

## 3. 并行执行

```csharp
// 并行等待多个任务
public async Task<UserOrderDto> GetUserOrderAsync(int userId, int orderId)
{
    // 顺序执行
    var user = await GetUserByIdAsync(userId);
    var order = await GetOrderByIdAsync(orderId);

    // 并行执行
    var userTask = GetUserByIdAsync(userId);
    var orderTask = GetOrderByIdAsync(orderId);
    await Task.WhenAll(userTask, orderTask);

    return new UserOrderDto(await userTask, await orderTask);
}

// WhenAny - 等待任意一个完成
var firstCompleted = await Task.WhenAny(task1, task2, task3);
var result = await firstCompleted;
```

## 4. 配置上下文

```csharp
// ConfigureAwait(false) 避免返回原始上下文
public async Task<string> GetDataAsync()
{
    using var response = await _httpClient.GetAsync("url");
    return await response.Content.ReadAsStringAsync().ConfigureAwait(false);
}

// 在库中始终使用 ConfigureAwait(false)
public async Task<List<User>> GetAllUsersAsync()
{
    var users = await _context.Users.ToListAsync().ConfigureAwait(false);
    return users;
}

// 在应用代码中可以使用 ConfigureAwait(true)（默认）
```

## 5. 取消令牌

```csharp
// 使用 CancellationToken
public async Task<User> GetUserByIdAsync(int id, CancellationToken cancellationToken = default)
{
    _logger.LogDebug("Getting user: {UserId}", id);
    return await _userRepository.GetByIdAsync(id, cancellationToken)
        ?? throw new UserNotFoundException(id);
}

// 传递取消令牌
public async Task ProcessUsersAsync(IEnumerable<int> userIds, CancellationToken cancellationToken)
{
    foreach (var userId in userIds)
    {
        cancellationToken.ThrowIfCancellationRequested();
        await ProcessUserAsync(userId, cancellationToken);
    }
}

// 控制器中使用
[HttpGet("{id}")]
public async Task<ActionResult<User>> GetUser(int id, CancellationToken cancellationToken)
{
    var user = await _userService.GetUserByIdAsync(id, cancellationToken);
    return Ok(user);
}
```

## 6. 异步流

```csharp
// IAsyncEnumerable - 流式处理
public async IAsyncEnumerable<User> GetUsersAsync([EnumeratorCancellation] CancellationToken cancellationToken = default)
{
    await foreach (var user in _repository.GetAllAsync(cancellationToken))
    {
        yield return user;
    }
}

// 使用
await foreach (var user in _userService.GetUsersAsync(cancellationToken))
{
    Console.WriteLine(user.Name);
}
```

## 7. 异步 LINQ

```csharp
// 使用 AsyncEnumerable 扩展
public static async Task<User?> FirstOrDefaultAsync<T>(
    this IAsyncEnumerable<T> source,
    Func<T, bool> predicate,
    CancellationToken cancellationToken = default)
{
    await foreach (var item in source.WithCancellation(cancellationToken))
    {
        if (predicate(item))
            return item;
    }
    return default;
}
```

## 8. 常见错误

```csharp
// 错误：同步方法调用异步方法
public User GetUser(int id)
{
    return _userService.GetUserByIdAsync(id).Result;  // 死锁风险
}

// 正确：使用异步
public async Task<User> GetUserAsync(int id)
{
    return await _userService.GetUserByIdAsync(id);
}

// 错误：忘记 await
public async Task SaveUserAsync(User user)
{
    await _repository.SaveAsync(user);
    await _emailService.SendWelcomeEmailAsync(user);  // 忘记 await
}

// 错误：在构造行数中使用 await
using var connection = new SqlConnection(connectionString);
await connection.OpenAsync();  // 打开连接
var users = await connection.QueryAsync<User>("SELECT * FROM Users");
```

## 9. 性能考虑

```csharp
// 避免在循环中等待
// 错误
foreach (var id in ids)
{
    var user = await GetUserByIdAsync(id);
}

// 正确
var tasks = ids.Select(id => GetUserByIdAsync(id));
var users = await Task.WhenAll(tasks);

// 使用 Task.WhenAll 时注意异常处理
try
{
    await Task.WhenAll(tasks);
}
catch (Exception ex)
{
    // 处理异常
    var completed = tasks.Where(t => t.IsCompletedSuccessfully).ToList();
    var failed = tasks.Where(t => t.IsFaulted).ToList();
}
```
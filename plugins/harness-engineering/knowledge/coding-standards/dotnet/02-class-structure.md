# .NET 类结构规范

## 1. 类组织顺序

```csharp
namespace Company.Project.Services;

public class UserService : IUserService
{
    // 1. 私有字段
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UserService> _logger;
    private const int MaxRetryCount = 3;

    // 2. 构造函数
    public UserService(
        IUserRepository userRepository,
        ILogger<UserService> logger)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    // 3. 公共方法
    public async Task<User> GetUserByIdAsync(int id)
    {
        _logger.LogDebug("Getting user by id: {UserId}", id);
        return await _userRepository.GetByIdAsync(id)
            ?? throw new UserNotFoundException(id);
    }

    // 4. 私有方法
    private void ValidateUser(User user)
    {
        if (user is null)
            throw new ArgumentNullException(nameof(user));
    }
}
```

## 2. 类长度控制

- 每个类不超过 500 行
- 超过 300 行应考虑拆分
- 遵循单一职责原则

## 3. 方法规范

```csharp
// 方法长度不超过 50 行
// 参数不超过 3 个（超过使用 DTO）
// 返回类型明确

// 推荐的参数传递
public async Task<UserDto> GetUserByIdAsync(int id)
{
    var user = await _repository.GetByIdAsync(id);
    return user?.ToDto();
}

// 使用参数对象
public async Task<Order> SearchOrdersAsync(OrderSearchCriteria criteria)
{
    // 处理搜索逻辑
}
```

## 4. 接口设计

```csharp
// 接口应该小而精确
public interface IUserRepository
{
    Task<User?> GetByIdAsync(int id);
    Task<IEnumerable<User>> GetAllAsync();
    Task<User> CreateAsync(User user);
    Task UpdateAsync(User user);
    Task DeleteAsync(int id);
}

// 实现接口
public class UserRepository : IUserRepository
{
    private readonly ApplicationDbContext _context;

    public UserRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        return await _context.Users.FindAsync(id);
    }
}
```

## 5. 依赖注入

```csharp
// 注册服务
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<ISettings, Settings>();

// 使用构造函数注入
public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;

    public UserService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }
}
```

## 6. 基类和抽象类

```csharp
// 抽象基类
public abstract class BaseService<T> where T : class
{
    protected readonly IRepository<T> _repository;

    protected BaseService(IRepository<T> repository)
    {
        _repository = repository;
    }

    protected virtual Task<T?> GetByIdAsync(int id)
    {
        return _repository.GetByIdAsync(id);
    }
}

// 继承
public class UserService : BaseService<User>, IUserService
{
    private readonly IEmailService _emailService;

    public UserService(
        IRepository<User> repository,
        IEmailService emailService)
        : base(repository)
    {
        _emailService = emailService;
    }
}
```

## 7. 扩展方法

```csharp
// 扩展方法类
public static class UserExtensions
{
    public static UserDto ToDto(this User user)
    {
        return new UserDto
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email
        };
    }

    public static bool IsActive(this User user)
    {
        return user.Status == UserStatus.Active;
    }
}
```
# .NET 安全规范

## 1. 输入验证

```csharp
// 使用 Data Annotations
public class CreateUserRequest
{
    [Required]
    [StringLength(50, MinimumLength = 2)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Range(0, 150)]
    public int? Age { get; set; }
}

// 使用 FluentValidation
public class CreateUserRequestValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Name is required")
            .Length(2, 50);

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Invalid email format");
    }
}
```

## 2. SQL 注入防护

```csharp
// 使用参数化查询
// 错误
var query = $"SELECT * FROM Users WHERE Name = '{name}'";

// 正确
var users = await _context.Users
    .Where(u => u.Name == name)
    .ToListAsync();

// 使用存储过程
var result = await _context.Database
    .ExecuteSqlRawAsync("EXEC sp_UpdateUser @p0, @p1", userId, newName);

// Dapper 参数化
connection.Query<User>("SELECT * FROM Users WHERE Name = @Name", new { Name = name });
```

## 3. 密码安全

```csharp
// 使用 BCrypt
using BCrypt.Net;

public string HashPassword(string password)
{
    return BCrypt.Net.BCrypt.HashPassword(password, workFactor: 12);
}

public bool VerifyPassword(string password, string hash)
{
    return BCrypt.Net.BCrypt.Verify(password, hash);
}

// 或使用 .NET 提供的 Rfc2898DeriveBytes
using System.Security.Cryptography;

public string HashPassword(string password, byte[] salt)
{
    var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
    return Convert.ToBase64String(pbkdf2.GetBytes(32));
}
```

## 4. XSS 防护

```csharp
// ASP.NET Core 自动编码
// Razor 默认编码所有输出
@Model.UserName  // 自动编码

// 如果需要显示 HTML（谨慎）
@Html.Raw(Model.HtmlContent)  // 仅在确信任内容安全时使用

// 使用 HtmlSanitizer
using Ganss.Xss;
var sanitizer = new HtmlSanitizer();
var sanitized = sanitizer.Sanitize(userInput);
```

## 5. 认证授权

```csharp
// JWT 配置
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// 授权策略
builder.Services.AddAuthorizationBuilder()
    .AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"))
    .AddPolicy("MinimumAge", policy => policy.RequireClaim("Age", "18"));

[Authorize(Policy = "AdminOnly")]
public class AdminController : ControllerBase { }
```

## 6. 敏感数据保护

```csharp
// 使用 secrets.json 或环境变量
builder.Configuration.AddEnvironmentVariables();

// 环境变量
Environment.GetEnvironmentVariable("DATABASE_PASSWORD");

// 数据脱敏
public string MaskCreditCard(string cardNumber)
{
    if (string.IsNullOrEmpty(cardNumber) || cardNumber.Length < 13)
        return cardNumber;
    return new string('*', cardNumber.Length - 4).Insert(0, cardNumber[..4]);
}

// 日志中不记录敏感信息
_logger.LogInformation("User login: Username={Username}", username);  // OK
_logger.LogInformation("User login: Password={Password}", password);  // 禁止
```

## 7. CSRF 防护

```csharp
// ASP.NET Core 默认启用 CSRF 保护
// 使用 Antiforgery Token
[ValidateAntiForgeryToken]
[HttpPost]
public IActionResult Create(UserCreateModel model) { ... }

// 前端
<form>
    @Html.AntiForgeryToken()
    ...
</form>
```

## 8. 限流

```csharp
// 使用 AspNetCoreRateLimit
builder.Services.AddMemoryCache();
builder.Services.Configure<IpRateLimitOptions>(options =>
{
    options.GeneralRules = new List<RateLimitRule>
    {
        new RateLimitRule
        {
            Endpoint = "*",
            Period = "1m",
            Limit = 100
        }
    };
});
builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();

// 或使用自定义中间件
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly Dictionary<string, int> _counters = new();
    private readonly object _lock = new();

    public async Task InvokeAsync(HttpContext context)
    {
        var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        if (!TryIncrement(key, 60, 100))
        {
            context.Response.StatusCode = 429;
            return;
        }
        await _next(context);
    }
}
```

## 9. 安全配置检查清单

- 生产环境禁用 DEBUG 模式
- 使用 HTTPS
- 配置安全的 Cookie（HttpOnly, Secure, SameSite）
- 启用 CORS 限制
- 设置安全的 HTTP 头
- 限制请求大小
- 实现审计日志
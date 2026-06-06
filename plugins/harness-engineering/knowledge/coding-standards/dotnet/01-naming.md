# .NET 命名规范

## 1. 通用规则

- 使用有意义的英文命名
- 变量和方法使用 camelCase
- 类型、属性、类名使用 PascalCase
- 常量使用 PascalCase
- 接口名以 I 开头
- 私有字段以 _ 开头或使用 _camelCase

## 2. 命名空间

```csharp
// 命名空间格式
namespace Company.Project.Module;

namespace Company.Product.Business Logic;
namespace Company.Product.Data.Access;
namespace Company.Product.Services;
namespace Company.Product.Web.Api;
namespace Company.Product.Web.UI;
```

## 3. 类命名

```csharp
// 普通类
public class UserService { }
public class OrderController { }

// 抽象类
public abstract class BaseRepository<T> { }

// 接口
public interface IUserRepository { }
public interface IEmailService { }

// 异常类
public class UserNotFoundException : Exception { }

// 枚举
public enum OrderStatus { Pending, Paid, Shipped, Completed }
public enum HttpStatusCode { OK = 200, NotFound = 404 }
```

## 4. 方法命名

```csharp
// 使用动词或动词短语
public User GetUserById(int id) { }
public void CreateUser(User user) { }
public bool ValidateInput(string input) { }
public decimal CalculateTotal(Order order) { }

// 异步方法
public async Task<User> GetUserByIdAsync(int id) { }
public async Task CreateUserAsync(User user) { }
```

## 5. 属性命名

```csharp
// 公共属性 - PascalCase
public string UserName { get; set; }
public int PageSize { get; set; }

// 布尔属性
public bool IsActive { get; set; }
public bool HasPermission { get; set; }

// 私有字段 - _camelCase
private readonly IUserRepository _userRepository;
private string _connectionString;
```

## 6. 变量命名

```csharp
// 普通变量
string userName = "张三";
int pageSize = 20;
bool isDeleted = false;

// 可空类型
int? userId = null;
string? email = null;

// 集合变量
List<User> users = new();
IEnumerable<User> userList = users;
Dictionary<string, User> userMap = new();

// 常量
public const int MaxRetryCount = 3;
private const string DefaultVersion = "v1";
```

## 7. 文件命名

```
// 类文件
UserService.cs
OrderController.cs
UserNotFoundException.cs

// 接口文件（紧跟实现类）
IUserRepository.cs
IUserRepository.cs  // 与 UserRepository.cs 同目录

// 设计器文件
User.Designer.cs
Order.Designer.cs

// 测试文件
UserServiceTests.cs
UserServiceTests_GetUserById.cs
```

## 8. 命名禁忌

- 避免使用缩写（除非通用缩写）
- 避免使用无意义命名
- 避免使用中文拼音
- 避免在类型名后加类型后缀（如 UserClass）
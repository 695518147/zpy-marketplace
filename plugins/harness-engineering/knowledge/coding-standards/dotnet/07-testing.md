# .NET 测试规范

## 1. 测试框架

使用 xUnit + Moq + FluentAssertions。

```csharp
// 测试项目引用
<PackageReference Include="xunit" Version="2.6.2" />
<PackageReference Include="xunit.runner.visualstudio" Version="2.5.4" />
<PackageReference Include="Moq" Version="4.20.70" />
<PackageReference Include="FluentAssertions" Version="6.12.0" />
<PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
```

## 2. 单元测试

```csharp
using Xunit;
using FluentAssertions;

public class UserServiceTests
{
    private readonly Mock<IUserRepository> _mockRepository;
    private readonly UserService _service;

    public UserServiceTests()
    {
        _mockRepository = new Mock<IUserRepository>();
        _service = new UserService(_mockRepository.Object);
    }

    [Fact]
    public async Task GetUserById_WhenUserExists_ReturnsUser()
    {
        // Arrange
        var userId = 1;
        var expectedUser = new User { Id = userId, Name = "Alice" };
        _mockRepository.Setup(r => r.GetByIdAsync(userId))
            .ReturnsAsync(expectedUser);

        // Act
        var result = await _service.GetUserByIdAsync(userId);

        // Assert
        result.Should().NotBeNull();
        result.Should().BeEquivalentTo(expectedUser);
    }

    [Fact]
    public async Task GetUserById_WhenUserNotExists_ThrowsException()
    {
        // Arrange
        var userId = 999;
        _mockRepository.Setup(r => r.GetByIdAsync(userId))
            .ReturnsAsync((User?)null);

        // Act & Assert
        await Assert.ThrowsAsync<UserNotFoundException>(
            () => _service.GetUserByIdAsync(userId));
    }
}
```

## 3. 参数化测试

```csharp
[Theory]
[InlineData(0, 0)]
[InlineData(1, 10)]
[InlineData(5, 50)]
[InlineData(10, 100)]
public async Task CalculateTotal_ReturnsCorrectAmount(int quantity, decimal expected)
{
    // Arrange
    var items = new[] { new Item { Quantity = quantity, Price = 10 } };

    // Act
    var result = await _calculator.CalculateTotalAsync(items);

    // Assert
    result.Should().Be(expected);
}

[Theory]
[InlineData("alice@example.com", true)]
[InlineData("invalid-email", false)]
[InlineData("", false)]
public void IsValidEmail_ReturnsExpectedResult(string email, bool expected)
{
    _validator.IsValidEmail(email).Should().Be(expected);
}
```

## 4. Mock 使用

```csharp
// Mock 行为设置
var mockRepository = new Mock<IUserRepository>();

// 返回值
mockRepository.Setup(r => r.GetByIdAsync(1))
    .ReturnsAsync(new User { Id = 1, Name = "Alice" });

// 返回 null
mockRepository.Setup(r => r.GetByIdAsync(999))
    .ReturnsAsync((User?)null);

// 抛出异常
mockRepository.Setup(r => r.GetByIdAsync(-1))
    .ThrowsAsync(new ArgumentException("Invalid ID"));

// 设置输出参数
mockRepository.Setup(r => r.SearchAsync(It.IsAny<string>(), out userList))
    .Returns(true);

// 验证调用
mockRepository.Verify(r => r.SaveAsync(It.IsAny<User>()), Times.Once);
mockRepository.Verify(r => r.DeleteAsync(It.IsAny<int>()), Times.Never);

// 回调
mockRepository.Setup(r => r.SaveAsync(It.IsAny<User>()))
    .Callback<User>(user => Console.WriteLine($"Saved: {user.Name}"));
```

## 5. 测试数据

```csharp
// 使用测试数据构建器
public class UserBuilder
{
    private User _user = new();

    public UserBuilder WithId(int id)
    {
        _user.Id = id;
        return this;
    }

    public UserBuilder WithName(string name)
    {
        _user.Name = name;
        return this;
    }

    public UserBuilder WithEmail(string email)
    {
        _user.Email = email;
        return this;
    }

    public User Build() => _user;
}

// 使用
var user = new UserBuilder()
    .WithId(1)
    .WithName("Alice")
    .WithEmail("alice@example.com")
    .Build();
```

## 6. 集成测试

```csharp
[Collection("Database")]
public class UserRepositoryTests : IDisposable
{
    private readonly TestDatabaseFixture _fixture;

    public UserRepositoryTests(TestDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task CreateUser_PersistsToDatabase()
    {
        // Arrange
        using var context = _fixture.CreateContext();
        var repository = new UserRepository(context);
        var user = new User { Name = "Bob", Email = "bob@example.com" };

        // Act
        var created = await repository.CreateAsync(user);

        // Assert
        created.Id.Should().BeGreaterThan(0);
        var persisted = await context.Users.FindAsync(created.Id);
        persisted.Should().NotBeNull();
    }
}

// Database fixture
public class TestDatabaseFixture : IDisposable
{
    public ApplicationDbContext CreateContext()
    {
        return new ApplicationDbContext(
            new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase()
                .Options);
    }

    public void Dispose() { }
}
```

## 7. 覆盖率

```bash
# 运行覆盖率
dotnet test --collect:"XPlat Code Coverage"
dotnet reportgenerator -reports:coverage.cobertura.xml -targetdir:coverage-report

# .csproj 配置
<PropertyGroup>
  <CollectCoverage>true</CollectCoverage>
  <CoverletOutputFormat>opencover</CoverletOutputFormat>
  <Threshold>80</Threshold>
</PropertyGroup>
```

## 8. 测试原则

- 每个测试只测试一个概念
- 测试应该独立，不依赖其他测试
- 使用清晰的测试命名（方法_场景_预期结果）
- Arrange-Act-Assert 模式
- 避免测试实现细节
- 测试边界条件
- 保持测试快速
# Go 测试规范

## 1. 测试文件组织

```go
// 文件命名
user_service.go          // 源文件
user_service_test.go     // 单元测试
user_service_test.go     // 集成测试（可分离）

// 测试函数命名
func TestFindByID(t *testing.T) { ... }
func TestFindByID_NotFound(t *testing.T) { ... }
func TestFindByID_InvalidID(t *testing.T) { ... }
func BenchmarkFindByID(b *testing.B) { ... }
func ExampleFindByID(t *testing.T) { ... }
```

## 2. 单元测试

```go
import (
    "testing"
    "errors"
)

func TestFindByID(t *testing.T) {
    // 准备数据
    repo := NewMockUserRepository()
    repo.Users = []User{
        {ID: 1, Name: "Alice"},
        {ID: 2, Name: "Bob"},
    }
    svc := NewUserService(repo)

    // 执行测试
    user, err := svc.FindByID(1)

    // 验证结果
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Name != "Alice" {
        t.Errorf("expected name Alice, got %s", user.Name)
    }
}
```

## 3. 表驱动测试

```go
func TestCalculateTotal(t *testing.T) {
    tests := []struct {
        name     string
        items    []Item
        expected float64
    }{
        {
            name:     "empty items",
            items:    []Item{},
            expected: 0,
        },
        {
            name: "single item",
            items: []Item{{Price: 10}},
            expected: 10,
        },
        {
            name: "multiple items",
            items: []Item{{Price: 10}, {Price: 20}},
            expected: 30,
        },
        {
            name: "with discount",
            items: []Item{{Price: 100, Discount: 10}},
            expected: 90,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := CalculateTotal(tt.items)
            if result != tt.expected {
                t.Errorf("expected %f, got %f", tt.expected, result)
            }
        })
    }
}
```

## 4. 模拟对象

```go
// 定义接口
type UserRepository interface {
    FindByID(id int) (*User, error)
    Save(user *User) error
}

// 使用 mock
type mockUserRepository struct {
    users  map[int]*User
    called bool
}

func (m *mockUserRepository) FindByID(id int) (*User, error) {
    m.called = true
    if user, ok := m.users[id]; ok {
        return user, nil
    }
    return nil, ErrNotFound
}

func TestUserService(t *testing.T) {
    repo := &mockUserRepository{
        users: map[int]*User{1: {ID: 1, Name: "Alice"}},
    }
    svc := NewUserService(repo)

    user, err := svc.FindByID(1)
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if !repo.called {
        t.Error("expected repository to be called")
    }
}
```

## 5. 测试覆盖率

```bash
# 查看覆盖率
go test -cover ./...

# 生成覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html

# 检查特定包的覆盖率
go test -coverprofile=coverage.out ./user/...
go tool cover -func=coverage.out
```

## 6. Benchmark 测试

```go
func BenchmarkFindByID(b *testing.B) {
    repo := NewMockUserRepository(10000)
    svc := NewUserService(repo)

    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, _ = svc.FindByID(rand.Intn(10000))
    }
}

// 运行 benchmark
go test -bench=. -benchmem ./...

// 对比性能
go test -bench=. -benchmem -cpuprofile=cpu.out ./...
go tool pprof cpu.out
```

## 7. 集成测试

```go
import (
    "os"
    "testing"
    "database/sql"
    _ "github.com/go-sql-driver/mysql"
)

func TestMain(m *testing.M) {
    // 设置测试数据库
    os.Setenv("DB_HOST", "localhost")
    os.Setenv("DB_NAME", "test_db")

    code := m.Run()
    os.Exit(code)
}

func TestUserRepository(t *testing.T) {
    // 跳过如果没有数据库
    if os.Getenv("SKIP_INTEGRATION") == "true" {
        t.Skip("skipping integration test")
    }

    db, err := sql.Open("mysql", "user:pass@tcp(localhost)/testdb")
    if err != nil {
        t.Fatalf("failed to connect: %v", err)
    }
    defer db.Close()

    repo := NewSQLUserRepository(db)
    user, err := repo.FindByID(1)
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    t.Logf("found user: %v", user)
}
```

## 8. 测试工具

```go
// 使用 testify
import (
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

func TestUserService(t *testing.T) {
    mockRepo := new(MockUserRepository)
    mockRepo.On("FindByID", 1).Return(&User{ID: 1}, nil)

    svc := NewUserService(mockRepo)
    user, err := svc.FindByID(1)

    assert.NoError(t, err)
    assert.Equal(t, 1, user.ID)
    mockRepo.AssertExpectations(t)
}

// 使用 httptest
import "net/http/httptest"

func TestHandler(t *testing.T) {
    req := httptest.NewRequest("GET", "/users/1", nil)
    rec := httptest.NewRecorder()

    handler := http.HandlerFunc(userHandler)
    handler.ServeHTTP(rec, req)

    assert.Equal(t, http.StatusOK, rec.Code)
}
```

## 9. 测试原则

- 测试应该是确定性的
- 每个测试应该独立
- 避免测试实现细节
- 测试边界条件
- 保持测试快速
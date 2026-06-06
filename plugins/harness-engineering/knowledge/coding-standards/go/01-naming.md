# Go 命名规范

## 1. 通用规则

- 使用有意义的英文命名
- 变量名和函数名使用 camelCase（私有）或 PascalCase（导出）
- 常量使用 PascalCase（导出）或 camelCase（私有）
- 包名小写，使用简短命名

## 2. 包命名

```go
// 包名小写简短
import "fmt"
import "strings"

import "github.com/company/project/repository"
import "github.com/company/project/service"

// 避免重复
package user          // 不要 package userService
package userv1         // API 版本控制
```

## 3. 变量命名

```go
// 普通变量 - 使用驼峰
var userName string
var pageSize int
var isDeleted bool

// 导出变量 - 使用 PascalCase
var MaxRetryCount = 3
var DefaultPageSize = 20

// 常量
const MaxRetryCount = 3
const apiBaseURL = "https://api.example.com"

// 集合命名
var users []User
var userMap map[string]User
var userIDs []int

// 布尔变量
var isActive bool
var hasPermission bool
var canEdit bool
```

## 4. 函数命名

```go
// 导出函数 - PascalCase
func GetUserByID(id int) (*User, error) { ... }
func CreateUser(user *User) error { ... }
func CalculateTotal(amount float64) float64 { ... }

// 私有函数 - camelCase
func validateInput(data string) bool { ... }
func processRequest(req *Request) error { ... }

// 方法命名
type UserService struct{}
func (s *UserService) FindByID(id int) (*User, error) { ... }
func (s *UserService) Create(ctx context.Context, user *User) error { ... }
```

## 5. 接口命名

```go
// 接口名使用名词或动词+名词
type Reader interface {
    Read(p []byte) (n int, err error)
}

type UserRepository interface {
    FindByID(ctx context.Context, id int) (*User, error)
    Save(ctx context.Context, user *User) error
    Delete(ctx context.Context, id int) error
}

type Logger interface {
    Info(msg string, fields ...Field)
    Error(err error, msg string, fields ...Field)
}
```

## 6. 结构体 命名

```go
// 结构体 - PascalCase
type User struct {
    ID    int
    Name  string
    Email string
}

// 错误类型 - 以 Error 结尾
type NotFoundError struct {
    Resource string
    ID      int
}
func (e *NotFoundError) Error() string {
    return fmt.Sprintf("%s not found: %d", e.Resource, e.ID)
}
```

## 7. 测试文件命名

```go
// 单元测试
user_service_test.go

// 集成测试
user_service_integration_test.go

// 测试用例函数
func TestFindByID(t *testing.T) { ... }
func TestFindByID_NotFound(t *testing.T) { ... }
func BenchmarkFindByID(b *testing.B) { ... }
```

## 8. 命名禁忌

- 避免使用下划线命名（除非测试文件）
- 避免使用缩写（除非是通用缩写）
- 避免使用单字母变量（循环变量除外）
- 避免重复包名
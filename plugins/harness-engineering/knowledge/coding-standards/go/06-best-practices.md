# Go 最佳实践

## 1. 项目结构

```
project/
├── cmd/
│   └── app/
│       └── main.go
├── internal/
│   ├── api/
│   │   ├── handler/
│   │   ├── middleware/
│   │   └── router.go
│   ├── config/
│   ├── domain/
│   │   ├── model/
│   │   └── repository/
│   ├── service/
│   └── repository/
├── pkg/
│   └── utils/
├── configs/
├── scripts/
├── go.mod
└── README.md
```

## 2. 依赖管理

```go
// go.mod
module github.com/company/project

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    go.uber.org/zap v1.26.0
)

// 使用 go mod tidy 整理依赖
// 使用 go mod verify 验证依赖
```

## 3. 错误处理

```go
// 错误包装
if err != nil {
    return fmt.Errorf("user service: %w", err)
}

// 错误判断
if errors.Is(err, sql.ErrNoRows) {
    // 处理未找到
}

// 错误日志
slog.Info("operation failed", "error", err)
```

## 4. Context 传递

```go
// 在函数间传递 context
func findUser(ctx context.Context, id int) (*User, error) {
    user, err := repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    return user, nil
}

// HTTP handler 中获取 context
func handler(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    user, err := findUser(ctx, getUserID(r))
}
```

## 5. 接口设计

```go
// 接口应该小而精确
type Reader interface {
    Read(p []byte) (n int, err error)
}

// 实现接口的值接收者
func (u User) String() string {
    return fmt.Sprintf("%s <%s>", u.Name, u.Email)
}

// 指针接收者用于修改
func (u *User) Update(name string) {
    u.Name = name
}
```

## 6. 并发安全

```go
// 使用 sync.Map 对于读多写少
var cache sync.Map

func getCached(key string) (interface{}, bool) {
    return cache.Load(key)
}

func setCached(key string, value interface{}) {
    cache.Store(key, value)
}

// 使用 channel 进行通信
func worker(in <-chan Work, out chan<- Result) {
    for w := range in {
        out <- Result{Value: w.Value * 2}
    }
}
```

## 7. 性能优化

```go
// 避免不必要的内存分配
// 使用切片预分配
items := make([]Item, 0, len(expectSize))

// 对象池
var pool = sync.Pool{
    New: func() interface{} {
        return &bytes.Buffer{}
    },
}

buf := pool.Get().(*bytes.Buffer)
defer pool.Put(buf)

// 字符串拼接优化
var builder strings.Builder
builder.WriteString("hello")
builder.WriteString(" world")
result := builder.String()
```

## 8. 数据库操作

```go
// 使用 sqlx
import "github.com/jmoiron/sqlx"

var users []User
err := db.Select(&users, "SELECT * FROM users WHERE age > ?", 18)

// 事务处理
tx, err := db.Begin()
if err != nil {
    return err
}
defer tx.Rollback()

_, err = tx.Exec("INSERT INTO users (name) VALUES (?)", name)
if err != nil {
    return err
}

return tx.Commit()
```

## 9. HTTP 服务

```go
// Gin 框架
import "github.com/gin-gonic/gin"

func setupRouter() *gin.Engine {
    r := gin.Default()

    r.GET("/users/:id", getUser)
    r.POST("/users", createUser)

    return r
}

// 中间件
func authMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            c.AbortWithStatus(401)
            return
        }
        c.Next()
    }
}
```

## 10. 配置管理

```go
import "github.com/knadh/koanf"

var k = koanf.New(".")

k.Load("config.yaml", yaml.Parser())

// 环境变量
k.Load("env", koanf EnvVars)

dbHost := k.String("database.host")
dbPort := k.Int("database.port")
```

## 11. 代码格式化

```bash
# 格式化代码
gofmt -w .

# 静态分析
golangci-lint run

# 检查未使用变量
go vet ./...

# 整理依赖
go mod tidy
```

## 12. API 设计

```go
// RESTful 路由设计
GET    /users          // 列表
GET    /users/:id      // 详情
POST   /users          // 创建
PUT    /users/:id      // 更新
DELETE /users/:id      // 删除

// 响应格式
type Response struct {
    Code    int         `json:"code"`
    Message string      `json:"message"`
    Data    interface{} `json:"data,omitempty"`
}
```
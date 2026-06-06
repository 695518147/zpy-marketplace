# Go 错误处理规范

## 1. 错误是值

```go
// 错误作为返回值
func findUser(id int) (*User, error) {
    user, err := repository.FindByID(id)
    if err != nil {
        return nil, err
    }
    return user, nil
}

// 多返回值是 Go 的惯用法
result, err := doSomething()
if err != nil {
    // 处理错误
}
```

## 2. 自定义错误

```go
import "errors"

// 定义错误变量
var (
    ErrUserNotFound   = errors.New("user not found")
    ErrInvalidInput   = errors.New("invalid input")
    ErrUnauthorized   = errors.New("unauthorized")
)

// 自定义错误类型
type NotFoundError struct {
    Resource string
    ID       int
}

func (e *NotFoundError) Error() string {
    return fmt.Sprintf("%s not found: %d", e.Resource, e.ID)
}

// 使用 errors.Is 检查错误
if errors.Is(err, ErrUserNotFound) {
    // 处理用户未找到
}

// 使用 errors.As 转换错误类型
var notFoundErr *NotFoundError
if errors.As(err, &notFoundErr) {
    fmt.Printf("Resource: %s, ID: %d\n", notFoundErr.Resource, notFoundErr.ID)
}
```

## 3. 错误处理模式

```go
// 早期返回（首选）
func process(data []byte) error {
    if len(data) == 0 {
        return errors.New("data is empty")
    }
    // 处理逻辑
}

// 包装错误
if err != nil {
    return fmt.Errorf("failed to find user: %w", err)
}

// 带上下文的错误
if err := db.Query(sql); err != nil {
    return fmt.Errorf("query user by id %d: %w", id, err)
}
```

## 4. 错误与日志

```go
import "log"

// 在最外层记录错误
func main() {
    if err := run(); err != nil {
        log.Fatalf("Application failed: %v", err)
    }
}

// 在中间层传播错误（不记录）
func findUser(id int) (*User, error) {
    user, err := db.FindByID(id)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    return user, nil
}

// 在边缘记录错误
handler := func(w http.ResponseWriter, r *http.Request) {
    if err := process(r); err != nil {
        log.Printf("Process request failed: %v", err)
        http.Error(w, "Internal error", 500)
    }
}
```

## 5. 批量错误处理

```go
import "errors"

// 收集多个错误
var errs []error
for _, task := range tasks {
    if err := execute(task); err != nil {
        errs = append(errs, err)
    }
}
if len(errs) > 0 {
    return fmt.Errorf("failed tasks: %d, first error: %w", len(errs), errs[0])
}

// 使用 errgroup
import "golang.org/x/sync/errgroup"

func parallelProcess(items []Item) error {
    g := new(errgroup.Group)
    for _, item := range items {
        item := item
        g.Go(func() error {
            return process(item)
        })
    }
    return g.Wait()
}
```

## 6. 无错误情况

```go
// 返回空切片而非 nil
func getUsers() ([]User, error) {
    return []User{}, nil  // 不用 return nil, nil
}

// 布尔函数使用清晰命名
func exists(users []User, id int) bool {
    for _, u := range users {
        if u.ID == id {
            return true
        }
    }
    return false
}

// 使用指针表示可选
type Config struct {
    Timeout *time.Duration  // nil 表示使用默认值
}
```

## 7. 避免的错误模式

```go
// 避免忽略错误
result, _ := doSomething()  // 错误：忽略错误

// 避免在循环中记录后继续
for _, item := range items {
    if err := process(item); err != nil {
        log.Printf("Process item %d failed: %v", item.ID, err)
        continue  // 明确继续而非遗漏
    }
}

// 避免错误默认值
func findUser(id int) (*User, error) {
    user, err := db.FindByID(id)
    if err != nil {
        return nil, err  // 直接返回，不用自定义错误
    }
    return user, nil
}
```
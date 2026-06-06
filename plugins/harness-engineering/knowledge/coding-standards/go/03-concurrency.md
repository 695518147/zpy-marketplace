# Go 并发规范

## 1. Goroutine 管理

```go
// 启动 goroutine 时考虑生命周期
func process(ctx context.Context, data []byte) error {
    result := make(chan error, 1)
    go func() {
        result <- doWork(data)
    }()

    select {
    case <-ctx.Done():
        return ctx.Err()
    case err := <-result:
        return err
    }
}

// 使用 WaitGroup 等待完成
var wg sync.WaitGroup
for i := 0; i < 10; i++ {
    wg.Add(1)
    go func(id int) {
        defer wg.Done()
        process(id)
    }(i)
}
wg.Wait()
```

## 2. Channel 使用

```go
// 创建有缓冲 channel
ch := make(chan Task, 100)

// 关闭 channel
close(ch)  // 仅在发送端关闭

// Channel 方向
func send(ch chan<- string) { ... }  // 只能发送
func receive(ch <-chan string) { ... }  // 只能接收

// 遍历 channel
for item := range ch {
    fmt.Println(item)
}

// 适当大小的 buffer
work := make(chan WorkRequest, 1000)  // 避免频繁阻塞
```

## 3. 同步原语

```go
import "sync"

// Mutex 保护共享状态
type Counter struct {
    mu  sync.Mutex
    cnt int
}

func (c *Counter) Inc() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.cnt++
}

// RWMutex 适用于读多写少
type Cache struct {
    mu  sync.RWMutex
    m   map[string]string
}

func (c *Cache) Get(key string) string {
    c.mu.RLock()
    defer c.mu.RUnlock()
    return c.m[key]
}

func (c *Cache) Set(key, value string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.m[key] = value
}

// Once 只执行一次
var once sync.Once
var instance *Singleton

func GetInstance() *Singleton {
    once.Do(func() {
        instance = &Singleton{}
    })
    return instance
}

// Map 并发安全
var safeMap sync.Map
safeMap.Store("key", "value")
value, ok := safeMap.Load("key")
```

## 4. Context 使用

```go
// 传递 context
func findUser(ctx context.Context, id int) (*User, error) {
    user, err := db.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    return user, nil
}

// WithTimeout 限制时间
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

// WithCancel 取消操作
ctx, cancel := context.WithCancel(context.Background())
go func() {
    <-stopCh
    cancel()
}()

// 检查 ctx 是否取消
select {
case <-ctx.Done():
    return ctx.Err()
default:
    // 继续执行
}
```

## 5. 并发模式

```go
// 生产者-消费者
func pipeline(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        for v := range in {
            out <- v * 2
        }
        close(out)
    }()
    return out
}

// 扇入-扇出
func merge(inputs ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup
    for _, ch := range inputs {
        wg.Add(1)
        go func(c <-chan int) {
            defer wg.Done()
            for v := range c {
                out <- v
            }
        }(ch)
    }
    go func() {
        wg.Wait()
        close(out)
    }()
    return out
}
```

## 6. 避免常见错误

```go
// 避免 goroutine 泄漏
func leak() {
    ch := make(chan int)
    // 没有发送者，range 永远阻塞
    for v := range ch {
        fmt.Println(v)
    }
}

// 使用 select + default 避免阻塞
select {
case msg := <-ch:
    fmt.Println(msg)
case <-time.After(time.Second):
    fmt.Println("timeout")
default:
    fmt.Println("no message")
}

// 避免共享变量
// 正确做法：使用 channel 传递数据
func worker(in <-chan int, out chan<- int) {
    for v := range in {
        out <- v * 2
    }
}
```

## 7. 竞态检测

```bash
# 使用 race 检测器
go test -race ./...

# 运行时检测
go run -race main.go

# 检测结果示例
WARNING: DATA RACE
Read at 0x00c00012c008 by goroutine 7:
  ...
Write at 0x00c00012c008 by goroutine 8:
  ...
```

## 8. 并发安全 map

```go
// sync.Map 适用于读多写少场景
var m sync.Map
m.Store("key", "value")
if v, ok := m.Load("key"); ok {
    fmt.Println(v)
}
m.Delete("key")

// 遍历
m.Range(func(key, value any) bool {
    fmt.Printf("%s: %s\n", key, value)
    return true
})
```
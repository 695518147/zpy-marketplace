# Recommended Patterns — 推荐模式

本文档记录推荐的设计模式和最佳实践。

---

## 设计模式

### 1. 策略模式 (Strategy Pattern)
定义一系列算法，使它们可以互相替换。

**适用场景**：
- 多种支付方式
- 多种排序算法
- 多种验证规则

**示例**：
```java
interface PaymentStrategy {
    void pay(double amount);
}

class WechatPay implements PaymentStrategy {
    public void pay(double amount) { /* ... */ }
}

class Alipay implements PaymentStrategy {
    public void pay(double amount) { /* ... */ }
}
```

---

### 2. 工厂模式 (Factory Pattern)
创建对象而不暴露创建逻辑。

**适用场景**：
- 对象创建复杂
- 需要统一创建入口
- 解耦创建者和使用者

**示例**：
```java
class PaymentFactory {
    static PaymentStrategy create(String type) {
        return switch (type) {
            case "wechat" -> new WechatPay();
            case "alipay" -> new Alipay();
            default -> throw new IllegalArgumentException();
        };
    }
}
```

---

### 3. 观察者模式 (Observer Pattern)
定义对象间一对多依赖关系。

**适用场景**：
- 事件监听
- 消息通知
- 数据同步

**示例**：
```java
interface Observer {
    void update(String event);
}

class UserService implements Observer {
    public void update(String event) {
        // 收到通知后处理
    }
}
```

---

## 架构模式

### 4. 分层架构 (Layered Architecture)
按职责分为多层。

**推荐分层**：
```
Controller/API Layer    ← 接入层
Service Layer          ← 业务逻辑层
Repository/DAO Layer   ← 数据访问层
Entity/Model Layer     ← 数据模型层
```

### 5. CQRS (Command Query Responsibility Segregation)
分离读写操作。

**适用场景**：
- 读多写少
- 需要分别优化读写性能
- 复杂业务域

---

## 测试模式

### 6. AAA 模式 (Arrange-Act-Assert)
测试组织结构。

**示例**：
```python
def test_user_creation():
    # Arrange
    repo = UserRepository()
    service = UserService(repo)

    # Act
    user = service.create("test@example.com", "password")

    # Assert
    assert user.email == "test@example.com"
```

### 7. Test Pyramid
测试金字塔。

**结构**：
```
       ┌─────────┐
       │   E2E   │     ← 少量端到端测试
      ┌──────────┐
      │ Integration│   ← 适量集成测试
     ┌────────────┐
     │   Unit     │     ← 大量单元测试
```

---

## 工程实践

### 8. 十二条因子 (12-Factor App)
云原生应用最佳实践。

1. 代码基准 (Codebase)
2. 依赖 (Dependencies)
3. 配置 (Config)
4. 后端服务 (Backing Services)
5. 构建、发布、运行 (Build, Release, Run)
6. 进程 (Processes)
7. 端口绑定 (Port Binding)
8. 并发 (Concurrency)
9. 易处置 (Disposability)
10. 开发环境与生产环境等价 (Dev/Prod Parity)
11. 日志 (Logs)
12. 管理进程 (Admin Processes)
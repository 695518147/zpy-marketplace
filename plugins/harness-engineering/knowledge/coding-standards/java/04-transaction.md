# Java 事务规范

## 1. 事务基础原则

- 默认情况下，Spring 事务在 `RuntimeException` 时回滚
- 使用 `@Transactional` 注解声明事务
- 事务边界应清晰，避免嵌套事务

## 2. 事务注解使用

```java
// 读操作使用 readOnly = true
@Service
@Transactional(readOnly = true)
public class UserQueryService {
    public User findById(Long id) {
        return userRepository.findById(id).orElse(null);
    }
}

// 写操作默认事务
@Service
@Transactional
public class UserWriteService {
    public User create(User user) {
        return userRepository.save(user);
    }
}
```

## 3. 事务传播行为

| 传播行为 | 说明 |
|----------|------|
| `REQUIRED` | 默认，存在事务则加入，否则创建新事务 |
| `REQUIRES_NEW` | 总是创建新事务，暂停当前事务 |
| `NESTED` | 使用嵌套事务（需要数据库支持） |
| `SUPPORTS` | 存在事务则加入，否则无事务执行 |
| `NOT_SUPPORTED` | 以非事务执行，挂起当前事务 |

```java
// 日志服务应总是创建新事务
@Service
@Transactional(propagation = Propagation.REQUIRES_NEW)
public class AuditLogService {
    public void log(String action) { ... }
}
```

## 4. 事务锁定

```java
// 乐观锁
@Entity
public class User {
    @Version
    private Long version;
}

// 悲观锁 - 读取时锁定
@Service
public class OrderService {
    @Transactional
    public Order getOrderWithLock(Long orderId) {
        return orderRepository.findByIdWithLock(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
    }
}

// Repository
@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("SELECT o FROM Order o WHERE o.id = :id")
Optional<Order> findByIdWithLock(@Param("id") Long id);
```

## 5. 事务注意事项

```java
// 1. 不要在事务中执行远程调用
@Transactional
public void createOrder(Order order) {
    orderRepository.save(order);
    // 错误：不要在这里调用第三方 API
    paymentService.process(order);  // 可能导致事务超时
}

// 2. 不要在事务中执行大量操作
@Transactional
public void importUsers(List<User> users) {
    for (User user : users) {
        userRepository.save(user);  // 效率低
    }
    // 使用批量操作
}

// 3. 事务方法内部不要捕获异常后抛出
@Transactional
public void updateUser(User user) {
    try {
        doUpdate(user);
    } catch (Exception e) {
        log.error("Update failed", e);
        throw e;  // 正确：保持异常传播
    }
}
```

## 6. 事务超时

```java
@Transactional(timeout = 30)  // 30 秒超时
public void processBatch(List<Long> ids) {
    // 处理逻辑
}
```

## 7. 事务与锁顺序

```java
// 为避免死锁，始终按固定顺序获取锁
// 例：先锁定用户，再锁定订单

@Service
public class TransferService {
    @Transactional
    public void transfer(Long fromUserId, Long toUserId, BigDecimal amount) {
        // 总是先锁定较小 ID
        User first = fromUserId < toUserId ?
            userRepository.lockById(fromUserId) :
            userRepository.lockById(toUserId);
        User second = fromUserId < toUserId ?
            userRepository.lockById(toUserId) :
            userRepository.lockById(fromUserId);

        // 执行转账
    }
}
```
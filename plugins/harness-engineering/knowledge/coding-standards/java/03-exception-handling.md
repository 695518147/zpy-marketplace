# Java 异常处理规范

## 1. 异常分类

| 类型 | 用途 | 示例 |
|------|------|------|
| `IllegalArgumentException` | 参数校验失败 | 参数为 null 或非法值 |
| `IllegalStateException` | 状态异常 | 对象状态不允许操作 |
| `EntityNotFoundException` | 实体不存在 | 找不到对应的数据 |
| `BusinessException` | 业务逻辑异常 | 业务规则不满足 |

## 2. 异常抛出原则

```java
// 1. 抛出自描述的异常
throw new EntityNotFoundException("User not found with id: " + id);

// 2. 不返回 null，使用 Optional 或抛出异常
public Optional<User> findById(Long id) { ... }

public User findByIdRequired(Long id) {
    return findById(id)
        .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + id));
}

// 3. 避免返回 null 集合
public List<User> findAll() {
    return Collections.emptyList(); // 不用返回 null
}
```

## 3. 异常捕获规范

```java
// 捕获特定异常，不捕获 Exception
try {
    userRepository.deleteById(id);
} catch (DataAccessException e) {
    log.error("Failed to delete user: {}", id, e);
    throw new DataAccessException("Failed to delete user");
}

// 使用 @ExceptionHandler 统一处理
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException e) {
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(e.getMessage()));
    }
}
```

## 4. 自定义异常定义

```java
public class BusinessException extends RuntimeException {
    private final String code;
    private final Map<String, Object> details;

    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
        this.details = Collections.emptyMap();
    }

    public BusinessException(String code, String message, Map<String, Object> details) {
        super(message);
        this.code = code;
        this.details = details;
    }

    public String getCode() { return code; }
    public Map<String, Object> getDetails() { return details; }
}
```

## 5. 事务中的异常处理

```java
// 事务默认在 RuntimeException 时回滚
@Transactional(rollbackFor = Exception.class)
// 指定所有异常都回滚

// 不要在事务中捕获异常后继续抛出不同异常
// 不要在 finally 中提交事务
```

## 6. 日志记录

```java
// 记录异常时使用对应的日志级别
log.debug("User not found: {}", id);
log.warn("Retry attempt {} failed", attempt);
log.error("Database connection failed", e);  // 记录完整堆栈

// 不要记录后重新抛出相同异常
```
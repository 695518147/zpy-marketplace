# Java 日志规范

## 1. 日志框架

使用 SLF4J + Logback 作为日志框架。

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
</dependency>
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
</dependency>
```

## 2. 日志级别使用

| 级别 | 使用场景 |
|------|----------|
| `ERROR` | 系统错误，需要立即处理 |
| `WARN` | 警告信息，可能有问题 |
| `INFO` | 重要业务节点，正常流程 |
| `DEBUG` | 调试信息，开发环境 |
| `TRACE` | 详细跟踪信息 |

```java
private static final Logger log = LoggerFactory.getLogger(UserService.class);

// 正确使用日志级别
log.error("Database connection failed", e);
log.warn("Retry count exceeded for user: {}", userId);
log.info("Order created successfully: orderId={}", orderId);
log.debug("Processing request: {}", request);
```

## 3. 日志内容规范

```java
// 使用占位符而不是字符串拼接
// 错误
log.info("User " + userId + " created");

// 正确
log.info("User created: userId={}", userId);

// 记录结构化数据
log.info("Order placed: orderId={}, amount={}, userId={}",
    order.getId(), order.getAmount(), user.getId());

// 避免记录敏感信息
log.info("User login: username={}, password={}", username, password);  // 错误
```

## 4. 日志记录时机

```java
// 入参加日志
public User create(User user) {
    log.debug("Creating user: username={}", user.getUsername());
    // ...
}

// 结果日志
public User create(User user) {
    User created = userRepository.save(user);
    log.info("User created: userId={}, username={}", created.getId(), created.getUsername());
    return created;
}

// 异常日志
try {
    process();
} catch (Exception e) {
    log.error("Process failed: requestId={}, error={}",
        request.getId(), e.getMessage(), e);  // 传递异常对象
    throw e;
}
```

## 5. 日志配置

```xml
<!-- logback-spring.xml -->
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/application.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/application.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
```

## 6. 业务日志

```java
// 使用 MDC 记录请求追踪 ID
public class RequestLoggingFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException {
        String requestId = UUID.randomUUID().toString();
        MDC.put("requestId", requestId);

        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}

// 日志中自动包含 requestId
log.info("Processing request");
```

## 7. 禁止事项

- 不要使用 `System.out` / `System.err`
- 不要记录密码、密钥等敏感信息
- 不要在日志中记录大对象内容
- 不要在循环中记录大量日志
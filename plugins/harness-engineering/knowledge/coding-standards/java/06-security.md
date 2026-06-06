# Java 安全规范

## 1. 注入防护

### SQL 注入防护

```java
// 使用参数化查询，不要拼接 SQL
// 错误
@Query("SELECT u FROM User u WHERE u.name = '" + name + "'")

// 正确
@Query("SELECT u FROM User u WHERE u.name = :name")
User findByName(@Param("name") String name);

// 使用 JPA Criteria API
public List<User> findByName(String name) {
    return entityManager.createQuery(
        "SELECT u FROM User u WHERE u.name = :name", User.class)
        .setParameter("name", name)
        .getResultList();
}
```

### XSS 防护

```java
// 对用户输入进行转义
import org.apache.commons.text.StringEscapeUtils;

String safeInput = StringEscapeUtils.escapeHtml4(userInput);
```

## 2. 认证与授权

```java
// 使用 Spring Security
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/public/**").permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .sessionManagement()
                .sessionCreationPolicy(STATELESS);
        return http.build();
    }
}
```

## 3. 密码安全

```java
// 使用 BCrypt 哈希密码
@Service
public class UserService {
    @Autowired
    private PasswordEncoder passwordEncoder;

    public User create(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }
}

// 配置 BCrypt
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(12);
}
```

## 4. 数据保护

```java
// 敏感数据脱敏
public class SensitiveDataUtils {
    public static String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) return phone;
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }

    public static String maskIdCard(String idCard) {
        if (idCard == null || idCard.length() < 8) return idCard;
        return idCard.substring(0, 4) + "**********" + idCard.substring(idCard.length() - 4);
    }
}

// 加密存储
@Column(name = "credit_card")
@Convert(converter = AesEncryptConverter.class)
private String creditCard;
```

## 5. 接口安全

```java
// 限流
@Service
public class RateLimitService {
    private final Map<String, AtomicInteger> counters = new ConcurrentHashMap<>();

    public boolean isAllowed(String key, int limit, int windowSeconds) {
        AtomicInteger counter = counters.computeIfAbsent(key, k -> new AtomicInteger(0));
        return counter.incrementAndGet() <= limit;
    }
}

// 参数校验
@PostMapping("/users")
public ResponseEntity<User> createUser(@Valid @RequestBody UserRequest request,
                                       BindingResult result) {
    if (result.hasErrors()) {
        return ResponseEntity.badRequest().build();
    }
    // ...
}
```

## 6. 日志安全

```java
// 不要记录敏感信息
log.info("User login: username={}", username);  // OK
log.info("User login: password={}", password);  // 禁止

// 审计日志
log.info("Security event: action={}, userId={}, ip={}, result={}",
    "PASSWORD_CHANGE", userId, ipAddress, "SUCCESS");
```

## 7. 常见安全配置

```yaml
# application.yml
spring:
  security:
    csrf:
      enabled: true
  data:
    redis:
      password: ${REDIS_PASSWORD}
```
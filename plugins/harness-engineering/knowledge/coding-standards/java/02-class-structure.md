# Java 类结构规范

## 1. 类组织顺序

```java
public class UserServiceImpl implements UserService {

    // 1. 常量（静态 final）
    private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);
    private static final int MAX_SIZE = 100;

    // 2. 成员变量
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // 3. 构造函数
    @Autowired
    public UserServiceImpl(UserRepository userRepository,
                           PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // 4. 公共方法
    @Override
    public User create(User user) {
        validate(user);
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    // 5. 私有方法
    private void validate(User user) {
        if (user == null) {
            throw new IllegalArgumentException("User cannot be null");
        }
    }
}
```

## 2. 类长度控制

- 每个类不超过 500 行
- 超过 300 行应考虑拆分
- 单一职责原则

## 3. 方法规范

```java
// 方法长度不超过 50 行
// 参数不超过 5 个
// 返回类型明确，避免返回 null（使用 Optional 或空集合）

// 推荐的参数传递方式
public User findById(Long id) { ... }

// 避免过深嵌套（不超过 3 层）
```

## 4. 接口设计

```java
public interface UserService {
    User create(User user);
    User findById(Long id);
    List<User> findAll();
    void update(User user);
    void deleteById(Long id);
}
```

## 5. 继承与实现

```java
// 抽象类
public abstract class BaseService<T> {
    protected abstract Repository<T> getRepository();
}

// 实现类
@Service
@Transactional(readOnly = true)
public class UserServiceImpl extends BaseService<User> implements UserService {
    // 实现代码
}
```

## 6. 内部类使用

```java
// 静态内部类用于封装相关常量
public class Constants {
    public static final String PREFIX = "USER_";
}

// 私有内部类用于实现复杂逻辑
public class UserServiceImpl {
    private class UserValidator {
        void validate(User user) { ... }
    }
}
```
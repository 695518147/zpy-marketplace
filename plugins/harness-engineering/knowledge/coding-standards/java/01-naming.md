# Java 命名规范

## 1. 通用规则

- 使用有意义的英文命名，避免拼音
- 变量名使用 camelCase，类名使用 PascalCase
- 常量使用 UPPER_SNAKE_CASE
- 包名全部小写，使用点分隔

## 2. 类命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 普通类 | PascalCase | `UserService` |
| 抽象类 | 以 Abstract 开头 | `AbstractUserService` |
| 异常类 | 以 Exception 结尾 | `UserNotFoundException` |
| 枚举类 | PascalCase | `OrderStatus` |
| 实体类 | PascalCase | `User` |
| DTO | 以 Dto 结尾 | `UserDto` |

## 3. 方法命名

```java
// 查询方法
User findById(Long id);
List<User> findAll();

// 保存方法
User save(User user);
void update(User user);

// 删除方法
void deleteById(Long id);

// 布尔方法
boolean isActive();
boolean hasPermission();

// 业务方法
BigDecimal calculateTotal();
```

## 4. 变量命名

```java
// 普通变量
String userName;
int pageSize;
boolean isDeleted;

// 集合变量
List<User> userList;      // 不推荐
List<User> users;         // 推荐
Map<String, User> userMap;

// 常量
static final int MAX_RETRY_COUNT = 3;
```

## 5. 包命名

```java
com.company.project.module
com.example.user.entity
com.example.user.service
com.example.user.repository
```

## 6. 命名禁忌

- 避免使用单字母变量（循环变量除外：`i`, `j`, `k`）
- 避免使用 `tmp`、`temp` 等无意义命名
- 避免使用数字序列：`param1`, `param2`
- 避免使用缩写，除非是通用缩写：`URL`, `API`, `DTO`
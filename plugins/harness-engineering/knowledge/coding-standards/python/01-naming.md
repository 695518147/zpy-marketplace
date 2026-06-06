# Python 命名规范

## 1. 通用规则

- 使用有意义的英文命名，避免拼音
- 变量名和函数名使用 snake_case
- 类名使用 PascalCase
- 常量使用 UPPER_SNAKE_CASE
- 私有属性以单下划线开头

## 2. 变量命名

```python
# 普通变量
user_name: str = "张三"
page_size: int = 20
is_deleted: bool = False

# 集合变量
user_list: list[User] = []  # 可读
users: list[User] = []
user_map: dict[str, User] = {}

# 布尔变量
is_active: bool = True
has_permission: bool = False
can_edit: bool = True
```

## 3. 函数命名

```python
# 使用动词或动词短语
def get_user(user_id: int) -> User | None:
    ...

def calculate_total(amount: Decimal) -> Decimal:
    ...

def validate_input(data: dict) -> bool:
    ...

def is_valid_email(email: str) -> bool:
    ...

# 私有函数
def _internal_helper() -> None:
    ...
```

## 4. 类命名

```python
# 普通类
class UserService:
    ...

class OrderController:
    ...

# 异常类
class UserNotFoundError(Exception):
    ...

class ValidationError(Exception):
    ...

# 数据类
@dataclass
class UserDto:
    name: str
    email: str
    age: int | None = None
```

## 5. 常量命名

```python
# 模块级常量
MAX_RETRY_COUNT: int = 3
DEFAULT_PAGE_SIZE: int = 20
API_BASE_URL: str = "https://api.example.com"

# 枚举值
class OrderStatus(Enum):
    PENDING = "pending"
    PAID = "paid"
    SHIPPED = "shipped"
    COMPLETED = "completed"
```

## 6. 文件命名

```
user_service.py      # 服务层
order_controller.py  # 控制器层
user_model.py        # 模型层
utils.py             # 工具函数
constants.py         # 常量定义
```

## 7. 命名禁忌

- 避免使用 l、O、I 等容易混淆的字母
- 避免使用单字母变量（循环变量除外）
- 避免使用中文拼音
- 避免使用无意义的 tmp、temp、data
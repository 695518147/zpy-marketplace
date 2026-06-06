# Python 类型注解规范

## 1. 基本类型注解

```python
# 基本类型
name: str = "张三"
age: int = 25
height: float = 1.75
is_active: bool = True

# 集合类型
users: list[str] = ["alice", "bob"]
user_map: dict[str, int] = {"alice": 1, "bob": 2}
user_ids: set[int] = {1, 2, 3}

# 可选类型
name: str | None = None
age: int | None = None

# 泛型
from typing import Optional, List, Dict

def find_user(user_id: int) -> Optional[User]:
    ...

def get_user_names(user_ids: list[int]) -> list[str]:
    ...
```

## 2. 函数类型注解

```python
# 输入输出类型
def greet(name: str) -> str:
    return f"Hello, {name}"

# 多参数
def calculate(a: int, b: int, operator: str) -> int:
    ...

# 默认参数
def create_user(name: str, age: int = 18) -> User:
    ...

# 可变参数
def sum_numbers(*numbers: float) -> float:
    return sum(numbers)

# 关键字参数
def query_users(**filters: str) -> list[User]:
    ...
```

## 3. 类成员类型注解

```python
class UserService:
    def __init__(self, repository: UserRepository) -> None:
        self._repository = repository
        self._cache: dict[int, User] = {}

    def find_by_id(self, user_id: int) -> Optional[User]:
        if user_id in self._cache:
            return self._cache[user_id]
        return self._repository.find_by_id(user_id)
```

## 4. 类型别名

```python
from typing import TypeAlias

UserId: TypeAlias = int
OrderId: TypeAlias = int
UserDict: TypeAlias = dict[str, Any]

# 复杂类型
PaginatedResult: TypeAlias = tuple[list[User], int, int]
```

## 5. Protocol 类型

```python
from typing import Protocol

class Repository(Protocol):
    def find_by_id(self, id: int) -> Optional[Any]:
        ...

    def save(self, entity: Any) -> Any:
        ...

def process_data(repo: Repository) -> None:
    ...
```

## 6. 泛型类

```python
from typing import Generic, TypeVar

T = TypeVar("T")

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()
```

## 7. 类型检查配置

```toml
# pyproject.toml
[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true
```

## 8. 类型注解最佳实践

- 所有公共API必须有类型注解
- 内部实现可省略类型注解
- 使用 Optional 而非 None | 类型
- 使用 list[T] 而非 List[T]（Python 3.9+）
- 避免使用 Any，除非必要
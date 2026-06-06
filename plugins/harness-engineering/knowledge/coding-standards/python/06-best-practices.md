# Python 最佳实践

## 1. 代码组织

```python
# project/
# ├── app/
# │   ├── __init__.py
# │   ├── main.py
# │   ├── api/
# │   │   ├── __init__.py
# │   │   ├── users.py
# │   │   └── orders.py
# │   ├── core/
# │   │   ├── __init__.py
# │   │   ├── config.py
# │   │   └── security.py
# │   ├── models/
# │   │   ├── __init__.py
# │   │   ├── user.py
# │   │   └── order.py
# │   ├── services/
# │   │   ├── __init__.py
# │   │   ├── user_service.py
# │   │   └── order_service.py
# │   └── repositories/
# │       ├── __init__.py
# │       ├── user_repository.py
# │       └── order_repository.py
# ├── tests/
# ├── pyproject.toml
# └── README.md
```

## 2. 配置管理

```python
# settings.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "MyApp"
    database_url: str
    secret_key: str
    debug: bool = False

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
```

## 3. 依赖注入

```python
from typing import Protocol

class UserRepository(Protocol):
    def find_by_id(self, id: int) -> User | None: ...

class UserService:
    def __init__(self, repository: UserRepository) -> None:
        self._repository = repository

# FastAPI 依赖注入
from fastapi import Depends

def get_user_repository() -> UserRepository:
    return SQLAlchemyUserRepository()

@app.get("/users/{user_id}")
def get_user(user_id: int, repo: UserRepository = Depends(get_user_repository)):
    return repo.find_by_id(user_id)
```

## 4. 数据类与类型

```python
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class User:
    name: str
    email: str
    age: Optional[int] = None
    tags: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        self.email = self.email.lower()
```

## 5. 异步编程

```python
import asyncio
from typing import Any

async def fetch_user(user_id: int) -> User:
    await asyncio.sleep(0.1)  # 模拟 IO
    return User(id=user_id, name="Test")

async def fetch_users(user_ids: list[int]) -> list[User]:
    tasks = [fetch_user(uid) for uid in user_ids]
    return await asyncio.gather(*tasks)

# 使用 aiomysql / asyncpg
import asyncpg

async def get_user(pool: asyncpg.Pool, user_id: int) -> User:
    row = await pool.fetchrow("SELECT * FROM users WHERE id = $1", user_id)
    return User(**dict(row))
```

## 6. 上下文管理器

```python
from contextlib import contextmanager

@contextmanager
def database_transaction(connection):
    try:
        connection.begin()
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise

# 使用
with database_transaction(conn) as tx:
    tx.execute("INSERT ...")
```

## 7. 列表推导与生成器

```python
# 使用列表推导
squares = [x**2 for x in range(10)]

# 使用生成器（节省内存）
def generate_squares():
    for x in range(10):
        yield x**2

# 字典推导
user_map = {user.id: user for user in users}

# 集合推导
unique_emails = {user.email for user in users}
```

## 8. 类型检查配置

```toml
# pyproject.toml
[tool.pyright]
pythonVersion = "3.11"
typeCheckingMode = "strict"

[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true
```

## 9. 性能优化

```python
# 使用 __slots__
class User:
    __slots__ = ["id", "name", "email"]
    def __init__(self, id: int, name: str, email: str) -> None:
        self.id = id
        self.name = name
        self.email = email

# 使用局部变量
def process(data: list[int]) -> int:
    result = 0
    for item in data:
        result += item
    return result

# 避免全局查找
def inner():
    local_func = global_func  # 缓存到局部
    local_func()
```

## 10. 测试最佳实践

```python
import pytest

@pytest.fixture
def user_repository():
    return InMemoryUserRepository()

def test_create_user(user_repository):
    service = UserService(user_repository)
    user = service.create(name="Alice", email="alice@example.com")
    assert user.name == "Alice"

# 使用 mock
from unittest.mock import Mock

def test_external_api():
    mock_client = Mock()
    mock_client.get.return_value = {"id": 1}
    service = ExternalService(client=mock_client)
    result = service.fetch_data()
    assert result["id"] == 1
```
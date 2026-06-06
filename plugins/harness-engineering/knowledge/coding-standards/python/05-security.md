# Python 安全规范

## 1. 输入验证

```python
from pydantic import BaseModel, validator

class UserCreate(BaseModel):
    email: str
    age: int | None = None

    @validator("email")
    def validate_email(cls, v: str) -> str:
        if "@" not in v:
            raise ValueError("Invalid email format")
        return v.lower()

    @validator("age")
    def validate_age(cls, v: int | None) -> int | None:
        if v is not None and (v < 0 or v > 150):
            raise ValueError("Age must be between 0 and 150")
        return v
```

## 2. SQL 注入防护

```python
# 使用参数化查询
# 错误
query = f"SELECT * FROM users WHERE name = '{name}'"
cursor.execute(query)

# 正确
query = "SELECT * FROM users WHERE name = %s"
cursor.execute(query, (name,))

# 使用 ORM（推荐）
users = session.query(User).filter(User.name == name).all()

# 使用 SQLAlchemy
from sqlalchemy import text
result = session.execute(text("SELECT * FROM users WHERE name = :name"), {"name": name})
```

## 3. 密码安全

```python
import bcrypt

# 密码哈希
def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode(), salt).decode()

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())

# 使用 argon2-cffi
from argon2 import PasswordHasher
ph = PasswordHasher()
hashed = ph.hash("password")
ph.verify(hashed, "password")
```

## 4. 依赖安全

```bash
# 使用 pip-audit 检查漏洞
pip install pip-audit
pip-audit

# 使用 safety 检查
pip install safety
safety check

# 锁定依赖版本
pip freeze > requirements.txt
```

## 5. 敏感数据保护

```python
import os
from typing import Any

# 使用环境变量
DATABASE_URL = os.getenv("DATABASE_URL")
API_KEY = os.getenv("API_KEY")

# 不要硬编码敏感信息
# 错误
API_KEY = "sk-1234567890abcdef"

# 正确
API_KEY = os.getenv("API_KEY")
if not API_KEY:
    raise ValueError("API_KEY not set")
```

## 6. XSS 防护

```python
import html

# 转义用户输入
user_input = "<script>alert('xss')</script>"
safe_input = html.escape(user_input)

# 使用模板引擎的自动转义
# Jinja2 默认自动转义
```

## 7. CSRF 防护

```python
# Flask
from flask_wtf import CSRFProtect
csrf = CSRFProtect(app)

# FastAPI
from fastapi import FastAPI
from fastapi-wtf import CSRFProtect

app = FastAPI()
csrf = CSRFProtect(app)
```

## 8. 限流

```python
from functools import wraps
import time

def rate_limit(max_calls: int, period: float):
    def decorator(func):
        calls: list[float] = []

        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            now = time.time()
            calls[:] = [t for t in calls if now - t < period]
            if len(calls) >= max_calls:
                raise ValueError("Rate limit exceeded")
            calls.append(now)
            return func(*args, **kwargs)
        return wrapper
    return decorator

@rate_limit(max_calls=100, period=60)
def api_call():
    ...
```

## 9. 安全配置检查清单

- 禁用 DEBUG 模式
- 使用 HTTPS
- 设置安全的 Cookie
- 启用 CORS 限制
- 使用安全的 session 配置
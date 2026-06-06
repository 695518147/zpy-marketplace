# Python 异常处理规范

## 1. 异常分类

| 异常类型 | 用途 | 示例 |
|----------|------|------|
| `ValueError` | 参数值非法 | 传入负数 |
| `TypeError` | 参数类型错误 | 传入字符串 |
| `KeyError` | 字典键不存在 | 访问不存在的 key |
| `NotFoundError` | 资源不存在 | 找不到用户 |
| `BusinessError` | 业务逻辑异常 | 余额不足 |

## 2. 自定义异常

```python
class AppError(Exception):
    """应用基础异常"""
    def __init__(self, message: str, code: str | None = None) -> None:
        super().__init__(message)
        self.code = code or "APP_ERROR"

class NotFoundError(AppError):
    """资源未找到异常"""
    def __init__(self, resource: str, identifier: Any) -> None:
        message = f"{resource} not found: {identifier}"
        super().__init__(message, "NOT_FOUND")
        self.resource = resource
        self.identifier = identifier

class ValidationError(AppError):
    """验证异常"""
    def __init__(self, field: str, message: str) -> None:
        super().__init__(f"{field}: {message}", "VALIDATION_ERROR")
        self.field = field
```

## 3. 异常抛出

```python
def find_user(user_id: int) -> User:
    user = repository.find_by_id(user_id)
    if user is None:
        raise NotFoundError("User", user_id)
    return user

# 使用 None 返回而非异常
def find_user_optional(user_id: int) -> User | None:
    return repository.find_by_id(user_id)
```

## 4. 异常捕获

```python
# 捕获特定异常
try:
    user = user_service.find_by_id(user_id)
except NotFoundError as e:
    logger.warning(f"User not found: {e.identifier}")
    raise

# 多异常捕获
try:
    result = process()
except (ValueError, TypeError) as e:
    logger.error(f"Validation error: {e}")
    raise ValidationError(str(e))

# 捕获所有异常（不推荐）
try:
    result = process()
except Exception as e:
    logger.error(f"Unexpected error", exc_info=True)
    raise
```

## 5. 异常链

```python
# 保留原始异常信息
try:
    db.query(sql)
except DatabaseError as e:
    raise AppError(f"Failed to query: {e}") from e

# 使用 raise from None 断开异常链
try:
    parse(data)
except ParseError:
    raise ValidationError("Invalid data") from None
```

## 6. 全局异常处理

```python
# FastAPI
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()

@app.exception_handler(NotFoundError)
async def handle_not_found(request: Request, exc: NotFoundError):
    return JSONResponse(
        status_code=404,
        content={"code": exc.code, "message": str(exc)}
    )

# Django
from django.http import JsonResponse

def handle_not_found(request, exception):
    return JsonResponse(
        {"code": "NOT_FOUND", "message": str(exception)},
        status=404
    )
```

## 7. 异常与日志

```python
import logging

logger = logging.getLogger(__name__)

# 记录异常堆栈
try:
    process()
except Exception as e:
    logger.exception(f"Process failed: {e}")
    # 自动记录完整堆栈

# 记录警告
try:
    validate(data)
except Warning as e:
    logger.warning(f"Validation warning: {e}")
```

## 8. 使用上下文管理器

```python
# 确保资源释放
with open("data.txt", "r") as f:
    content = f.read()

# 使用 contextlib
from contextlib import contextmanager

@contextmanager
def transaction():
    try:
        db.begin()
        yield
        db.commit()
    except Exception:
        db.rollback()
        raise

with transaction():
    save_user(user)
```